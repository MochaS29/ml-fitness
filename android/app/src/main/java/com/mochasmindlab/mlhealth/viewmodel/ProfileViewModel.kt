package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.UserProfile
import com.mochasmindlab.mlhealth.data.repository.UserProfileRepository
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userProfileRepository: UserProfileRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _userProfile = MutableStateFlow(UserProfile())
    val userProfile: StateFlow<UserProfile> = _userProfile.asStateFlow()

    private val _dailyCalorieGoal = MutableStateFlow(2000)
    val dailyCalorieGoal: StateFlow<Int> = _dailyCalorieGoal.asStateFlow()

    private val _currentStreak = MutableStateFlow(0)
    val currentStreak: StateFlow<Int> = _currentStreak.asStateFlow()

    private val _totalDaysTracked = MutableStateFlow(0)
    val totalDaysTracked: StateFlow<Int> = _totalDaysTracked.asStateFlow()

    init {
        loadUserProfile()
        loadStatistics()
    }

    private fun loadUserProfile() {
        viewModelScope.launch {
            userProfileRepository.getUserProfile().collect { profile ->
                profile?.let {
                    _userProfile.value = it
                    _dailyCalorieGoal.value = it.dailyCalorieGoal
                }
            }
        }
    }

    private fun loadStatistics() {
        viewModelScope.launch {
            // Load current streak
            val streak = userProfileRepository.getCurrentStreak()
            _currentStreak.value = streak

            // Load total days tracked
            val totalDays = userProfileRepository.getTotalDaysTracked()
            _totalDaysTracked.value = totalDays
        }
    }

    fun updateProfile(profile: UserProfile) {
        _userProfile.value = profile
    }

    fun saveProfile() {
        viewModelScope.launch {
            userProfileRepository.updateUserProfile(_userProfile.value.copy(
                lastUpdated = LocalDate.now()
            ))
        }
    }

    fun updateBodyMetrics(height: Float, weight: Float) {
        _userProfile.value = _userProfile.value.copy(
            height = height,
            currentWeight = weight
        )
    }

    fun updateActivityLevel(level: String) {
        _userProfile.value = _userProfile.value.copy(
            activityLevel = level
        )
        // Recalculate calorie goals based on new activity level
        recalculateCalorieGoals()
    }

    private fun recalculateCalorieGoals() {
        val profile = _userProfile.value
        val bmr = calculateBMR(profile)
        val activityMultiplier = when (profile.activityLevel) {
            "Sedentary" -> 1.2
            "Lightly Active" -> 1.375
            "Moderately Active" -> 1.55
            "Very Active" -> 1.725
            "Extra Active" -> 1.9
            else -> 1.55
        }

        val tdee = (bmr * activityMultiplier).toInt()

        // Adjust for weight goal
        val calorieGoal = when {
            profile.currentWeight > profile.goalWeight -> tdee - 500 // Deficit for weight loss
            profile.currentWeight < profile.goalWeight -> tdee + 300 // Surplus for weight gain
            else -> tdee // Maintenance
        }

        _dailyCalorieGoal.value = calorieGoal
        _userProfile.value = profile.copy(dailyCalorieGoal = calorieGoal)
    }

    private fun calculateBMR(profile: UserProfile): Double {
        // Mifflin-St Jeor Equation
        val weightInKg = profile.currentWeight * 0.453592
        val heightInCm = profile.height
        val age = java.time.Period.between(profile.birthDate, LocalDate.now()).years

        return if (profile.gender == "Male") {
            10 * weightInKg + 6.25 * heightInCm - 5 * age + 5
        } else {
            10 * weightInKg + 6.25 * heightInCm - 5 * age - 161
        }
    }

    fun signOut() {
        viewModelScope.launch {
            preferencesManager.clearAll()
            // Additional sign out logic
        }
    }
}