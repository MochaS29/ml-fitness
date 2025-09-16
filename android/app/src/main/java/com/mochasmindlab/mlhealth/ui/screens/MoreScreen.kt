package com.mochasmindlab.mlhealth.ui.screens

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(
    navController: NavController,
    preferencesManager: PreferencesManager
) {
    val scope = rememberCoroutineScope()
    var userProfile by remember { mutableStateOf<com.mochasmindlab.mlhealth.utils.UserProfile?>(null) }
    
    LaunchedEffect(Unit) {
        userProfile = preferencesManager.userProfile.first()
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "More",
                        fontWeight = FontWeight.Bold
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MindLabsPurple,
                    titleContentColor = Color.White
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Profile Section
            item {
                ProfileCard(
                    userName = userProfile?.name ?: "User",
                    onClick = {
                        navController.navigate("profile")
                    }
                )
            }
            
            // Goals & Progress
            item {
                SectionTitle("Goals & Progress")
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Flag,
                    title = "My Goals",
                    subtitle = "View and manage your health goals",
                    iconColor = ExerciseGreen,
                    onClick = { navController.navigate("goals") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.EmojiEvents,
                    title = "Achievements",
                    subtitle = "View your earned badges",
                    iconColor = GoldStar,
                    onClick = { navController.navigate("achievements") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.TrendingUp,
                    title = "Progress Reports",
                    subtitle = "View detailed analytics",
                    iconColor = MindfulTeal,
                    onClick = { navController.navigate("reports") }
                )
            }
            
            // Nutrition
            item {
                SectionTitle("Nutrition")
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.MenuBook,
                    title = "My Recipe Book",
                    subtitle = "Saved recipes and custom foods",
                    iconColor = NutritionGreen,
                    onClick = { navController.navigate("recipes") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.CalendarMonth,
                    title = "Meal Planner",
                    subtitle = "Plan your weekly meals",
                    iconColor = EnergeticOrange,
                    onClick = { navController.navigate("meal_planner") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.ShoppingCart,
                    title = "Grocery List",
                    subtitle = "Generate shopping lists",
                    iconColor = MindLabsPurple,
                    onClick = { navController.navigate("grocery_list") }
                )
            }
            
            // Health Tools
            item {
                SectionTitle("Health Tools")
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Timer,
                    title = "Intermittent Fasting",
                    subtitle = "Track fasting windows",
                    iconColor = FastingOrange,
                    onClick = { navController.navigate("fasting") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Bedtime,
                    title = "Sleep Tracking",
                    subtitle = "Monitor sleep patterns",
                    iconColor = SleepBlue,
                    onClick = { navController.navigate("sleep") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Medication,
                    title = "Supplement Regimes",
                    subtitle = "Manage daily supplement routines",
                    iconColor = SupplementPurple,
                    onClick = { navController.navigate("supplement_regimes") }
                )
            }
            
            // Settings
            item {
                SectionTitle("Settings")
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Notifications,
                    title = "Notifications",
                    subtitle = "Manage reminders and alerts",
                    iconColor = Color.Gray,
                    onClick = { navController.navigate("notifications") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.SetMeal,
                    title = "Food Preferences",
                    subtitle = "Dietary restrictions and allergies",
                    iconColor = Color.Gray,
                    onClick = { navController.navigate("food_preferences") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Download,
                    title = "Export Data",
                    subtitle = "Download your health data",
                    iconColor = Color.Gray,
                    onClick = { navController.navigate("export") }
                )
            }
            
            item {
                MenuItemCard(
                    icon = Icons.Default.Info,
                    title = "About",
                    subtitle = "App version and info",
                    iconColor = Color.Gray,
                    onClick = { navController.navigate("about") }
                )
            }
            
            // Sign Out
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable {
                            scope.launch {
                                preferencesManager.clearAllPreferences()
                                navController.navigate("onboarding") {
                                    popUpTo(0) { inclusive = true }
                                }
                            }
                        },
                    colors = CardDefaults.cardColors(
                        containerColor = Color.Red.copy(alpha = 0.1f)
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.Logout,
                            contentDescription = "Sign Out",
                            tint = Color.Red,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(16.dp))
                        Text(
                            "Sign Out",
                            color = Color.Red,
                            fontWeight = FontWeight.Medium,
                            fontSize = 16.sp
                        )
                    }
                }
            }
            
            // Version info
            item {
                Text(
                    "Version 1.0.0",
                    fontSize = 12.sp,
                    color = Color.Gray,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )
            }
        }
    }
}

@Composable
private fun ProfileCard(
    userName: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = MindLabsPurple.copy(alpha = 0.1f)
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
                    .size(60.dp)
                    .clip(CircleShape)
                    .background(MindLabsPurple),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    userName.firstOrNull()?.uppercase() ?: "U",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    userName,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    "View Profile",
                    fontSize = 14.sp,
                    color = MindLabsPurple
                )
            }
            
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = MindLabsPurple
            )
        }
    }
}

@Composable
private fun SectionTitle(title: String) {
    Text(
        title,
        fontSize = 14.sp,
        fontWeight = FontWeight.Bold,
        color = Color.Gray,
        modifier = Modifier.padding(horizontal = 4.dp, vertical = 8.dp)
    )
}

@Composable
private fun MenuItemCard(
    icon: ImageVector,
    title: String,
    subtitle: String,
    iconColor: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(iconColor.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = title,
                    tint = iconColor,
                    modifier = Modifier.size(20.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    title,
                    fontWeight = FontWeight.Medium,
                    fontSize = 16.sp
                )
                Text(
                    subtitle,
                    fontSize = 14.sp,
                    color = Color.Gray
                )
            }
            
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = Color.Gray.copy(alpha = 0.5f),
                modifier = Modifier.size(20.dp)
            )
        }
    }
}