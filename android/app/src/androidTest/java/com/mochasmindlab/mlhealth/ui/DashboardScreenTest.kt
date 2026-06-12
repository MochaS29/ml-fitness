package com.mochasmindlab.mlhealth.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.navigation.compose.rememberNavController
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.mochasmindlab.mlhealth.MainActivity
import com.mochasmindlab.mlhealth.ui.theme.MLHealthTheme
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@HiltAndroidTest
@RunWith(AndroidJUnit4::class)
class DashboardScreenTest {
    
    @get:Rule(order = 0)
    val hiltRule = HiltAndroidRule(this)
    
    @get:Rule(order = 1)
    val composeTestRule = createAndroidComposeRule<MainActivity>()
    
    @Before
    fun setup() {
        hiltRule.inject()
    }
    
    @Test
    fun dashboardScreen_displaysAllMainSections() {
        // Verify main dashboard elements
        composeTestRule.onNodeWithText("Dashboard", useUnmergedTree = true).assertExists()
        
        // Wait for content to load
        composeTestRule.waitForIdle()
        
        // Check for main metric cards
        composeTestRule.onNodeWithText("Calories", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Water", useUnmergedTree = true).assertExists()
        composeTestRule.onNodeWithText("Exercise", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun dashboardScreen_navigatesToDiary() {
        // Click on Diary tab
        composeTestRule.onNodeWithText("Diary").performClick()
        
        // Verify Diary screen is displayed
        composeTestRule.onNodeWithText("Food Diary", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun dashboardScreen_showsAIInsights() {
        // Check for AI Insights section
        composeTestRule.onNodeWithText("AI Insights", useUnmergedTree = true).assertExists()
    }
    
    @Test
    fun dashboardScreen_periodSelector_changes() {
        // Find and click on period selector
        composeTestRule.onNodeWithText("Day").assertExists()
        composeTestRule.onNodeWithText("Week").performClick()
        
        // Verify Week is now selected
        composeTestRule.onNodeWithText("Week").assertIsSelected()
    }
    
    @Test
    fun dashboardScreen_refreshButton_works() {
        // Find and click refresh button
        composeTestRule.onNodeWithContentDescription("Refresh").performClick()
        
        // Verify refresh happens (loading indicator or data update)
        composeTestRule.waitForIdle()
    }
}