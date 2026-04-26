package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.CustomFood
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Date
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class AddCustomFoodViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    data class FormState(
        val name: String = "",
        val brand: String = "",
        val servingSize: String = "",
        val servingUnit: String = "g",
        val calories: String = "",
        val protein: String = "",
        val carbs: String = "",
        val fat: String = "",
        val fiber: String = "",
        val sugar: String = "",
        val sodium: String = "",
        val isSaving: Boolean = false,
        val savedSuccessfully: Boolean = false,
        val errorMessage: String? = null,
        // Validation errors
        val nameError: String? = null,
        val servingSizeError: String? = null,
        val caloriesError: String? = null
    )

    private val _formState = MutableStateFlow(FormState())
    val formState: StateFlow<FormState> = _formState.asStateFlow()

    fun updateName(value: String) {
        _formState.value = _formState.value.copy(name = value, nameError = null)
    }

    fun updateBrand(value: String) {
        _formState.value = _formState.value.copy(brand = value)
    }

    fun updateServingSize(value: String) {
        _formState.value = _formState.value.copy(servingSize = value, servingSizeError = null)
    }

    fun updateServingUnit(value: String) {
        _formState.value = _formState.value.copy(servingUnit = value)
    }

    fun updateCalories(value: String) {
        _formState.value = _formState.value.copy(calories = value, caloriesError = null)
    }

    fun updateProtein(value: String) {
        _formState.value = _formState.value.copy(protein = value)
    }

    fun updateCarbs(value: String) {
        _formState.value = _formState.value.copy(carbs = value)
    }

    fun updateFat(value: String) {
        _formState.value = _formState.value.copy(fat = value)
    }

    fun updateFiber(value: String) {
        _formState.value = _formState.value.copy(fiber = value)
    }

    fun updateSugar(value: String) {
        _formState.value = _formState.value.copy(sugar = value)
    }

    fun updateSodium(value: String) {
        _formState.value = _formState.value.copy(sodium = value)
    }

    fun clearError() {
        _formState.value = _formState.value.copy(errorMessage = null)
    }

    private fun validate(): Boolean {
        val state = _formState.value
        var isValid = true

        if (state.name.isBlank()) {
            _formState.value = _formState.value.copy(nameError = "Name is required")
            isValid = false
        }
        if (state.servingSize.isBlank() || state.servingSize.toDoubleOrNull() == null) {
            _formState.value = _formState.value.copy(servingSizeError = "Enter a valid serving size")
            isValid = false
        }
        if (state.calories.isBlank() || state.calories.toDoubleOrNull() == null) {
            _formState.value = _formState.value.copy(caloriesError = "Enter valid calories")
            isValid = false
        }

        return isValid
    }

    /**
     * Validates and saves the custom food to the database.
     * Returns true if the save was initiated successfully so the screen can pop back.
     * Actual navigation should wait for [FormState.savedSuccessfully] to become true.
     */
    fun save(): Boolean {
        if (!validate()) return false

        val state = _formState.value
        _formState.value = state.copy(isSaving = true, errorMessage = null)

        val food = CustomFood(
            id = UUID.randomUUID(),
            name = state.name.trim(),
            brand = state.brand.takeIf { it.isNotBlank() },
            servingSize = state.servingSize.trim(),
            servingUnit = state.servingUnit.trim(),
            calories = state.calories.toDoubleOrNull() ?: 0.0,
            protein = state.protein.toDoubleOrNull() ?: 0.0,
            carbs = state.carbs.toDoubleOrNull() ?: 0.0,
            fat = state.fat.toDoubleOrNull() ?: 0.0,
            fiber = state.fiber.toDoubleOrNull(),
            sugar = state.sugar.toDoubleOrNull(),
            sodium = state.sodium.toDoubleOrNull(),
            isUserCreated = true,
            createdDate = Date()
        )

        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    database.customFoodDao().insert(food)
                }
                _formState.value = _formState.value.copy(isSaving = false, savedSuccessfully = true)
            } catch (e: Exception) {
                _formState.value = _formState.value.copy(
                    isSaving = false,
                    errorMessage = "Failed to save: ${e.message}"
                )
            }
        }

        return true
    }
}
