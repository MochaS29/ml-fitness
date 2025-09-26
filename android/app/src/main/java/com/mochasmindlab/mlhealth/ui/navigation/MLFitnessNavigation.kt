package com.mochasmindlab.mlhealth.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.screens.OnboardingScreen
import com.mochasmindlab.mlhealth.ui.screens.dashboard.DashboardScreen
import com.mochasmindlab.mlhealth.ui.screens.diary.DiaryScreen
import com.mochasmindlab.mlhealth.ui.screens.exercise.ExerciseTrackingScreen
import com.mochasmindlab.mlhealth.ui.screens.food.FoodSearchScreen
import com.mochasmindlab.mlhealth.ui.screens.goals.GoalsScreen
import com.mochasmindlab.mlhealth.ui.screens.mealplan.MealPlanScreen
import com.mochasmindlab.mlhealth.ui.screens.more.MoreScreen
import com.mochasmindlab.mlhealth.ui.screens.profile.ProfileScreen
import com.mochasmindlab.mlhealth.ui.screens.weight.WeightTrackingScreen
import com.mochasmindlab.mlhealth.ui.screens.ComingSoonScreen
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import javax.inject.Inject

// Navigation destinations matching iOS tabs
sealed class Screen(val route: String, val title: String, val icon: ImageVector) {
    object Dashboard : Screen("dashboard", "Dashboard", Icons.Default.Home)
    object Diary : Screen("diary", "Diary", Icons.Default.MenuBook)
    object MealPlan : Screen("mealplan", "Plan", Icons.Default.CalendarMonth)
    object More : Screen("more", "More", Icons.Default.MoreHoriz)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MLFitnessNavigation(
    preferencesManager: PreferencesManager? = null
) {
    val navController = rememberNavController()
    var showAddMenu by remember { mutableStateOf(false) }

    // Check if onboarding is completed
    val startDestination = if (preferencesManager != null) {
        runBlocking {
            if (preferencesManager.isOnboardingCompleted.first()) {
                Screen.Dashboard.route
            } else {
                "onboarding"
            }
        }
    } else {
        Screen.Dashboard.route
    }

    val items = listOf(
        Screen.Dashboard,
        Screen.Diary,
        Screen.MealPlan,
        Screen.More
    )

    Scaffold(
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentRoute = navBackStackEntry?.destination?.route

            // Don't show bottom bar on onboarding or detail screens
            if (currentRoute != "onboarding" && !currentRoute?.contains("/")!!) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = MaterialTheme.colorScheme.onSurface
                ) {
                    items.forEach { screen ->
                        NavigationBarItem(
                            icon = {
                                Icon(
                                    screen.icon,
                                    contentDescription = screen.title
                                )
                            },
                            label = { Text(screen.title) },
                            selected = currentRoute == screen.route,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = MochaBrown,
                                selectedTextColor = MochaBrown,
                                indicatorColor = MochaBrown.copy(alpha = 0.1f),
                                unselectedIconColor = Color.Gray,
                                unselectedTextColor = Color.Gray
                            )
                        )
                    }

                    // Add button in the middle (matching iOS)
                    Box(
                        modifier = Modifier.weight(1f),
                        contentAlignment = Alignment.Center
                    ) {
                        FloatingActionButton(
                            onClick = { showAddMenu = true },
                            containerColor = MochaBrown,
                            contentColor = Color.White,
                            modifier = Modifier
                                .size(56.dp)
                                .offset(y = (-8).dp)
                        ) {
                            Icon(
                                Icons.Default.Add,
                                contentDescription = "Add",
                                modifier = Modifier.size(28.dp)
                            )
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable("onboarding") {
                OnboardingScreen(
                    navController = navController,
                    preferencesManager = preferencesManager
                )
            }

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
                MoreScreen(navController, preferencesManager)
            }

            // Profile & Settings
            composable("profile") {
                ProfileScreen(navController = navController)
            }

            composable("goals") {
                GoalsScreen(navController = navController)
            }

            composable("settings") {
                ComingSoonScreen(
                    title = "Settings",
                    message = "App settings and preferences",
                    navController = navController
                )
            }

            composable("food_preferences") {
                ComingSoonScreen(
                    title = "Food Preferences",
                    message = "Manage your dietary preferences and restrictions",
                    navController = navController
                )
            }

            composable("reminders") {
                ComingSoonScreen(
                    title = "Reminders",
                    message = "Set meal and water reminders",
                    navController = navController
                )
            }

            // Food & Nutrition
            composable("food_search/{mealType}") { backStackEntry ->
                val mealType = try {
                    MealType.valueOf(
                        backStackEntry.arguments?.getString("mealType") ?: "BREAKFAST"
                    )
                } catch (e: Exception) {
                    MealType.BREAKFAST
                }
                FoodSearchScreen(
                    navController = navController,
                    mealType = mealType
                )
            }

            composable("food_database") {
                ComingSoonScreen(
                    title = "Food Database",
                    message = "Browse and search our extensive food database",
                    navController = navController
                )
            }

            composable("recipes") {
                ComingSoonScreen(
                    title = "Recipes",
                    message = "Discover healthy recipes",
                    navController = navController
                )
            }

            composable("add_custom_food") {
                ComingSoonScreen(
                    title = "Add Custom Food",
                    message = "Create your own food entries",
                    navController = navController
                )
            }

            composable("barcode_scanner/{mealType}") {
                ComingSoonScreen(
                    title = "Barcode Scanner",
                    message = "Scan food barcodes for quick entry",
                    navController = navController
                )
            }

            // Exercise & Activity
            composable("exercise") {
                ExerciseTrackingScreen(navController = navController)
            }

            composable("exercise_search") {
                ComingSoonScreen(
                    title = "Exercise Search",
                    message = "Find and log exercises",
                    navController = navController
                )
            }

            // Weight & Measurements
            composable("weight") {
                WeightTrackingScreen(navController = navController)
            }

            composable("weight_entry") {
                WeightTrackingScreen(navController = navController)
            }

            // Water & Hydration
            composable("water") {
                ComingSoonScreen(
                    title = "Water Tracking",
                    message = "Track your daily water intake",
                    navController = navController
                )
            }

            composable("water_entry") {
                ComingSoonScreen(
                    title = "Water Entry",
                    message = "Log your water consumption",
                    navController = navController
                )
            }

            // Supplements
            composable("supplements") {
                ComingSoonScreen(
                    title = "Supplements",
                    message = "Track your supplements and vitamins",
                    navController = navController
                )
            }

            composable("supplement_entry") {
                ComingSoonScreen(
                    title = "Supplement Entry",
                    message = "Log your supplements",
                    navController = navController
                )
            }

            // Progress & Reports
            composable("progress") {
                ComingSoonScreen(
                    title = "Progress Charts",
                    message = "View your fitness progress over time",
                    navController = navController
                )
            }

            composable("export") {
                ComingSoonScreen(
                    title = "Export Data",
                    message = "Export your health data",
                    navController = navController
                )
            }

            // Help & Support
            composable("help") {
                ComingSoonScreen(
                    title = "Help & Support",
                    message = "Get help with using the app",
                    navController = navController
                )
            }

            composable("about") {
                ComingSoonScreen(
                    title = "About",
                    message = "Learn more about ML Fitness",
                    navController = navController
                )
            }

            composable("privacy") {
                ComingSoonScreen(
                    title = "Privacy Policy",
                    message = "Review our privacy policy",
                    navController = navController
                )
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
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        AddMenuContent(
            onDismiss = onDismiss,
            navController = navController
        )
    }
}

@Composable
fun AddMenuContent(
    onDismiss: () -> Unit,
    navController: androidx.navigation.NavController
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text(
                "Quick Add",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.Restaurant,
                title = "Food",
                subtitle = "Log meals and snacks",
                color = MochaBrown,
                onClick = {
                    onDismiss()
                    navController.navigate("food_search/SNACK")
                }
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.FitnessCenter,
                title = "Exercise",
                subtitle = "Track your workouts",
                color = ExerciseOrange,
                onClick = {
                    onDismiss()
                    navController.navigate("exercise")
                }
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.MonitorWeight,
                title = "Weight",
                subtitle = "Log your weight",
                color = MochaBrown,
                onClick = {
                    onDismiss()
                    navController.navigate("weight")
                }
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.LocalDrink,
                title = "Water",
                subtitle = "Track hydration",
                color = WaterBlue,
                onClick = {
                    onDismiss()
                    navController.navigate("water")
                }
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.Medication,
                title = "Supplements",
                subtitle = "Log vitamins and supplements",
                color = SupplementPurple,
                onClick = {
                    onDismiss()
                    navController.navigate("supplements")
                }
            )
        }

        item {
            AddMenuItem(
                icon = Icons.Default.QrCodeScanner,
                title = "Barcode Scanner",
                subtitle = "Scan food barcodes",
                color = WarningOrange,
                onClick = {
                    onDismiss()
                    navController.navigate("barcode_scanner/SNACK")
                }
            )
        }

        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
fun AddMenuItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = color.copy(alpha = 0.1f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = title,
                    tint = color,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    title,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    subtitle,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}