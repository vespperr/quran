package com.dya.azadalkrd

import android.content.Context
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import java.io.IOException

/**
 * Plays adhan from res/raw.
 * - In-app: Play button and when user opens app from notification — full clip ([play]).
 * - At prayer time: [PrayerAlarmReceiver] uses [playForAlarm] — ~3s on STREAM_ALARM, then stops.
 */
object AdhanPlayer {
    private var player: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var alarmAutoStopRunnable: Runnable? = null

    private fun cancelAlarmAutoStop() {
        alarmAutoStopRunnable?.let { handler.removeCallbacks(it) }
        alarmAutoStopRunnable = null
    }

    fun play(context: Context, rawName: String?) {
        if (rawName.isNullOrEmpty()) return
        stop()
        try {
            val uri = Uri.parse("android.resource://${context.packageName}/raw/$rawName")
            player = MediaPlayer().apply {
                setDataSource(context, uri)
                setAudioStreamType(AudioManager.STREAM_ALARM)
                setOnCompletionListener { stop() }
                prepare()
                start()
            }
        } catch (e: IOException) {
            player?.release()
            player = null
        }
    }

    /** Play at prayer time: alarm stream, then auto-stop after durationMs. */
    fun playForAlarm(context: Context, rawName: String?, durationMs: Long = 30000L) {
        if (rawName.isNullOrEmpty()) return
        stop()
        try {
            val uri = Uri.parse("android.resource://${context.packageName}/raw/$rawName")
            player = MediaPlayer().apply {
                setDataSource(context, uri)
                setAudioStreamType(AudioManager.STREAM_ALARM)
                setOnCompletionListener { stop() }
                isLooping = false
                prepare()
                start()
            }
            if (durationMs > 0) {
                val r = Runnable { stop() }
                alarmAutoStopRunnable = r
                handler.postDelayed(r, durationMs)
            }
        } catch (e: IOException) {
            cancelAlarmAutoStop()
            player?.release()
            player = null
        }
    }

    fun stop() {
        cancelAlarmAutoStop()
        try {
            player?.apply {
                if (isPlaying) stop()
                release()
            }
        } catch (_: Exception) {}
        player = null
    }
}
