package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.models.Gender
import com.mochasmindlab.mlhealth.data.models.RDAEntry
import com.mochasmindlab.mlhealth.data.models.RDAValues
import com.mochasmindlab.mlhealth.services.RDACalculator
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.Date
import javax.inject.Inject

@HiltViewModel
class RDAViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    private val prefs: PreferencesManager,
    private val calc: RDACalculator
) : ViewModel() {

    private val _entries = MutableStateFlow<List<RDAEntry>>(emptyList())
    val entries: StateFlow<List<RDAEntry>> = _entries.asStateFlow()

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        load()
    }

    fun refresh() {
        load()
    }

    private fun load() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                withContext(Dispatchers.IO) {
                    val profile = prefs.userProfile.first()
                    val age    = profile?.age    ?: 25
                    val gender = profile?.gender ?: Gender.FEMALE

                    val today   = dayStart(Date())
                    val entries = database.foodDao().getEntriesForDate(today)

                    // Sum all tracked nutrients, respecting servingCount.
                    // saturatedFat and cholesterol are not stored on FoodEntry —
                    // they default to 0 until the schema gains those columns.
                    var calories     = 0.0
                    var protein      = 0.0
                    var carbs        = 0.0
                    var fat          = 0.0
                    var fiber        = 0.0
                    var sugar        = 0.0
                    var sodium       = 0.0

                    for (e in entries) {
                        val sc = e.servingCount
                        calories += e.calories * sc
                        protein  += e.protein  * sc
                        carbs    += e.carbs    * sc
                        fat      += e.fat      * sc
                        fiber    += (e.fiber  ?: 0.0) * sc
                        sugar    += (e.sugar  ?: 0.0) * sc
                        sodium   += (e.sodium ?: 0.0) * sc
                    }

                    val consumed = RDAValues(
                        calories     = calories,
                        protein      = protein,
                        carbs        = carbs,
                        fat          = fat,
                        fiber        = fiber,
                        sugar        = sugar,
                        sodium       = sodium,
                        saturatedFat = 0.0,   // not tracked per-entry yet
                        cholesterol  = 0.0    // not tracked per-entry yet
                    )

                    _entries.value = calc.analyze(consumed, age, gender)
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun dayStart(date: Date): Date {
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }
}
