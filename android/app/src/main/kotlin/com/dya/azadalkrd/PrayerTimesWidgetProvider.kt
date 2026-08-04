package com.dya.azadalkrd

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Home screen widget: a compact bar showing today's prayer times.
 * Data is updated when the app schedules alarms (display times from selected city).
 *
 * Lock screen / glanceable widgets: availability and layout depend on OEM and Android version;
 * this provider only targets the standard home-screen AppWidget pipeline.
 */
class PrayerTimesWidgetProvider : AppWidgetProvider() {

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
        val views = RemoteViews(context.packageName, R.layout.widget_prayer_times_bar)
        val cityLabel = PrayerAlarmScheduler.getWidgetCity(context).trim()
        views.setTextViewText(
            R.id.widget_prayer_title,
            if (cityLabel.isNotEmpty()) {
                cityLabel
            } else {
                context.getString(R.string.widget_prayer_city_hint)
            },
        )
        val displayTimes = PrayerAlarmScheduler.getDisplayTimes(context)
        val timesText = if (displayTimes.isNotEmpty()) {
            parseDisplayTimes(displayTimes)
        } else {
            context.getString(R.string.widget_prayer_times_empty)
        }
        views.setTextViewText(R.id.widget_prayer_times, timesText)

        val openApp = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pending = PendingIntent.getActivity(
            context,
            0,
            openApp,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_prayer_bar_root, pending)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    /** Parses "Fajr|05:30;Dhuhr|12:15;..." into two columns per row for readability. */
    private fun parseDisplayTimes(displayTimes: String): String {
        if (displayTimes.isBlank()) return ""
        val items = displayTimes.split(";")
            .mapNotNull { part ->
                val pipe = part.indexOf('|')
                if (pipe < 0) return@mapNotNull null
                val name = part.substring(0, pipe).trim()
                val time = part.substring(pipe + 1).trim()
                if (name.isNotEmpty() && time.isNotEmpty()) "$name  $time" else null
            }
        return items.chunked(2).joinToString("\n") { row ->
            row.joinToString("     ")
        }
    }

    companion object {
        /** Call after scheduling alarms so the widget shows the new times. */
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = android.content.ComponentName(context, PrayerTimesWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isNotEmpty()) {
                PrayerTimesWidgetProvider().onUpdate(context, manager, ids)
            }
        }
    }
}
