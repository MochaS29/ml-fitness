package com.mochasmindlab.mlhealth.ui.screens.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.UserProfile
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.ProfileViewModel
import java.time.LocalDate
import java.time.Period
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    navController: NavController,
    viewModel: ProfileViewModel = hiltViewModel()
) {
    var isEditing by remember { mutableStateOf(false) }
    val userProfile by viewModel.userProfile.collectAsState()
    val dailyCalorieGoal by viewModel.dailyCalorieGoal.collectAsState()
    val currentStreak by viewModel.currentStreak.collectAsState()
    val totalDaysTracked by viewModel.totalDaysTracked.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Profile",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
                            if (isEditing) {
                                viewModel.saveProfile()
                            }
                            isEditing = !isEditing
                        }
                    ) {
                        Icon(
                            if (isEditing) Icons.Default.Check else Icons.Default.Edit,
                            contentDescription = if (isEditing) "Save" else "Edit"
                        )
                    }
                }
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
            // Profile Header
            item {
                ProfileHeaderCard(
                    userProfile = userProfile,
                    isEditing = isEditing,
                    onProfileUpdate = { updatedProfile ->
                        viewModel.updateProfile(updatedProfile)
                    }
                )
            }

            // Stats Overview
            item {
                StatsOverviewCard(
                    currentStreak = currentStreak,
                    totalDaysTracked = totalDaysTracked,
                    memberSince = userProfile.createdDate
                )
            }

            // Body Metrics
            item {
                BodyMetricsCard(
                    userProfile = userProfile,
                    isEditing = isEditing,
                    onMetricsUpdate = { height, weight ->
                        viewModel.updateBodyMetrics(height, weight)
                    }
                )
            }

            // Goals Section
            item {
                GoalsCard(
                    dailyCalorieGoal = dailyCalorieGoal,
                    weightGoal = userProfile.goalWeight,
                    currentWeight = userProfile.currentWeight,
                    onGoalsClick = {
                        navController.navigate("goals")
                    }
                )
            }

            // Dietary Preferences
            item {
                DietaryPreferencesCard(
                    dietType = userProfile.dietType,
                    allergies = userProfile.allergies,
                    onPreferencesClick = {
                        navController.navigate("food_preferences")
                    }
                )
            }

            // Activity Level
            item {
                ActivityLevelCard(
                    activityLevel = userProfile.activityLevel,
                    isEditing = isEditing,
                    onActivityLevelChange = { level ->
                        viewModel.updateActivityLevel(level)
                    }
                )
            }

            // Account Actions
            item {
                AccountActionsCard(
                    onExportData = {
                        navController.navigate("export_data")
                    },
                    onPrivacyPolicy = {
                        navController.navigate("privacy")
                    },
                    onSignOut = {
                        viewModel.signOut()
                        navController.navigate("onboarding") {
                            popUpTo("dashboard") { inclusive = true }
                        }
                    }
                )
            }
        }
    }
}

@Composable
fun ProfileHeaderCard(
    userProfile: UserProfile,
    isEditing: Boolean,
    onProfileUpdate: (UserProfile) -> Unit
) {
    var name by remember(userProfile) { mutableStateOf(userProfile.name) }
    var email by remember(userProfile) { mutableStateOf(userProfile.email) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MochaBrown.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Profile Picture
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .clip(CircleShape)
                    .background(MochaBrown),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    userProfile.name.firstOrNull()?.uppercase() ?: "U",
                    fontSize = 40.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (isEditing) {
                OutlinedTextField(
                    value = name,
                    onValueChange = {
                        name = it
                        onProfileUpdate(userProfile.copy(name = it))
                    },
                    label = { Text("Name") },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = email,
                    onValueChange = {
                        email = it
                        onProfileUpdate(userProfile.copy(email = it))
                    },
                    label = { Text("Email") },
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Email
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            } else {
                Text(
                    userProfile.name,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold
                )

                Text(
                    userProfile.email,
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun StatsOverviewCard(
    currentStreak: Int,
    totalDaysTracked: Int,
    memberSince: LocalDate
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            StatColumn(
                value = "$currentStreak",
                label = "Day Streak",
                icon = "🔥"
            )

            StatColumn(
                value = "$totalDaysTracked",
                label = "Days Tracked",
                icon = "📊"
            )

            val monthsMember = Period.between(memberSince, LocalDate.now()).months
            StatColumn(
                value = "$monthsMember",
                label = "Months",
                icon = "📅"
            )
        }
    }
}

@Composable
fun StatColumn(
    value: String,
    label: String,
    icon: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(icon, fontSize = 24.sp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = MochaBrown
        )
        Text(
            label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun BodyMetricsCard(
    userProfile: UserProfile,
    isEditing: Boolean,
    onMetricsUpdate: (Float, Float) -> Unit
) {
    var height by remember(userProfile) { mutableStateOf(userProfile.height.toString()) }
    var weight by remember(userProfile) { mutableStateOf(userProfile.currentWeight.toString()) }

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Body Metrics",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold
                )

                val bmi = userProfile.currentWeight / ((userProfile.height / 100) * (userProfile.height / 100))
                Text(
                    "BMI: ${String.format("%.1f", bmi)}",
                    fontSize = 14.sp,
                    color = MochaBrown
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            if (isEditing) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    OutlinedTextField(
                        value = height,
                        onValueChange = {
                            height = it
                            val h = it.toFloatOrNull() ?: userProfile.height
                            val w = weight.toFloatOrNull() ?: userProfile.currentWeight
                            onMetricsUpdate(h, w)
                        },
                        label = { Text("Height (cm)") },
                        keyboardOptions = KeyboardOptions(
                            keyboardType = KeyboardType.Number
                        ),
                        modifier = Modifier.weight(1f)
                    )

                    OutlinedTextField(
                        value = weight,
                        onValueChange = {
                            weight = it
                            val h = height.toFloatOrNull() ?: userProfile.height
                            val w = it.toFloatOrNull() ?: userProfile.currentWeight
                            onMetricsUpdate(h, w)
                        },
                        label = { Text("Weight (lbs)") },
                        keyboardOptions = KeyboardOptions(
                            keyboardType = KeyboardType.Decimal
                        ),
                        modifier = Modifier.weight(1f)
                    )
                }
            } else {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    MetricItem(
                        label = "Height",
                        value = "${userProfile.height.toInt()} cm",
                        icon = Icons.Default.Height
                    )

                    MetricItem(
                        label = "Weight",
                        value = "${userProfile.currentWeight} lbs",
                        icon = Icons.Default.MonitorWeight
                    )

                    MetricItem(
                        label = "Age",
                        value = "${Period.between(userProfile.birthDate, LocalDate.now()).years}",
                        icon = Icons.Default.Cake
                    )
                }
            }
        }
    }
}

@Composable
fun MetricItem(
    label: String,
    value: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            icon,
            contentDescription = label,
            tint = MochaBrown,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium
        )
        Text(
            label,
            fontSize = 11.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun GoalsCard(
    dailyCalorieGoal: Int,
    weightGoal: Float,
    currentWeight: Float,
    onGoalsClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onGoalsClick() }
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Goals",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Icon(
                    Icons.Default.ChevronRight,
                    contentDescription = "View Goals",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                GoalItem(
                    label = "Daily Calories",
                    value = "$dailyCalorieGoal",
                    color = MochaBrown
                )

                GoalItem(
                    label = "Weight Goal",
                    value = "${weightGoal.toInt()} lbs",
                    color = SuccessGreen
                )

                val toGo = kotlin.math.abs(weightGoal - currentWeight)
                GoalItem(
                    label = "To Go",
                    value = "${toGo.toInt()} lbs",
                    color = WarningOrange
                )
            }
        }
    }
}

@Composable
fun GoalItem(
    label: String,
    value: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            value,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            label,
            fontSize = 11.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun DietaryPreferencesCard(
    dietType: String,
    allergies: List<String>,
    onPreferencesClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onPreferencesClick() }
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Dietary Preferences",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Icon(
                    Icons.Default.ChevronRight,
                    contentDescription = "Edit Preferences",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                "Diet: $dietType",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            if (allergies.isNotEmpty()) {
                Text(
                    "Allergies: ${allergies.joinToString(", ")}",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun ActivityLevelCard(
    activityLevel: String,
    isEditing: Boolean,
    onActivityLevelChange: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    val activityLevels = listOf(
        "Sedentary" to "Little or no exercise",
        "Lightly Active" to "Exercise 1-3 days/week",
        "Moderately Active" to "Exercise 3-5 days/week",
        "Very Active" to "Exercise 6-7 days/week",
        "Extra Active" to "Very intense exercise daily"
    )

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Activity Level",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(12.dp))

            if (isEditing) {
                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { expanded = !expanded }
                ) {
                    OutlinedTextField(
                        value = activityLevel,
                        onValueChange = {},
                        readOnly = true,
                        trailingIcon = {
                            ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor()
                    )

                    ExposedDropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        activityLevels.forEach { (level, description) ->
                            DropdownMenuItem(
                                text = {
                                    Column {
                                        Text(level)
                                        Text(
                                            description,
                                            fontSize = 12.sp,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant
                                        )
                                    }
                                },
                                onClick = {
                                    onActivityLevelChange(level)
                                    expanded = false
                                }
                            )
                        }
                    }
                }
            } else {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.DirectionsRun,
                        contentDescription = "Activity",
                        tint = MochaBrown
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            activityLevel,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Medium
                        )
                        val description = activityLevels.find { it.first == activityLevel }?.second
                        if (description != null) {
                            Text(
                                description,
                                fontSize = 13.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun AccountActionsCard(
    onExportData: () -> Unit,
    onPrivacyPolicy: () -> Unit,
    onSignOut: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(8.dp)
        ) {
            ListItem(
                headlineContent = { Text("Export Data") },
                leadingContent = {
                    Icon(Icons.Default.Download, contentDescription = "Export")
                },
                modifier = Modifier.clickable { onExportData() }
            )

            Divider()

            ListItem(
                headlineContent = { Text("Privacy Policy") },
                leadingContent = {
                    Icon(Icons.Default.PrivacyTip, contentDescription = "Privacy")
                },
                modifier = Modifier.clickable { onPrivacyPolicy() }
            )

            Divider()

            ListItem(
                headlineContent = {
                    Text(
                        "Sign Out",
                        color = ErrorRed
                    )
                },
                leadingContent = {
                    Icon(
                        Icons.Default.Logout,
                        contentDescription = "Sign Out",
                        tint = ErrorRed
                    )
                },
                modifier = Modifier.clickable { onSignOut() }
            )
        }
    }
}