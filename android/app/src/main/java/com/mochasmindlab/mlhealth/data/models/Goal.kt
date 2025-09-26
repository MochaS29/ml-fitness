package com.mochasmindlab.mlhealth.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(tableName = "goals")
data class Goal(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val type: GoalType,
    val title: String,
    val description: String,
    val targetValue: Float,
    val currentValue: Float = 0f,
    val progress: Int = 0, // Percentage 0-100
    val startDate: LocalDate = LocalDate.now(),
    val deadline: LocalDate? = null,
    val isActive: Boolean = true,
    val isCompleted: Boolean = false,
    val completedDate: LocalDate? = null
)

enum class GoalType(val displayName: String) {
    WEIGHT_LOSS("Weight Loss"),
    CALORIES("Calorie Goal"),
    EXERCISE("Exercise"),
    WATER("Water Intake"),
    STEPS("Daily Steps"),
    NUTRITION("Nutrition")
}