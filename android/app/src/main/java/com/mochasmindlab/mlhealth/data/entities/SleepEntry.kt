package com.mochasmindlab.mlhealth.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

/**
 * Room entity for sleep log entries.
 *
 * Entries (source = "manual") are created via the in-app form.
 *
 * [quality] is nullable so manual entries that skip the star rating still persist cleanly.
 * [durationMinutes] is a computed property — NOT stored in the DB column.
 */
@Entity(tableName = "sleep_entries")
data class SleepEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val bedTime: Date,
    val wakeTime: Date,
    val notes: String? = null,
    /** Sleep quality rating 0–5. Null means not rated. */
    val quality: Int? = null,
    /** "manual" or "health_connect" */
    val source: String = "manual"
) {
    /** Duration in whole minutes. Negative values indicate data entry error. */
    val durationMinutes: Long
        get() = (wakeTime.time - bedTime.time) / 60_000L
}
