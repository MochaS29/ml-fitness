package com.mlhealth.app.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mlhealth.app.data.Supplement
import com.mlhealth.app.data.local.MLFitnessDatabase
import com.mlhealth.app.data.local.SupplementEntryEntity
import com.mlhealth.app.ui.screens.SupplementEntry
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class SupplementViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    private val _supplements = MutableStateFlow<List<SupplementEntry>>(emptyList())
    val supplements: StateFlow<List<SupplementEntry>> = _supplements.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        loadSupplements()
    }

    private fun loadSupplements() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                database.supplementEntryDao().getAllSupplementEntries()
                    .collect { entities ->
                        _supplements.value = entities.map { entity ->
                            entity.toSupplementEntry()
                        }
                    }
            } catch (e: Exception) {
                _errorMessage.value = "Failed to load supplements: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun addSupplement(supplement: Supplement) {
        viewModelScope.launch {
            try {
                val nutrients = mutableMapOf<String, Double>()

                // Add vitamins
                with(supplement.vitamins) {
                    if (vitaminA > 0) nutrients["Vitamin A"] = vitaminA
                    if (vitaminC > 0) nutrients["Vitamin C"] = vitaminC
                    if (vitaminD > 0) nutrients["Vitamin D"] = vitaminD
                    if (vitaminE > 0) nutrients["Vitamin E"] = vitaminE
                    if (vitaminK > 0) nutrients["Vitamin K"] = vitaminK
                    if (thiamine > 0) nutrients["Thiamine"] = thiamine
                    if (riboflavin > 0) nutrients["Riboflavin"] = riboflavin
                    if (niacin > 0) nutrients["Niacin"] = niacin
                    if (vitaminB6 > 0) nutrients["Vitamin B6"] = vitaminB6
                    if (folate > 0) nutrients["Folate"] = folate
                    if (vitaminB12 > 0) nutrients["Vitamin B12"] = vitaminB12
                    if (biotin > 0) nutrients["Biotin"] = biotin
                    if (pantothenicAcid > 0) nutrients["Pantothenic Acid"] = pantothenicAcid
                }

                // Add minerals
                with(supplement.minerals) {
                    if (calcium > 0) nutrients["Calcium"] = calcium
                    if (iron > 0) nutrients["Iron"] = iron
                    if (magnesium > 0) nutrients["Magnesium"] = magnesium
                    if (phosphorus > 0) nutrients["Phosphorus"] = phosphorus
                    if (potassium > 0) nutrients["Potassium"] = potassium
                    if (sodium > 0) nutrients["Sodium"] = sodium
                    if (zinc > 0) nutrients["Zinc"] = zinc
                    if (copper > 0) nutrients["Copper"] = copper
                    if (manganese > 0) nutrients["Manganese"] = manganese
                    if (selenium > 0) nutrients["Selenium"] = selenium
                    if (chromium > 0) nutrients["Chromium"] = chromium
                    if (molybdenum > 0) nutrients["Molybdenum"] = molybdenum
                    if (iodine > 0) nutrients["Iodine"] = iodine
                }

                val entry = SupplementEntryEntity(
                    id = UUID.randomUUID().toString(),
                    name = supplement.name,
                    brand = supplement.brand,
                    category = supplement.category,
                    servingSize = supplement.servingSize,
                    timestamp = LocalDateTime.now(),
                    nutrients = nutrients,
                    barcode = supplement.barcode,
                    dpn = supplement.dpn
                )

                database.supplementEntryDao().insertSupplementEntry(entry)

                // Update local state
                val newEntry = entry.toSupplementEntry()
                _supplements.value = _supplements.value + newEntry

            } catch (e: Exception) {
                _errorMessage.value = "Failed to add supplement: ${e.message}"
            }
        }
    }

    fun deleteSupplement(supplement: SupplementEntry) {
        viewModelScope.launch {
            try {
                database.supplementEntryDao().deleteSupplementEntry(supplement.id)

                // Update local state
                _supplements.value = _supplements.value.filter { it.id != supplement.id }

            } catch (e: Exception) {
                _errorMessage.value = "Failed to delete supplement: ${e.message}"
            }
        }
    }

    fun getSupplementsByDate(date: LocalDateTime): List<SupplementEntry> {
        return supplements.value.filter { supplement ->
            supplement.date.toLocalDate() == date.toLocalDate()
        }
    }

    fun getTodaysSupplements(): List<SupplementEntry> {
        return getSupplementsByDate(LocalDateTime.now())
    }

    fun getNutrientTotals(date: LocalDateTime? = null): Map<String, Double> {
        val supplementsToAnalyze = if (date != null) {
            getSupplementsByDate(date)
        } else {
            getTodaysSupplements()
        }

        val totals = mutableMapOf<String, Double>()

        supplementsToAnalyze.forEach { supplement ->
            supplement.nutrients.forEach { (nutrient, amount) ->
                totals[nutrient] = (totals[nutrient] ?: 0.0) + amount
            }
        }

        return totals
    }

    fun clearError() {
        _errorMessage.value = null
    }
}

// Extension function to convert entity to domain model
fun SupplementEntryEntity.toSupplementEntry(): SupplementEntry {
    return SupplementEntry(
        id = this.id,
        name = this.name,
        brand = this.brand,
        date = this.timestamp,
        nutrients = this.nutrients,
        barcode = this.barcode
    )
}