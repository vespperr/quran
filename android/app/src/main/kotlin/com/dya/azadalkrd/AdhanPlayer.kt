package com.dya.azadalkrd

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log

/**
 * Plays adhan from res/raw.
 * - In-app: Play button and when user opens app from notification — full clip ([play]).
 * - At prayer time: [PrayerAlarmReceiver] uses [playForAlarm] — on USAGE_ALARM with WakeLock, then stops.
 */
object AdhanPlayer {
    private const val TAG = "AdhanPlayer"
    private var player: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var alarmAutoStopRunnable: Runnable? = null
    private var wakeLock: PowerManager.WakeLock? = null

    private fun acquireWakeLock(context: Context, timeoutMs: Long) {
        releaseWakeLock()
        try {
            val pm = context.applicationContext.getSystemService(Context.POWER_SERVICE) as? PowerManager
            wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "the_open_quran:AdhanWakeLock")?.apply {
                setReferenceCounted(false)
                acquire(timeoutMs)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not acquire WakeLock", e)
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

    private fun cancelAlarmAutoStop() {
        alarmAutoStopRunnable?.let { handler.removeCallbacks(it) }
        alarmAutoStopRunnable = null
    }

    fun play(context: Context, rawName: String?) {
        if (rawName.isNullOrEmpty()) return
        stop()
        try {
            val resId = context.resources.getIdentifier(rawName, "raw", context.packageName)
            if (resId == 0) return
            val uri = Uri.parse("android.resource://${context.packageName}/$resId")
            player = MediaPlayer().apply {
                setDataSource(context, uri)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                } else {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(AudioManager.STREAM_MUSIC)
                }
                setOnCompletionListener { stop() }
                prepare()
                start()
            }
        } catch (e: Exception) {
            Log.e(TAG, "play failed", e)
            player?.release()
            player = null
        }
    }

    /** Play at prayer time: alarm stream with WakeLock, then auto-stop after durationMs. */
    fun playForAlarm(context: Context, rawName: String?, durationMs: Long = 30000L) {
        if (rawName.isNullOrEmpty()) return
        stop()
        try {
            val resId = context.resources.getIdentifier(rawName, "raw", context.packageName)
            if (resId == 0) return
            val uri = Uri.parse("android.resource://${context.packageName}/$resId")

            // Acquire wakelock so CPU stays awake while playing
            acquireWakeLock(context, durationMs + 3000L)

            player = MediaPlayer().apply {
                setWakeMode(context.applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
                setDataSource(context, uri)
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
                setOnCompletionListener { stop() }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what extra=$extra")
                    stop()
                    true
                }
                isLooping = false
                prepare()
                start()
            }
            if (durationMs > 0) {
                val r = Runnable { stop() }
                alarmAutoStopRunnable = r
                handler.postDelayed(r, durationMs)
            }
        } catch (e: Exception) {
            Log.e(TAG, "playForAlarm failed", e)
            stop()
        }
    }

    fun stop() {
        cancelAlarmAutoStop()
        releaseWakeLock()
        try {
            player?.apply {
                if (isPlaying) stop()
                release()
            }
        } catch (_: Exception) {}
        player = null
    }
}
