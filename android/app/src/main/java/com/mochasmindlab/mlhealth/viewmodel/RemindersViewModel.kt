package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.services.ReminderScheduler
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import com.mochasmindlab.mlhealth.utils.ReminderSettings
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RemindersViewModel @Inject constructor(
    private val prefs: PreferencesManager,
    private val scheduler: ReminderScheduler
) : ViewModel() {

    val settings: StateFlow<ReminderSettings> = prefs.reminderSettings
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = ReminderSettings(
                waterEnabled = false, waterIntervalMinutes = 120,
                waterStartHour = 8, waterEndHour = 20,
                mealsEnabled = false, breakfastHour = 8, lunchHour = 12, dinnerHour = 18,
                exerciseEnabled = false, exerciseHour = 18, exerciseMinute = 0,
                weightEnabled = false, weightHour = 8, weightMinute = 0
            )
        )

    fun setWaterEnabled(enabled: Boolean) = viewModelScope.launch {
        prefs.setWaterReminderEnabled(enabled)
        scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setWaterInterval(minutes: Int) = viewModelScope.launch {
        prefs.setWaterReminderIntervalMinutes(minutes)
        if (settings.value.waterEnabled) scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setWaterWindow(startHour: Int, endHour: Int) = viewModelScope.launch {
        prefs.setWaterWindow(startHour, endHour)
        if (settings.value.waterEnabled) scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setMealsEnabled(enabled: Boolean) = viewModelScope.launch {
        prefs.setMealReminderEnabled(enabled)
        scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setMealHours(breakfast: Int, lunch: Int, dinner: Int) = viewModelScope.launch {
        prefs.setMealHours(breakfast, lunch, dinner)
        if (settings.value.mealsEnabled) scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setWeightEnabled(enabled: Boolean) = viewModelScope.launch {
        prefs.setWeightReminder(enabled, settings.value.weightHour, settings.value.weightMinute)
        scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setWeightTime(hour: Int, minute: Int) = viewModelScope.launch {
        prefs.setWeightReminder(settings.value.weightEnabled, hour, minute)
        if (settings.value.weightEnabled) scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setExerciseEnabled(enabled: Boolean) = viewModelScope.launch {
        prefs.setExerciseReminderEnabled(enabled)
        scheduler.apply(prefs.reminderSettingsValue())
    }

    fun setExerciseTime(hour: Int, minute: Int) = viewModelScope.launch {
        prefs.setExerciseReminderTime(hour, minute)
        if (settings.value.exerciseEnabled) scheduler.apply(prefs.reminderSettingsValue())
    }
}

private suspend fun PreferencesManager.reminderSettingsValue(): ReminderSettings =
    reminderSettings.first()
