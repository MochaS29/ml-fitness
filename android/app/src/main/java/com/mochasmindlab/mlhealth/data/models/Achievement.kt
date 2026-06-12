package com.mochasmindlab.mlhealth.data.models

/**
 * Achievement category — mirrors iOS AchievementType groupings.
 */
enum class AchievementCategory(val displayName: String) {
    STREAK("Streaks"),
    LOGGING("Logging"),
    WEIGHT("Weight"),
    EXERCISE("Exercise"),
    WATER("Hydration"),
    MEAL_SCAN("Meal Scan")
}

/**
 * A single, static achievement definition.
 * [id] is the stable string key persisted to DataStore.
 * [iconName] is a descriptive name used to pick a Material Icon in the UI layer.
 */
data class MLAchievement(
    val id: String,
    val title: String,
    val description: String,
    val iconName: String,
    val category: AchievementCategory
)

/**
 * Events that trigger achievement checks.
 * Callers fire these after the relevant action completes.
 *
 * Usage:
 *   achievementManager.checkAndUnlock(AchievementEvent.FoodLogged(totalLogs = 1))
 */
sealed class AchievementEvent {
    /** Fired after any food entry is saved. [totalLogs] = all-time food entry count. */
    data class FoodLogged(val totalLogs: Int) : AchievementEvent()

    /** Fired when the logging streak is recalculated. [streakDays] = current streak. */
    data class StreakUpdated(val streakDays: Int) : AchievementEvent()

    /** Fired after a weight entry is saved. [totalLogs] = all-time weight entry count. */
    data class WeightLogged(val totalLogs: Int) : AchievementEvent()

    /** Fired after an exercise entry is saved. [totalLogs] = all-time exercise entry count. */
    data class ExerciseLogged(val totalLogs: Int) : AchievementEvent()

    /** Fired when a water goal is hit for the day. [glassesLogged] = total 8-oz glasses today. */
    data class WaterGoalHit(val glassesLogged: Int) : AchievementEvent()

    /** Fired after a meal scan (AI photo scan) completes. [totalScans] = all-time scan count. */
    data class MealScanned(val totalScans: Int) : AchievementEvent()
}
