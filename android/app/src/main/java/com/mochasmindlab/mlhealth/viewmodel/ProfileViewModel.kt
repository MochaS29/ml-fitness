package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.ActivityLevel
import com.mochasmindlab.mlhealth.data.models.Gender
import com.mochasmindlab.mlhealth.data.models.UserProfile
import com.mochasmindlab.mlhealth.data.repository.UserProfileRepository
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.Period
import java.time.ZoneId
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userProfileRepository: UserProfileRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _userProfile = MutableStateFlow(UserProfile())
    val userProfile: StateFlow<UserProfile> = _userProfile.asStateFlow()

    // Daily calorie goal is canonically owned by PreferencesManager — that's where
    // Goals/Dashboard write. Profile observes it so a goal change anywhere is
    // immediately reflected here instead of showing the stale Room-backed value.
    val dailyCalorieGoal: StateFlow<Int> = preferencesManager.dailyCalorieGoal
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 2000)

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
            val current = _userProfile.value
            userProfileRepository.updateUserProfile(current.copy(
                lastUpdated = java.util.Date()
            ))
            // Mirror the whole profile to PreferencesManager so anything reading
            // from DataStore (Dashboard, WeightVM, RDAViewModel) gets fresh values.
            mirrorToPreferences(current)
        }
    }

    fun updateBodyMetrics(height: Float, weight: Float) {
        _userProfile.value = _userProfile.value.copy(
            height = height,
            currentWeight = weight
        )
        viewModelScope.launch {
            preferencesManager.setUserHeight(height)
            preferencesManager.setUserWeight(weight)
        }
    }

    fun updateActivityLevel(level: String) {
        _userProfile.value = _userProfile.value.copy(
            activityLevel = level
        )
        viewModelScope.launch {
            preferencesManager.setUserActivityLevel(activityLevelStringToEnum(level))
        }
        // Recalculate calorie goals based on new activity level
        recalculateCalorieGoals()
    }

    private suspend fun mirrorToPreferences(profile: UserProfile) {
        preferencesManager.setUserHeight(profile.height)
        preferencesManager.setUserWeight(profile.currentWeight)
        preferencesManager.setUserTargetWeight(profile.goalWeight)
        preferencesManager.setUserAge(ageFromBirthDate(profile.birthDate))
        preferencesManager.setUserGender(genderStringToEnum(profile.gender))
        preferencesManager.setUserActivityLevel(activityLevelStringToEnum(profile.activityLevel))
    }

    private fun ageFromBirthDate(birthDate: java.util.Date): Int {
        val localBirth = birthDate.toInstant().atZone(ZoneId.systemDefault()).toLocalDate()
        return Period.between(localBirth, LocalDate.now()).years.coerceAtLeast(0)
    }

    // Room stores friendly strings ("Male", "Female", "Other"); PreferencesManager
    // round-trips through the Gender enum (.name = "MALE" etc.). Convert here so
    // downstream consumers reading PreferencesManager.userProfile don't blow up on
    // Gender.valueOf().
    private fun genderStringToEnum(value: String): Gender = when (value.lowercase()) {
        "male" -> Gender.MALE
        "female" -> Gender.FEMALE
        else -> Gender.OTHER
    }

    // Same idea for activity level — Room uses "Lightly Active", "Moderately Active"
    // etc., the enum uses LIGHT/MODERATE/ACTIVE/VERY_ACTIVE.
    private fun activityLevelStringToEnum(value: String): ActivityLevel = when (value.lowercase()) {
        "sedentary" -> ActivityLevel.SEDENTARY
        "lightly active", "light" -> ActivityLevel.LIGHT
        "moderately active", "moderate" -> ActivityLevel.MODERATE
        "very active", "active" -> ActivityLevel.ACTIVE
        "extra active" -> ActivityLevel.VERY_ACTIVE
        else -> ActivityLevel.MODERATE
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

        _userProfile.value = profile.copy(dailyCalorieGoal = calorieGoal)
        // Mirror to PreferencesManager so Dashboard and Goals screens reflect the
        // recalculated value — they read from DataStore, not the Room entity.
        viewModelScope.launch {
            preferencesManager.updateDailyCalorieGoal(calorieGoal)
        }
    }

    private fun calculateBMR(profile: UserProfile): Double {
        // Mifflin-St Jeor Equation
        val weightInKg = profile.currentWeight * 0.453592
        val heightInCm = profile.height
        val age = java.time.Period.between(
            profile.birthDate.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate(),
            LocalDate.now()
        ).years

        return if (profile.gender == "Male") {
            10 * weightInKg + 6.25 * heightInCm - 5 * age + 5
        } else {
            10 * weightInKg + 6.25 * heightInCm - 5 * age - 161
        }
    }

    fun signOut() {
        viewModelScope.launch {
            preferencesManager.clearAllPreferences()
            // Additional sign out logic
        }
    }
}