package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry
import com.mochasmindlab.mlhealth.data.entities.SupplementRegime
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject

@HiltViewModel
class SupplementRegimeViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(SupplementRegimeUiState())
    val uiState: StateFlow<SupplementRegimeUiState> = _uiState.asStateFlow()
    
    init {
        loadRegimes()
    }
    
    private fun loadRegimes() {
        viewModelScope.launch {
            // Note: We'll need to add the SupplementRegimeDao to the database
            // For now, using in-memory storage
            // database.supplementRegimeDao().getAllRegimes().collect { regimes ->
            //     _uiState.update { state ->
            //         state.copy(
            //             activeRegimes = regimes.filter { it.isActive },
            //             inactiveRegimes = regimes.filter { !it.isActive }
            //         )
            //     }
            // }
        }
    }
    
    fun addRegime(regime: SupplementRegime) {
        viewModelScope.launch {
            // Add to in-memory storage for now
            _uiState.update { state ->
                state.copy(
                    activeRegimes = if (regime.isActive) {
                        state.activeRegimes + regime
                    } else {
                        state.activeRegimes
                    },
                    inactiveRegimes = if (!regime.isActive) {
                        state.inactiveRegimes + regime
                    } else {
                        state.inactiveRegimes
                    }
                )
            }
            // database.supplementRegimeDao().insert(regime)
        }
    }
    
    fun updateRegime(regime: SupplementRegime) {
        viewModelScope.launch {
            // Update in-memory storage
            _uiState.update { state ->
                state.copy(
                    activeRegimes = state.activeRegimes.map { 
                        if (it.id == regime.id) regime else it 
                    }.filter { it.isActive },
                    inactiveRegimes = state.inactiveRegimes.map { 
                        if (it.id == regime.id) regime else it 
                    }.filter { !it.isActive }
                )
            }
            // database.supplementRegimeDao().update(regime)
        }
    }
    
    fun deleteRegime(regime: SupplementRegime) {
        viewModelScope.launch {
            _uiState.update { state ->
                state.copy(
                    activeRegimes = state.activeRegimes.filter { it.id != regime.id },
                    inactiveRegimes = state.inactiveRegimes.filter { it.id != regime.id }
                )
            }
            // database.supplementRegimeDao().delete(regime)
        }
    }
    
    fun toggleRegimeActive(regime: SupplementRegime) {
        val updatedRegime = regime.copy(isActive = !regime.isActive)
        updateRegime(updatedRegime)
    }
    
    fun logRegimeForToday(regime: SupplementRegime) {
        viewModelScope.launch {
            val today = Date()
            
            // Convert regime supplements to supplement entries and add to database
            regime.supplements.forEach { supplement ->
                val entry = SupplementEntry(
                    id = UUID.randomUUID(),
                    name = supplement.name,
                    brand = supplement.brand,
                    date = today,
                    timestamp = today,
                    servingSize = supplement.servingSize,
                    servingUnit = supplement.servingUnit,
                    nutrients = supplement.nutrients
                )
                
                try {
                    database.supplementDao().insert(entry)
                } catch (e: Exception) {
                    // Handle error
                    e.printStackTrace()
                }
            }
            
            // Update UI to show success
            _uiState.update { state ->
                state.copy(
                    lastLoggedRegime = regime.name,
                    lastLoggedTime = System.currentTimeMillis()
                )
            }
        }
    }
}

data class SupplementRegimeUiState(
    val activeRegimes: List<SupplementRegime> = emptyList(),
    val inactiveRegimes: List<SupplementRegime> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val lastLoggedRegime: String? = null,
    val lastLoggedTime: Long? = null
)