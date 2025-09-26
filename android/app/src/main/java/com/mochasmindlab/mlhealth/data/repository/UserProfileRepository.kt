package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.UserProfileDao
import com.mochasmindlab.mlhealth.data.models.UserProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserProfileRepository @Inject constructor(
    private val userProfileDao: UserProfileDao
) {
    suspend fun insertUserProfile(profile: UserProfile) = userProfileDao.insertUserProfile(profile)
    
    suspend fun updateUserProfile(profile: UserProfile) = userProfileDao.updateUserProfile(profile)
    
    fun getUserProfile(): Flow<UserProfile?> = userProfileDao.getUserProfile()
    
    suspend fun getUserProfileDirect(): UserProfile? = userProfileDao.getUserProfileDirect()
    
    suspend fun deleteUserProfile() = userProfileDao.deleteUserProfile()
    
    suspend fun getCurrentStreak(): Int {
        // Calculate based on daily entries (food, exercise, weight logs)
        // This is a simplified implementation - would need actual tracking logic
        return 7 // Placeholder
    }
    
    suspend fun getTotalDaysTracked(): Int {
        // Calculate based on days with any logged data
        // This is a simplified implementation - would need actual tracking logic
        return 30 // Placeholder
    }
    
    suspend fun updateDailyCalorieGoal(calories: Int) {
        val profile = getUserProfileDirect()
        profile?.let {
            updateUserProfile(it.copy(dailyCalorieGoal = calories))
        }
    }
    
    suspend fun updateGoalWeight(weight: Float) {
        val profile = getUserProfileDirect()
        profile?.let {
            updateUserProfile(it.copy(goalWeight = weight))
        }
    }
    
    suspend fun updateActivityLevel(level: String) {
        val profile = getUserProfileDirect()
        profile?.let {
            updateUserProfile(it.copy(activityLevel = level))
        }
    }
    
    suspend fun updateDietaryPreferences(preferences: List<String>) {
        val profile = getUserProfileDirect()
        profile?.let {
            updateUserProfile(it.copy(dietaryPreferences = preferences))
        }
    }
    
    suspend fun calculateBMR(): Double {
        val profile = getUserProfileDirect() ?: return 0.0
        
        val weightInKg = profile.currentWeight * 0.453592
        val heightInCm = profile.height
        val age = java.time.Period.between(profile.birthDate, LocalDate.now()).years
        
        return if (profile.gender == "Male") {
            10 * weightInKg + 6.25 * heightInCm - 5 * age + 5
        } else {
            10 * weightInKg + 6.25 * heightInCm - 5 * age - 161
        }
    }
    
    suspend fun calculateTDEE(): Int {
        val profile = getUserProfileDirect() ?: return 0
        val bmr = calculateBMR()
        
        val activityMultiplier = when (profile.activityLevel) {
            "Sedentary" -> 1.2
            "Lightly Active" -> 1.375
            "Moderately Active" -> 1.55
            "Very Active" -> 1.725
            "Extra Active" -> 1.9
            else -> 1.55
        }
        
        return (bmr * activityMultiplier).toInt()
    }
}