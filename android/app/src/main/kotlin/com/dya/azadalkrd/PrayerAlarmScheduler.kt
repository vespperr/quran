package com.dya.azadalkrd

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.Date
import org.json.JSONArray
import org.json.JSONObject

/**
 * Schedules and cancels prayer alarms using AlarmManager.
 * Persists schedule for rescheduling after device boot.
 */
object PrayerAlarmScheduler {

    private const val PREFS = "prayer_alarms"
    private const val KEY_SCHEDULE_JSON = "schedule_json"
    private const val KEY_ADHAN_RAW = "adhan_raw"
    private const val KEY_ADHAN_DURATION = "adhan_duration"
    private const val KEY_DISPLAY_TIMES = "display_times"
    private const val KEY_WIDGET_CITY = "widget_city"
    private const val TAG = "PrayerAlarmScheduler"

    fun scheduleAlarms(
        context: Context,
        alarms: List<AlarmItem>,
        adhanRawName: String?,
        adhanDurationMs: Int = 30000,
        displayTimes: String? = null,
        widgetCity: String? = null
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        cancelAll(context)

        val now = System.currentTimeMillis()
        val toPersist = JSONArray()
        for (item in alarms) {
            if (item.triggerAtMillis < now) continue
            Log.d(TAG, "scheduleOne id=${item.id} prayer=${item.prayerName} at=${Date(item.triggerAtMillis)} millis=${item.triggerAtMillis}")
            try {
                scheduleOne(context, alarmManager, item, adhanRawName, adhanDurationMs)
                toPersist.put(item.toJson())
            } catch (e: Exception) {
                Log.e(TAG, "Failed to schedule item id=${item.id}", e)
            }
        }
        persist(context, toPersist, adhanRawName, adhanDurationMs, displayTimes, widgetCity)
        Log.d(TAG, "Scheduled ${toPersist.length()} prayer alarms (filtered from ${alarms.size})")
    }

    fun cancelAll(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // Cancel a wide range to catch alarms from legacy builds that used different ids.
        // Canceling a non-existing PendingIntent is safe.
        for (id in 1..2000) {
            val intent = alarmIntent(context, id)
            val pending = PendingIntent.getBroadcast(
                context, id, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pending)
        }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().remove(KEY_SCHEDULE_JSON).apply()
    }

    fun rescheduleAfterBoot(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val adhanRaw = prefs.getString(KEY_ADHAN_RAW, null)
        val adhanDurationMs = prefs.getInt(KEY_ADHAN_DURATION, 30000)
        val displayTimes = prefs.getString(KEY_DISPLAY_TIMES, null)
        val widgetCity = prefs.getString(KEY_WIDGET_CITY, null)

        try {
            if (!displayTimes.isNullOrEmpty()) {
                val recalculated = recalculateAlarmsFromDisplayTimes(displayTimes)
                if (recalculated.isNotEmpty()) {
                    scheduleAlarms(context, recalculated, adhanRaw, adhanDurationMs, displayTimes, widgetCity)
                    return
                }
            }

            val json = prefs.getString(KEY_SCHEDULE_JSON, null) ?: return
            val arr = JSONArray(json)
            val list = mutableListOf<AlarmItem>()
            for (i in 0 until arr.length()) {
                list.add(AlarmItem.fromJson(arr.getJSONObject(i)))
            }
            val now = System.currentTimeMillis()
            val future = list.filter { it.triggerAtMillis > now }
            if (future.isNotEmpty()) {
                scheduleAlarms(context, future, adhanRaw, adhanDurationMs, displayTimes, widgetCity)
            }
        } catch (e: Exception) {
            Log.e(TAG, "rescheduleAfterBoot failed", e)
        }
    }

    private fun recalculateAlarmsFromDisplayTimes(displayTimes: String): List<AlarmItem> {
        val list = mutableListOf<AlarmItem>()
        if (displayTimes.isEmpty()) return list

        val prayers = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
        val prayerIds = mapOf("fajr" to 1, "dhuhr" to 2, "asr" to 3, "maghrib" to 4, "isha" to 5)

        val timeMap = mutableMapOf<String, String>()
        val parts = displayTimes.split(";")
        for (p in parts) {
            val pair = p.split("|")
            if (pair.size == 2) {
                timeMap[pair[0].trim().lowercase()] = pair[1].trim()
            }
        }

        val now = System.currentTimeMillis()
        val cal = java.util.Calendar.getInstance()

        // Today
        for (name in prayers) {
            val lower = name.lowercase()
            val timeStr = timeMap[lower] ?: continue
            val timeParts = timeStr.split(":")
            if (timeParts.size < 2) continue
            var hour = timeParts[0].trim().toIntOrNull() ?: continue
            val minute = timeParts[1].trim().take(2).toIntOrNull() ?: continue

            if ((lower == "asr" || lower == "maghrib" || lower == "isha") && hour < 12) {
                hour += 12
            }

            cal.timeInMillis = now
            cal.set(java.util.Calendar.HOUR_OF_DAY, hour)
            cal.set(java.util.Calendar.MINUTE, minute)
            cal.set(java.util.Calendar.SECOND, 0)
            cal.set(java.util.Calendar.MILLISECOND, 0)

            val trigger = cal.timeInMillis
            if (trigger > now) {
                val id = prayerIds[lower] ?: 1
                list.add(AlarmItem(
                    id = id,
                    triggerAtMillis = trigger,
                    title = "Prayer: $name",
                    body = "حان الآن موعد صلاة $name",
                    prayerName = name
                ))
            }
        }

        // Tomorrow
        val calTomorrow = java.util.Calendar.getInstance()
        calTomorrow.timeInMillis = now
        calTomorrow.add(java.util.Calendar.DAY_OF_YEAR, 1)

        for (name in prayers) {
            val lower = name.lowercase()
            val timeStr = timeMap[lower] ?: continue
            val timeParts = timeStr.split(":")
            if (timeParts.size < 2) continue
            var hour = timeParts[0].trim().toIntOrNull() ?: continue
            val minute = timeParts[1].trim().take(2).toIntOrNull() ?: continue

            if ((lower == "asr" || lower == "maghrib" || lower == "isha") && hour < 12) {
                hour += 12
            }

            calTomorrow.set(java.util.Calendar.HOUR_OF_DAY, hour)
            calTomorrow.set(java.util.Calendar.MINUTE, minute)
            calTomorrow.set(java.util.Calendar.SECOND, 0)
            calTomorrow.set(java.util.Calendar.MILLISECOND, 0)

            val trigger = calTomorrow.timeInMillis
            val id = (prayerIds[lower] ?: 1) + 5
            list.add(AlarmItem(
                id = id,
                triggerAtMillis = trigger,
                title = "Prayer: $name",
                body = "حان الآن موعد صلاة $name",
                prayerName = name
            ))
        }

        return list
    }

    private fun scheduleOne(
        context: Context,
        alarmManager: AlarmManager,
        item: AlarmItem,
        adhanRawName: String? = null,
        adhanDurationMs: Int = 30000
    ) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val adhan = adhanRawName ?: prefs.getString(KEY_ADHAN_RAW, null)
        val duration = if (adhanRawName != null) adhanDurationMs else prefs.getInt(KEY_ADHAN_DURATION, 30000)
        val intent = alarmIntent(context, item.id).apply {
            putExtra(PrayerAlarmReceiver.EXTRA_ID, item.id)
            putExtra(PrayerAlarmReceiver.EXTRA_TITLE, item.title)
            putExtra(PrayerAlarmReceiver.EXTRA_BODY, item.body)
            putExtra(PrayerAlarmReceiver.EXTRA_ADHAN_RAW, adhan ?: "")
            putExtra(PrayerAlarmReceiver.EXTRA_ADHAN_DURATION, duration)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            item.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val canExact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                alarmManager.canScheduleExactAlarms()
            } catch (_: Exception) {
                false
            }
        } else {
            true
        }

        try {
            if (canExact) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
                }
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
                }
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "Exact alarm permission denied, falling back to setAndAllowWhileIdle", e)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, item.triggerAtMillis, pending)
            }
        }
    }

    private fun alarmIntent(context: Context, id: Int): Intent {
        return Intent(context, PrayerAlarmReceiver::class.java).apply {
            action = PrayerAlarmReceiver.ACTION_PRAYER_ALARM
        }
    }

    private fun persist(
        context: Context,
        arr: JSONArray,
        adhanRaw: String?,
        adhanDurationMs: Int,
        displayTimes: String?,
        widgetCity: String?
    ) {
        val edit = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY_SCHEDULE_JSON, arr.toString())
            .putString(KEY_ADHAN_RAW, adhanRaw ?: "")
            .putInt(KEY_ADHAN_DURATION, adhanDurationMs)
        if (displayTimes != null) edit.putString(KEY_DISPLAY_TIMES, displayTimes)
        if (widgetCity != null) edit.putString(KEY_WIDGET_CITY, widgetCity)
        edit.apply()
        try {
            PrayerTimesWidgetBaseProvider.refreshAllWidgets(context)
        } catch (_: Exception) {}
    }

    fun saveWidgetData(context: Context, displayTimes: String?, widgetCity: String?) {
        val edit = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
        if (displayTimes != null) edit.putString(KEY_DISPLAY_TIMES, displayTimes)
        if (widgetCity != null) edit.putString(KEY_WIDGET_CITY, widgetCity)
        edit.apply()
        try {
            PrayerTimesWidgetBaseProvider.refreshAllWidgets(context)
        } catch (_: Exception) {}
    }

    /** Display string for home widget: "Fajr|05:30;Dhuhr|12:15;...". Empty if not set. */
    fun getDisplayTimes(context: Context): String =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_DISPLAY_TIMES, "") ?: ""

    /** City label for the home widget title (same key as selected in the app). */
    fun getWidgetCity(context: Context): String =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_WIDGET_CITY, "") ?: ""

    data class AlarmItem(
        val id: Int,
        val triggerAtMillis: Long,
        val title: String,
        val body: String,
        val prayerName: String
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("id", id)
            put("triggerAtMillis", triggerAtMillis)
            put("title", title)
            put("body", body)
            put("prayerName", prayerName)
        }

        companion object {
            fun fromJson(o: JSONObject) = AlarmItem(
                id = o.getInt("id"),
                triggerAtMillis = o.getLong("triggerAtMillis"),
                title = o.getString("title"),
                body = o.getString("body"),
                prayerName = o.optString("prayerName", "")
            )
        }
    }
}
