package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.*
import com.mochasmindlab.mlhealth.data.models.Achievement
import com.mochasmindlab.mlhealth.data.models.AchievementType
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()
    
    private val _aiInsights = MutableStateFlow<List<AIInsight>>(emptyList())
    val aiInsights: StateFlow<List<AIInsight>> = _aiInsights.asStateFlow()
    
    init {
        loadDashboardData()
        generateAIInsights()
    }
    
    private fun loadDashboardData() {
        viewModelScope.launch {
            try {
                val today = Date()
                
                // Load calories - these might be null initially
                val totalCalories = try {
                    database.foodDao().getTotalCaloriesForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                // Load water
                val waterIntake = try {
                    database.waterDao().getTotalForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                // Load exercise
                val exerciseMinutes = try {
                    database.exerciseDao().getTotalDurationForDate(today) ?: 0
                } catch (e: Exception) {
                    0
                }
                
                // Load weight
                val latestWeight = try {
                    database.weightDao().getLatestEntry()
                } catch (e: Exception) {
                    null
                }
                
                _uiState.value = DashboardUiState(
                    userName = "You", // Default name until loaded from preferences
                    caloriesConsumed = totalCalories.toInt(),
                    caloriesGoal = 2200,
                    waterCups = (waterIntake / 8).toInt(), // Convert oz to cups
                    waterGoal = 8,
                    exerciseMinutes = exerciseMinutes,
                    exerciseGoal = 60,
                    currentWeight = latestWeight?.weight ?: 70.0,
                    selectedPeriod = DashboardPeriod.DAY
                )
            } catch (e: Exception) {
                // Handle any database errors gracefully
                _uiState.value = DashboardUiState(
                    userName = "You",
                    caloriesConsumed = 0,
                    caloriesGoal = 2200,
                    waterCups = 0,
                    waterGoal = 8,
                    exerciseMinutes = 0,
                    exerciseGoal = 60,
                    currentWeight = 70.0,
                    selectedPeriod = DashboardPeriod.DAY
                )
            }
        }
    }
    
    private fun generateAIInsights() {
        viewModelScope.launch {
            try {
                val insights = mutableListOf<AIInsight>()
                
                // Check hydration
                val waterIntake = try {
                    database.waterDao().getTotalForDate(Date()) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                if (waterIntake < 64) { // Less than 8 cups (64 oz)
                    val percentage = if (waterIntake > 0) ((waterIntake / 64) * 100).toInt() else 0
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Hydration Alert",
                            description = "You're ${100 - percentage}% below your daily water goal",
                            type = InsightType.HYDRATION,
                            priority = if (percentage < 30) InsightPriority.HIGH else InsightPriority.MEDIUM
                        )
                    )
                }
                
                // Check calorie balance
                val calories = try {
                    database.foodDao().getTotalCaloriesForDate(Date()) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                if (calories > 2200) {
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Calorie Alert",
                            description = "You've exceeded your daily calorie goal",
                            type = InsightType.NUTRITION,
                            priority = InsightPriority.MEDIUM
                        )
                    )
                }
                
                // Check exercise
                val exerciseMinutes = try {
                    database.exerciseDao().getTotalDurationForDate(Date()) ?: 0
                } catch (e: Exception) {
                    0
                }
                
                if (exerciseMinutes < 30) {
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Movement Reminder",
                            description = "Time to get moving! Only ${30 - exerciseMinutes} minutes to reach your goal",
                            type = InsightType.EXERCISE,
                            priority = InsightPriority.LOW
                        )
                    )
                }
                
                _aiInsights.value = insights
            } catch (e: Exception) {
                // If there's an error, just set empty insights
                _aiInsights.value = emptyList()
            }
        }
    }
    
    fun selectPeriod(period: DashboardPeriod) {
        _uiState.value = _uiState.value.copy(selectedPeriod = period)
        // Reload data for selected period
        when (period) {
            DashboardPeriod.DAY -> loadDashboardData()
            DashboardPeriod.WEEK -> loadWeekData()
            DashboardPeriod.MONTH -> loadMonthData()
        }
    }
    
    private fun loadWeekData() {
        viewModelScope.launch {
            // TODO: Implement week data aggregation
        }
    }
    
    private fun loadMonthData() {
        viewModelScope.launch {
            // TODO: Implement month data aggregation
        }
    }
    
    fun refreshData() {
        loadDashboardData()
        generateAIInsights()
    }
}

data class DashboardUiState(
    val userName: String = "",
    val caloriesConsumed: Int = 0,
    val caloriesGoal: Int = 2200,
    val waterCups: Int = 0,
    val waterGoal: Int = 8,
    val exerciseMinutes: Int = 0,
    val exerciseGoal: Int = 60,
    val currentWeight: Double = 0.0,
    val selectedPeriod: DashboardPeriod = DashboardPeriod.DAY,
    val isLoading: Boolean = false
)

enum class DashboardPeriod {
    DAY, WEEK, MONTH
}

data class AIInsight(
    val id: String,
    val title: String,
    val description: String,
    val type: InsightType,
    val priority: InsightPriority
)

enum class InsightType {
    NUTRITION, HYDRATION, EXERCISE, WEIGHT, SLEEP, GENERAL
}

enum class InsightPriority {
    LOW, MEDIUM, HIGH
}