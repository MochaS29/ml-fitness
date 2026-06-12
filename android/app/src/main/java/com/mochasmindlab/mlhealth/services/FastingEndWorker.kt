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

class FastingEndWorker(
    ctx: Context,
    params: WorkerParameters
) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        val planName = inputData.getString(K_PLAN_NAME)
            ?: fallbackPlanName(inputData.getDouble(K_FAST_HOURS, 16.0))

        val manager = NotificationManagerCompat.from(applicationContext)
        if (!manager.areNotificationsEnabled()) return Result.success()

        val tapIntent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(NotificationService.EXTRA_ROUTE, "fasting")
        }
        val pendingIntent = PendingIntent.getActivity(
            applicationContext,
            NOTIFICATION_ID,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(applicationContext, NotificationService.CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Fast complete!")
            .setContentText("Your $planName fast is done.")
            .setStyle(NotificationCompat.BigTextStyle().bigText("Your $planName fast is done."))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        runCatching { manager.notify(NOTIFICATION_ID, notification) }
        return Result.success()
    }

    private fun fallbackPlanName(fastHours: Double): String = when (fastHours) {
        16.0 -> "16:8"
        18.0 -> "18:6"
        20.0 -> "20:4"
        14.0 -> "14:10"
        23.0 -> "OMAD"
        else -> "${fastHours.toInt()}-hour"
    }

    companion object {
        const val K_SESSION_ID = "session_id"
        const val K_FAST_HOURS = "fast_hours"
        const val K_PLAN_NAME = "plan_name"
        const val NOTIFICATION_ID = 1100
    }
}
