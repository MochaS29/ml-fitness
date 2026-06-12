package com.mochasmindlab.mlhealth.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.mochasmindlab.mlhealth.data.database.StringListConverter
import java.util.Date

@Entity(tableName = "user_profiles")
data class UserProfile(
    @PrimaryKey
    val id: Long = 1,
    val name: String = "",
    val email: String = "",
    val height: Float = 170f, // in cm
    val currentWeight: Float = 70f, // in lbs
    val goalWeight: Float = 65f, // in lbs
    val birthDate: Date = Date(),
    val gender: String = "Other",
    val activityLevel: String = "Moderately Active",
    val dietType: String = "No Restrictions",
    @TypeConverters(StringListConverter::class)
    val dietaryPreferences: List<String> = emptyList(),
    val dailyCalorieGoal: Int = 2000,
    val dailyProteinGoal: Int = 50,
    val dailyCarbsGoal: Int = 250,
    val dailyFatGoal: Int = 65,
    val dailyWaterGoal: Int = 8,
    val createdDate: Date = Date(),
    val lastUpdated: Date = Date()
)