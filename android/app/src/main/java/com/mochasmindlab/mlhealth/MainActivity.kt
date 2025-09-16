package com.mochasmindlab.mlhealth

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.mochasmindlab.mlhealth.ui.screens.*
import androidx.compose.material3.Text
import com.mochasmindlab.mlhealth.ui.theme.MLHealthTheme
import com.mochasmindlab.mlhealth.ui.theme.MindLabsPurple
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import com.mochasmindlab.mlhealth.utils.SampleDataGenerator
import com.mochasmindlab.mlhealth.viewmodel.DashboardViewModel
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    
    @Inject
    lateinit var preferencesManager: PreferencesManager
    
    @Inject
    lateinit var sampleDataGenerator: SampleDataGenerator
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Generate sample data for demonstration
        // Comment this out for production
        sampleDataGenerator.generateSampleData()
        
        // Check if onboarding is completed
        val startDestination = runBlocking {
            if (preferencesManager.isOnboardingCompleted.first()) {
                "dashboard"
            } else {
                "onboarding"
            }
        }
        
        setContent {
            MLHealthTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MLHealthApp(
                        startDestination = startDestination,
                        preferencesManager = preferencesManager
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MLHealthApp(
    startDestination: String,
    preferencesManager: PreferencesManager
) {
    val navController = rememberNavController()
    var showAddMenu by remember { mutableStateOf(false) }
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
    
    // Don't show bottom bar on onboarding
    val showBottomBar = currentRoute != "onboarding"
    
    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                BottomNavigationBar(
                    navController = navController,
                    onAddClick = { showAddMenu = true }
                )
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = Modifier.padding(paddingValues)
        ) {
            composable("onboarding") {
                OnboardingScreen(
                    navController = navController,
                    preferencesManager = preferencesManager
                )
            }
            
            composable("dashboard") {
                val viewModel: DashboardViewModel = hiltViewModel()
                FunctionalDashboardScreen(
                    navController = navController,
                    viewModel = viewModel
                )
            }
            
            composable("diary") {
                DiaryScreen(
                    navController = navController
                )
            }
            
            composable("meal_plan") {
                MealPlanScreen(navController = navController)
            }
            
            composable("more") {
                MoreScreen(
                    navController = navController,
                    preferencesManager = preferencesManager
                )
            }
            
            // Quick Add destinations
            composable("food_entry") {
                // TODO: Implement FoodEntryScreen
                Text("Food Entry - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("water_intake") {
                // TODO: Implement WaterIntakeScreen
                Text("Water Intake - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("water") {
                // Navigate to diary with water tab selected
                DiaryScreen(navController = navController)
            }
            
            composable("nutrition") {
                // Navigate to diary for food tracking
                DiaryScreen(navController = navController)
            }
            
            composable("exercise") {
                ComingSoonScreen(
                    title = "Exercise Tracking",
                    message = "Track your workouts, monitor progress, and achieve your fitness goals!",
                    navController = navController
                )
            }
            
            composable("weight") {
                ComingSoonScreen(
                    title = "Weight Tracking",
                    message = "Monitor your weight trends and track your progress towards your goals.",
                    navController = navController
                )
            }
            
            composable("weight_tracking") {
                // TODO: Implement WeightTrackingScreen
                Text("Weight Tracking - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("supplements") {
                // TODO: Implement SupplementsScreen
                Text("Supplements - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("fasting") {
                // TODO: Implement FastingScreen
                Text("Fasting - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("barcode_scanner") {
                // TODO: Implement BarcodeScannerScreen
                Text("Barcode Scanner - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            // More screen destinations
            composable("profile") {
                // TODO: Implement ProfileScreen
                Text("Profile - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("goals") {
                // TODO: Implement GoalsScreen
                Text("Goals - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("achievements") {
                // TODO: Implement AchievementsScreen
                Text("Achievements - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("reports") {
                // TODO: Implement ReportsScreen
                Text("Progress Reports - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("recipes") {
                MealPlanScreen(navController = navController)
            }
            
            composable("add_recipe") {
                MealPlanScreen(navController = navController)
            }
            
            composable("meal_planner") {
                // TODO: Implement MealPlannerScreen
                Text("Meal Planner - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("grocery_list") {
                // TODO: Implement GroceryListScreen
                Text("Grocery List - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("sleep") {
                // TODO: Implement SleepScreen
                Text("Sleep Tracking - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("notifications") {
                // TODO: Implement NotificationsScreen
                Text("Notifications - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("food_preferences") {
                // TODO: Implement FoodPreferencesScreen
                Text("Food Preferences - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("export") {
                // TODO: Implement ExportScreen
                Text("Export Data - Coming Soon", modifier = Modifier.padding(16.dp))
            }
            
            composable("about") {
                // TODO: Implement AboutScreen
                Text("About - Coming Soon", modifier = Modifier.padding(16.dp))
            }
        }
    }
    
    if (showAddMenu) {
        AddMenuScreen(
            navController = navController,
            onDismiss = { showAddMenu = false }
        )
    }
}

@Composable
fun BottomNavigationBar(
    navController: NavController,
    onAddClick: () -> Unit
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination
    
    val items = listOf(
        BottomNavItem("dashboard", "Dashboard", Icons.Default.Home),
        BottomNavItem("diary", "Diary", Icons.Default.Book),
        BottomNavItem("add", "", Icons.Default.Add), // Special center button
        BottomNavItem("meal_plan", "Plan", Icons.Default.CalendarMonth),
        BottomNavItem("more", "More", Icons.Default.MoreHoriz)
    )
    
    NavigationBar(
        containerColor = MaterialTheme.colorScheme.surface,
        contentColor = MaterialTheme.colorScheme.onSurface
    ) {
        items.forEach { item ->
            if (item.route == "add") {
                // Special center add button
                Box(
                    modifier = Modifier.weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    FloatingActionButton(
                        onClick = onAddClick,
                        containerColor = MindLabsPurple,
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
            } else {
                NavigationBarItem(
                    selected = currentDestination?.hierarchy?.any { it.route == item.route } == true,
                    onClick = {
                        navController.navigate(item.route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    icon = {
                        Icon(
                            item.icon,
                            contentDescription = item.label
                        )
                    },
                    label = {
                        Text(item.label)
                    },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = MindLabsPurple,
                        selectedTextColor = MindLabsPurple,
                        indicatorColor = MindLabsPurple.copy(alpha = 0.1f),
                        unselectedIconColor = Color.Gray,
                        unselectedTextColor = Color.Gray
                    )
                )
            }
        }
    }
}

data class BottomNavItem(
    val route: String,
    val label: String,
    val icon: ImageVector
)