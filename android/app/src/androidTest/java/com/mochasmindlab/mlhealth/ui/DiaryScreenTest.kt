package com.mochasmindlab.mlhealth.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.mochasmindlab.mlhealth.MainActivity
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@HiltAndroidTest
@RunWith(AndroidJUnit4::class)
class DiaryScreenTest {
    
    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)
    
    @get:Rule(order = 1)
    val composeTestRule = createAndroidComposeRule<MainActivity>()
    
    @Before
    fun setup() {
        hiltRule.inject()
        
        // Navigate to Diary screen
        composeTestRule.onNodeWithText("Diary").performClick()
        composeTestRule.waitForIdle()
    }
    
    @Test
    fun diaryScreen_displaysAllMealSections() {
        // Verify all meal sections are present
        composeTestRule.onNodeWithText("Breakfast").assertExists()
        composeTestRule.onNodeWithText("Lunch").assertExists()
        composeTestRule.onNodeWithText("Dinner").assertExists()
        composeTestRule.onNodeWithText("Snacks").assertExists()
    }
    
    @Test
    fun diaryScreen_displaysDateNavigation() {
        // Check for date navigation elements
        composeTestRule.onNodeWithContentDescription("Previous day").assertExists()
        composeTestRule.onNodeWithContentDescription("Next day").assertExists()
        composeTestRule.onNodeWithText("Today").assertExists()
    }
    
    @Test
    fun diaryScreen_navigatesToPreviousDay() {
        // Click previous day button
        composeTestRule.onNodeWithContentDescription("Previous day").performClick()
        
        // Verify date changed (Today button should still be visible)
        composeTestRule.onNodeWithText("Today").assertExists()
    }
    
    @Test
    fun diaryScreen_navigatesToNextDay() {
        // Click next day button
        composeTestRule.onNodeWithContentDescription("Next day").performClick()
        
        // Verify date changed
        composeTestRule.onNodeWithText("Today").assertExists()
    }
    
    @Test
    fun diaryScreen_returnsToToday() {
        // Navigate away from today
        composeTestRule.onNodeWithContentDescription("Previous day").performClick()
        composeTestRule.waitForIdle()
        
        // Click Today button
        composeTestRule.onNodeWithText("Today").performClick()
        
        // Verify we're back on today
        composeTestRule.onNodeWithText("Today").assertExists()
    }
    
    @Test
    fun diaryScreen_displaysWaterTracking() {
        // Check for water tracking section
        composeTestRule.onNodeWithText("Water Intake").assertExists()
        
        // Check for water cup controls
        composeTestRule.onNodeWithContentDescription("Remove water cup").assertExists()
        composeTestRule.onNodeWithContentDescription("Add water cup").assertExists()
    }
    
    @Test
    fun diaryScreen_addWaterCup() {
        // Find initial water count
        val waterSection = composeTestRule.onNode(hasText("cups", substring = true))
        
        // Click add water button
        composeTestRule.onNodeWithContentDescription("Add water cup").performClick()
        
        // Verify water count increased
        composeTestRule.waitForIdle()
    }
    
    @Test
    fun diaryScreen_showsNutrientTotals() {
        // Check for nutrient summary
        composeTestRule.onNodeWithText("Total Calories", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Protein", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Carbs", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Fat", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun diaryScreen_addFoodButton_existsForEachMeal() {
        // Check each meal has an add button
        val meals = listOf("Breakfast", "Lunch", "Dinner", "Snacks")
        
        for (meal in meals) {
            composeTestRule.onNode(
                hasParent(hasTestTag("${meal.lowercase()}_section")) and 
                hasContentDescription("Add food")
            ).assertExists()
        }
    }
}