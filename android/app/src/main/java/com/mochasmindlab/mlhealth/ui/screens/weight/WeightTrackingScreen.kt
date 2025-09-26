package com.mochasmindlab.mlhealth.ui.screens.weight

import androidx.compose.foundation.Canvas
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.WeightEntry
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.WeightViewModel
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WeightTrackingScreen(
    navController: NavController,
    viewModel: WeightViewModel = hiltViewModel()
) {
    var showAddDialog by remember { mutableStateOf(false) }
    val currentWeight by viewModel.currentWeight.collectAsState()
    val goalWeight by viewModel.goalWeight.collectAsState()
    val startingWeight by viewModel.startingWeight.collectAsState()
    val weightHistory by viewModel.weightHistory.collectAsState()
    val weeklyAverage by viewModel.weeklyAverage.collectAsState()
    val monthlyProgress by viewModel.monthlyProgress.collectAsState()
    val bmi by viewModel.bmi.collectAsState()
    val bmiCategory by viewModel.bmiCategory.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Weight Tracking",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { navController.navigate("weight_settings") }) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddDialog = true },
                containerColor = MochaBrown
            ) {
                Icon(
                    Icons.Default.Add,
                    contentDescription = "Add Weight",
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
            // Current Weight Card
            item {
                CurrentWeightCard(
                    currentWeight = currentWeight,
                    goalWeight = goalWeight,
                    startingWeight = startingWeight,
                    onAddWeight = { showAddDialog = true }
                )
            }

            // BMI Card
            item {
                BMICard(
                    bmi = bmi,
                    category = bmiCategory
                )
            }

            // Progress Chart
            item {
                WeightProgressChart(
                    weightHistory = weightHistory,
                    goalWeight = goalWeight
                )
            }

            // Statistics
            item {
                WeightStatisticsCard(
                    weeklyAverage = weeklyAverage,
                    monthlyProgress = monthlyProgress,
                    totalLost = startingWeight - currentWeight
                )
            }

            // Recent Entries
            if (weightHistory.isNotEmpty()) {
                item {
                    Text(
                        "Recent Entries",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MochaBrown
                    )
                }

                items(weightHistory.take(10)) { entry ->
                    WeightEntryCard(
                        entry = entry,
                        onDelete = {
                            viewModel.deleteWeightEntry(entry.id)
                        }
                    )
                }
            }
        }
    }

    if (showAddDialog) {
        AddWeightDialog(
            onDismiss = { showAddDialog = false },
            onAdd = { weight, notes ->
                viewModel.addWeightEntry(weight, notes)
                showAddDialog = false
            }
        )
    }
}

@Composable
fun CurrentWeightCard(
    currentWeight: Float,
    goalWeight: Float,
    startingWeight: Float,
    onAddWeight: () -> Unit
) {
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
            Text(
                "Current Weight",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    "${String.format("%.1f", currentWeight)}",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    color = MochaBrown
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    "lbs",
                    fontSize = 20.sp,
                    color = MochaBrown,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Progress to Goal
            val progress = if (goalWeight < startingWeight) {
                // Weight loss goal
                val totalToLose = startingWeight - goalWeight
                val lost = startingWeight - currentWeight
                (lost / totalToLose).coerceIn(0f, 1f)
            } else {
                // Weight gain goal
                val totalToGain = goalWeight - startingWeight
                val gained = currentWeight - startingWeight
                (gained / totalToGain).coerceIn(0f, 1f)
            }

            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        "Progress to Goal",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        "${(progress * 100).roundToInt()}%",
                        fontSize = 12.sp,
                        color = MochaBrown
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                LinearProgressIndicator(
                    progress = progress,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(RoundedCornerShape(4.dp)),
                    color = MochaBrown,
                    trackColor = MochaBrown.copy(alpha = 0.2f)
                )

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(
                            "Start",
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            "${startingWeight.roundToInt()} lbs",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }

                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            if (goalWeight < startingWeight) "To Lose" else "To Gain",
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            "${kotlin.math.abs(goalWeight - currentWeight).roundToInt()} lbs",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = MochaBrown
                        )
                    }

                    Column(
                        horizontalAlignment = Alignment.End
                    ) {
                        Text(
                            "Goal",
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            "${goalWeight.roundToInt()} lbs",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = onAddWeight,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MochaBrown
                )
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Log Weight")
            }
        }
    }
}

@Composable
fun BMICard(
    bmi: Float,
    category: String
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    "BMI",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Row(
                    verticalAlignment = Alignment.Bottom
                ) {
                    Text(
                        String.format("%.1f", bmi),
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        category,
                        fontSize = 14.sp,
                        color = when (category) {
                            "Underweight" -> WarningOrange
                            "Normal" -> SuccessGreen
                            "Overweight" -> WarningOrange
                            "Obese" -> ErrorRed
                            else -> MaterialTheme.colorScheme.onSurfaceVariant
                        }
                    )
                }
            }

            // BMI Range Indicator
            BMIRangeIndicator(bmi = bmi)
        }
    }
}

@Composable
fun BMIRangeIndicator(bmi: Float) {
    Box(
        modifier = Modifier
            .width(120.dp)
            .height(8.dp)
            .clip(RoundedCornerShape(4.dp))
            .background(Color.Gray.copy(alpha = 0.2f))
    ) {
        // BMI ranges: < 18.5 (underweight), 18.5-24.9 (normal), 25-29.9 (overweight), 30+ (obese)
        val position = when {
            bmi < 18.5f -> (bmi / 18.5f) * 0.25f
            bmi < 25f -> 0.25f + ((bmi - 18.5f) / 6.5f) * 0.25f
            bmi < 30f -> 0.5f + ((bmi - 25f) / 5f) * 0.25f
            else -> minOf(0.75f + ((bmi - 30f) / 10f) * 0.25f, 1f)
        }

        Box(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth(position)
                .background(
                    when {
                        bmi < 18.5f -> WarningOrange
                        bmi < 25f -> SuccessGreen
                        bmi < 30f -> WarningOrange
                        else -> ErrorRed
                    },
                    RoundedCornerShape(4.dp)
                )
        )
    }
}

@Composable
fun WeightProgressChart(
    weightHistory: List<WeightEntry>,
    goalWeight: Float
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Progress Chart",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(16.dp))

            if (weightHistory.size >= 2) {
                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp)
                ) {
                    val padding = 40.dp.toPx()
                    val chartWidth = size.width - (padding * 2)
                    val chartHeight = size.height - padding

                    val weights = weightHistory.map { it.weight }
                    val minWeight = (weights.minOrNull() ?: 0f) - 5
                    val maxWeight = (weights.maxOrNull() ?: 100f) + 5
                    val weightRange = maxWeight - minWeight

                    // Draw goal line
                    val goalY = chartHeight - ((goalWeight - minWeight) / weightRange * chartHeight)
                    drawLine(
                        color = SuccessGreen.copy(alpha = 0.5f),
                        start = Offset(padding, goalY),
                        end = Offset(size.width - padding, goalY),
                        strokeWidth = 2.dp.toPx()
                    )

                    // Draw weight line
                    if (weightHistory.isNotEmpty()) {
                        val path = Path()
                        weightHistory.forEachIndexed { index, entry ->
                            val x = padding + (index.toFloat() / (weightHistory.size - 1)) * chartWidth
                            val y = chartHeight - ((entry.weight - minWeight) / weightRange * chartHeight)

                            if (index == 0) {
                                path.moveTo(x, y)
                            } else {
                                path.lineTo(x, y)
                            }

                            // Draw data points
                            drawCircle(
                                color = MochaBrown,
                                radius = 4.dp.toPx(),
                                center = Offset(x, y)
                            )
                        }

                        drawPath(
                            path = path,
                            color = MochaBrown,
                            style = Stroke(width = 3.dp.toPx())
                        )
                    }
                }
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "Add more entries to see progress chart",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
fun WeightStatisticsCard(
    weeklyAverage: Float,
    monthlyProgress: Float,
    totalLost: Float
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Statistics",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatItem(
                    label = "Weekly Avg",
                    value = String.format("%.1f lbs", weeklyAverage),
                    color = MochaBrown
                )

                StatItem(
                    label = "Monthly",
                    value = String.format("%+.1f lbs", monthlyProgress),
                    color = if (monthlyProgress < 0) SuccessGreen else WarningOrange
                )

                StatItem(
                    label = "Total",
                    value = String.format("%+.1f lbs", -totalLost),
                    color = if (totalLost > 0) SuccessGreen else WarningOrange
                )
            }
        }
    }
}

@Composable
fun StatItem(
    label: String,
    value: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            value,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
    }
}

@Composable
fun WeightEntryCard(
    entry: WeightEntry,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    entry.date.format(DateTimeFormatter.ofPattern("MMM d, yyyy")),
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                if (entry.notes.isNotEmpty()) {
                    Text(
                        entry.notes,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                    )
                }
            }

            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "${entry.weight} lbs",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )

                Spacer(modifier = Modifier.width(8.dp))

                IconButton(
                    onClick = onDelete,
                    modifier = Modifier.size(36.dp)
                ) {
                    Icon(
                        Icons.Default.Delete,
                        contentDescription = "Delete",
                        tint = ErrorRed,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun AddWeightDialog(
    onDismiss: () -> Unit,
    onAdd: (Float, String) -> Unit
) {
    var weight by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text("Log Weight")
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedTextField(
                    value = weight,
                    onValueChange = { weight = it },
                    label = { Text("Weight (lbs)") },
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Decimal
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Notes (optional)") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    weight.toFloatOrNull()?.let {
                        onAdd(it, notes)
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