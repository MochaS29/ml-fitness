package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import com.mochasmindlab.mlhealth.data.entities.WaterUnit
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.screens.FoodEntryDisplay
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject

@HiltViewModel
class DiaryViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(DiaryUiState())
    val uiState: StateFlow<DiaryUiState> = _uiState.asStateFlow()
    
    init {
        loadDiaryDataInternal()
    }

    fun selectToday() {
        _uiState.value = _uiState.value.copy(selectedDate = Date())
        loadDiaryDataInternal()
    }

    fun previousDay() {
        val calendar = Calendar.getInstance()
        calendar.time = _uiState.value.selectedDate
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        _uiState.value = _uiState.value.copy(selectedDate = calendar.time)
        loadDiaryDataInternal()
    }

    fun nextDay() {
        val calendar = Calendar.getInstance()
        calendar.time = _uiState.value.selectedDate
        calendar.add(Calendar.DAY_OF_YEAR, 1)
        _uiState.value = _uiState.value.copy(selectedDate = calendar.time)
        loadDiaryDataInternal()
    }
    
    fun addWaterCup() {
        viewModelScope.launch {
            try {
                val entry = WaterEntry(
                    id = UUID.randomUUID(),
                    amount = 8.0, // 8 oz per cup
                    unit = WaterUnit.OZ,
                    timestamp = Date()
                )
                database.waterDao().insert(entry)
                loadDiaryDataInternal()
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
    
    fun removeWaterCup() {
        viewModelScope.launch {
            try {
                val currentCups = _uiState.value.waterCups
                if (currentCups > 0) {
                    // Remove last water entry for the day
                    val entries = database.waterDao().getEntriesForDate(_uiState.value.selectedDate)
                    if (entries.isNotEmpty()) {
                        database.waterDao().delete(entries.last())
                        loadDiaryDataInternal()
                    }
                }
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
    
    fun deleteFoodEntry(entry: FoodEntryDisplay) {
        viewModelScope.launch {
            try {
                // Find the actual entry by ID and delete it
                val foodEntries = database.foodDao().getEntriesForDate(_uiState.value.selectedDate)
                val entryToDelete = foodEntries.find { it.id.toString() == entry.id }
                if (entryToDelete != null) {
                    database.foodDao().delete(entryToDelete)
                    loadDiaryDataInternal()
                }
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
    
    fun loadDiaryData(date: Date = _uiState.value.selectedDate) {
        _uiState.value = _uiState.value.copy(selectedDate = date)
        loadDiaryDataInternal()
    }

    private fun loadDiaryDataInternal() {
        viewModelScope.launch {
            try {
                val date = _uiState.value.selectedDate
                
                // Load food entries
                val foodEntries = database.foodDao().getEntriesForDate(date)
                val mealEntries = mutableMapOf<MealType, List<FoodEntryDisplay>>()
                
                MealType.values().forEach { mealType ->
                    val entries = foodEntries
                        .filter { it.mealType == mealType.name.lowercase() }
                        .map { entry ->
                            FoodEntryDisplay(
                                id = entry.id.toString(),
                                name = entry.name,
                                quantity = entry.servingCount.toFloat(),
                                unit = entry.servingUnit,
                                calories = entry.calories.toInt(),
                                protein = entry.protein.toFloat(),
                                carbs = entry.carbs.toFloat(),
                                fat = entry.fat.toFloat()
                            )
                        }
                    mealEntries[mealType] = entries
                }
                
                // Calculate totals
                val totalCalories = foodEntries.sumOf { it.calories * it.servingCount }.toInt()
                val totalProtein = foodEntries.sumOf { it.protein * it.servingCount }.toFloat()
                val totalCarbs = foodEntries.sumOf { it.carbs * it.servingCount }.toFloat()
                val totalFat = foodEntries.sumOf { it.fat * it.servingCount }.toFloat()
                
                // Load water intake
                val waterIntake = database.waterDao().getTotalForDate(date) ?: 0.0
                val waterCups = (waterIntake / 8).toInt() // Convert oz to cups
                
                _uiState.value = _uiState.value.copy(
                    mealEntries = mealEntries,
                    breakfastEntries = mealEntries[MealType.BREAKFAST] ?: emptyList(),
                    lunchEntries = mealEntries[MealType.LUNCH] ?: emptyList(),
                    dinnerEntries = mealEntries[MealType.DINNER] ?: emptyList(),
                    snackEntries = mealEntries[MealType.SNACK] ?: emptyList(),
                    exerciseEntries = emptyList(), // TODO: Load from database
                    supplementEntries = emptyList(), // TODO: Load from database
                    totalCalories = totalCalories,
                    totalProtein = totalProtein,
                    totalCarbs = totalCarbs,
                    totalFat = totalFat,
                    waterCups = waterCups,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message
                )
            }
        }
    }
}

data class DiaryUiState(
    val selectedDate: Date = Date(),
    val mealEntries: Map<MealType, List<FoodEntryDisplay>> = emptyMap(),
    val breakfastEntries: List<FoodEntryDisplay> = emptyList(),
    val lunchEntries: List<FoodEntryDisplay> = emptyList(),
    val dinnerEntries: List<FoodEntryDisplay> = emptyList(),
    val snackEntries: List<FoodEntryDisplay> = emptyList(),
    val exerciseEntries: List<ExerciseEntryDisplay> = emptyList(),
    val supplementEntries: List<SupplementEntryDisplay> = emptyList(),
    val totalCalories: Int = 0,
    val totalProtein: Float = 0f,
    val totalCarbs: Float = 0f,
    val totalFat: Float = 0f,
    val caloriesGoal: Int = 2200,
    val proteinGoal: Float = 50f,
    val carbsGoal: Float = 275f,
    val fatGoal: Float = 65f,
    val waterCups: Int = 0,
    val waterGoal: Int = 8,
    val isLoading: Boolean = true,
    val error: String? = null
)

data class ExerciseEntryDisplay(
    val id: String,
    val name: String,
    val duration: Int,
    val caloriesBurned: Int
)

data class SupplementEntryDisplay(
    val id: String,
    val name: String,
    val amount: String,
    val time: String
)