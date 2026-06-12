package com.mochasmindlab.mlhealth.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.mochasmindlab.mlhealth.ui.screens.*

@Composable
fun MLHealthNavHost(
    navController: NavHostController,
    startDestination: String = "dashboard"
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable("dashboard") {
            DashboardScreen(
                onNavigateToDiary = { navController.navigate("diary") },
                onNavigateToMealPlan = { navController.navigate("meal_plan") },
                onNavigateToMore = { navController.navigate("more") }
            )
        }
        
        composable("diary") {
            // TODO: DiaryScreen()
            DashboardScreen() // Placeholder
        }
        
        composable("meal_plan") {
            // TODO: MealPlanScreen()
            DashboardScreen() // Placeholder
        }
        
        composable("more") {
            // TODO: MoreScreen()
            DashboardScreen() // Placeholder
        }
    }
}