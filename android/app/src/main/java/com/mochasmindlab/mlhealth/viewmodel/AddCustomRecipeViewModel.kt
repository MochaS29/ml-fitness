package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.CustomRecipe
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
class AddCustomRecipeViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    data class FormState(
        val name: String = "",
        val description: String = "",
        val category: String = "Dinner",
        val prepTime: Int = 15,
        val cookTime: Int = 30,
        val servings: Int = 4,
        val ingredients: List<String> = emptyList(),
        val instructions: List<String> = emptyList(),
        val caloriesStr: String = "",
        val proteinStr: String = "",
        val carbsStr: String = "",
        val fatStr: String = "",
        val fiberStr: String = "",
        val sugarStr: String = "",
        val sodiumStr: String = "",
        val tags: List<String> = emptyList(),
        val nameError: String? = null,
        val isSaving: Boolean = false,
        val savedSuccessfully: Boolean = false,
        val errorMessage: String? = null
    )

    private val _state = MutableStateFlow(FormState())
    val state: StateFlow<FormState> = _state.asStateFlow()

    // ---------- Field setters ----------

    fun setName(v: String)        { _state.value = _state.value.copy(name = v, nameError = null) }
    fun setDescription(v: String) { _state.value = _state.value.copy(description = v) }
    fun setCategory(v: String)    { _state.value = _state.value.copy(category = v) }
    fun setPrepTime(v: Int)       { _state.value = _state.value.copy(prepTime = v.coerceIn(0, 300)) }
    fun setCookTime(v: Int)       { _state.value = _state.value.copy(cookTime = v.coerceIn(0, 300)) }
    fun setServings(v: Int)       { _state.value = _state.value.copy(servings = v.coerceIn(1, 20)) }
    fun setCalories(v: String)    { _state.value = _state.value.copy(caloriesStr = v) }
    fun setProtein(v: String)     { _state.value = _state.value.copy(proteinStr = v) }
    fun setCarbs(v: String)       { _state.value = _state.value.copy(carbsStr = v) }
    fun setFat(v: String)         { _state.value = _state.value.copy(fatStr = v) }
    fun setFiber(v: String)       { _state.value = _state.value.copy(fiberStr = v) }
    fun setSugar(v: String)       { _state.value = _state.value.copy(sugarStr = v) }
    fun setSodium(v: String)      { _state.value = _state.value.copy(sodiumStr = v) }

    // ---------- Ingredient list ----------

    fun addIngredient(text: String) {
        if (text.isBlank()) return
        _state.value = _state.value.copy(ingredients = _state.value.ingredients + text.trim())
    }

    fun updateIngredient(index: Int, text: String) {
        val updated = _state.value.ingredients.toMutableList()
        if (index in updated.indices) { updated[index] = text }
        _state.value = _state.value.copy(ingredients = updated)
    }

    fun removeIngredient(index: Int) {
        _state.value = _state.value.copy(
            ingredients = _state.value.ingredients.filterIndexed { i, _ -> i != index }
        )
    }

    // ---------- Instruction list ----------

    fun addInstruction(text: String) {
        _state.value = _state.value.copy(instructions = _state.value.instructions + text)
    }

    fun updateInstruction(index: Int, text: String) {
        val updated = _state.value.instructions.toMutableList()
        if (index in updated.indices) { updated[index] = text }
        _state.value = _state.value.copy(instructions = updated)
    }

    fun removeInstruction(index: Int) {
        _state.value = _state.value.copy(
            instructions = _state.value.instructions.filterIndexed { i, _ -> i != index }
        )
    }

    // ---------- Tags ----------

    fun addTag(tag: String) {
        if (tag.isBlank()) return
        val trimmed = tag.trim()
        if (_state.value.tags.none { it.equals(trimmed, ignoreCase = true) }) {
            _state.value = _state.value.copy(tags = _state.value.tags + trimmed)
        }
    }

    fun removeTag(tag: String) {
        _state.value = _state.value.copy(tags = _state.value.tags.filter { it != tag })
    }

    // ---------- Save ----------

    /**
     * Validates and inserts the recipe. Returns true immediately if validation passes;
     * check [FormState.savedSuccessfully] to know when the DB write completes.
     */
    fun save(): Boolean {
        val s = _state.value
        if (s.name.isBlank()) {
            _state.value = s.copy(nameError = "Recipe name is required")
            return false
        }
        _state.value = s.copy(isSaving = true, errorMessage = null)

        val recipe = CustomRecipe(
            id           = UUID.randomUUID(),
            name         = s.name.trim(),
            category     = s.category,
            source       = "user-created",
            isUserCreated = true,
            isFavorite   = false,
            createdDate  = Date(),
            prepTime     = s.prepTime,
            cookTime     = s.cookTime,
            servings     = s.servings,
            ingredients  = s.ingredients.filter { it.isNotBlank() },
            instructions = s.instructions.filter { it.isNotBlank() },
            tags         = s.tags,
            calories     = s.caloriesStr.toDoubleOrNull() ?: 0.0,
            protein      = s.proteinStr.toDoubleOrNull() ?: 0.0,
            carbs        = s.carbsStr.toDoubleOrNull() ?: 0.0,
            fat          = s.fatStr.toDoubleOrNull() ?: 0.0,
            fiber        = s.fiberStr.toDoubleOrNull(),
            sugar        = s.sugarStr.toDoubleOrNull(),
            sodium       = s.sodiumStr.toDoubleOrNull()
        )

        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) { database.customRecipeDao().insert(recipe) }
                _state.value = _state.value.copy(isSaving = false, savedSuccessfully = true)
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    isSaving = false,
                    errorMessage = "Failed to save: ${e.message}"
                )
            }
        }
        return true
    }
}
