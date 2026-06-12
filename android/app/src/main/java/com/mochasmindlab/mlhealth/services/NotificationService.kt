package com.mochasmindlab.mlhealth.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.mochasmindlab.mlhealth.MainActivity
import com.mochasmindlab.mlhealth.R
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Wraps NotificationManager: creates the reminders channel, fires notifications,
 * and exposes a permission-check helper.
 *
 * Channel is created on app start via MLFitnessApplication.onCreate().
 */
@Singleton
class NotificationService @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val manager = NotificationManagerCompat.from(context)

    fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Reminders",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Water, meals, weight and exercise reminders"
        }
        val sysManager = context.getSystemService(NotificationManager::class.java)
        sysManager?.createNotificationChannel(channel)
    }

    fun areNotificationsEnabled(): Boolean = manager.areNotificationsEnabled()

    fun show(id: Int, title: String, body: String, route: String? = null) {
        if (!areNotificationsEnabled()) return

        val tapIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            route?.let { putExtra(EXTRA_ROUTE, it) }
        }
        val pendingIntent = PendingIntent.getActivity(
            context, id, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        runCatching { manager.notify(id, notification) }
    }

    companion object {
        const val CHANNEL_ID = "ml_fitness_reminders"
        const val EXTRA_ROUTE = "tap_route"

        // Stable IDs per reminder type
        const val ID_WATER = 1001
        const val ID_BREAKFAST = 1002
        const val ID_LUNCH = 1003
        const val ID_DINNER = 1004
        const val ID_WEIGHT = 1005
        const val ID_EXERCISE = 1006
    }
}
