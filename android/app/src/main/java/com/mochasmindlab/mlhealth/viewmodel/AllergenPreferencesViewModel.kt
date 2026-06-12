package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.DietaryPreference
import com.mochasmindlab.mlhealth.data.models.FoodAllergy
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for [AllergenPreferencesScreen].
 *
 * Persists the user's allergen selection as a [Set<String>] in DataStore
 * (via [PreferencesManager.allergens]) and exposes it as a typed
 * [StateFlow<Set<FoodAllergy>>] by mapping each stored string back to the
 * [FoodAllergy] enum.  Unknown / stale enum values are silently discarded
 * to stay forward-compatible with future data-model changes.
 */
@HiltViewModel
class AllergenPreferencesViewModel @Inject constructor(
    private val prefs: PreferencesManager
) : ViewModel() {

    /** Currently selected allergens, derived from the DataStore-backed string set. */
    val selected: StateFlow<Set<FoodAllergy>> = prefs.allergens
        .map { stringSet ->
            stringSet.mapNotNull { name ->
                runCatching { FoodAllergy.valueOf(name) }.getOrNull()
            }.toSet()
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptySet()
        )

    /**
     * Toggle [allergy] in the persisted set.
     * If it is already selected it will be removed; otherwise it will be added.
     * The DataStore write happens on the ViewModel's scope — callers do not
     * need to handle the suspend themselves.
     */
    fun toggle(allergy: FoodAllergy) {
        viewModelScope.launch {
            val current = selected.value
            val updated = if (allergy in current) {
                current - allergy
            } else {
                current + allergy
            }
            prefs.setAllergens(updated.map { it.name }.toSet())
        }
    }

    /** Currently selected dietary preferences (vegan, keto, etc.), derived from DataStore. */
    val dietaryPreferences: StateFlow<Set<DietaryPreference>> = prefs.dietaryPreferences
        .map { stringSet ->
            stringSet.mapNotNull { name ->
                runCatching { DietaryPreference.valueOf(name) }.getOrNull()
            }.toSet()
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptySet()
        )

    fun toggleDietaryPreference(pref: DietaryPreference) {
        viewModelScope.launch {
            val current = dietaryPreferences.value
            val updated = if (pref in current) current - pref else current + pref
            prefs.setDietaryPreferences(updated.map { it.name }.toSet())
        }
    }
}
