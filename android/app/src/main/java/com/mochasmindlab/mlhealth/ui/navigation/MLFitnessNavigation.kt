package com.mochasmindlab.mlhealth.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.mochasmindlab.mlhealth.ui.screens.dashboard.DashboardScreen
import com.mochasmindlab.mlhealth.ui.screens.diary.DiaryScreen
import com.mochasmindlab.mlhealth.ui.screens.mealplan.MealPlanScreen
import com.mochasmindlab.mlhealth.ui.screens.more.MoreScreen

// Navigation destinations matching iOS tabs
sealed class Screen(val route: String, val title: String, val icon: Int) {
    object Dashboard : Screen("dashboard", "Dashboard", android.R.drawable.ic_menu_view)
    object Diary : Screen("diary", "Diary", android.R.drawable.ic_menu_agenda)
    object MealPlan : Screen("mealplan", "Plan", android.R.drawable.ic_menu_today)
    object More : Screen("more", "More", android.R.drawable.ic_menu_more)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MLFitnessNavigation() {
    val navController = rememberNavController()
    var showAddMenu by remember { mutableStateOf(false) }

    val items = listOf(
        Screen.Dashboard,
        Screen.Diary,
        Screen.MealPlan,
        Screen.More
    )

    Scaffold(
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                items.forEach { screen ->
                    NavigationBarItem(
                        icon = {
                            Icon(
                                painterResource(id = screen.icon),
                                contentDescription = screen.title
                            )
                        },
                        label = { Text(screen.title) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }

                // Add button in the middle (matching iOS)
                NavigationBarItem(
                    icon = {
                        Icon(
                            painterResource(id = android.R.drawable.ic_input_add),
                            contentDescription = "Add"
                        )
                    },
                    label = { Text("") },
                    selected = false,
                    onClick = { showAddMenu = true }
                )
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Dashboard.route) {
                DashboardScreen(navController)
            }
            composable(Screen.Diary.route) {
                DiaryScreen(
                    navController = navController,
                    onAddClick = { showAddMenu = true }
                )
            }
            composable(Screen.MealPlan.route) {
                MealPlanScreen(navController)
            }
            composable(Screen.More.route) {
                MoreScreen(navController)
            }
        }
    }

    // Add menu bottom sheet (matching iOS sheet)
    if (showAddMenu) {
        AddMenuBottomSheet(
            onDismiss = { showAddMenu = false },
            navController = navController
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMenuBottomSheet(
    onDismiss: () -> Unit,
    navController: androidx.navigation.NavController
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss
    ) {
        // Add menu options matching iOS
        AddMenuContent(
            onFoodClick = {
                onDismiss()
                navController.navigate("food_search")
            },
            onExerciseClick = {
                onDismiss()
                navController.navigate("exercise_search")
            },
            onWeightClick = {
                onDismiss()
                navController.navigate("weight_entry")
            },
            onWaterClick = {
                onDismiss()
                navController.navigate("water_entry")
            },
            onSupplementClick = {
                onDismiss()
                navController.navigate("supplement_entry")
            }
        )
    }
}

@Composable
fun AddMenuContent(
    onFoodClick: () -> Unit,
    onExerciseClick: () -> Unit,
    onWeightClick: () -> Unit,
    onWaterClick: () -> Unit,
    onSupplementClick: () -> Unit
) {
    // Implementation will be added
}