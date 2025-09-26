package com.mochasmindlab.mlhealth.ui.screens.goals

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.mochasmindlab.mlhealth.data.models.Goal
import com.mochasmindlab.mlhealth.data.models.GoalType
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.GoalsViewModel
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GoalsScreen(
    navController: NavController,
    viewModel: GoalsViewModel = hiltViewModel()
) {
    var showAddGoalDialog by remember { mutableStateOf(false) }
    val goals by viewModel.goals.collectAsState()
    val activeGoals = goals.filter { it.isActive }
    val completedGoals = goals.filter { !it.isActive }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Goals",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddGoalDialog = true },
                containerColor = MochaBrown
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = "Add Goal",
                    tint = Color.White
                )
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Goals Summary
            item {
                GoalsSummaryCard(
                    totalGoals = goals.size,
                    activeGoals = activeGoals.size,
                    completedGoals = completedGoals.size
                )
            }

            // Quick Goals
            item {
                Text(
                    "Quick Goals",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MochaBrown
                )
            }

            item {
                QuickGoalsSection(
                    onQuickGoalSelected = { goalType ->
                        showAddGoalDialog = true
                    }
                )
            }

            // Active Goals
            if (activeGoals.isNotEmpty()) {
                item {
                    Text(
                        "Active Goals",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MochaBrown
                    )
                }

                items(activeGoals) { goal ->
                    GoalCard(
                        goal = goal,
                        onClick = {
                            navController.navigate("goal_detail/${goal.id}")
                        },
                        onToggleComplete = {
                            viewModel.toggleGoalComplete(goal.id)
                        },
                        onDelete = {
                            viewModel.deleteGoal(goal.id)
                        }
                    )
                }
            }

            // Completed Goals
            if (completedGoals.isNotEmpty()) {
                item {
                    Text(
                        "Completed Goals",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = SuccessGreen
                    )
                }

                items(completedGoals) { goal ->
                    GoalCard(
                        goal = goal,
                        onClick = {
                            navController.navigate("goal_detail/${goal.id}")
                        },
                        onToggleComplete = {
                            viewModel.toggleGoalComplete(goal.id)
                        },
                        onDelete = {
                            viewModel.deleteGoal(goal.id)
                        },
                        isCompleted = true
                    )
                }
            }

            // Achievements
            item {
                AchievementsSection(
                    navController = navController
                )
            }
        }
    }

    if (showAddGoalDialog) {
        AddGoalDialog(
            onDismiss = { showAddGoalDialog = false },
            onAdd = { goalType, target, duration ->
                viewModel.addGoal(goalType, target, duration)
                showAddGoalDialog = false
            }
        )
    }
}

@Composable
fun GoalsSummaryCard(
    totalGoals: Int,
    activeGoals: Int,
    completedGoals: Int
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MochaBrown.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Goals Overview",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = MochaBrown
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatColumn(
                    value = "$totalGoals",
                    label = "Total",
                    color = MochaBrown
                )
                StatColumn(
                    value = "$activeGoals",
                    label = "Active",
                    color = WarningOrange
                )
                StatColumn(
                    value = "$completedGoals",
                    label = "Completed",
                    color = SuccessGreen
                )
            }

            if (totalGoals > 0) {
                Spacer(modifier = Modifier.height(12.dp))

                val progress = completedGoals.toFloat() / totalGoals
                LinearProgressIndicator(
                    progress = progress,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(RoundedCornerShape(4.dp)),
                    color = SuccessGreen,
                    trackColor = SuccessGreen.copy(alpha = 0.2f)
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    "${(progress * 100).roundToInt()}% Complete",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.align(Alignment.End)
                )
            }
        }
    }
}

@Composable
fun StatColumn(
    value: String,
    label: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            value,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun QuickGoalsSection(
    onQuickGoalSelected: (GoalType) -> Unit
) {
    val quickGoals = listOf(
        Triple(GoalType.WEIGHT_LOSS, "Lose Weight", "🎯"),
        Triple(GoalType.CALORIES, "Calorie Goal", "🔥"),
        Triple(GoalType.EXERCISE, "Exercise More", "💪"),
        Triple(GoalType.WATER, "Drink Water", "💧"),
        Triple(GoalType.STEPS, "Daily Steps", "🚶"),
        Triple(GoalType.NUTRITION, "Eat Healthy", "🥗")
    )

    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(quickGoals.size) { index ->
            val (type, label, emoji) = quickGoals[index]
            QuickGoalCard(
                label = label,
                emoji = emoji,
                onClick = { onQuickGoalSelected(type) }
            )
        }
    }
}

@Composable
fun QuickGoalCard(
    label: String,
    emoji: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .width(100.dp)
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(emoji, fontSize = 24.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                label,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1
            )
        }
    }
}

@Composable
fun GoalCard(
    goal: Goal,
    onClick: () -> Unit,
    onToggleComplete: () -> Unit,
    onDelete: () -> Unit,
    isCompleted: Boolean = false
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = if (isCompleted)
                SuccessGreen.copy(alpha = 0.1f)
            else MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    // Goal Icon
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(
                                if (isCompleted) SuccessGreen
                                else goal.getColor().copy(alpha = 0.2f)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        if (isCompleted) {
                            Icon(
                                Icons.Default.Check,
                                contentDescription = "Completed",
                                tint = Color.White,
                                modifier = Modifier.size(24.dp)
                            )
                        } else {
                            Text(
                                goal.getEmoji(),
                                fontSize = 20.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column(
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            goal.title,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (isCompleted) SuccessGreen else Color.Unspecified
                        )
                        Text(
                            goal.description,
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                Row {
                    IconButton(
                        onClick = onToggleComplete,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            if (isCompleted) Icons.Default.Replay else Icons.Default.CheckCircle,
                            contentDescription = if (isCompleted) "Mark Incomplete" else "Mark Complete",
                            tint = if (isCompleted) WarningOrange else SuccessGreen,
                            modifier = Modifier.size(20.dp)
                        )
                    }

                    IconButton(
                        onClick = onDelete,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            Icons.Default.Delete,
                            contentDescription = "Delete",
                            tint = ErrorRed,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }

            if (!isCompleted && goal.progress > 0) {
                Spacer(modifier = Modifier.height(12.dp))

                // Progress Bar
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            "Progress",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            "${goal.progress}%",
                            fontSize = 12.sp,
                            color = goal.getColor()
                        )
                    }

                    Spacer(modifier = Modifier.height(4.dp))

                    LinearProgressIndicator(
                        progress = goal.progress / 100f,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = goal.getColor(),
                        trackColor = goal.getColor().copy(alpha = 0.2f)
                    )
                }
            }

            if (goal.deadline != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.Schedule,
                        contentDescription = "Deadline",
                        modifier = Modifier.size(14.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        goal.getDeadlineText(),
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}

@Composable
fun AchievementsSection(
    navController: NavController
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { navController.navigate("achievements") },
        colors = CardDefaults.cardColors(
            containerColor = GoldStar.copy(alpha = 0.1f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("🏆", fontSize = 24.sp)
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(
                        "Achievements",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        "View your earned badges",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = "View Achievements",
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun AddGoalDialog(
    onDismiss: () -> Unit,
    onAdd: (GoalType, String, Int) -> Unit
) {
    var selectedType by remember { mutableStateOf(GoalType.WEIGHT_LOSS) }
    var target by remember { mutableStateOf("") }
    var duration by remember { mutableStateOf("30") }
    var expanded by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text("Add New Goal")
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Goal Type Dropdown
                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { expanded = !expanded }
                ) {
                    OutlinedTextField(
                        value = selectedType.displayName,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Goal Type") },
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
                        GoalType.values().forEach { type ->
                            DropdownMenuItem(
                                text = { Text(type.displayName) },
                                onClick = {
                                    selectedType = type
                                    expanded = false
                                }
                            )
                        }
                    }
                }

                // Target Input
                OutlinedTextField(
                    value = target,
                    onValueChange = { target = it },
                    label = { Text(getTargetLabel(selectedType)) },
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Number
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                // Duration Input
                OutlinedTextField(
                    value = duration,
                    onValueChange = { duration = it },
                    label = { Text("Duration (days)") },
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Number
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (target.isNotEmpty() && duration.isNotEmpty()) {
                        onAdd(selectedType, target, duration.toIntOrNull() ?: 30)
                    }
                }
            ) {
                Text("Add", color = MochaBrown)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

fun getTargetLabel(type: GoalType): String {
    return when (type) {
        GoalType.WEIGHT_LOSS -> "Target Weight (lbs)"
        GoalType.CALORIES -> "Daily Calories"
        GoalType.EXERCISE -> "Minutes per Day"
        GoalType.WATER -> "Cups per Day"
        GoalType.STEPS -> "Steps per Day"
        GoalType.NUTRITION -> "Healthy Meals per Week"
    }
}

fun Goal.getColor(): Color {
    return when (type) {
        GoalType.WEIGHT_LOSS -> MochaBrown
        GoalType.CALORIES -> ExerciseOrange
        GoalType.EXERCISE -> ExerciseOrange
        GoalType.WATER -> WaterBlue
        GoalType.STEPS -> StepsGreen
        GoalType.NUTRITION -> CarbsGreen
    }
}

fun Goal.getEmoji(): String {
    return when (type) {
        GoalType.WEIGHT_LOSS -> "⚖️"
        GoalType.CALORIES -> "🔥"
        GoalType.EXERCISE -> "💪"
        GoalType.WATER -> "💧"
        GoalType.STEPS -> "🚶"
        GoalType.NUTRITION -> "🥗"
    }
}

fun Goal.getDeadlineText(): String {
    return deadline?.let {
        val daysLeft = java.time.temporal.ChronoUnit.DAYS.between(
            java.time.LocalDate.now(),
            it
        )
        when {
            daysLeft < 0 -> "Overdue"
            daysLeft == 0L -> "Today"
            daysLeft == 1L -> "1 day left"
            else -> "$daysLeft days left"
        }
    } ?: "No deadline"
}