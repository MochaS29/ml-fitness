package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry
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
class CopyFromPreviousDayViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    private val _selectedSourceDate = MutableStateFlow(yesterday())
    val selectedSourceDate: StateFlow<Date> = _selectedSourceDate.asStateFlow()

    private val _targetDate = MutableStateFlow(today())
    val targetDate: StateFlow<Date> = _targetDate.asStateFlow()

    private val _foodEntries = MutableStateFlow<List<FoodEntry>>(emptyList())
    val foodEntries: StateFlow<List<FoodEntry>> = _foodEntries.asStateFlow()

    private val _supplementEntries = MutableStateFlow<List<SupplementEntry>>(emptyList())
    val supplementEntries: StateFlow<List<SupplementEntry>> = _supplementEntries.asStateFlow()

    private val _selectedFoodIds = MutableStateFlow<Set<UUID>>(emptySet())
    val selectedFoodIds: StateFlow<Set<UUID>> = _selectedFoodIds.asStateFlow()

    private val _selectedSupplementIds = MutableStateFlow<Set<UUID>>(emptySet())
    val selectedSupplementIds: StateFlow<Set<UUID>> = _selectedSupplementIds.asStateFlow()

    private val _isCopying = MutableStateFlow(false)
    val isCopying: StateFlow<Boolean> = _isCopying.asStateFlow()

    private val _done = MutableSharedFlow<Int>()
    val done: SharedFlow<Int> = _done.asSharedFlow()

    init {
        loadSourceEntries()
    }

    fun setTargetDate(date: Date) {
        _targetDate.value = date
    }

    fun setSourceDate(date: Date) {
        _selectedSourceDate.value = date
        _selectedFoodIds.value = emptySet()
        _selectedSupplementIds.value = emptySet()
        loadSourceEntries()
    }

    fun toggleFood(id: UUID) {
        val current = _selectedFoodIds.value.toMutableSet()
        if (id in current) current.remove(id) else current.add(id)
        _selectedFoodIds.value = current
    }

    fun toggleSupplement(id: UUID) {
        val current = _selectedSupplementIds.value.toMutableSet()
        if (id in current) current.remove(id) else current.add(id)
        _selectedSupplementIds.value = current
    }

    fun selectAllForMeal(mealType: String) {
        val ids = _foodEntries.value
            .filter { it.mealType.equals(mealType, ignoreCase = true) }
            .map { it.id }
            .toSet()
        _selectedFoodIds.value = _selectedFoodIds.value + ids
    }

    fun deselectAllForMeal(mealType: String) {
        val ids = _foodEntries.value
            .filter { it.mealType.equals(mealType, ignoreCase = true) }
            .map { it.id }
            .toSet()
        _selectedFoodIds.value = _selectedFoodIds.value - ids
    }

    fun selectAll() {
        _selectedFoodIds.value = _foodEntries.value.map { it.id }.toSet()
        _selectedSupplementIds.value = _supplementEntries.value.map { it.id }.toSet()
    }

    fun selectNone() {
        _selectedFoodIds.value = emptySet()
        _selectedSupplementIds.value = emptySet()
    }

    fun copy(targetDate: Date) {
        val foodIds = _selectedFoodIds.value
        val suppIds = _selectedSupplementIds.value
        if (foodIds.isEmpty() && suppIds.isEmpty()) return

        viewModelScope.launch {
            _isCopying.value = true
            var count = 0
            withContext(Dispatchers.IO) {
                val now = Date()
                _foodEntries.value
                    .filter { it.id in foodIds }
                    .forEach { entry ->
                        database.foodDao().insert(
                            entry.copy(id = UUID.randomUUID(), date = targetDate, timestamp = now)
                        )
                        count++
                    }
                _supplementEntries.value
                    .filter { it.id in suppIds }
                    .forEach { entry ->
                        database.supplementDao().insert(
                            entry.copy(id = UUID.randomUUID(), date = targetDate, timestamp = now)
                        )
                        count++
                    }
            }
            _isCopying.value = false
            _done.emit(count)
        }
    }

    private fun loadSourceEntries() {
        viewModelScope.launch {
            val date = _selectedSourceDate.value
            withContext(Dispatchers.IO) {
                val foods = database.foodDao().getEntriesForDate(date)
                val supps = database.supplementDao().getEntriesForDate(date)
                _foodEntries.value = foods
                _supplementEntries.value = supps
            }
        }
    }

    private fun yesterday(): Date = Calendar.getInstance().apply {
        add(Calendar.DAY_OF_YEAR, -1)
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }.time

    private fun today(): Date = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
    }.time
}
