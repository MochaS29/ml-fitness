package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.DietPlan
import com.mochasmindlab.mlhealth.data.models.PlanRecipe
import com.mochasmindlab.mlhealth.services.MealPlanLoader
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.Date
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class MealPlanViewModel @Inject constructor(
    private val loader: MealPlanLoader,
    private val database: MLFitnessDatabase
) : ViewModel() {

    private val _state = MutableStateFlow(MealPlanUiState())
    val state: StateFlow<MealPlanUiState> = _state.asStateFlow()

    private val _toast = MutableSharedFlow<String>(extraBufferCapacity = 1)
    val toast: SharedFlow<String> = _toast.asSharedFlow()

    init {
        loadDiets()
    }

    private fun loadDiets() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            val diets = loader.loadAll()
            _state.value = _state.value.copy(
                diets = diets,
                selectedDiet = diets.firstOrNull(),
                selectedWeekIndex = 0,
                selectedDayIndex = 0,
                isLoading = false
            )
        }
    }

    fun selectDiet(dietId: String) {
        val diet = _state.value.diets.firstOrNull { it.id == dietId } ?: return
        _state.value = _state.value.copy(
            selectedDiet = diet,
            selectedWeekIndex = 0,
            selectedDayIndex = 0
        )
    }

    fun selectWeek(index: Int) {
        _state.value = _state.value.copy(selectedWeekIndex = index, selectedDayIndex = 0)
    }

    fun selectDay(index: Int) {
        _state.value = _state.value.copy(selectedDayIndex = index)
    }

    /**
     * Logs the given meal-plan recipe as a FoodEntry on the chosen date + meal type with serving count.
     * Mirrors iOS "Log This Meal" on ProfessionalRecipeDetailView.
     */
    fun logRecipeToDiary(
        recipe: PlanRecipe,
        mealType: String,
        servings: Double = 1.0,
        date: Date = startOfDay(Date())
    ) {
        viewModelScope.launch {
            withContext(Dispatchers.IO) {
                val entry = FoodEntry(
                    id = UUID.randomUUID(),
                    name = recipe.name,
                    brand = null,
                    barcode = null,
                    date = startOfDay(date),
                    timestamp = Date(),
                    mealType = mealType.lowercase(),
                    servingSize = "1",
                    servingUnit = "serving",
                    servingCount = servings,
                    calories = recipe.calories.toDouble(),
                    protein = recipe.protein,
                    carbs = recipe.carbs,
                    fat = recipe.fat,
                    fiber = recipe.fiber,
                    sugar = null,
                    sodium = null
                )
                database.foodDao().insert(entry)
            }
            _toast.tryEmit("Added to ${mealType.replaceFirstChar { it.uppercase() }}")
        }
    }

    private fun startOfDay(date: Date): Date {
        val cal = Calendar.getInstance().apply {
            time = date
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return cal.time
    }
}

data class MealPlanUiState(
    val diets: List<DietPlan> = emptyList(),
    val selectedDiet: DietPlan? = null,
    val selectedWeekIndex: Int = 0,
    val selectedDayIndex: Int = 0,
    val isLoading: Boolean = true
) {
    val selectedWeek get() = selectedDiet?.weeks?.getOrNull(selectedWeekIndex)
    val selectedDay get() = selectedWeek?.days?.getOrNull(selectedDayIndex)
}
