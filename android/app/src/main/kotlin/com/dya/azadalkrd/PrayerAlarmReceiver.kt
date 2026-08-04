package com.dya.azadalkrd

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.Date

/**
 * Receives prayer alarm intents from AlarmManager.
 * - ACTION_PRAYER_ALARM: at prayer time → play ~3s of selected adhan, show notification with Stop action.
 * - ACTION_STOP_ADHAN: user tapped Stop on notification → stop playback.
 */
class PrayerAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_PRAYER_ALARM = "com.dya.azadalkrd.PRAYER_ALARM"
        const val ACTION_STOP_ADHAN = "com.dya.azadalkrd.STOP_ADHAN"
        const val EXTRA_ID = "prayer_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_ADHAN_RAW = "adhan_raw"
        const val EXTRA_ADHAN_DURATION = "adhan_duration"
        private const val CHANNEL_ID = "prayer_times_channel"
        private const val TAG = "PrayerAlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_STOP_ADHAN -> {
                AdhanPlayer.stop()
                return
            }
            ACTION_PRAYER_ALARM -> { /* fall through */ }
            else -> return
        }

        val id = intent.getIntExtra(EXTRA_ID, 0)
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Prayer"
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""
        val adhanRaw = intent.getStringExtra(EXTRA_ADHAN_RAW)
        val adhanDurationMs = intent.getIntExtra(EXTRA_ADHAN_DURATION, 3000)

        Log.d(TAG, "onReceive id=$id at=${Date(System.currentTimeMillis())} adhanRaw=${adhanRaw ?: ""} title=$title")
        createChannelIfNeeded(context)

        if (adhanRaw != null && adhanRaw.isNotEmpty()) {
            AdhanPlayer.playForAlarm(context, adhanRaw, adhanDurationMs.toLong())
            showNotification(context, id, title, body, null)
        } else {
            val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            showNotification(context, id, title, body, defaultUri)
        }
    }

    private fun showNotification(context: Context, id: Int, title: String, body: String, soundUri: Uri?) {
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingOpen = PendingIntent.getActivity(
            context,
            id,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(context, PrayerAlarmReceiver::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val pendingStop = PendingIntent.getBroadcast(
            context,
            id + 1000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pendingOpen)
        if (soundUri != null) {
            builder.setSound(soundUri)
        }
        if (soundUri == null) {
            builder.addAction(android.R.drawable.ic_media_pause, "Stop", pendingStop)
        }
        val notification = builder.build()

        try {
            NotificationManagerCompat.from(context).notify(id, notification)
        } catch (_: SecurityException) {}
    }

    private fun createChannelIfNeeded(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Prayer Times",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notifications at prayer times"
            setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), null)
            enableVibration(true)
        }
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
    }
}
