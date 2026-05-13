package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry
import com.mochasmindlab.mlhealth.di.ApplicationScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Calendar
import java.util.Date
import javax.inject.Inject

@HiltViewModel
class SupplementsViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    @ApplicationScope private val appScope: CoroutineScope
) : ViewModel() {

    private val _entries = MutableStateFlow<List<SupplementEntry>>(emptyList())
    val entries: StateFlow<List<SupplementEntry>> = _entries.asStateFlow()

    private val _suggestions = MutableStateFlow<List<String>>(emptyList())
    val suggestions: StateFlow<List<String>> = _suggestions.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _entries.value = database.supplementDao().getEntriesForDate(startOfDay())
            _suggestions.value = database.supplementDao().getAllSupplementNames()
        }
    }

    fun add(
        name: String,
        brand: String?,
        servingSize: String,
        servingUnit: String
    ) {
        if (name.isBlank() || servingSize.isBlank() || servingUnit.isBlank()) return
        appScope.launch {
            database.supplementDao().insert(
                SupplementEntry(
                    name = name.trim(),
                    brand = brand?.trim()?.takeIf { it.isNotBlank() },
                    date = startOfDay(),
                    servingSize = servingSize.trim(),
                    servingUnit = servingUnit.trim()
                )
            )
            refresh()
        }
    }

    fun delete(entry: SupplementEntry) {
        appScope.launch {
            database.supplementDao().delete(entry)
            refresh()
        }
    }

    private fun startOfDay(): Date = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.time
}
