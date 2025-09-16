package com.mochasmindlab.mlhealth.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.mochasmindlab.mlhealth.data.models.*
import com.mochasmindlab.mlhealth.ui.screens.OnboardingScreen
import com.mochasmindlab.mlhealth.ui.theme.MLHealthTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class OnboardingScreenTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun onboardingScreen_welcomeStep_displaysCorrectly() {
        var onboardingCompleted = false
        
        composeTestRule.setContent {
            MLHealthTheme {
                OnboardingScreen(
                    onOnboardingComplete = { onboardingCompleted = true }
                )
            }
        }
        
        // Verify welcome screen elements
        composeTestRule.onNodeWithText("Welcome to ML Health").assertIsDisplayed()
        composeTestRule.onNodeWithText("Your personal health companion").assertIsDisplayed()
        composeTestRule.onNodeWithText("Get Started").assertIsDisplayed()
    }
    
    @Test
    fun onboardingScreen_navigatesThroughAllSteps() {
        var completedData: Map<String, Any>? = null
        
        composeTestRule.setContent {
            MLHealthTheme {
                OnboardingScreen(
                    onOnboardingComplete = { data ->
                        completedData = data
                    }
                )
            }
        }
        
        // Step 1: Welcome
        composeTestRule.onNodeWithText("Get Started").performClick()
        
        // Step 2: Name
        composeTestRule.onNodeWithTag("name_input").assertIsDisplayed()
        composeTestRule.onNodeWithTag("name_input").performTextInput("Test User")
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 3: Age
        composeTestRule.onNodeWithTag("age_input").assertIsDisplayed()
        composeTestRule.onNodeWithTag("age_input").performTextInput("30")
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 4: Gender
        composeTestRule.onNodeWithText("Male").assertIsDisplayed()
        composeTestRule.onNodeWithText("Male").performClick()
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 5: Height
        composeTestRule.onNodeWithTag("height_input").assertIsDisplayed()
        composeTestRule.onNodeWithTag("height_input").performTextInput("180")
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 6: Weight
        composeTestRule.onNodeWithTag("weight_input").assertIsDisplayed()
        composeTestRule.onNodeWithTag("weight_input").performTextInput("75")
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 7: Activity Level
        composeTestRule.onNodeWithText("Moderate").assertIsDisplayed()
        composeTestRule.onNodeWithText("Moderate").performClick()
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Step 8: Goal
        composeTestRule.onNodeWithText("Weight Loss").assertIsDisplayed()
        composeTestRule.onNodeWithText("Weight Loss").performClick()
        composeTestRule.onNodeWithText("Complete").performClick()
        
        // Verify completion
        assert(completedData != null)
        assert(completedData!!["name"] == "Test User")
        assert(completedData!!["age"] == 30)
    }
    
    @Test
    fun onboardingScreen_backButton_navigatesToPreviousStep() {
        composeTestRule.setContent {
            MLHealthTheme {
                OnboardingScreen(
                    onOnboardingComplete = { }
                )
            }
        }
        
        // Go to step 2
        composeTestRule.onNodeWithText("Get Started").performClick()
        
        // Go to step 3
        composeTestRule.onNodeWithTag("name_input").performTextInput("Test")
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Verify we're on age step
        composeTestRule.onNodeWithTag("age_input").assertIsDisplayed()
        
        // Go back
        composeTestRule.onNodeWithText("Back").performClick()
        
        // Verify we're back on name step
        composeTestRule.onNodeWithTag("name_input").assertIsDisplayed()
    }
    
    @Test
    fun onboardingScreen_unitToggle_switchesBetweenMetricAndImperial() {
        composeTestRule.setContent {
            MLHealthTheme {
                OnboardingScreen(
                    onOnboardingComplete = { }
                )
            }
        }
        
        // Navigate to height step
        composeTestRule.onNodeWithText("Get Started").performClick()
        composeTestRule.onNodeWithTag("name_input").performTextInput("Test")
        composeTestRule.onNodeWithText("Next").performClick()
        composeTestRule.onNodeWithTag("age_input").performTextInput("30")
        composeTestRule.onNodeWithText("Next").performClick()
        composeTestRule.onNodeWithText("Male").performClick()
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Check metric is default
        composeTestRule.onNodeWithText("cm").assertIsDisplayed()
        
        // Switch to imperial
        composeTestRule.onNodeWithText("ft/in").performClick()
        composeTestRule.onNodeWithTag("feet_input").assertIsDisplayed()
        composeTestRule.onNodeWithTag("inches_input").assertIsDisplayed()
        
        // Switch back to metric
        composeTestRule.onNodeWithText("cm").performClick()
        composeTestRule.onNodeWithTag("height_input").assertIsDisplayed()
    }
    
    @Test
    fun onboardingScreen_validation_preventsEmptyInput() {
        composeTestRule.setContent {
            MLHealthTheme {
                OnboardingScreen(
                    onOnboardingComplete = { }
                )
            }
        }
        
        // Go to name step
        composeTestRule.onNodeWithText("Get Started").performClick()
        
        // Try to proceed without entering name
        composeTestRule.onNodeWithText("Next").performClick()
        
        // Should still be on name step
        composeTestRule.onNodeWithTag("name_input").assertIsDisplayed()
        composeTestRule.onNodeWithText("Please enter your name").assertIsDisplayed()
    }
}