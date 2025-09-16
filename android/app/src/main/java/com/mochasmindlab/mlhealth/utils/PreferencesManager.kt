package com.mochasmindlab.mlhealth.utils

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.mochasmindlab.mlhealth.data.models.*
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import java.io.IOException
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "ml_health_preferences")

@Singleton
class PreferencesManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val dataStore = context.dataStore
    
    // Preference Keys
    private object PreferenceKeys {
        val ONBOARDING_COMPLETED = booleanPreferencesKey("onboarding_completed")
        val USER_NAME = stringPreferencesKey("user_name")
        val USER_AGE = intPreferencesKey("user_age")
        val USER_GENDER = stringPreferencesKey("user_gender")
        val USER_HEIGHT = floatPreferencesKey("user_height")
        val USER_HEIGHT_UNIT = stringPreferencesKey("user_height_unit")
        val USER_WEIGHT = floatPreferencesKey("user_weight")
        val USER_WEIGHT_UNIT = stringPreferencesKey("user_weight_unit")
        val USER_ACTIVITY_LEVEL = stringPreferencesKey("user_activity_level")
        val USER_GOAL_TYPE = stringPreferencesKey("user_goal_type")
        val USER_TARGET_WEIGHT = floatPreferencesKey("user_target_weight")
        val DAILY_CALORIE_GOAL = intPreferencesKey("daily_calorie_goal")
        val DAILY_WATER_GOAL = intPreferencesKey("daily_water_goal")
        val DAILY_EXERCISE_GOAL = intPreferencesKey("daily_exercise_goal")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        val WATER_REMINDER_ENABLED = booleanPreferencesKey("water_reminder_enabled")
        val MEAL_REMINDER_ENABLED = booleanPreferencesKey("meal_reminder_enabled")
        val EXERCISE_REMINDER_ENABLED = booleanPreferencesKey("exercise_reminder_enabled")
    }
    
    // Onboarding
    suspend fun setOnboardingCompleted(completed: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.ONBOARDING_COMPLETED] = completed
        }
    }
    
    val isOnboardingCompleted: Flow<Boolean> = dataStore.data
        .catch { exception ->
            if (exception is IOException) {
                emit(emptyPreferences())
            } else {
                throw exception
            }
        }
        .map { preferences ->
            preferences[PreferenceKeys.ONBOARDING_COMPLETED] ?: false
        }
    
    // User Profile
    suspend fun saveUserProfile(
        name: String,
        age: Int,
        gender: Gender,
        height: Float,
        heightUnit: HeightUnit = HeightUnit.CM,
        weight: Float,
        weightUnit: WeightUnit = WeightUnit.KG,
        activityLevel: ActivityLevel,
        goalType: GoalCategory,
        targetWeight: Float
    ) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.USER_NAME] = name
            preferences[PreferenceKeys.USER_AGE] = age
            preferences[PreferenceKeys.USER_GENDER] = gender.name
            preferences[PreferenceKeys.USER_HEIGHT] = height
            preferences[PreferenceKeys.USER_HEIGHT_UNIT] = heightUnit.name
            preferences[PreferenceKeys.USER_WEIGHT] = weight
            preferences[PreferenceKeys.USER_WEIGHT_UNIT] = weightUnit.name
            preferences[PreferenceKeys.USER_ACTIVITY_LEVEL] = activityLevel.name
            preferences[PreferenceKeys.USER_GOAL_TYPE] = goalType.name
            preferences[PreferenceKeys.USER_TARGET_WEIGHT] = targetWeight
            
            // Calculate and save daily goals based on user profile
            val bmr = calculateBMR(weight, height, age, gender)
            val tdee = calculateTDEE(bmr, activityLevel)
            val calorieGoal = calculateCalorieGoal(tdee, goalType)
            
            preferences[PreferenceKeys.DAILY_CALORIE_GOAL] = calorieGoal
            preferences[PreferenceKeys.DAILY_WATER_GOAL] = 8 // Default 8 cups
            preferences[PreferenceKeys.DAILY_EXERCISE_GOAL] = 30 // Default 30 minutes
        }
    }
    
    val userProfile: Flow<UserProfile?> = dataStore.data
        .catch { exception ->
            if (exception is IOException) {
                emit(emptyPreferences())
            } else {
                throw exception
            }
        }
        .map { preferences ->
            val name = preferences[PreferenceKeys.USER_NAME]
            if (name != null) {
                UserProfile(
                    name = name,
                    age = preferences[PreferenceKeys.USER_AGE] ?: 25,
                    gender = Gender.valueOf(preferences[PreferenceKeys.USER_GENDER] ?: Gender.FEMALE.name),
                    height = preferences[PreferenceKeys.USER_HEIGHT] ?: 170f,
                    heightUnit = HeightUnit.valueOf(
                        preferences[PreferenceKeys.USER_HEIGHT_UNIT] ?: HeightUnit.CM.name
                    ),
                    weight = preferences[PreferenceKeys.USER_WEIGHT] ?: 70f,
                    weightUnit = WeightUnit.valueOf(
                        preferences[PreferenceKeys.USER_WEIGHT_UNIT] ?: WeightUnit.KG.name
                    ),
                    activityLevel = ActivityLevel.valueOf(
                        preferences[PreferenceKeys.USER_ACTIVITY_LEVEL] ?: ActivityLevel.MODERATE.name
                    ),
                    goalType = GoalCategory.valueOf(
                        preferences[PreferenceKeys.USER_GOAL_TYPE] ?: GoalCategory.WEIGHT_LOSS.name
                    ),
                    targetWeight = preferences[PreferenceKeys.USER_TARGET_WEIGHT] ?: 70f,
                    dailyCalorieGoal = preferences[PreferenceKeys.DAILY_CALORIE_GOAL] ?: 2000,
                    dailyWaterGoal = preferences[PreferenceKeys.DAILY_WATER_GOAL] ?: 8,
                    dailyExerciseGoal = preferences[PreferenceKeys.DAILY_EXERCISE_GOAL] ?: 30
                )
            } else {
                null
            }
        }
    
    // Goals
    suspend fun updateDailyCalorieGoal(calories: Int) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.DAILY_CALORIE_GOAL] = calories
        }
    }
    
    suspend fun updateDailyWaterGoal(cups: Int) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.DAILY_WATER_GOAL] = cups
        }
    }
    
    suspend fun updateDailyExerciseGoal(minutes: Int) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.DAILY_EXERCISE_GOAL] = minutes
        }
    }
    
    val dailyCalorieGoal: Flow<Int> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.DAILY_CALORIE_GOAL] ?: 2000
        }
    
    val dailyWaterGoal: Flow<Int> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.DAILY_WATER_GOAL] ?: 8
        }
    
    val dailyExerciseGoal: Flow<Int> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.DAILY_EXERCISE_GOAL] ?: 30
        }
    
    // Notifications
    suspend fun setNotificationsEnabled(enabled: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.NOTIFICATIONS_ENABLED] = enabled
        }
    }
    
    suspend fun setWaterReminderEnabled(enabled: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_ENABLED] = enabled
        }
    }
    
    suspend fun setMealReminderEnabled(enabled: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.MEAL_REMINDER_ENABLED] = enabled
        }
    }
    
    suspend fun setExerciseReminderEnabled(enabled: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.EXERCISE_REMINDER_ENABLED] = enabled
        }
    }
    
    val notificationsEnabled: Flow<Boolean> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.NOTIFICATIONS_ENABLED] ?: true
        }
    
    val waterReminderEnabled: Flow<Boolean> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_ENABLED] ?: true
        }
    
    val mealReminderEnabled: Flow<Boolean> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.MEAL_REMINDER_ENABLED] ?: true
        }
    
    val exerciseReminderEnabled: Flow<Boolean> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.EXERCISE_REMINDER_ENABLED] ?: false
        }
    
    // Clear all preferences (for logout/reset)
    suspend fun clearAllPreferences() {
        dataStore.edit { preferences ->
            preferences.clear()
        }
    }
    
    // Helper functions
    private fun calculateBMR(weight: Float, height: Float, age: Int, gender: Gender): Float {
        return when (gender) {
            Gender.MALE -> 88.362f + (13.397f * weight) + (4.799f * height) - (5.677f * age)
            Gender.FEMALE -> 447.593f + (9.247f * weight) + (3.098f * height) - (4.330f * age)
            Gender.OTHER -> 447.593f + (9.247f * weight) + (3.098f * height) - (4.330f * age)
        }
    }
    
    private fun calculateTDEE(bmr: Float, activityLevel: ActivityLevel): Float {
        val multiplier = when (activityLevel) {
            ActivityLevel.SEDENTARY -> 1.2f
            ActivityLevel.LIGHT -> 1.375f
            ActivityLevel.MODERATE -> 1.55f
            ActivityLevel.ACTIVE -> 1.725f
            ActivityLevel.VERY_ACTIVE -> 1.9f
        }
        return bmr * multiplier
    }
    
    private fun calculateCalorieGoal(tdee: Float, goalType: GoalCategory): Int {
        return when (goalType) {
            GoalCategory.WEIGHT_LOSS -> (tdee - 500).toInt() // 500 calorie deficit
            GoalCategory.WEIGHT_GAIN -> (tdee + 500).toInt() // 500 calorie surplus
            else -> tdee.toInt() // Maintenance
        }
    }
}

data class UserProfile(
    val name: String,
    val age: Int,
    val gender: Gender,
    val height: Float,
    val heightUnit: HeightUnit,
    val weight: Float,
    val weightUnit: WeightUnit,
    val activityLevel: ActivityLevel,
    val goalType: GoalCategory,
    val targetWeight: Float,
    val dailyCalorieGoal: Int,
    val dailyWaterGoal: Int,
    val dailyExerciseGoal: Int
)