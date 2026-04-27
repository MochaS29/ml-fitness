package com.mochasmindlab.mlhealth.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(tableName = "fasting_sessions")
data class FastingSession(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val startTime: Date,
    val endTime: Date? = null,
    val targetHours: Double,
    val planName: String,
    val notes: String? = null
)
