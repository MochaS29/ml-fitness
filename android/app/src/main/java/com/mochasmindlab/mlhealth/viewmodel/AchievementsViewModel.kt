package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.AchievementCategory
import com.mochasmindlab.mlhealth.data.models.MLAchievement
import com.mochasmindlab.mlhealth.services.AchievementManager
import com.mochasmindlab.mlhealth.services.LoggingStreakManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import javax.inject.Inject

/**
 * ViewModel powering AchievementsScreen.
 *
 * Exposes:
 *   - [uiState] — grouped achievements with unlock status, counts, and current streak.
 */
@HiltViewModel
class AchievementsViewModel @Inject constructor(
    private val achievementManager: AchievementManager,
    private val loggingStreakManager: LoggingStreakManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(AchievementsUiState())
    val uiState: StateFlow<AchievementsUiState> = _uiState.asStateFlow()

    init {
        combine(
            achievementManager.unlockedIds,
            loggingStreakManager.currentStreak
        ) { unlockedIds, streak ->
            val allAchievements = achievementManager.allAchievements

            // Build (achievement, isUnlocked) pairs grouped by category
            val grouped: Map<AchievementCategory, List<Pair<MLAchievement, Boolean>>> =
                AchievementCategory.values().associateWith { category ->
                    allAchievements
                        .filter { it.category == category }
                        .map { achievement ->
                            achievement to (achievement.id in unlockedIds)
                        }
                }

            AchievementsUiState(
                groupedAchievements = grouped,
                totalUnlocked = unlockedIds.size,
                totalAchievements = allAchievements.size,
                currentStreak = streak
            )
        }
        .onEach { state -> _uiState.value = state }
        .launchIn(viewModelScope)
    }
}

data class AchievementsUiState(
    /** All achievements grouped by category, each paired with its unlock status. */
    val groupedAchievements: Map<AchievementCategory, List<Pair<MLAchievement, Boolean>>> = emptyMap(),
    val totalUnlocked: Int = 0,
    val totalAchievements: Int = 0,
    val currentStreak: Int = 0
)
