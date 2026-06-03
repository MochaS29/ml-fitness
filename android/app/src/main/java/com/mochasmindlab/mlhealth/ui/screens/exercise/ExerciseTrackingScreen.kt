package com.mochasmindlab.mlhealth.ui.screens.exercise

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
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
import com.mochasmindlab.mlhealth.data.entities.ExerciseEntry
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.ExerciseViewModel
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExerciseTrackingScreen(
    navController: NavController,
    viewModel: ExerciseViewModel = hiltViewModel()
) {
    var selectedDate by remember { mutableStateOf(LocalDate.now()) }
    var showQuickAdd by remember { mutableStateOf(false) }
    var prefilledExerciseName by remember { mutableStateOf<String?>(null) }
    val exerciseEntries by viewModel.todayExercises.collectAsState()
    val totalCaloriesBurned by viewModel.totalCaloriesBurned.collectAsState()
    val totalMinutes by viewModel.totalMinutes.collectAsState()
    val weeklyStats by viewModel.weeklyStats.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Exercise Tracking",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { showQuickAdd = true }) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add Exercise",
                            tint = ExerciseOrange
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
            // Date Selector
            item {
                DateSelector(
                    selectedDate = selectedDate,
                    onDateChange = {
                        selectedDate = it
                        viewModel.loadExercisesForDate(it)
                    }
                )
            }

            // Today's Summary
            item {
                ExerciseSummaryCard(
                    totalCalories = totalCaloriesBurned,
                    totalMinutes = totalMinutes,
                    exerciseCount = exerciseEntries.size
                )
            }

            // Quick Add Options
            item {
                Text(
                    "Quick Add",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = ExerciseOrange
                )
            }

            item {
                QuickExerciseOptions(
                    onExerciseSelected = { exercise ->
                        // Open the QuickAdd dialog pre-filled with the chosen exercise.
                        prefilledExerciseName = exercise
                        showQuickAdd = true
                    }
                )
            }

            // Today's Exercises
            if (exerciseEntries.isNotEmpty()) {
                item {
                    Text(
                        "Today's Exercises",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = ExerciseOrange
                    )
                }

                items(exerciseEntries) { exercise ->
                    ExerciseEntryCard(
                        exercise = exercise,
                        onEdit = {
                            // Edit screen not yet built — re-open QuickAdd seeded with the
                            // existing entry's name. User can re-log; deleting is via the
                            // delete button.
                            prefilledExerciseName = exercise.name
                            showQuickAdd = true
                        },
                        onDelete = {
                            viewModel.deleteExercise(exercise)
                        }
                    )
                }
            }

            // Weekly Overview
            item {
                WeeklyExerciseChart(
                    weeklyStats = weeklyStats
                )
            }

            // Popular Workouts
            item {
                Text(
                    "Popular Workouts",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = ExerciseOrange
                )
            }

            item {
                PopularWorkoutsSection(
                    onWorkoutClick = { workout ->
                        prefilledExerciseName = workout
                        showQuickAdd = true
                    }
                )
            }
        }
    }

    if (showQuickAdd) {
        QuickAddExerciseDialog(
            initialName = prefilledExerciseName.orEmpty(),
            onDismiss = {
                showQuickAdd = false
                prefilledExerciseName = null
            },
            onAdd = { name, duration, calories ->
                viewModel.quickAddExercise(name, duration, calories)
                showQuickAdd = false
                prefilledExerciseName = null
            }
        )
    }
}

@Composable
fun ExerciseSummaryCard(
    totalCalories: Int,
    totalMinutes: Int,
    exerciseCount: Int
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = ExerciseOrange.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Today's Activity",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = ExerciseOrange
                )
                Text(
                    "💪",
                    fontSize = 24.sp
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatColumn(
                    value = "$totalCalories",
                    label = "Calories",
                    icon = "🔥"
                )
                StatColumn(
                    value = "$totalMinutes",
                    label = "Minutes",
                    icon = "⏱️"
                )
                StatColumn(
                    value = "$exerciseCount",
                    label = "Exercises",
                    icon = "💪"
                )
            }
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
        Text(icon, fontSize = 20.sp)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = ExerciseOrange
        )
        Text(
            label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun QuickExerciseOptions(
    onExerciseSelected: (String) -> Unit
) {
    val quickExercises = listOf(
        "Walking" to "🚶",
        "Running" to "🏃",
        "Cycling" to "🚴",
        "Swimming" to "🏊",
        "Weights" to "🏋️",
        "Yoga" to "🧘",
        "HIIT" to "🔥",
        "Pilates" to "🤸",
        "Dancing" to "💃",
        "Hiking" to "🥾",
        "Tennis" to "🎾",
        "Basketball" to "🏀"
    )

    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(quickExercises.size) { index ->
            val (name, emoji) = quickExercises[index]
            QuickExerciseCard(
                name = name,
                emoji = emoji,
                onClick = { onExerciseSelected(name) }
            )
        }
    }
}

@Composable
fun QuickExerciseCard(
    name: String,
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
                name,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun ExerciseEntryCard(
    exercise: ExerciseEntry,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
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
                    .background(ExerciseOrange.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "💪", // Default emoji
                    fontSize = 24.sp
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    exercise.name,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
                Row {
                    Text(
                        "${exercise.duration} min",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        " • ",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        "${exercise.caloriesBurned} cal",
                        fontSize = 13.sp,
                        color = ExerciseOrange
                    )
                }
            }

            IconButton(onClick = onEdit) {
                Icon(
                    Icons.Default.Edit,
                    contentDescription = "Edit",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = ErrorRed
                )
            }
        }
    }
}

@Composable
fun WeeklyExerciseChart(
    weeklyStats: List<Pair<String, Int>>
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Weekly Overview",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.Bottom
            ) {
                weeklyStats.forEach { (day, minutes) ->
                    WeeklyBar(
                        day = day,
                        minutes = minutes,
                        maxMinutes = weeklyStats.maxOf { it.second }
                    )
                }
            }
        }
    }
}

@Composable
fun WeeklyBar(
    day: String,
    minutes: Int,
    maxMinutes: Int
) {
    val height = if (maxMinutes > 0) {
        (minutes.toFloat() / maxMinutes) * 100
    } else 0f

    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .width(32.dp)
                .height(100.dp),
            contentAlignment = Alignment.BottomCenter
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(height / 100)
                    .background(
                        if (minutes > 0) ExerciseOrange else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                        RoundedCornerShape(topStart = 4.dp, topEnd = 4.dp)
                    )
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            day,
            fontSize = 11.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        if (minutes > 0) {
            Text(
                "${minutes}m",
                fontSize = 10.sp,
                color = ExerciseOrange
            )
        }
    }
}

@Composable
fun PopularWorkoutsSection(
    onWorkoutClick: (String) -> Unit
) {
    val workouts = listOf(
        "Full Body Workout" to "45 min",
        "Upper Body" to "30 min",
        "Lower Body" to "35 min",
        "Core & Abs" to "20 min",
        "HIIT Cardio" to "25 min"
    )

    Column(
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        workouts.forEach { (name, duration) ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onWorkoutClick(name) }
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(name, fontSize = 14.sp)
                    Text(
                        duration,
                        fontSize = 13.sp,
                        color = ExerciseOrange
                    )
                }
            }
        }
    }
}

@Composable
fun QuickAddExerciseDialog(
    initialName: String = "",
    onDismiss: () -> Unit,
    onAdd: (name: String, duration: Int, calories: Int) -> Unit
) {
    var exerciseName by remember(initialName) { mutableStateOf(initialName) }
    var duration by remember { mutableStateOf("") }
    var calories by remember { mutableStateOf("") }
    var caloriesEdited by remember { mutableStateOf(false) }

    // Auto-fill calories from a MET-based estimate whenever name or duration changes,
    // unless the user has manually overridden the value.
    LaunchedEffect(exerciseName, duration) {
        if (!caloriesEdited) {
            val mins = duration.toIntOrNull()
            calories = if (mins != null && mins > 0 && exerciseName.isNotBlank()) {
                estimateCaloriesBurned(exerciseName, mins).toString()
            } else {
                ""
            }
        }
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text("Quick Add Exercise")
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedTextField(
                    value = exerciseName,
                    onValueChange = { exerciseName = it },
                    label = { Text("Exercise Name") },
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = duration,
                    onValueChange = { duration = it.filter(Char::isDigit).take(4) },
                    label = { Text("Duration (minutes)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = calories,
                    onValueChange = {
                        calories = it.filter(Char::isDigit).take(5)
                        caloriesEdited = true
                    },
                    label = { Text("Calories Burned") },
                    supportingText = {
                        if (!caloriesEdited && calories.isNotEmpty()) {
                            Text("Estimated — tap to adjust", fontSize = 11.sp)
                        }
                    },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (exerciseName.isNotEmpty() && duration.isNotEmpty()) {
                        onAdd(
                            exerciseName,
                            duration.toIntOrNull() ?: 0,
                            calories.toIntOrNull() ?: 0
                        )
                    }
                }
            ) {
                Text("Add", color = ExerciseOrange)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

/**
 * Rough calories-burned estimate from exercise name + duration in minutes.
 * Uses MET (Metabolic Equivalent of Task) values for an average ~70kg adult:
 *   calories = MET × weight_kg × hours
 * Matches the iOS app's approach so the user doesn't have to look up burn rates.
 */
private fun estimateCaloriesBurned(exerciseName: String, durationMinutes: Int): Int {
    val name = exerciseName.lowercase()
    val met = when {
        "run" in name || "jog" in name -> 9.8
        "cycl" in name || "bike" in name || "spin" in name -> 7.5
        "swim" in name -> 7.0
        "walk" in name || "hike" in name -> 3.8
        "yoga" in name || "stretch" in name -> 2.5
        "pilates" in name -> 3.0
        "dance" in name -> 5.5
        "row" in name -> 7.0
        "elliptical" in name -> 5.0
        "weight" in name || "strength" in name || "lift" in name || "gym" in name -> 5.0
        "hiit" in name || "crossfit" in name -> 8.0
        "tennis" in name || "soccer" in name || "basketball" in name -> 7.0
        else -> 5.0 // Reasonable default for "general" activity
    }
    val weightKg = 70.0
    return (met * weightKg * (durationMinutes / 60.0)).toInt()
}

@Composable
fun DateSelector(
    selectedDate: LocalDate,
    onDateChange: (LocalDate) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { onDateChange(selectedDate.minusDays(1)) }) {
                Icon(
                    Icons.Default.ChevronLeft,
                    contentDescription = "Previous Day"
                )
            }

            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = selectedDate.format(DateTimeFormatter.ofPattern("EEEE")),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = selectedDate.format(DateTimeFormatter.ofPattern("MMM d, yyyy")),
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                if (selectedDate == LocalDate.now()) {
                    Text(
                        text = "Today",
                        fontSize = 12.sp,
                        color = ExerciseOrange
                    )
                }
            }

            IconButton(
                onClick = { onDateChange(selectedDate.plusDays(1)) },
                enabled = selectedDate < LocalDate.now()
            ) {
                Icon(
                    Icons.Default.ChevronRight,
                    contentDescription = "Next Day"
                )
            }
        }
    }
}