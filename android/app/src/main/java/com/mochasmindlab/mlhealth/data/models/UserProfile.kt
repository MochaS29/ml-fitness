package com.mochasmindlab.mlhealth.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(tableName = "user_profile")
data class UserProfile(
    @PrimaryKey
    val id: Long = 1,
    val name: String = "",
    val email: String = "",
    val height: Float = 170f, // in cm
    val currentWeight: Float = 70f, // in lbs
    val goalWeight: Float = 65f, // in lbs
    val birthDate: LocalDate = LocalDate.of(1990, 1, 1),
    val gender: String = "Other",
    val activityLevel: String = "Moderately Active",
    val dietType: String = "No Restrictions",
    val allergies: List<String> = emptyList(),
    val dailyCalorieGoal: Int = 2000,
    val dailyProteinGoal: Int = 50,
    val dailyCarbsGoal: Int = 250,
    val dailyFatGoal: Int = 65,
    val dailyWaterGoal: Int = 8,
    val createdDate: LocalDate = LocalDate.now(),
    val lastUpdated: LocalDate = LocalDate.now()
)