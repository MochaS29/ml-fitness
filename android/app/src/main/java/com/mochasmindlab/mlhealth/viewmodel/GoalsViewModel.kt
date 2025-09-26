package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.Goal
import com.mochasmindlab.mlhealth.data.models.GoalType
import com.mochasmindlab.mlhealth.data.repository.GoalsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

@HiltViewModel
class GoalsViewModel @Inject constructor(
    private val goalsRepository: GoalsRepository
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
            val goal = Goal(
                type = type,
                title = type.displayName,
                description = getGoalDescription(type, target),
                targetValue = target.toFloatOrNull() ?: 0f,
                deadline = LocalDate.now().plusDays(durationDays.toLong()),
                isActive = true
            )
            goalsRepository.insertGoal(goal)
        }
    }

    fun toggleGoalComplete(goalId: Long) {
        viewModelScope.launch {
            val goal = _goals.value.find { it.id == goalId }
            goal?.let {
                val updatedGoal = it.copy(
                    isActive = it.isCompleted,
                    isCompleted = !it.isCompleted,
                    completedDate = if (!it.isCompleted) LocalDate.now() else null,
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
                    completedDate = if (progress >= 100) LocalDate.now() else null
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