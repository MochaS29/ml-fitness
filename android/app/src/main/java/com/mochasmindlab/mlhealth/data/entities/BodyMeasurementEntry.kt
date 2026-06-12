package com.mochasmindlab.mlhealth.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

/**
 * Body measurement log entry. All dimension values are stored in centimetres (cm)
 * regardless of the display unit preference. The UI converts to/from inches when
 * rendering based on the user's unit setting, but storage is always metric.
 *
 * Every field except [id], [date], and [timestamp] is nullable so a user can log
 * just one metric at a time (e.g. only waist) without having to fill everything.
 */
@Entity(tableName = "body_measurement_entries")
data class BodyMeasurementEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val date: Date,
    val timestamp: Date = Date(),
    // All measurements stored in centimetres (cm)
    val waist: Double? = null,
    val hips: Double? = null,
    val chest: Double? = null,
    val biceps: Double? = null,
    val thighs: Double? = null,
    val height: Double? = null
)
