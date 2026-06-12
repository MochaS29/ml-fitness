package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.data.models.AchievementCategory
import com.mochasmindlab.mlhealth.data.models.AchievementEvent
import com.mochasmindlab.mlhealth.data.models.MLAchievement
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Central achievement registry and unlock manager.
 *
 * Mirrors iOS AchievementManager unlock-set approach:
 *   - Achievements are static definitions identified by a stable String [id].
 *   - Unlock state is persisted as a Set<String> in DataStore via PreferencesManager.
 *   - Callers fire [AchievementEvent] variants; this class evaluates which
 *     achievements should unlock and writes new IDs to the set (idempotent).
 *   - [recentlyUnlocked] is a SharedFlow that emits each newly unlocked
 *     achievement so the UI layer can hook in a celebration (snackbar, animation, etc.).
 */
@Singleton
class AchievementManager @Inject constructor(
    private val preferencesManager: PreferencesManager
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    // ── All-time achievement definitions ──────────────────────────────────────

    val allAchievements: List<MLAchievement> = listOf(

        // STREAK
        MLAchievement(
            id = "streak_1_day",
            title = "First Log",
            description = "Log food for your first day.",
            iconName = "LocalFireDepartment",
            category = AchievementCategory.STREAK
        ),
        MLAchievement(
            id = "streak_7_days",
            title = "Week Warrior",
            description = "Log food for 7 consecutive days.",
            iconName = "LocalFireDepartment",
            category = AchievementCategory.STREAK
        ),
        MLAchievement(
            id = "streak_30_days",
            title = "Monthly Master",
            description = "Log food for 30 consecutive days.",
            iconName = "EmojiEvents",
            category = AchievementCategory.STREAK
        ),

        // LOGGING
        MLAchievement(
            id = "logs_100",
            title = "Century Logger",
            description = "Log 100 food entries total.",
            iconName = "Book",
            category = AchievementCategory.LOGGING
        ),
        MLAchievement(
            id = "logs_500",
            title = "Elite Tracker",
            description = "Log 500 food entries total.",
            iconName = "Star",
            category = AchievementCategory.LOGGING
        ),

        // WEIGHT
        MLAchievement(
            id = "weight_first",
            title = "Scale Starter",
            description = "Log your first weight entry.",
            iconName = "FitnessCenter",
            category = AchievementCategory.WEIGHT
        ),
        MLAchievement(
            id = "weight_10",
            title = "Weight Watcher",
            description = "Log 10 weight entries.",
            iconName = "TrendingDown",
            category = AchievementCategory.WEIGHT
        ),

        // EXERCISE
        MLAchievement(
            id = "exercise_first",
            title = "First Workout",
            description = "Log your first exercise session.",
            iconName = "DirectionsRun",
            category = AchievementCategory.EXERCISE
        ),
        MLAchievement(
            id = "exercise_50",
            title = "Fitness Fanatic",
            description = "Log 50 exercise sessions.",
            iconName = "SportsMartialArts",
            category = AchievementCategory.EXERCISE
        ),

        // WATER
        MLAchievement(
            id = "water_8_glasses",
            title = "Hydration Hero",
            description = "Drink 8 glasses of water in a single day.",
            iconName = "WaterDrop",
            category = AchievementCategory.WATER
        ),

        // MEAL_SCAN
        MLAchievement(
            id = "scan_first",
            title = "AI Pioneer",
            description = "Use the AI meal scanner for the first time.",
            iconName = "CameraAlt",
            category = AchievementCategory.MEAL_SCAN
        ),
        MLAchievement(
            id = "scan_25",
            title = "Scan Master",
            description = "Scan 25 meals with the AI scanner.",
            iconName = "QrCodeScanner",
            category = AchievementCategory.MEAL_SCAN
        )
    )

    // Quick lookup map
    private val achievementsById: Map<String, MLAchievement> =
        allAchievements.associateBy { it.id }

    // ── State ─────────────────────────────────────────────────────────────────

    private val _unlockedIds = MutableStateFlow<Set<String>>(emptySet())
    val unlockedIds: StateFlow<Set<String>> = _unlockedIds.asStateFlow()

    private val _recentlyUnlocked = MutableSharedFlow<MLAchievement>(
        extraBufferCapacity = 8
    )
    /** Emits each achievement the moment it is first unlocked. Use for celebration UI. */
    val recentlyUnlocked: SharedFlow<MLAchievement> = _recentlyUnlocked.asSharedFlow()

    init {
        // Mirror DataStore into the StateFlow so UI always has an up-to-date snapshot.
        preferencesManager.unlockedAchievements
            .onEach { ids -> _unlockedIds.value = ids }
            .launchIn(scope)
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Evaluate [event] against all achievement conditions.
     * Any achievement that qualifies and has not yet been unlocked is persisted
     * and emitted on [recentlyUnlocked].
     */
    fun checkAndUnlock(event: AchievementEvent) {
        scope.launch {
            val candidates: List<String> = when (event) {
                is AchievementEvent.StreakUpdated -> {
                    buildList {
                        if (event.streakDays >= 1) add("streak_1_day")
                        if (event.streakDays >= 7) add("streak_7_days")
                        if (event.streakDays >= 30) add("streak_30_days")
                    }
                }
                is AchievementEvent.FoodLogged -> {
                    buildList {
                        if (event.totalLogs >= 100) add("logs_100")
                        if (event.totalLogs >= 500) add("logs_500")
                    }
                }
                is AchievementEvent.WeightLogged -> {
                    buildList {
                        if (event.totalLogs >= 1) add("weight_first")
                        if (event.totalLogs >= 10) add("weight_10")
                    }
                }
                is AchievementEvent.ExerciseLogged -> {
                    buildList {
                        if (event.totalLogs >= 1) add("exercise_first")
                        if (event.totalLogs >= 50) add("exercise_50")
                    }
                }
                is AchievementEvent.WaterGoalHit -> {
                    if (event.glassesLogged >= 8) listOf("water_8_glasses") else emptyList()
                }
                is AchievementEvent.MealScanned -> {
                    buildList {
                        if (event.totalScans >= 1) add("scan_first")
                        if (event.totalScans >= 25) add("scan_25")
                    }
                }
            }

            val currentUnlocked = _unlockedIds.value
            val newlyUnlocked = candidates.filter { it !in currentUnlocked }

            if (newlyUnlocked.isNotEmpty()) {
                preferencesManager.addUnlockedAchievements(newlyUnlocked.toSet())
                // Emit each new achievement for the celebration hook
                newlyUnlocked.forEach { id ->
                    achievementsById[id]?.let { achievement ->
                        _recentlyUnlocked.emit(achievement)
                    }
                }
            }
        }
    }
}
