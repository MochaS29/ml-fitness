package com.mochasmindlab.mlhealth.utils

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.mochasmindlab.mlhealth.data.models.*
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
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
        val MEAL_SCAN_COUNT = intPreferencesKey("meal_scan_count")
        val WATER_REMINDER_ENABLED = booleanPreferencesKey("water_reminder_enabled")
        val MEAL_REMINDER_ENABLED = booleanPreferencesKey("meal_reminder_enabled")
        val EXERCISE_REMINDER_ENABLED = booleanPreferencesKey("exercise_reminder_enabled")
        val WATER_GOAL_OZ = intPreferencesKey("water_goal_oz")
        val WATER_REMINDER_INTERVAL = stringPreferencesKey("water_reminder_interval")
        // Smart reminders (mirrors iOS SmartReminderSettings)
        val WATER_REMINDER_INTERVAL_MIN = intPreferencesKey("reminder_water_interval_min")
        val WATER_REMINDER_START_HOUR = intPreferencesKey("reminder_water_start_hour")
        val WATER_REMINDER_END_HOUR = intPreferencesKey("reminder_water_end_hour")
        val MEAL_BREAKFAST_HOUR = intPreferencesKey("reminder_meal_breakfast_hour")
        val MEAL_LUNCH_HOUR = intPreferencesKey("reminder_meal_lunch_hour")
        val MEAL_DINNER_HOUR = intPreferencesKey("reminder_meal_dinner_hour")
        val WEIGHT_REMINDER_ENABLED = booleanPreferencesKey("reminder_weight_enabled")
        val WEIGHT_REMINDER_HOUR = intPreferencesKey("reminder_weight_hour")
        val WEIGHT_REMINDER_MINUTE = intPreferencesKey("reminder_weight_minute")
        // Exercise reminder time — paired with EXERCISE_REMINDER_ENABLED above.
        // Mirrors the iOS Smart Reminders schema (single daily nudge).
        val EXERCISE_REMINDER_HOUR = intPreferencesKey("reminder_exercise_hour")
        val EXERCISE_REMINDER_MINUTE = intPreferencesKey("reminder_exercise_minute")
        val DARK_MODE_ENABLED = booleanPreferencesKey("dark_mode_enabled")
        val IS_PRO_USER = booleanPreferencesKey("is_pro_user")
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
    
    // Individual field setters — used when Profile screen edits a single field.
    // Without these, post-onboarding edits stay in the Room UserProfile entity and
    // any screen reading PreferencesManager.userProfile (Dashboard, WeightVM,
    // RDAViewModel) gets stale data.

    suspend fun setUserHeight(height: Float) {
        dataStore.edit { it[PreferenceKeys.USER_HEIGHT] = height }
    }

    suspend fun setUserWeight(weight: Float) {
        dataStore.edit { it[PreferenceKeys.USER_WEIGHT] = weight }
    }

    suspend fun setUserTargetWeight(target: Float) {
        dataStore.edit { it[PreferenceKeys.USER_TARGET_WEIGHT] = target }
    }

    suspend fun setUserAge(age: Int) {
        dataStore.edit { it[PreferenceKeys.USER_AGE] = age }
    }

    suspend fun setUserGender(gender: Gender) {
        dataStore.edit { it[PreferenceKeys.USER_GENDER] = gender.name }
    }

    suspend fun setUserActivityLevel(level: ActivityLevel) {
        dataStore.edit { it[PreferenceKeys.USER_ACTIVITY_LEVEL] = level.name }
    }

    // Individual field flows — let screens read body metrics + goals without
    // depending on the full userProfile aggregate (which only emits when
    // USER_NAME is set, breaking screens for users who skipped onboarding).
    val userTargetWeight: Flow<Float> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[PreferenceKeys.USER_TARGET_WEIGHT] ?: 0f }

    val userWeight: Flow<Float> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[PreferenceKeys.USER_WEIGHT] ?: 0f }

    val userHeight: Flow<Float> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[PreferenceKeys.USER_HEIGHT] ?: 0f }

    // Dietary preferences — multi-select set persisted as enum names. Mirrors
    // iOS UserFoodPreferences.dietaryPreferences. Allergens use AllergenKeys
    // further below; intentionally separate so allergens (food safety) can be
    // edited independently from dietary lifestyle choices.
    private object DietaryKeys {
        val DIETARY_PREFERENCES = stringSetPreferencesKey("dietary_preferences")
    }

    val dietaryPreferences: Flow<Set<String>> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[DietaryKeys.DIETARY_PREFERENCES] ?: emptySet() }

    suspend fun setDietaryPreferences(set: Set<String>) {
        dataStore.edit { it[DietaryKeys.DIETARY_PREFERENCES] = set }
    }

    suspend fun setExerciseReminderTime(hour: Int, minute: Int) {
        dataStore.edit {
            it[PreferenceKeys.EXERCISE_REMINDER_HOUR] = hour
            it[PreferenceKeys.EXERCISE_REMINDER_MINUTE] = minute
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

    /** Number of AI meal scans the user has performed. Used to gate the free trial. */
    val mealScanCount: Flow<Int> = dataStore.data
        .map { it[PreferenceKeys.MEAL_SCAN_COUNT] ?: 0 }

    suspend fun incrementMealScanCount() {
        dataStore.edit { preferences ->
            val current = preferences[PreferenceKeys.MEAL_SCAN_COUNT] ?: 0
            preferences[PreferenceKeys.MEAL_SCAN_COUNT] = current + 1
        }
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
    
    // Water tracking specific
    suspend fun setWaterGoalOz(ounces: Int) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.WATER_GOAL_OZ] = ounces
        }
    }

    val waterGoalOz: Flow<Int> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.WATER_GOAL_OZ] ?: 64 // Default 64 oz (8 glasses of 8 oz)
        }

    suspend fun setWaterRemindersEnabled(enabled: Boolean) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_ENABLED] = enabled
        }
    }

    val waterRemindersEnabled: Flow<Boolean> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_ENABLED] ?: false
        }

    suspend fun setWaterReminderInterval(interval: String) {
        dataStore.edit { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_INTERVAL] = interval
        }
    }

    val waterReminderInterval: Flow<String> = dataStore.data
        .map { preferences ->
            preferences[PreferenceKeys.WATER_REMINDER_INTERVAL] ?: "Every 2 hours"
        }

    // Smart reminder settings (water window, meal times, weight time, weight toggle)
    suspend fun setWaterReminderIntervalMinutes(minutes: Int) {
        dataStore.edit { it[PreferenceKeys.WATER_REMINDER_INTERVAL_MIN] = minutes }
    }

    suspend fun setWaterWindow(startHour: Int, endHour: Int) {
        dataStore.edit {
            it[PreferenceKeys.WATER_REMINDER_START_HOUR] = startHour
            it[PreferenceKeys.WATER_REMINDER_END_HOUR] = endHour
        }
    }

    suspend fun setMealHours(breakfast: Int, lunch: Int, dinner: Int) {
        dataStore.edit {
            it[PreferenceKeys.MEAL_BREAKFAST_HOUR] = breakfast
            it[PreferenceKeys.MEAL_LUNCH_HOUR] = lunch
            it[PreferenceKeys.MEAL_DINNER_HOUR] = dinner
        }
    }

    suspend fun setWeightReminder(enabled: Boolean, hour: Int = 8, minute: Int = 0) {
        dataStore.edit {
            it[PreferenceKeys.WEIGHT_REMINDER_ENABLED] = enabled
            it[PreferenceKeys.WEIGHT_REMINDER_HOUR] = hour
            it[PreferenceKeys.WEIGHT_REMINDER_MINUTE] = minute
        }
    }

    val reminderSettings: Flow<ReminderSettings> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { p ->
            ReminderSettings(
                waterEnabled = p[PreferenceKeys.WATER_REMINDER_ENABLED] ?: false,
                waterIntervalMinutes = p[PreferenceKeys.WATER_REMINDER_INTERVAL_MIN] ?: 120,
                waterStartHour = p[PreferenceKeys.WATER_REMINDER_START_HOUR] ?: 8,
                waterEndHour = p[PreferenceKeys.WATER_REMINDER_END_HOUR] ?: 20,
                mealsEnabled = p[PreferenceKeys.MEAL_REMINDER_ENABLED] ?: false,
                breakfastHour = p[PreferenceKeys.MEAL_BREAKFAST_HOUR] ?: 8,
                lunchHour = p[PreferenceKeys.MEAL_LUNCH_HOUR] ?: 12,
                dinnerHour = p[PreferenceKeys.MEAL_DINNER_HOUR] ?: 18,
                exerciseEnabled = p[PreferenceKeys.EXERCISE_REMINDER_ENABLED] ?: false,
                exerciseHour = p[PreferenceKeys.EXERCISE_REMINDER_HOUR] ?: 18,
                exerciseMinute = p[PreferenceKeys.EXERCISE_REMINDER_MINUTE] ?: 0,
                weightEnabled = p[PreferenceKeys.WEIGHT_REMINDER_ENABLED] ?: false,
                weightHour = p[PreferenceKeys.WEIGHT_REMINDER_HOUR] ?: 8,
                weightMinute = p[PreferenceKeys.WEIGHT_REMINDER_MINUTE] ?: 0
            )
        }

    // Dark mode
    suspend fun setDarkMode(enabled: Boolean) {
        dataStore.edit { it[PreferenceKeys.DARK_MODE_ENABLED] = enabled }
    }

    val darkModeEnabled: Flow<Boolean> = dataStore.data
        .map { it[PreferenceKeys.DARK_MODE_ENABLED] ?: false }

    // Pro user state (Play Billing-driven)
    suspend fun setProUser(isPro: Boolean) {
        dataStore.edit { it[PreferenceKeys.IS_PRO_USER] = isPro }
    }

    val isProUser: Flow<Boolean> = dataStore.data
        .map { it[PreferenceKeys.IS_PRO_USER] ?: false }

    // Per-install UUID used to rate-limit meal-scan proxy calls. Generated on
    // first read and cached for the install's lifetime — wiped only by Settings
    // → Clear Data (which clears all preferences). Not personally identifying;
    // pairs with APP_SHARED_SECRET to authenticate proxy requests.
    private object InstallKeys {
        val INSTALL_ID = stringPreferencesKey("install_id")
    }

    suspend fun getOrCreateInstallId(): String {
        val existing = dataStore.data.first()[InstallKeys.INSTALL_ID]
        if (!existing.isNullOrBlank()) return existing
        val fresh = java.util.UUID.randomUUID().toString()
        dataStore.edit { it[InstallKeys.INSTALL_ID] = fresh }
        return fresh
    }

    // ===== Allergens =====

    private object AllergenKeys {
        val ALLERGENS = stringSetPreferencesKey("allergens")
    }

    /** Observe the user's saved allergen IDs (each value is a [FoodAllergy] enum name). */
    val allergens: Flow<Set<String>> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[AllergenKeys.ALLERGENS] ?: emptySet() }

    /** Persist the full allergen set (replaces any previous value). */
    suspend fun setAllergens(set: Set<String>) {
        dataStore.edit { it[AllergenKeys.ALLERGENS] = set }
    }

    // ===== Achievements =====

    private object AchievementKeys {
        val UNLOCKED_ACHIEVEMENTS = stringSetPreferencesKey("unlocked_achievements")
    }

    /** Observe the full set of unlocked achievement IDs. */
    val unlockedAchievements: Flow<Set<String>> = dataStore.data
        .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
        .map { it[AchievementKeys.UNLOCKED_ACHIEVEMENTS] ?: emptySet() }

    /** Persist a single unlocked achievement ID (idempotent — DataStore sets are de-duped). */
    suspend fun addUnlockedAchievement(id: String) {
        dataStore.edit { prefs ->
            val current = prefs[AchievementKeys.UNLOCKED_ACHIEVEMENTS] ?: emptySet()
            prefs[AchievementKeys.UNLOCKED_ACHIEVEMENTS] = current + id
        }
    }

    /** Batch-persist a set of unlocked achievement IDs. */
    suspend fun addUnlockedAchievements(ids: Set<String>) {
        dataStore.edit { prefs ->
            val current = prefs[AchievementKeys.UNLOCKED_ACHIEVEMENTS] ?: emptySet()
            prefs[AchievementKeys.UNLOCKED_ACHIEVEMENTS] = current + ids
        }
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

data class ReminderSettings(
    val waterEnabled: Boolean,
    val waterIntervalMinutes: Int,
    val waterStartHour: Int,
    val waterEndHour: Int,
    val mealsEnabled: Boolean,
    val breakfastHour: Int,
    val lunchHour: Int,
    val dinnerHour: Int,
    val exerciseEnabled: Boolean,
    val exerciseHour: Int,
    val exerciseMinute: Int,
    val weightEnabled: Boolean,
    val weightHour: Int,
    val weightMinute: Int
)

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