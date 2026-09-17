package com.dya.azadalkrd

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Foreground service to play Adhan audio reliably when a prayer alarm fires.
 * Ensures the Android OS does not kill or freeze playback even in deep Doze mode.
 */
class AdhanForegroundService : Service() {

    companion object {
        const val ACTION_PLAY_ADHAN = "com.dya.azadalkrd.PLAY_ADHAN"
        const val ACTION_STOP_ADHAN = "com.dya.azadalkrd.STOP_ADHAN"

        const val EXTRA_ID = "prayer_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_ADHAN_RAW = "adhan_raw"
        const val EXTRA_ADHAN_DURATION = "adhan_duration"

        private const val CHANNEL_ID = "prayer_times_channel"
        private const val TAG = "AdhanForegroundService"

        fun start(
            context: Context,
            id: Int,
            title: String,
            body: String,
            adhanRaw: String,
            durationMs: Int
        ) {
            val intent = Intent(context, AdhanForegroundService::class.java).apply {
                action = ACTION_PLAY_ADHAN
                putExtra(EXTRA_ID, id)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
                putExtra(EXTRA_ADHAN_RAW, adhanRaw)
                putExtra(EXTRA_ADHAN_DURATION, durationMs)
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start AdhanForegroundService", e)
                // Fallback to direct player if service cannot start
                AdhanPlayer.playForAlarm(context, adhanRaw, durationMs.toLong())
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, AdhanForegroundService::class.java).apply {
                action = ACTION_STOP_ADHAN
            }
            try {
                context.startService(intent)
            } catch (_: Exception) {}
            AdhanPlayer.stop()
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private var autoStopRunnable: Runnable? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }

        when (intent.action) {
            ACTION_STOP_ADHAN -> {
                stopPlayback()
                stopForeground(true)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_PLAY_ADHAN -> {
                val id = intent.getIntExtra(EXTRA_ID, 1001)
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "Prayer"
                val body = intent.getStringExtra(EXTRA_BODY) ?: ""
                var adhanRaw = intent.getStringExtra(EXTRA_ADHAN_RAW)
                val durationMs = intent.getIntExtra(EXTRA_ADHAN_DURATION, 30000)

                if (adhanRaw.isNullOrEmpty()) {
                    adhanRaw = "bang_hijaz_maghrib_isha"
                }

                createChannelIfNeeded()
                val notification = buildNotification(id, title, body)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        id,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
                    )
                } else {
                    startForeground(id, notification)
                }

                playAdhanAudio(adhanRaw, durationMs.toLong())
                return START_NOT_STICKY
            }
            else -> {
                stopSelf()
                return START_NOT_STICKY
            }
        }
    }

    private fun playAdhanAudio(rawName: String, durationMs: Long) {
        stopPlayback()
        try {
            val resId = resources.getIdentifier(rawName, "raw", packageName)
            if (resId == 0) {
                Log.w(TAG, "Resource not found for rawName=$rawName")
                return
            }

            acquireWakeLock(durationMs + 3000L)
            requestAudioFocus()

            val uri = Uri.parse("android.resource://$packageName/$resId")
            mediaPlayer = MediaPlayer().apply {
                setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
                setDataSource(applicationContext, uri)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                } else {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(AudioManager.STREAM_ALARM)
                }
                setOnCompletionListener {
                    Log.d(TAG, "Adhan playback completed normally")
                    stopPlayback()
                    stopForeground(false)
                    stopSelf()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what extra=$extra")
                    stopPlayback()
                    stopForeground(false)
                    stopSelf()
                    true
                }
                prepare()
                start()
            }

            if (durationMs > 0) {
                val r = Runnable {
                    Log.d(TAG, "Adhan auto-stopping after ${durationMs}ms")
                    stopPlayback()
                    stopForeground(false)
                    stopSelf()
                }
                autoStopRunnable = r
                handler.postDelayed(r, durationMs)
            }
        } catch (e: Exception) {
            Log.e(TAG, "playAdhanAudio failed", e)
            stopPlayback()
            stopForeground(false)
            stopSelf()
        }
    }

    private fun requestAudioFocus() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .build()
                audioFocusRequest = req
                audioManager.requestAudioFocus(req)
            } else {
                @Suppress("DEPRECATION")
                audioManager.requestAudioFocus(
                    null,
                    AudioManager.STREAM_ALARM,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
                )
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not request audio focus", e)
        }
    }

    private fun abandonAudioFocus() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager.abandonAudioFocus(null)
            }
        } catch (_: Exception) {}
        audioFocusRequest = null
    }

    private fun acquireWakeLock(timeoutMs: Long) {
        releaseWakeLock()
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager
            wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "the_open_quran:AdhanServiceWakeLock")?.apply {
                setReferenceCounted(false)
                acquire(timeoutMs)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not acquire wake lock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (_: Exception) {}
        wakeLock = null
    }

    private fun stopPlayback() {
        autoStopRunnable?.let { handler.removeCallbacks(it) }
        autoStopRunnable = null
        releaseWakeLock()
        abandonAudioFocus()
        try {
            mediaPlayer?.apply {
                if (isPlaying) stop()
                release()
            }
        } catch (_: Exception) {}
        mediaPlayer = null
    }

    override fun onDestroy() {
        stopPlayback()
        super.onDestroy()
    }

    private fun buildNotification(id: Int, title: String, body: String): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingOpen = PendingIntent.getActivity(
            this,
            id,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, PrayerAlarmReceiver::class.java).apply {
            action = PrayerAlarmReceiver.ACTION_STOP_ADHAN
        }
        val pendingStop = PendingIntent.getBroadcast(
            this,
            id + 1000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(pendingOpen, true)
            .setAutoCancel(true)
            .setContentIntent(pendingOpen)
            .addAction(android.R.drawable.ic_media_pause, "وەستان / Stop", pendingStop)
            .build()
    }

    private fun createChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Prayer Times",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notifications at prayer times"
            enableVibration(true)
        }
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
    }
}
