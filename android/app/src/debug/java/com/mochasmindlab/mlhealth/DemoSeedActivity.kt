package com.mochasmindlab.mlhealth

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Energy
import androidx.health.connect.client.units.Mass
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId

/**
 * DEBUG-ONLY. Requests Health Connect permissions through the real consent flow
 * (pm grant is NOT sufficient — Health Connect gates data access on its own
 * consent records), then injects sample step, active-calorie, and weight data so
 * the app has realistic data to display when recording a Health Connect demo.
 *
 * On Android 14+ (HC in the platform) the androidx PermissionController contract
 * returns empty, so we request the raw android.permission.health.* strings via
 * the standard runtime-permission contract and verify against HC's own
 * getGrantedPermissions().
 *
 * Launch: adb shell am start -n com.mochasmindlab.mlhealth/.DemoSeedActivity
 * Lives in src/debug — never present in any release build.
 */
class DemoSeedActivity : ComponentActivity() {

    private val requiredPerms = setOf(
        HealthPermission.getReadPermission(StepsRecord::class),
        HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
        HealthPermission.getReadPermission(WeightRecord::class),
        HealthPermission.getWritePermission(WeightRecord::class),
        HealthPermission.getWritePermission(StepsRecord::class),
        HealthPermission.getWritePermission(ActiveCaloriesBurnedRecord::class)
    )

    private val healthPermStrings = arrayOf(
        "android.permission.health.READ_STEPS",
        "android.permission.health.READ_ACTIVE_CALORIES_BURNED",
        "android.permission.health.READ_WEIGHT",
        "android.permission.health.WRITE_WEIGHT",
        "android.permission.health.WRITE_STEPS",
        "android.permission.health.WRITE_ACTIVE_CALORIES_BURNED"
    )

    private val permLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { result ->
        lifecycleScope.launch {
            val client = HealthConnectClient.getOrCreate(this@DemoSeedActivity)
            val granted = client.permissionController.getGrantedPermissions()
            writeResult("after request: androidResult=$result ; hcGranted=${granted.size} -> $granted")
            if (granted.containsAll(requiredPerms)) seed()
            else { toast("Missing: ${requiredPerms - granted}"); finish() }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycleScope.launch {
            val client = HealthConnectClient.getOrCreate(this@DemoSeedActivity)
            val granted = client.permissionController.getGrantedPermissions()
            writeResult("already granted: ${granted.size} -> $granted")
            if (granted.containsAll(requiredPerms)) seed() else permLauncher.launch(healthPermStrings)
        }
    }

    private fun seed() {
        val client = HealthConnectClient.getOrCreate(this)
        lifecycleScope.launch(Dispatchers.IO) {
            try {
                val zone = ZoneId.systemDefault()
                val now = Instant.now()
                val start = LocalDate.now().atTime(LocalTime.of(7, 0)).atZone(zone).toInstant()
                val startOffset = zone.rules.getOffset(start)
                val nowOffset = zone.rules.getOffset(now)
                client.insertRecords(
                    listOf(
                        StepsRecord(
                            count = 8742L,
                            startTime = start,
                            startZoneOffset = startOffset,
                            endTime = now,
                            endZoneOffset = nowOffset
                        ),
                        ActiveCaloriesBurnedRecord(
                            energy = Energy.kilocalories(423.0),
                            startTime = start,
                            startZoneOffset = startOffset,
                            endTime = now,
                            endZoneOffset = nowOffset
                        ),
                        WeightRecord(
                            weight = Mass.kilograms(70.3),
                            time = now,
                            zoneOffset = nowOffset
                        )
                    )
                )
                val agg = client.aggregate(
                    AggregateRequest(
                        setOf(StepsRecord.COUNT_TOTAL),
                        TimeRangeFilter.between(LocalDate.now().atStartOfDay(zone).toInstant(), Instant.now())
                    )
                )
                val back = agg[StepsRecord.COUNT_TOTAL] ?: -1L
                writeResult("SEEDED ok; readback steps=$back")
                toast("Seeded; readback steps=$back")
            } catch (e: Exception) {
                writeResult("SEED FAILED: ${e.javaClass.simpleName}: ${e.message}")
                toast("Seed failed: ${e.message}")
            } finally {
                withContext(Dispatchers.Main) { finish() }
            }
        }
    }

    private fun writeResult(msg: String) {
        Log.i("DemoSeed", msg)
        try { File(filesDir, "seedlog.txt").appendText(msg + "\n") } catch (_: Exception) {}
    }

    private fun toast(msg: String) {
        runOnUiThread { Toast.makeText(this, msg, Toast.LENGTH_LONG).show() }
    }
}
