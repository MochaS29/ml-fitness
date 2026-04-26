package com.mochasmindlab.mlhealth.services

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.mochasmindlab.mlhealth.utils.ReminderSettings
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Diff a user-edited ReminderSettings against the current state and (re)schedule
 * WorkManager jobs accordingly. Each reminder type owns a unique work tag —
 * cancelling by tag is how we turn things off.
 */
@Singleton
class ReminderScheduler @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val wm = WorkManager.getInstance(context)

    fun apply(settings: ReminderSettings) {
        applyWater(settings)
        applyMeals(settings)
        applyWeight(settings)
    }

    private fun applyWater(s: ReminderSettings) {
        wm.cancelAllWorkByTag(TAG_WATER)
        if (!s.waterEnabled) return

        // PeriodicWorkRequest minimum is 15min — round to a sensible cadence
        val intervalMinutes = s.waterIntervalMinutes.coerceAtLeast(15).toLong()
        val request = PeriodicWorkRequestBuilder<WaterReminderWorker>(
            intervalMinutes, java.util.concurrent.TimeUnit.MINUTES
        )
            .addTag(TAG_WATER)
            .setInputData(
                workDataOf(
                    WaterReminderWorker.K_START_HOUR to s.waterStartHour,
                    WaterReminderWorker.K_END_HOUR to s.waterEndHour
                )
            )
            .build()

        wm.enqueueUniquePeriodicWork(
            UNIQUE_WATER,
            ExistingPeriodicWorkPolicy.REPLACE,
            request
        )
    }

    private fun applyMeals(s: ReminderSettings) {
        wm.cancelAllWorkByTag(TAG_MEALS)
        if (!s.mealsEnabled) return

        ReminderWorker.scheduleNext(
            context, TAG_MEALS, NotificationService.ID_BREAKFAST,
            s.breakfastHour, 0,
            "Time for breakfast",
            "Start your day with a logged meal."
        )
        ReminderWorker.scheduleNext(
            context, TAG_MEALS, NotificationService.ID_LUNCH,
            s.lunchHour, 0,
            "Time for lunch",
            "Don't forget to log what you eat."
        )
        ReminderWorker.scheduleNext(
            context, TAG_MEALS, NotificationService.ID_DINNER,
            s.dinnerHour, 0,
            "Time for dinner",
            "Wrap up your day's tracking."
        )
    }

    private fun applyWeight(s: ReminderSettings) {
        wm.cancelAllWorkByTag(TAG_WEIGHT)
        if (!s.weightEnabled) return

        ReminderWorker.scheduleNext(
            context, TAG_WEIGHT, NotificationService.ID_WEIGHT,
            s.weightHour, s.weightMinute,
            "Weigh-in time",
            "Log today's weight to keep your progress accurate."
        )
    }

    fun cancelAll() {
        wm.cancelAllWorkByTag(TAG_WATER)
        wm.cancelAllWorkByTag(TAG_MEALS)
        wm.cancelAllWorkByTag(TAG_WEIGHT)
    }

    companion object {
        const val TAG_WATER = "reminder_water"
        const val TAG_MEALS = "reminder_meals"
        const val TAG_WEIGHT = "reminder_weight"
        private const val UNIQUE_WATER = "unique_water_reminder"
    }
}
