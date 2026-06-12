package com.mochasmindlab.mlhealth.services

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import com.mochasmindlab.mlhealth.MainActivity
import com.mochasmindlab.mlhealth.R
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * Fires a single reminder notification. For "daily" type reminders, the worker
 * re-enqueues itself for ~24h later so the chain continues without requiring
 * device boot.
 *
 * Input data:
 *   K_TYPE: "daily" or "interval"
 *   K_ID:   stable notification id
 *   K_TITLE/K_BODY: notification text
 *   K_HOUR/K_MINUTE: target time-of-day for daily reminders (used when re-enqueueing)
 *   K_TAG:  unique work tag — caller cancels by this tag when toggling off
 */
class ReminderWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val type = inputData.getString(K_TYPE) ?: return Result.failure()
        val id = inputData.getInt(K_ID, 0)
        val title = inputData.getString(K_TITLE) ?: return Result.failure()
        val body = inputData.getString(K_BODY) ?: ""
        val tag = inputData.getString(K_TAG) ?: "reminder"

        showNotification(id, title, body)

        if (type == TYPE_DAILY) {
            val hour = inputData.getInt(K_HOUR, 8)
            val minute = inputData.getInt(K_MINUTE, 0)
            scheduleNext(applicationContext, tag, id, hour, minute, title, body)
        }
        return Result.success()
    }

    private fun showNotification(id: Int, title: String, body: String) {
        val ctx = applicationContext
        val manager = NotificationManagerCompat.from(ctx)
        if (!manager.areNotificationsEnabled()) return

        val tapIntent = Intent(ctx, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pending = PendingIntent.getActivity(
            ctx, id, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notif = NotificationCompat.Builder(ctx, NotificationService.CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()

        runCatching { manager.notify(id, notif) }
    }

    companion object {
        const val K_TYPE = "type"
        const val K_ID = "id"
        const val K_TITLE = "title"
        const val K_BODY = "body"
        const val K_HOUR = "hour"
        const val K_MINUTE = "minute"
        const val K_TAG = "tag"

        const val TYPE_DAILY = "daily"
        const val TYPE_INTERVAL = "interval"

        fun scheduleNext(
            context: Context,
            tag: String,
            id: Int,
            hour: Int,
            minute: Int,
            title: String,
            body: String
        ) {
            val nextMillis = millisUntilNext(hour, minute)
            val request = OneTimeWorkRequestBuilder<ReminderWorker>()
                .setInitialDelay(nextMillis, TimeUnit.MILLISECONDS)
                .addTag(tag)
                .setInputData(
                    workDataOf(
                        K_TYPE to TYPE_DAILY,
                        K_ID to id,
                        K_TITLE to title,
                        K_BODY to body,
                        K_HOUR to hour,
                        K_MINUTE to minute,
                        K_TAG to tag
                    )
                )
                .build()
            WorkManager.getInstance(context).enqueue(request)
        }

        private fun millisUntilNext(hour: Int, minute: Int): Long {
            val now = Calendar.getInstance()
            val target = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                if (timeInMillis <= now.timeInMillis) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            return target.timeInMillis - now.timeInMillis
        }
    }
}
