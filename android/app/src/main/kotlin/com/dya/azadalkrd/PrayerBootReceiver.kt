package com.dya.azadalkrd

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * On boot, re-schedules persisted prayer alarms so they fire after device restart.
 */
class PrayerBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != "android.intent.action.QUICKBOOT_POWERON" &&
            action != Intent.ACTION_TIME_CHANGED &&
            action != Intent.ACTION_TIMEZONE_CHANGED
        ) return
        Log.d(TAG, "Boot/replace/time change: rescheduling prayer alarms")
        PrayerAlarmScheduler.rescheduleAfterBoot(context)
    }

    companion object {
        private const val TAG = "PrayerBootReceiver"
    }
}
