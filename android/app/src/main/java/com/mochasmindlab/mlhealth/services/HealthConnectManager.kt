package com.mochasmindlab.mlhealth.services

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Mass
import com.mochasmindlab.mlhealth.data.entities.SleepEntry
import dagger.hilt.android.qualifiers.ApplicationContext
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.util.Date
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Wraps the Health Connect SDK for reading/writing steps and weight.
 * Mirrors iOS HealthKitManager: reads steps (cumulative sum) and reads/writes weight.
 *
 * Availability is checked via [HealthConnectClient.getSdkStatus]. This must be checked
 * before any read/write operations — if NOT_INSTALLED or PROVIDER_UPDATE_REQUIRED, the
 * methods below return safe defaults (0 / null) rather than throwing.
 */
@Singleton
class HealthConnectManager @Inject constructor(
    @ApplicationContext private val context: Context
) {

    // Sealed enum mirroring SdkAvailabilityStatus values we care about
    enum class SdkAvailabilityStatus {
        AVAILABLE,
        PROVIDER_UPDATE_REQUIRED,
        NOT_INSTALLED
    }

    val installPlayStoreLink: String =
        "https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata"

    val requiredPermissions: Set<String> = setOf(
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getReadPermission(WeightRecord::class),
        HealthPermission.getWritePermission(WeightRecord::class),
        // Sleep tracking — added by sleep-tracking agent (gap #10)
        HealthPermission.getReadPermission(SleepSessionRecord::class),
        // Active energy — surfaces real-world calorie burn in the dashboard
        // Burned tile (mirrors iOS HealthKit activeEnergyBurned). Read-only;
        // falls back to a step-derived estimate when no samples exist.
        HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class)
    )

    /**
     * Returns availability status of the Health Connect SDK on this device.
     * Safe to call without a [HealthConnectClient] instance.
     */
    fun isAvailable(): SdkAvailabilityStatus {
        return when (HealthConnectClient.getSdkStatus(context)) {
            HealthConnectClient.SDK_AVAILABLE -> SdkAvailabilityStatus.AVAILABLE
            HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED ->
                SdkAvailabilityStatus.PROVIDER_UPDATE_REQUIRED
            else -> SdkAvailabilityStatus.NOT_INSTALLED
        }
    }

    /**
     * Lazily obtain the [HealthConnectClient]. Returns null if HC is not installed/available.
     */
    private fun getClientOrNull(): HealthConnectClient? {
        return if (isAvailable() == SdkAvailabilityStatus.AVAILABLE) {
            HealthConnectClient.getOrCreate(context)
        } else {
            null
        }
    }

    /**
     * Returns true only when all [requiredPermissions] have been granted by the user.
     */
    suspend fun hasAllPermissions(): Boolean {
        val client = getClientOrNull() ?: return false
        return try {
            val granted = client.permissionController.getGrantedPermissions()
            granted.containsAll(requiredPermissions)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Returns the permission contract launcher result for use with
     * [androidx.activity.compose.rememberLauncherForActivityResult] in Compose.
     *
     * Usage in a Composable:
     *   val launcher = rememberLauncherForActivityResult(manager.permissionsContract()) { granted ->
     *       viewModel.onPermissionResult(granted)
     *   }
     *   launcher.launch(manager.requiredPermissions)
     */
    fun permissionsContract() =
        androidx.health.connect.client.PermissionController
            .createRequestPermissionResultContract()

    /**
     * Reads the total step count from midnight today until now.
     * Returns 0 if Health Connect is unavailable or permission not granted.
     */
    suspend fun readStepsToday(): Long {
        return readStepsForDate(LocalDate.now())
    }

    /**
     * Reads the total step count for a given [date] (full calendar day in the device's default zone).
     * Returns 0 on any error or if HC is unavailable.
     */
    suspend fun readStepsForDate(date: LocalDate): Long {
        val client = getClientOrNull() ?: return 0L
        return try {
            val zone = ZoneId.systemDefault()
            val startOfDay = date.atStartOfDay(zone).toInstant()
            val endOfDay = date.atTime(LocalTime.MAX).atZone(zone).toInstant()
                .let { if (it.isAfter(Instant.now())) Instant.now() else it }

            val response = client.aggregate(
                AggregateRequest(
                    metrics = setOf(StepsRecord.COUNT_TOTAL),
                    timeRangeFilter = TimeRangeFilter.between(startOfDay, endOfDay)
                )
            )
            response[StepsRecord.COUNT_TOTAL] ?: 0L
        } catch (e: Exception) {
            0L
        }
    }

    /**
     * Reads total active energy burned (kcal) for a given [date] (full calendar
     * day in the device's default zone). Returns 0 if Health Connect is
     * unavailable, the permission isn't granted, or no samples exist — callers
     * fall back to a step-derived estimate. Mirrors iOS
     * HealthKitManager.fetchActiveEnergy.
     */
    suspend fun readActiveCaloriesForDate(date: LocalDate): Double {
        val client = getClientOrNull() ?: return 0.0
        return try {
            val zone = ZoneId.systemDefault()
            val startOfDay = date.atStartOfDay(zone).toInstant()
            val endOfDay = date.atTime(LocalTime.MAX).atZone(zone).toInstant()
                .let { if (it.isAfter(Instant.now())) Instant.now() else it }

            val response = client.aggregate(
                AggregateRequest(
                    metrics = setOf(ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL),
                    timeRangeFilter = TimeRangeFilter.between(startOfDay, endOfDay)
                )
            )
            response[ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL]?.inKilocalories ?: 0.0
        } catch (e: Exception) {
            0.0
        }
    }

    /** Convenience: active energy burned (kcal) for today. */
    suspend fun readActiveCaloriesToday(): Double = readActiveCaloriesForDate(LocalDate.now())

    /**
     * Reads the most recent [WeightRecord] and returns the value in kilograms.
     * Returns null if no record exists, or HC is unavailable/not permitted.
     */
    suspend fun readLatestWeightKg(): Double? {
        val client = getClientOrNull() ?: return null
        return try {
            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(
                        Instant.EPOCH,
                        Instant.now()
                    ),
                    ascendingOrder = false,
                    pageSize = 1
                )
            )
            response.records.firstOrNull()?.weight?.inKilograms
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Reads [SleepSessionRecord] entries for a given [date] (full calendar day in the device's
     * default time zone) and maps them to [SleepEntry] with source = "health_connect".
     *
     * Returns an empty list if Health Connect is unavailable, the permission is not granted,
     * or no sessions were recorded for the day.
     */
    suspend fun readSleepSessions(date: LocalDate): List<SleepEntry> {
        val client = getClientOrNull() ?: return emptyList()
        return try {
            val zone = ZoneId.systemDefault()
            val startOfDay = date.atStartOfDay(zone).toInstant()
            val endOfDay = date.atTime(LocalTime.MAX).atZone(zone).toInstant()
                .let { if (it.isAfter(Instant.now())) Instant.now() else it }

            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = SleepSessionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startOfDay, endOfDay)
                )
            )
            response.records.map { record ->
                SleepEntry(
                    id = UUID.randomUUID(),
                    bedTime = Date.from(record.startTime),
                    wakeTime = Date.from(record.endTime),
                    notes = record.title?.takeIf { it.isNotBlank() },
                    quality = null, // SleepSessionRecord has no direct quality field
                    source = "health_connect"
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Writes a [WeightRecord] with [weight] in kilograms at [time] (defaults to now).
     * Silently fails if HC is unavailable or not permitted — caller should check
     * [hasAllPermissions] first if confirmation is needed.
     */
    suspend fun writeWeightKg(weight: Double, time: Instant = Instant.now()) {
        val client = getClientOrNull() ?: return
        try {
            client.insertRecords(
                listOf(
                    WeightRecord(
                        weight = Mass.kilograms(weight),
                        time = time,
                        zoneOffset = ZoneId.systemDefault().rules.getOffset(time)
                    )
                )
            )
        } catch (e: Exception) {
            // Fail silently — caller can observe via readLatestWeightKg
        }
    }
}
