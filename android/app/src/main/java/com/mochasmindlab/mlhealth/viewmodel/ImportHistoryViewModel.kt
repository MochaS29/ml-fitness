package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.importer.MfpImporter
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject

/** Drives the Import History screen: parse a MyFitnessPal CSV, preview it, import it. */
@HiltViewModel
class ImportHistoryViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    sealed class Stage {
        object Idle : Stage()
        data class Preview(val summary: MfpImporter.Summary) : Stage()
        data class Importing(val progress: Float) : Stage()
        data class Done(val inserted: Int) : Stage()
        data class Failed(val message: String) : Stage()
    }

    private val _stage = MutableStateFlow<Stage>(Stage.Idle)
    val stage: StateFlow<Stage> = _stage.asStateFlow()

    fun reset() { _stage.value = Stage.Idle }

    fun preview(csvText: String) {
        viewModelScope.launch {
            try {
                val summary = withContext(Dispatchers.Default) { MfpImporter.preview(csvText) }
                _stage.value = Stage.Preview(summary)
            } catch (e: Exception) {
                _stage.value = Stage.Failed(e.message ?: "We couldn't read that file.")
            }
        }
    }

    fun runImport(entries: List<MfpImporter.ParsedFoodRow>) {
        viewModelScope.launch {
            _stage.value = Stage.Importing(0f)
            try {
                val inserted = withContext(Dispatchers.IO) {
                    MfpImporter.importEntries(entries, database.foodDao()) { progress ->
                        _stage.value = Stage.Importing(progress.toFloat())
                    }
                }
                _stage.value = Stage.Done(inserted)
            } catch (e: Exception) {
                _stage.value = Stage.Failed("Something went wrong while importing. Please try again.")
            }
        }
    }
}
