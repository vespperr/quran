package com.dya.azadalkrd

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import java.util.Calendar

open class PrayerTimesWidgetBaseProvider(
    private val layoutResId: Int
) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val views = RemoteViews(context.packageName, layoutResId)
            val widgetData = context.getSharedPreferences("DATA", Context.MODE_PRIVATE)

            var fajr = widgetData.getString("fajr", null)
            var dhuhr = widgetData.getString("dhuhr", null)
            var asr = widgetData.getString("asr", null)
            var maghrib = widgetData.getString("maghrib", null)
            var isha = widgetData.getString("isha", null)
            var nextPrayer = widgetData.getString("next_prayer", null)

            if (fajr.isNullOrEmpty() || dhuhr.isNullOrEmpty()) {
                val rawDisplayTimes = PrayerAlarmScheduler.getDisplayTimes(context)
                if (rawDisplayTimes.isNotEmpty()) {
                    val parts = rawDisplayTimes.split(";")
                    for (part in parts) {
                        val pair = part.split("|")
                        if (pair.size == 2) {
                            val name = pair[0].trim().lowercase()
                            val time = pair[1].trim()
                            when (name) {
                                "fajr" -> if (fajr.isNullOrEmpty()) fajr = time
                                "dhuhr" -> if (dhuhr.isNullOrEmpty()) dhuhr = time
                                "asr" -> if (asr.isNullOrEmpty()) asr = time
                                "maghrib" -> if (maghrib.isNullOrEmpty()) maghrib = time
                                "isha" -> if (isha.isNullOrEmpty()) isha = time
                            }
                        }
                    }
                }
            }

            fajr = fajr ?: "--:--"
            dhuhr = dhuhr ?: "--:--"
            asr = asr ?: "--:--"
            maghrib = maghrib ?: "--:--"
            isha = isha ?: "--:--"

            // Calculate next prayer dynamically based on current wall clock
            val calculatedNext = calculateNextPrayer(fajr, dhuhr, asr, maghrib, isha)
            if (nextPrayer.isNullOrEmpty() || nextPrayer == "Next: --:--" || nextPrayer == "Next: ") {
                nextPrayer = calculatedNext
            } else {
                // If stored next prayer is valid, use calculated if it's available and non-default
                if (calculatedNext != "Next: Fajr --:--") {
                    nextPrayer = calculatedNext
                }
            }

            // Small Layout Updates
            if (layoutResId == R.layout.prayer_times_widget_small) {
                val parsedNextName = parsePrayerName(nextPrayer)
                val parsedNextTime = parsePrayerTime(nextPrayer, fajr, dhuhr, asr, maghrib, isha)
                views.setTextViewText(R.id.next_prayer_name, parsedNextName.uppercase())
                views.setTextViewText(R.id.next_prayer_time, parsedNextTime)
            } else {
                // Medium & Large Layout Updates
                views.setTextViewText(R.id.fajr_time, fajr)
                views.setTextViewText(R.id.dhuhr_time, dhuhr)
                views.setTextViewText(R.id.asr_time, asr)
                views.setTextViewText(R.id.maghrib_time, maghrib)
                views.setTextViewText(R.id.isha_time, isha)

                if (layoutResId == R.layout.prayer_times_widget_large) {
                    views.setTextViewText(R.id.next_prayer_badge, nextPrayer)
                    val parsedNextName = parsePrayerName(nextPrayer)
                    val parsedNextTime = parsePrayerTime(nextPrayer, fajr, dhuhr, asr, maghrib, isha)
                    views.setTextViewText(R.id.hero_next_prayer_name, parsedNextName)
                    views.setTextViewText(R.id.hero_next_prayer_time, parsedNextTime)
                } else {
                    views.setTextViewText(R.id.next_prayer_text, nextPrayer)
                }

                // Highlight active next prayer slot
                val nextPrayerLower = nextPrayer.lowercase()
                val prayerCards = mapOf(
                    "fajr" to Pair(R.id.fajr_card, Pair(R.id.fajr_label, R.id.fajr_time)),
                    "dhuhr" to Pair(R.id.dhuhr_card, Pair(R.id.dhuhr_label, R.id.dhuhr_time)),
                    "asr" to Pair(R.id.asr_card, Pair(R.id.asr_label, R.id.asr_time)),
                    "maghrib" to Pair(R.id.maghrib_card, Pair(R.id.maghrib_label, R.id.maghrib_time)),
                    "isha" to Pair(R.id.isha_card, Pair(R.id.isha_label, R.id.isha_time))
                )

                for ((name, ids) in prayerCards) {
                    val cardId = ids.first
                    val labelId = ids.second.first
                    val timeId = ids.second.second

                    if (nextPrayerLower.contains(name)) {
                        views.setInt(cardId, "setBackgroundResource", R.drawable.widget_card_active_bg)
                        views.setTextColor(labelId, Color.parseColor("#D4AF37"))
                        views.setTextColor(timeId, Color.parseColor("#FFFFFF"))
                    } else {
                        views.setInt(cardId, "setBackgroundResource", R.drawable.widget_card_bg)
                        views.setTextColor(labelId, Color.parseColor("#B3FFFFFF"))
                        views.setTextColor(timeId, Color.parseColor("#FFFFFF"))
                    }
                }
            }

            // Click pending intent to launch app
            val openApp = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                openApp,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val rootId = when (layoutResId) {
                R.layout.prayer_times_widget_small -> R.id.widget_small_root
                R.layout.prayer_times_widget_large -> R.id.widget_large_root
                else -> R.id.widget_prayer_bar_root
            }
            views.setOnClickPendingIntent(rootId, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun parseTimeToMinutes(timeStr: String, prayerName: String): Int? {
        if (timeStr.isEmpty() || timeStr == "--:--") return null
        val clean = timeStr.trim().uppercase()
        val isPm = clean.contains("PM")
        val isAm = clean.contains("AM")
        val timeOnly = clean.replace("AM", "").replace("PM", "").trim()
        val parts = timeOnly.split(":")
        if (parts.size < 2) return null
        var h = parts[0].trim().toIntOrNull() ?: return null
        val m = parts[1].trim().toIntOrNull() ?: return null

        if (isPm && h < 12) h += 12
        if (isAm && h == 12) h = 0

        if (!isPm && !isAm) {
            when (prayerName.lowercase()) {
                "dhuhr" -> if (h in 1..11) h += 12
                "asr", "maghrib", "isha" -> if (h in 1..11) h += 12
            }
        }
        return h * 60 + m
    }

    private fun calculateNextPrayer(
        fajr: String,
        dhuhr: String,
        asr: String,
        maghrib: String,
        isha: String
    ): String {
        val calendar = Calendar.getInstance()
        val nowMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

        val list = listOf(
            Pair("Fajr", parseTimeToMinutes(fajr, "fajr")),
            Pair("Dhuhr", parseTimeToMinutes(dhuhr, "dhuhr")),
            Pair("Asr", parseTimeToMinutes(asr, "asr")),
            Pair("Maghrib", parseTimeToMinutes(maghrib, "maghrib")),
            Pair("Isha", parseTimeToMinutes(isha, "isha"))
        )

        for (item in list) {
            val minutes = item.second
            if (minutes != null && minutes > nowMinutes) {
                val prayerTime = when(item.first.lowercase()) {
                    "fajr" -> fajr
                    "dhuhr" -> dhuhr
                    "asr" -> asr
                    "maghrib" -> maghrib
                    else -> isha
                }
                return "Next: ${item.first} $prayerTime"
            }
        }

        return "Next: Fajr $fajr"
    }

    private fun parsePrayerName(nextPrayer: String): String {
        val lower = nextPrayer.lowercase()
        return when {
            lower.contains("fajr") -> "Fajr"
            lower.contains("dhuhr") -> "Dhuhr"
            lower.contains("asr") -> "Asr"
            lower.contains("maghrib") -> "Maghrib"
            lower.contains("isha") -> "Isha"
            else -> "Next Prayer"
        }
    }

    private fun parsePrayerTime(
        nextPrayer: String,
        fajr: String,
        dhuhr: String,
        asr: String,
        maghrib: String,
        isha: String
    ): String {
        val lower = nextPrayer.lowercase()
        return when {
            lower.contains("fajr") -> fajr
            lower.contains("dhuhr") -> dhuhr
            lower.contains("asr") -> asr
            lower.contains("maghrib") -> maghrib
            lower.contains("isha") -> isha
            else -> {
                val parts = nextPrayer.split(":")
                if (parts.size >= 2) {
                    val raw = nextPrayer.replace("Next:", "").replace("Next", "").trim()
                    if (raw.isNotEmpty()) raw else "--:--"
                } else "--:--"
            }
        }
    }

    companion object {
        fun refreshAllWidgets(context: Context) {
            val providers = listOf(
                PrayerTimesWidgetSmallProvider::class.java,
                PrayerTimesWidgetMediumProvider::class.java,
                PrayerTimesWidgetLargeProvider::class.java,
                PrayerTimesWidgetProvider::class.java
            )
            val mgr = AppWidgetManager.getInstance(context)
            for (p in providers) {
                val ids = mgr.getAppWidgetIds(ComponentName(context, p))
                if (ids.isNotEmpty()) {
                    val intent = Intent(context, p).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                    }
                    context.sendBroadcast(intent)
                }
            }
        }
    }
}

// 3 Provider Classes for Small, Medium, Large
class PrayerTimesWidgetSmallProvider : PrayerTimesWidgetBaseProvider(R.layout.prayer_times_widget_small)
class PrayerTimesWidgetMediumProvider : PrayerTimesWidgetBaseProvider(R.layout.prayer_times_widget_medium)
class PrayerTimesWidgetLargeProvider : PrayerTimesWidgetBaseProvider(R.layout.prayer_times_widget_large)

// Original Provider subclassed for backwards compatibility
class PrayerTimesWidgetProvider : PrayerTimesWidgetBaseProvider(R.layout.prayer_times_widget_medium)
