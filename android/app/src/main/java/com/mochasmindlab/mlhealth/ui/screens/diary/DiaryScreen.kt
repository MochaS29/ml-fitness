package com.mochasmindlab.mlhealth.ui.screens.diary

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.FoodEntry
import com.mochasmindlab.mlhealth.data.models.ExerciseEntry
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.DiaryViewModel
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
    var selectedDate by remember { mutableStateOf(LocalDate.now()) }

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
                    IconButton(onClick = onAddClick) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add",
                            tint = MochaBrown
                        )
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onAddClick,
                containerColor = MochaBrown
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = "Add Entry",
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
            // Date Selector
            item {
                DateSelector(
                    selectedDate = selectedDate,
                    onDateChange = {
                        selectedDate = it
                        viewModel.loadDiaryData(it)
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
                            viewModel.deleteFoodEntry(entry.id)
                        }
                    )
                }
            }

            // Exercise Section
            item {
                ExerciseSection(
                    exercises = uiState.exerciseEntries,
                    onAddClick = {
                        navController.navigate("exercise_search")
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
                    }
                )
            }
        }
    }
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
                    goal = "${uiState.calorieGoal}",
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
                progress = (uiState.totalCalories.toFloat() / uiState.calorieGoal).coerceIn(0f, 1f),
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
    entries: List<FoodEntry>,
    onAddClick: () -> Unit,
    onDeleteEntry: (FoodEntry) -> Unit
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
                        onDelete = { onDeleteEntry(entry) }
                    )
                }
            }
        }
    }
}

@Composable
fun FoodEntryItem(
    entry: FoodEntry,
    onDelete: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
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
    exercises: List<ExerciseEntry>,
    onAddClick: () -> Unit
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
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = exercise.name,
                            fontSize = 14.sp
                        )
                        Text(
                            text = "${exercise.minutes} min • ${exercise.caloriesBurned} cal",
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
                        tint = if (cups > 0) WaterBlue else Color.Gray
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
    supplements: List<Any>, // Replace with SupplementEntry model
    onAddClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = SupplementPurple.copy(alpha = 0.1f)
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