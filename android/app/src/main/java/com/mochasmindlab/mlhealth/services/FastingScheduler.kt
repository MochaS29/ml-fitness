package com.mochasmindlab.mlhealth.services

import android.content.Context
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.UUID
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FastingScheduler @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val wm = WorkManager.getInstance(context)

    fun scheduleEndNotification(
        sessionId: UUID,
        fastHours: Double,
        startMillis: Long,
        planName: String = ""
    ) {
        val targetMillis = startMillis + (fastHours * 3600 * 1000).toLong()
        val delayMillis = (targetMillis - System.currentTimeMillis()).coerceAtLeast(0L)

        val inputData = Data.Builder()
            .putString(FastingEndWorker.K_SESSION_ID, sessionId.toString())
            .putDouble(FastingEndWorker.K_FAST_HOURS, fastHours)
            .putString(FastingEndWorker.K_PLAN_NAME, planName)
            .build()

        val request = OneTimeWorkRequestBuilder<FastingEndWorker>()
            .setInitialDelay(delayMillis, TimeUnit.MILLISECONDS)
            .addTag("fast_$sessionId")
            .setInputData(inputData)
            .build()

        wm.enqueue(request)
    }

    fun cancelEndNotification(sessionId: UUID) {
        wm.cancelAllWorkByTag("fast_$sessionId")
    }
}
