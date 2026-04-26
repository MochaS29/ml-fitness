package com.mochasmindlab.mlhealth.services

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.mochasmindlab.mlhealth.MainActivity
import com.mochasmindlab.mlhealth.R
import java.util.Calendar

/**
 * Periodic worker that fires water reminders only when the current hour falls
 * inside the user's configured awake window.
 */
class WaterReminderWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val startHour = inputData.getInt(K_START_HOUR, 8)
        val endHour = inputData.getInt(K_END_HOUR, 20)
        val now = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)

        val withinWindow = if (startHour <= endHour) {
            now in startHour..endHour
        } else {
            // Window wraps past midnight (e.g. 22 → 6) — uncommon but handle it
            now >= startHour || now <= endHour
        }
        if (!withinWindow) return Result.success()

        val ctx = applicationContext
        val manager = NotificationManagerCompat.from(ctx)
        if (!manager.areNotificationsEnabled()) return Result.success()

        val tapIntent = Intent(ctx, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pending = PendingIntent.getActivity(
            ctx, NotificationService.ID_WATER, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notif = NotificationCompat.Builder(ctx, NotificationService.CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Hydration check")
            .setContentText("Time for a glass of water.")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()

        runCatching { manager.notify(NotificationService.ID_WATER, notif) }
        return Result.success()
    }

    companion object {
        const val K_START_HOUR = "start_hour"
        const val K_END_HOUR = "end_hour"
    }
}
