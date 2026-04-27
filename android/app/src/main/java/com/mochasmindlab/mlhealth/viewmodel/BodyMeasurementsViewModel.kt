package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.BodyMeasurementDao
import com.mochasmindlab.mlhealth.data.entities.BodyMeasurementEntry
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.Date
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class BodyMeasurementsViewModel @Inject constructor(
    private val dao: BodyMeasurementDao
) : ViewModel() {

    // ── Observable entry list (newest first) ──────────────────────────────────
    val entries: StateFlow<List<BodyMeasurementEntry>> =
        dao.getAll()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = emptyList()
            )

    // ── Form state exposed to the screen ──────────────────────────────────────
    private val _selectedDate = MutableStateFlow(Date())
    val selectedDate: StateFlow<Date> = _selectedDate.asStateFlow()

    private val _waist  = MutableStateFlow("")
    val waist: StateFlow<String> = _waist.asStateFlow()

    private val _hips   = MutableStateFlow("")
    val hips: StateFlow<String> = _hips.asStateFlow()

    private val _chest  = MutableStateFlow("")
    val chest: StateFlow<String> = _chest.asStateFlow()

    private val _biceps = MutableStateFlow("")
    val biceps: StateFlow<String> = _biceps.asStateFlow()

    private val _thighs = MutableStateFlow("")
    val thighs: StateFlow<String> = _thighs.asStateFlow()

    private val _height = MutableStateFlow("")
    val height: StateFlow<String> = _height.asStateFlow()

    // True when at least one field has a parseable numeric value
    val canSave: StateFlow<Boolean> = combine(
        _waist, _hips, _chest, _biceps, _thighs, _height
    ) { values ->
        values.any { it.toDoubleOrNull() != null }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

    // ── Form update helpers ────────────────────────────────────────────────────
    fun onDateChanged(date: Date)    { _selectedDate.value = date }
    fun onWaistChanged(v: String)    { _waist.value   = v }
    fun onHipsChanged(v: String)     { _hips.value    = v }
    fun onChestChanged(v: String)    { _chest.value   = v }
    fun onBicepsChanged(v: String)   { _biceps.value  = v }
    fun onThighsChanged(v: String)   { _thighs.value  = v }
    fun onHeightChanged(v: String)   { _height.value  = v }

    // ── Save ──────────────────────────────────────────────────────────────────
    /**
     * Persist a new entry from current form state. All values are already in cm
     * (the screen converts from the user's display unit before calling this).
     */
    fun save(
        date: Date,
        waist: Double?,
        hips: Double?,
        chest: Double?,
        biceps: Double?,
        thighs: Double?,
        height: Double?
    ) {
        viewModelScope.launch {
            dao.insert(
                BodyMeasurementEntry(
                    id = UUID.randomUUID(),
                    date = date,
                    timestamp = Date(),
                    waist  = waist,
                    hips   = hips,
                    chest  = chest,
                    biceps = biceps,
                    thighs = thighs,
                    height = height
                )
            )
            resetForm()
        }
    }

    /** Convenience overload that reads current form state directly. */
    fun saveFromForm() {
        save(
            date   = _selectedDate.value,
            waist  = _waist.value.toDoubleOrNull(),
            hips   = _hips.value.toDoubleOrNull(),
            chest  = _chest.value.toDoubleOrNull(),
            biceps = _biceps.value.toDoubleOrNull(),
            thighs = _thighs.value.toDoubleOrNull(),
            height = _height.value.toDoubleOrNull()
        )
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    fun delete(entry: BodyMeasurementEntry) {
        viewModelScope.launch { dao.delete(entry) }
    }

    // ── Internal helpers ──────────────────────────────────────────────────────
    private fun resetForm() {
        _selectedDate.value = Date()
        _waist.value  = ""
        _hips.value   = ""
        _chest.value  = ""
        _biceps.value = ""
        _thighs.value = ""
        _height.value = ""
    }
}
