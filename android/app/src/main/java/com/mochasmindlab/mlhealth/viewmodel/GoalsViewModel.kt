package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.Goal
import com.mochasmindlab.mlhealth.data.models.GoalType
import com.mochasmindlab.mlhealth.data.repository.GoalsRepository
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

@HiltViewModel
class GoalsViewModel @Inject constructor(
    private val goalsRepository: GoalsRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _goals = MutableStateFlow<List<Goal>>(emptyList())
    val goals: StateFlow<List<Goal>> = _goals.asStateFlow()

    init {
        loadGoals()
    }

    private fun loadGoals() {
        viewModelScope.launch {
            goalsRepository.getAllGoals().collect { goalsList ->
                _goals.value = goalsList
            }
        }
    }

    fun addGoal(type: GoalType, target: String, durationDays: Int) {
        viewModelScope.launch {
            val targetValue = target.toFloatOrNull() ?: 0f
            val goal = Goal(
                type = type,
                title = type.displayName,
                description = getGoalDescription(type, target),
                targetValue = targetValue,
                deadline = java.util.Date(System.currentTimeMillis() + (durationDays.toLong() * 24 * 60 * 60 * 1000)),
                isActive = true
            )
            goalsRepository.insertGoal(goal)

            // Mirror daily targets to PreferencesManager so the dashboard / reminders
            // pick up the new goal without re-querying the goals table on every read.
            // Weight goals also mirror to USER_TARGET_WEIGHT so the Weight Tracking
            // screen's "Goal" stat reflects the goal you just set on the Goals page.
            when (type) {
                GoalType.CALORIES -> preferencesManager.updateDailyCalorieGoal(targetValue.toInt())
                GoalType.WATER -> preferencesManager.updateDailyWaterGoal(targetValue.toInt())
                GoalType.EXERCISE -> preferencesManager.updateDailyExerciseGoal(targetValue.toInt())
                GoalType.WEIGHT_LOSS -> preferencesManager.setUserTargetWeight(targetValue)
                else -> Unit
            }
        }
    }

    fun toggleGoalComplete(goalId: Long) {
        viewModelScope.launch {
            val goal = _goals.value.find { it.id == goalId }
            goal?.let {
                val updatedGoal = it.copy(
                    isActive = it.isCompleted,
                    isCompleted = !it.isCompleted,
                    completedDate = if (!it.isCompleted) java.util.Date() else null,
                    progress = if (!it.isCompleted) 100 else it.progress
                )
                goalsRepository.updateGoal(updatedGoal)
            }
        }
    }

    fun deleteGoal(goalId: Long) {
        viewModelScope.launch {
            goalsRepository.deleteGoal(goalId)
        }
    }

    fun updateGoalProgress(goalId: Long, currentValue: Float) {
        viewModelScope.launch {
            val goal = _goals.value.find { it.id == goalId }
            goal?.let {
                val progress = ((currentValue / it.targetValue) * 100).coerceIn(0f, 100f).toInt()
                val updatedGoal = it.copy(
                    currentValue = currentValue,
                    progress = progress,
                    isCompleted = progress >= 100,
                    completedDate = if (progress >= 100) java.util.Date() else null
                )
                goalsRepository.updateGoal(updatedGoal)
            }
        }
    }

    private fun getGoalDescription(type: GoalType, target: String): String {
        return when (type) {
            GoalType.WEIGHT_LOSS -> "Reach $target lbs"
            GoalType.CALORIES -> "Stay under $target calories daily"
            GoalType.EXERCISE -> "Exercise $target minutes daily"
            GoalType.WATER -> "Drink $target cups of water daily"
            GoalType.STEPS -> "Walk $target steps daily"
            GoalType.NUTRITION -> "Eat $target healthy meals per week"
        }
    }
}