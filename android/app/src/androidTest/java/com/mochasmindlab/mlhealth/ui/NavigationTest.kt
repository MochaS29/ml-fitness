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
class NavigationTest {
    
    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)
    
    @get:Rule(order = 1)
    val composeTestRule = createAndroidComposeRule<MainActivity>()
    
    @Before
    fun setup() {
        hiltRule.inject()
    }
    
    @Test
    fun bottomNavigation_allItemsAreDisplayed() {
        // Verify all navigation items are present
        composeTestRule.onNodeWithText("Dashboard").assertExists()
        composeTestRule.onNodeWithText("Diary").assertExists()
        composeTestRule.onNodeWithText("Plan").assertExists()
        composeTestRule.onNodeWithText("More").assertExists()
        
        // Verify FAB is present
        composeTestRule.onNodeWithContentDescription("Add").assertExists()
    }
    
    @Test
    fun bottomNavigation_navigatesToAllScreens() {
        // Test Dashboard navigation
        composeTestRule.onNodeWithText("Dashboard").performClick()
        composeTestRule.onNodeWithText("AI Insights", useUnmergedTree = true).assertExists()
        
        // Test Diary navigation
        composeTestRule.onNodeWithText("Diary").performClick()
        composeTestRule.onNodeWithText("Food Diary", useUnmergedTree = true).assertExists()
        
        // Test Meal Plan navigation
        composeTestRule.onNodeWithText("Plan").performClick()
        composeTestRule.onNodeWithText("Meal Plans", useUnmergedTree = true).assertExists()
        
        // Test More navigation
        composeTestRule.onNodeWithText("More").performClick()
        composeTestRule.onNodeWithText("Settings", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun bottomNavigation_showsSelectedState() {
        // Click on Diary
        composeTestRule.onNodeWithText("Diary").performClick()
        
        // Verify Diary is selected
        composeTestRule.onNode(
            hasText("Diary") and hasClickAction()
        ).assertIsSelected()
        
        // Verify Dashboard is not selected
        composeTestRule.onNode(
            hasText("Dashboard") and hasClickAction()
        ).assertIsNotSelected()
    }
    
    @Test
    fun fab_opensAddMenu() {
        // Click on FAB
        composeTestRule.onNodeWithContentDescription("Add").performClick()
        
        // Verify add menu is displayed
        composeTestRule.onNodeWithText("Quick Add", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Food", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Water", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Exercise", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun addMenu_canBeDismissed() {
        // Open add menu
        composeTestRule.onNodeWithContentDescription("Add").performClick()
        composeTestRule.onNodeWithText("Quick Add", useUnmergedTree = true).assertExists()
        
        // Dismiss by clicking outside or back
        composeTestRule.onNodeWithContentDescription("Close").performClick()
        
        // Verify menu is closed
        composeTestRule.onNodeWithText("Quick Add", useUnmergedTree = true).assertDoesNotExist()
    }
    
    @Test
    fun navigation_maintainsStateOnRotation() {
        // Navigate to Diary
        composeTestRule.onNodeWithText("Diary").performClick()
        composeTestRule.onNodeWithText("Food Diary", useUnmergedTree = true).assertExists()
        
        // Simulate configuration change (would need actual device rotation in real test)
        composeTestRule.activityRule.scenario.recreate()
        
        // Verify still on Diary screen
        composeTestRule.waitForIdle()
        composeTestRule.onNodeWithText("Food Diary", useUnmergedTree = true).assertExists()
    }
}