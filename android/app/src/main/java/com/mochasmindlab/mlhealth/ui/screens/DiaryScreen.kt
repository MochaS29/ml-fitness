package com.mochasmindlab.mlhealth.ui.screens

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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.DiaryViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DiaryScreen(
    navController: NavController,
    viewModel: DiaryViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val dateFormatter = SimpleDateFormat("EEEE, MMMM d", Locale.getDefault())
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            "Food Diary",
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            dateFormatter.format(uiState.selectedDate),
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { viewModel.previousDay() }) {
                        Icon(Icons.Default.ChevronLeft, contentDescription = "Previous Day")
                    }
                    TextButton(onClick = { viewModel.selectToday() }) {
                        Text("Today")
                    }
                    IconButton(onClick = { viewModel.nextDay() }) {
                        Icon(Icons.Default.ChevronRight, contentDescription = "Next Day")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MindLabsPurple,
                    titleContentColor = Color.White,
                    actionIconContentColor = Color.White
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
            // Daily Summary Card
            item {
                DailySummaryCard(
                    caloriesConsumed = uiState.totalCalories,
                    caloriesGoal = uiState.caloriesGoal,
                    proteinConsumed = uiState.totalProtein,
                    carbsConsumed = uiState.totalCarbs,
                    fatConsumed = uiState.totalFat
                )
            }
            
            // Meal Sections
            MealType.values().forEach { mealType ->
                item {
                    MealSection(
                        mealType = mealType,
                        entries = uiState.mealEntries[mealType] ?: emptyList(),
                        onAddFood = {
                            navController.navigate("add_food/$mealType")
                        },
                        onEditEntry = { entry ->
                            navController.navigate("edit_food/${entry.id}")
                        },
                        onDeleteEntry = { entry ->
                            viewModel.deleteFoodEntry(entry)
                        }
                    )
                }
            }
            
            // Water Tracking
            item {
                WaterTrackingCard(
                    cupsConsumed = uiState.waterCups,
                    cupsGoal = uiState.waterGoal,
                    onAddWater = { viewModel.addWaterCup() },
                    onRemoveWater = { viewModel.removeWaterCup() }
                )
            }
            
            // Quick Add Buttons
            item {
                QuickAddSection(
                    onScanBarcode = {
                        navController.navigate("barcode_scanner")
                    },
                    onSearchFood = {
                        navController.navigate("food_search")
                    },
                    onAddCustomFood = {
                        navController.navigate("add_custom_food")
                    }
                )
            }
        }
    }
}

@Composable
private fun DailySummaryCard(
    caloriesConsumed: Int,
    caloriesGoal: Int,
    proteinConsumed: Float,
    carbsConsumed: Float,
    fatConsumed: Float
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MindLabsPurple.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    "Daily Summary",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
                Text(
                    "${caloriesGoal - caloriesConsumed} cal remaining",
                    color = if (caloriesConsumed <= caloriesGoal) ExerciseGreen else Color.Red,
                    fontWeight = FontWeight.Medium
                )
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Calorie Progress Bar
            LinearProgressIndicator(
                progress = (caloriesConsumed.toFloat() / caloriesGoal).coerceIn(0f, 1f),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = if (caloriesConsumed <= caloriesGoal) ExerciseGreen else Color.Red,
                trackColor = Color.Gray.copy(alpha = 0.2f)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Macros
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                MacroDisplay("Protein", proteinConsumed, NutritionGreen)
                MacroDisplay("Carbs", carbsConsumed, EnergeticOrange)
                MacroDisplay("Fat", fatConsumed, CalorieRed)
            }
        }
    }
}

@Composable
private fun MacroDisplay(
    label: String,
    value: Float,
    color: Color
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            "${value.toInt()}g",
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp,
            color = color
        )
        Text(
            label,
            fontSize = 12.sp,
            color = Color.Gray
        )
    }
}

@Composable
private fun MealSection(
    mealType: MealType,
    entries: List<FoodEntryDisplay>,
    onAddFood: () -> Unit,
    onEditEntry: (FoodEntryDisplay) -> Unit,
    onDeleteEntry: (FoodEntryDisplay) -> Unit
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
                Text(
                    text = when(mealType) {
                        MealType.BREAKFAST -> "Breakfast"
                        MealType.LUNCH -> "Lunch"
                        MealType.DINNER -> "Dinner"
                        MealType.SNACK -> "Snacks"
                    },
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp
                )
                
                IconButton(onClick = onAddFood) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add Food",
                        tint = MindLabsPurple
                    )
                }
            }
            
            if (entries.isEmpty()) {
                Text(
                    "No items added",
                    color = Color.Gray,
                    fontSize = 14.sp,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            } else {
                entries.forEach { entry ->
                    FoodEntryItem(
                        entry = entry,
                        onEdit = { onEditEntry(entry) },
                        onDelete = { onDeleteEntry(entry) }
                    )
                }
                
                Divider(modifier = Modifier.padding(vertical = 8.dp))
                
                // Meal totals
                val totalCalories = entries.sumOf { it.calories }
                Text(
                    "Total: $totalCalories cal",
                    fontWeight = FontWeight.Medium,
                    fontSize = 14.sp,
                    textAlign = TextAlign.End,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun FoodEntryItem(
    entry: FoodEntryDisplay,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    var showMenu by remember { mutableStateOf(false) }
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onEdit() }
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                entry.name,
                fontWeight = FontWeight.Medium
            )
            Text(
                "${entry.quantity} ${entry.unit}",
                fontSize = 12.sp,
                color = Color.Gray
            )
        }
        
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                "${entry.calories} cal",
                fontWeight = FontWeight.Medium
            )
            
            Box {
                IconButton(onClick = { showMenu = true }) {
                    Icon(
                        Icons.Default.MoreVert,
                        contentDescription = "More options",
                        modifier = Modifier.size(20.dp)
                    )
                }
                
                DropdownMenu(
                    expanded = showMenu,
                    onDismissRequest = { showMenu = false }
                ) {
                    DropdownMenuItem(
                        text = { Text("Edit") },
                        onClick = {
                            showMenu = false
                            onEdit()
                        },
                        leadingIcon = {
                            Icon(Icons.Default.Edit, contentDescription = null)
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Delete", color = Color.Red) },
                        onClick = {
                            showMenu = false
                            onDelete()
                        },
                        leadingIcon = {
                            Icon(Icons.Default.Delete, contentDescription = null, tint = Color.Red)
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun WaterTrackingCard(
    cupsConsumed: Int,
    cupsGoal: Int,
    onAddWater: () -> Unit,
    onRemoveWater: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = HydrationBlue.copy(alpha = 0.1f)
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
                Column {
                    Text(
                        "Water Intake",
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp
                    )
                    Text(
                        "$cupsConsumed of $cupsGoal cups",
                        fontSize = 14.sp,
                        color = Color.Gray
                    )
                }
                
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(
                        onClick = onRemoveWater,
                        enabled = cupsConsumed > 0,
                        modifier = Modifier
                            .size(36.dp)
                            .background(Color.White, CircleShape)
                    ) {
                        Icon(
                            Icons.Default.Remove,
                            contentDescription = "Remove Water",
                            tint = if (cupsConsumed > 0) HydrationBlue else Color.Gray
                        )
                    }
                    
                    Text(
                        "💧",
                        fontSize = 32.sp
                    )
                    
                    IconButton(
                        onClick = onAddWater,
                        modifier = Modifier
                            .size(36.dp)
                            .background(HydrationBlue, CircleShape)
                    ) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add Water",
                            tint = Color.White
                        )
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            LinearProgressIndicator(
                progress = (cupsConsumed.toFloat() / cupsGoal).coerceIn(0f, 1f),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = HydrationBlue,
                trackColor = Color.Gray.copy(alpha = 0.2f)
            )
        }
    }
}

@Composable
private fun QuickAddSection(
    onScanBarcode: () -> Unit,
    onSearchFood: () -> Unit,
    onAddCustomFood: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        QuickAddButton(
            modifier = Modifier.weight(1f),
            icon = Icons.Default.CameraAlt,
            label = "Scan",
            onClick = onScanBarcode,
            backgroundColor = MindLabsPurple
        )
        
        QuickAddButton(
            modifier = Modifier.weight(1f),
            icon = Icons.Default.Search,
            label = "Search",
            onClick = onSearchFood,
            backgroundColor = MindfulTeal
        )
        
        QuickAddButton(
            modifier = Modifier.weight(1f),
            icon = Icons.Default.Add,
            label = "Custom",
            onClick = onAddCustomFood,
            backgroundColor = EnergeticOrange
        )
    }
}

@Composable
private fun QuickAddButton(
    modifier: Modifier = Modifier,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    onClick: () -> Unit,
    backgroundColor: Color
) {
    Card(
        modifier = modifier
            .height(60.dp)
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = backgroundColor.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                icon,
                contentDescription = label,
                tint = backgroundColor,
                modifier = Modifier.size(24.dp)
            )
            Text(
                label,
                fontSize = 12.sp,
                color = backgroundColor
            )
        }
    }
}

// Data class for display
data class FoodEntryDisplay(
    val id: String,
    val name: String,
    val quantity: Float,
    val unit: String,
    val calories: Int,
    val protein: Float,
    val carbs: Float,
    val fat: Float
)