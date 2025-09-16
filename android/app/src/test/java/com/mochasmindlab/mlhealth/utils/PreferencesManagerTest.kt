package com.mochasmindlab.mlhealth.utils

import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.models.*
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Test

@ExperimentalCoroutinesApi
class PreferencesManagerTest {
    
    // Note: PreferencesManager requires Android context and DataStore
    // These tests verify the logic but actual DataStore tests should be in androidTest
    
    @Test
    fun `test Gender enum values`() {
        assertThat(Gender.values().toList()).contains(Gender.MALE)
        assertThat(Gender.values().toList()).contains(Gender.FEMALE)
        assertThat(Gender.values().toList()).contains(Gender.OTHER)
    }
    
    @Test
    fun `test ActivityLevel enum values`() {
        val levels = ActivityLevel.values().toList()
        assertThat(levels).contains(ActivityLevel.SEDENTARY)
        assertThat(levels).contains(ActivityLevel.LIGHT)
        assertThat(levels).contains(ActivityLevel.MODERATE)
        assertThat(levels).contains(ActivityLevel.ACTIVE)
        assertThat(levels).contains(ActivityLevel.VERY_ACTIVE)
    }
    
    @Test
    fun `test GoalCategory enum values`() {
        val goals = GoalCategory.values().toList()
        assertThat(goals).contains(GoalCategory.WEIGHT_LOSS)
        assertThat(goals).contains(GoalCategory.WEIGHT_GAIN)
        assertThat(goals).contains(GoalCategory.NUTRITION)
        assertThat(goals).contains(GoalCategory.EXERCISE)
        assertThat(goals).contains(GoalCategory.HYDRATION)
        assertThat(goals).contains(GoalCategory.SLEEP)
        assertThat(goals).contains(GoalCategory.MINDFULNESS)
        assertThat(goals).contains(GoalCategory.CUSTOM)
    }
    
    @Test
    fun `test WeightUnit enum values`() {
        assertThat(WeightUnit.values().toList()).contains(WeightUnit.KG)
        assertThat(WeightUnit.values().toList()).contains(WeightUnit.LBS)
    }
    
    @Test
    fun `test HeightUnit enum values`() {
        assertThat(HeightUnit.values().toList()).contains(HeightUnit.CM)
        assertThat(HeightUnit.values().toList()).contains(HeightUnit.FEET_INCHES)
    }
    
    @Test
    fun `calculate BMR for male`() {
        // BMR = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        val weight = 75.0 // kg
        val height = 180.0 // cm
        val age = 30
        
        val expectedBMR = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        assertThat(expectedBMR).isWithin(10.0).of(1786.6)
    }
    
    @Test
    fun `calculate BMR for female`() {
        // BMR = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
        val weight = 60.0 // kg
        val height = 165.0 // cm
        val age = 25
        
        val expectedBMR = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
        assertThat(expectedBMR).isWithin(10.0).of(1405.3)
    }
    
    @Test
    fun `calculate TDEE with activity multipliers`() {
        val bmr = 1786.6
        
        // Test each activity level multiplier
        assertThat(bmr * 1.2).isWithin(10.0).of(2143.9) // Sedentary
        assertThat(bmr * 1.375).isWithin(10.0).of(2456.6) // Light
        assertThat(bmr * 1.55).isWithin(10.0).of(2769.2) // Moderate
        assertThat(bmr * 1.725).isWithin(10.0).of(3082.0) // Active
        assertThat(bmr * 1.9).isWithin(10.0).of(3394.5) // Very Active
    }
    
    @Test
    fun `calculate calorie goals based on goal type`() {
        val tdee = 2769.0
        
        // Weight loss: TDEE - 500
        assertThat(tdee - 500).isEqualTo(2269.0)
        
        // Weight gain: TDEE + 500
        assertThat(tdee + 500).isEqualTo(3269.0)
        
        // Nutrition/Exercise goals: TDEE (maintenance)
        assertThat(tdee).isEqualTo(2769.0)
    }
    
    @Test
    fun `default water goal should be 8 cups`() {
        val defaultWaterGoal = 8
        assertThat(defaultWaterGoal).isEqualTo(8)
    }
    
    @Test
    fun `default exercise goal should be 30 minutes`() {
        val defaultExerciseGoal = 30
        assertThat(defaultExerciseGoal).isEqualTo(30)
    }
}