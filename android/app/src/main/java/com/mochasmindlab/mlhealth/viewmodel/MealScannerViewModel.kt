package com.mochasmindlab.mlhealth.viewmodel

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.FoodDao
import com.mochasmindlab.mlhealth.data.models.DetectedFood
import com.mochasmindlab.mlhealth.data.models.MealAnalysis
import com.mochasmindlab.mlhealth.services.BillingManager
import com.mochasmindlab.mlhealth.services.MealAnalysisService
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class ScanPhase { Idle, Capturing, Analyzing, Results, Error, Paywall }

@HiltViewModel
class MealScannerViewModel @Inject constructor(
    private val mealAnalysisService: MealAnalysisService,
    private val foodDao: FoodDao,
    private val preferencesManager: PreferencesManager,
    private val billingManager: BillingManager
) : ViewModel() {

    /** Number of free scans before the paywall kicks in, matching the iOS quota. */
    private val freeScanLimit = 3

    val mealScanCount: StateFlow<Int> = preferencesManager.mealScanCount
        .stateIn(viewModelScope, SharingStarted.Eagerly, 0)

    val isPro: StateFlow<Boolean> = billingManager.isProUser

    val freeScansRemaining: Int
        get() = (freeScanLimit - mealScanCount.value).coerceAtLeast(0)

    private val _phase = MutableStateFlow(ScanPhase.Idle)
    val phase: StateFlow<ScanPhase> = _phase.asStateFlow()

    private val _analysis = MutableStateFlow<MealAnalysis?>(null)
    val analysis: StateFlow<MealAnalysis?> = _analysis.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _selectedMealType = MutableStateFlow("snack")
    val selectedMealType: StateFlow<String> = _selectedMealType.asStateFlow()

    // Editable items mirror the analysis results; user can tweak before saving.
    private val _editableItems = MutableStateFlow<List<DetectedFood>>(emptyList())
    val editableItems: StateFlow<List<DetectedFood>> = _editableItems.asStateFlow()

    fun analyze(bitmap: Bitmap) {
        viewModelScope.launch {
            // Pro users have unlimited scans; free users get [freeScanLimit] before paywall.
            if (!isPro.value && mealScanCount.first() >= freeScanLimit) {
                _phase.value = ScanPhase.Paywall
                return@launch
            }

            _phase.value = ScanPhase.Analyzing
            _errorMessage.value = null

            mealAnalysisService.analyzeMealPhoto(bitmap)
                .onSuccess { result ->
                    _analysis.value = result
                    _editableItems.value = result.items.toMutableList()
                    _phase.value = ScanPhase.Results
                    if (!isPro.value) preferencesManager.incrementMealScanCount()
                }
                .onFailure { err ->
                    _errorMessage.value = err.message ?: "An unexpected error occurred"
                    _phase.value = ScanPhase.Error
                }
        }
    }

    fun updateItem(index: Int, updated: DetectedFood) {
        val current = _editableItems.value.toMutableList()
        if (index in current.indices) {
            current[index] = updated
            _editableItems.value = current
        }
    }

    fun selectMealType(type: String) {
        _selectedMealType.value = type.lowercase()
    }

    fun saveToDiary() {
        val items = _editableItems.value
        if (items.isEmpty()) return

        viewModelScope.launch {
            val totalCalories = items.sumOf { it.calories }.toInt()
            val syntheticAnalysis = MealAnalysis(
                items = items,
                totalCalories = totalCalories,
                confidence = _analysis.value?.confidence ?: 0.0
            )
            mealAnalysisService.saveAnalysisToDiary(
                analysis = syntheticAnalysis,
                mealType = _selectedMealType.value,
                foodDao = foodDao
            )
            reset()
        }
    }

    fun reset() {
        _phase.value = ScanPhase.Idle
        _analysis.value = null
        _editableItems.value = emptyList()
        _errorMessage.value = null
    }
}
