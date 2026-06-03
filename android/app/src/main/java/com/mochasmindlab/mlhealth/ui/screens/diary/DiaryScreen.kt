package com.mochasmindlab.mlhealth.ui.screens.diary

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import android.content.Intent
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.screens.FoodEntryDisplay
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.DiaryViewModel
import com.mochasmindlab.mlhealth.viewmodel.ExerciseEntryDisplay
import com.mochasmindlab.mlhealth.viewmodel.SupplementEntryDisplay
import com.mochasmindlab.mlhealth.utils.DateConverter
import com.mochasmindlab.mlhealth.utils.DiaryShareFormatter
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DiaryScreen(
    navController: NavController,
    viewModel: DiaryViewModel = hiltViewModel(),
    onAddClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    var selectedDate by remember { mutableStateOf(LocalDate.now()) }
    // Editing dialog state — non-null shows the edit dialog for that entry.
    // Tapping a food row in any meal section sets this; saving / dismissing
    // clears it. Lives at the screen top level so dialogs render over the
    // full Scaffold rather than inside a meal card's clipping bounds.
    var editingFoodEntry by remember { mutableStateOf<FoodEntryDisplay?>(null) }
    var editingExerciseEntry by remember { mutableStateOf<ExerciseEntryDisplay?>(null) }
    var editingSupplementEntry by remember { mutableStateOf<SupplementEntryDisplay?>(null) }

    // Refresh diary contents whenever the screen comes back into the foreground —
    // e.g. after the user logs a food in FoodSearchScreen and pops back here.
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    androidx.compose.runtime.DisposableEffect(lifecycleOwner) {
        val observer = androidx.lifecycle.LifecycleEventObserver { _, event ->
            if (event == androidx.lifecycle.Lifecycle.Event.ON_RESUME) {
                DateConverter.localDateToDate(selectedDate)?.let { viewModel.loadDiaryData(it) }
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Food Diary",
                        fontWeight = FontWeight.Bold
                    )
                },
                actions = {
                    IconButton(onClick = {
                        val text = DiaryShareFormatter.format(uiState)
                        val sendIntent = Intent(Intent.ACTION_SEND).apply {
                            putExtra(Intent.EXTRA_TEXT, text)
                            type = "text/plain"
                        }
                        context.startActivity(Intent.createChooser(sendIntent, "Share diary"))
                    }) {
                        Icon(
                            Icons.Default.Share,
                            contentDescription = "Share diary",
                            tint = MochaBrown
                        )
                    }
                    IconButton(onClick = { navController.navigate("copy_from_previous") }) {
                        Icon(
                            Icons.Default.ContentCopy,
                            contentDescription = "Copy from previous day",
                            tint = MochaBrown
                        )
                    }
                    IconButton(onClick = onAddClick) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add",
                            tint = MochaBrown
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
                        DateConverter.localDateToDate(it)?.let { date ->
                            viewModel.loadDiaryData(date)
                        }
                    }
                )
            }

            // Daily Summary
            item {
                DailySummaryCard(uiState)
            }

            // Meals Sections (matching iOS structure)
            MealType.values().forEach { mealType ->
                val entries = when (mealType) {
                    MealType.BREAKFAST -> uiState.breakfastEntries
                    MealType.LUNCH -> uiState.lunchEntries
                    MealType.DINNER -> uiState.dinnerEntries
                    MealType.SNACK -> uiState.snackEntries
                }

                item {
                    MealSection(
                        mealType = mealType,
                        entries = entries,
                        onAddClick = {
                            // Navigate to food search with meal type
                            navController.navigate("food_search/$mealType")
                        },
                        onDeleteEntry = { entry ->
                            viewModel.deleteFoodEntry(entry)
                        },
                        onEditEntry = { entry ->
                            editingFoodEntry = entry
                        }
                    )
                }
            }

            // Exercise Section
            item {
                ExerciseSection(
                    exercises = uiState.exerciseEntries,
                    onAddClick = {
                        navController.navigate("exercise")
                    },
                    onEditEntry = { exercise ->
                        editingExerciseEntry = exercise
                    }
                )
            }

            // Water Section
            item {
                WaterSection(
                    cups = uiState.waterCups,
                    onAddCup = { viewModel.addWaterCup() },
                    onRemoveCup = { viewModel.removeWaterCup() }
                )
            }

            // Supplements Section
            item {
                SupplementsSection(
                    supplements = uiState.supplementEntries,
                    onAddClick = {
                        navController.navigate("supplement_entry")
                    },
                    onEditEntry = { supplement ->
                        editingSupplementEntry = supplement
                    }
                )
            }
        }
    }

    // Edit dialog — overlays the Scaffold so it can dim the background. Saving
    // calls back into the ViewModel which updates the Room row and refreshes
    // the diary list automatically through loadDiaryDataInternal.
    editingFoodEntry?.let { entry ->
        EditFoodEntryDialog(
            entry = entry,
            onDismiss = { editingFoodEntry = null },
            onSave = { servings, cal, protein, carbs, fat ->
                viewModel.updateFoodEntry(entry, servings, cal, protein, carbs, fat)
                editingFoodEntry = null
            }
        )
    }

    editingExerciseEntry?.let { entry ->
        EditExerciseEntryDialog(
            entry = entry,
            onDismiss = { editingExerciseEntry = null },
            onSave = { duration, calories ->
                viewModel.updateExerciseEntry(entry, duration, calories)
                editingExerciseEntry = null
            }
        )
    }

    editingSupplementEntry?.let { entry ->
        EditSupplementEntryDialog(
            entry = entry,
            onDismiss = { editingSupplementEntry = null },
            onSave = { name, amount ->
                viewModel.updateSupplementEntry(entry, name, amount)
                editingSupplementEntry = null
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditSupplementEntryDialog(
    entry: SupplementEntryDisplay,
    onDismiss: () -> Unit,
    onSave: (name: String, amount: String) -> Unit
) {
    var name by remember { mutableStateOf(entry.name) }
    var amount by remember { mutableStateOf(entry.amount) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Supplement") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Name") },
                    singleLine = true
                )
                OutlinedTextField(
                    value = amount,
                    onValueChange = { amount = it },
                    label = { Text("Amount (e.g. 1 capsule, 500 mg)") },
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(onClick = {
                onSave(
                    name.ifBlank { entry.name },
                    amount
                )
            }) { Text("Save") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditExerciseEntryDialog(
    entry: ExerciseEntryDisplay,
    onDismiss: () -> Unit,
    onSave: (duration: Int, caloriesBurned: Int) -> Unit
) {
    // Mirrors EditFoodEntryDialog: text fields for the editable numbers,
    // parsed back to Int at save with fall-back to the original values if
    // someone clears a field before tapping Save.
    var duration by remember { mutableStateOf(entry.duration.toString()) }
    var calories by remember { mutableStateOf(entry.caloriesBurned.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit ${entry.name}") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = duration,
                    onValueChange = { duration = it },
                    label = { Text("Duration (minutes)") },
                    singleLine = true
                )
                OutlinedTextField(
                    value = calories,
                    onValueChange = { calories = it },
                    label = { Text("Calories burned") },
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(onClick = {
                onSave(
                    duration.toIntOrNull() ?: entry.duration,
                    calories.toIntOrNull() ?: entry.caloriesBurned
                )
            }) { Text("Save") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditFoodEntryDialog(
    entry: FoodEntryDisplay,
    onDismiss: () -> Unit,
    onSave: (servings: Float, calories: Int, protein: Float, carbs: Float, fat: Float) -> Unit
) {
    // String state to allow partial typing ("12" → "12." → "12.5"); we parse
    // back to numbers at save. Defaults are the current entry's values so the
    // dialog opens "edit-ready" without needing to retype anything.
    var servings by remember { mutableStateOf(entry.quantity.toString()) }
    var calories by remember { mutableStateOf(entry.calories.toString()) }
    var protein by remember { mutableStateOf(entry.protein.toString()) }
    var carbs by remember { mutableStateOf(entry.carbs.toString()) }
    var fat by remember { mutableStateOf(entry.fat.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit ${entry.name}") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = servings,
                    onValueChange = { servings = it },
                    label = { Text("Servings (${entry.unit})") },
                    singleLine = true
                )
                OutlinedTextField(
                    value = calories,
                    onValueChange = { calories = it },
                    label = { Text("Calories") },
                    singleLine = true
                )
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(
                        value = protein,
                        onValueChange = { protein = it },
                        label = { Text("Protein (g)") },
                        modifier = Modifier.weight(1f),
                        singleLine = true
                    )
                    OutlinedTextField(
                        value = carbs,
                        onValueChange = { carbs = it },
                        label = { Text("Carbs (g)") },
                        modifier = Modifier.weight(1f),
                        singleLine = true
                    )
                }
                OutlinedTextField(
                    value = fat,
                    onValueChange = { fat = it },
                    label = { Text("Fat (g)") },
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(onClick = {
                onSave(
                    servings.toFloatOrNull() ?: entry.quantity,
                    calories.toIntOrNull() ?: entry.calories,
                    protein.toFloatOrNull() ?: entry.protein,
                    carbs.toFloatOrNull() ?: entry.carbs,
                    fat.toFloatOrNull() ?: entry.fat
                )
            }) { Text("Save") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
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
                        color = MochaBrown
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

@Composable
fun DailySummaryCard(uiState: com.mochasmindlab.mlhealth.viewmodel.DiaryUiState) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MochaBrown.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text(
                text = "Daily Summary",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = MochaBrown
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                SummaryItem(
                    label = "Calories",
                    value = "${uiState.totalCalories}",
                    goal = "${uiState.caloriesGoal}",
                    color = MochaBrown
                )
                SummaryItem(
                    label = "Protein",
                    value = "${uiState.totalProtein}g",
                    goal = "${uiState.proteinGoal}g",
                    color = ProteinBlue
                )
                SummaryItem(
                    label = "Carbs",
                    value = "${uiState.totalCarbs}g",
                    goal = "${uiState.carbsGoal}g",
                    color = CarbsGreen
                )
                SummaryItem(
                    label = "Fat",
                    value = "${uiState.totalFat}g",
                    goal = "${uiState.fatGoal}g",
                    color = FatYellow
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Calorie progress bar
            LinearProgressIndicator(
                progress = (uiState.totalCalories.toFloat() / uiState.caloriesGoal).coerceIn(0f, 1f),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(3.dp)),
                color = MochaBrown,
                trackColor = MochaBrown.copy(alpha = 0.2f)
            )
        }
    }
}

@Composable
fun SummaryItem(
    label: String,
    value: String,
    goal: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = label,
            fontSize = 11.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = "of $goal",
            fontSize = 10.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
        )
    }
}

@Composable
fun MealSection(
    mealType: MealType,
    entries: List<FoodEntryDisplay>,
    onAddClick: () -> Unit,
    onDeleteEntry: (FoodEntryDisplay) -> Unit,
    onEditEntry: (FoodEntryDisplay) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
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
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = getMealIcon(mealType),
                        fontSize = 20.sp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = mealType.displayName,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Row {
                    Text(
                        text = "${entries.sumOf { it.calories }} cal",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    IconButton(
                        onClick = onAddClick,
                        modifier = Modifier.size(24.dp)
                    ) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add ${mealType.displayName}",
                            tint = MochaBrown
                        )
                    }
                }
            }

            if (entries.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                entries.forEach { entry ->
                    FoodEntryItem(
                        entry = entry,
                        onDelete = { onDeleteEntry(entry) },
                        onEdit = { onEditEntry(entry) }
                    )
                }
            } else {
                Spacer(modifier = Modifier.height(8.dp))
                TextButton(
                    onClick = onAddClick,
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    Text(
                        "Add ${mealType.displayName.lowercase()}…",
                        color = MochaBrown,
                        fontSize = 14.sp
                    )
                }
            }
        }
    }
}

@Composable
fun FoodEntryItem(
    entry: FoodEntryDisplay,
    onDelete: () -> Unit,
    onEdit: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onEdit)
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = entry.name,
                fontSize = 14.sp
            )
            Text(
                text = "${entry.quantity} ${entry.unit}",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "${entry.calories} cal",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            IconButton(
                onClick = onDelete,
                modifier = Modifier.size(20.dp)
            ) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = ErrorRed,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
fun ExerciseSection(
    exercises: List<ExerciseEntryDisplay>,
    onAddClick: () -> Unit,
    onEditEntry: (ExerciseEntryDisplay) -> Unit = {}
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
                Row {
                    Text("💪", fontSize = 20.sp)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Exercise",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                IconButton(
                    onClick = onAddClick,
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add Exercise",
                        tint = ExerciseOrange
                    )
                }
            }

            if (exercises.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                exercises.forEach { exercise ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onEditEntry(exercise) }
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = exercise.name,
                            fontSize = 14.sp
                        )
                        Text(
                            text = "${exercise.duration} min • ${exercise.caloriesBurned} cal",
                            fontSize = 13.sp,
                            color = ExerciseOrange
                        )
                    }
                }
            } else {
                Text(
                    text = "No exercises logged",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun WaterSection(
    cups: Int,
    onAddCup: () -> Unit,
    onRemoveCup: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = WaterBlue.copy(alpha = 0.1f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row {
                Text("💧", fontSize = 20.sp)
                Spacer(modifier = Modifier.width(8.dp))
                Column {
                    Text(
                        "Water",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "$cups of 8 cups",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Row {
                IconButton(
                    onClick = onRemoveCup,
                    enabled = cups > 0
                ) {
                    Icon(
                        Icons.Default.Remove,
                        contentDescription = "Remove Cup",
                        tint = if (cups > 0) WaterBlue else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Text(
                    text = "$cups",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 8.dp)
                )
                IconButton(onClick = onAddCup) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add Cup",
                        tint = WaterBlue
                    )
                }
            }
        }
    }
}

@Composable
fun SupplementsSection(
    supplements: List<SupplementEntryDisplay>,
    onAddClick: () -> Unit,
    onEditEntry: (SupplementEntryDisplay) -> Unit = {}
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = SupplementPurple.copy(alpha = 0.1f)
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
                Row {
                    Text("💊", fontSize = 20.sp)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "Supplements",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                IconButton(
                    onClick = onAddClick,
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add Supplement",
                        tint = SupplementPurple
                    )
                }
            }

            if (supplements.isNotEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                supplements.forEach { supplement ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onEditEntry(supplement) }
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text(supplement.name, fontSize = 14.sp)
                            if (supplement.amount.isNotBlank()) {
                                Text(
                                    supplement.amount,
                                    fontSize = 12.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                        Text(
                            supplement.time,
                            fontSize = 13.sp,
                            color = SupplementPurple
                        )
                    }
                }
            }
        }
    }
}

fun getMealIcon(mealType: MealType): String {
    return when (mealType) {
        MealType.BREAKFAST -> "🌅"
        MealType.LUNCH -> "☀️"
        MealType.DINNER -> "🌙"
        MealType.SNACK -> "🍿"
    }
}