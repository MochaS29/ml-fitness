package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.DietPlan
import com.mochasmindlab.mlhealth.services.MealPlanLoader
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MealPlanViewModel @Inject constructor(
    private val loader: MealPlanLoader
) : ViewModel() {

    private val _state = MutableStateFlow(MealPlanUiState())
    val state: StateFlow<MealPlanUiState> = _state.asStateFlow()

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
