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
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
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
                    IconButton(onClick = { showAddDialog = true }) {
                        Icon(
                            Icons.Default.Add,
                            contentDescription = "Add Weight",
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
            // Current Weight Card
            item {
                CurrentWeightCard(
                    currentWeight = currentWeight.toFloat(),
                    goalWeight = goalWeight.toFloat(),
                    startingWeight = startingWeight.toFloat(),
                    onAddWeight = { showAddDialog = true }
                )
            }

            // BMI Card
            item {
                BMICard(
                    bmi = bmi.toFloat(),
                    category = bmiCategory
                )
            }

            // Progress Chart
            item {
                WeightProgressChart(
                    weightHistory = weightHistory,
                    goalWeight = goalWeight.toFloat()
                )
            }

            // Statistics
            item {
                WeightStatisticsCard(
                    weeklyAverage = weeklyAverage.toFloat(),
                    monthlyProgress = monthlyProgress.toFloat(),
                    totalLost = (startingWeight - currentWeight).toFloat()
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
            onAdd = { weight, notes, date ->
                viewModel.addWeightEntry(weight.toDouble(), notes, date)
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

            // Progress to Goal — guard against 0/0 (NaN) when no goal is set
            // and against Infinity when starting == current. Both default to 0.
            val raw = when {
                goalWeight < startingWeight -> {
                    val totalToLose = startingWeight - goalWeight
                    if (totalToLose == 0f) 0f else (startingWeight - currentWeight) / totalToLose
                }
                goalWeight > startingWeight -> {
                    val totalToGain = goalWeight - startingWeight
                    if (totalToGain == 0f) 0f else (currentWeight - startingWeight) / totalToGain
                }
                else -> 0f // No goal set yet (goalWeight == startingWeight, often both 0)
            }
            val progress = if (raw.isNaN() || raw.isInfinite()) 0f else raw.coerceIn(0f, 1f)

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
                        // Three label states: no goal yet, still losing, still
                        // gaining. Without the goalWeight<=0 guard the column
                        // showed "To Gain 167 lbs" simply because 0 < 167.
                        val (centerLabel, centerValue) = when {
                            goalWeight <= 0f -> "No Goal" to "—"
                            currentWeight > goalWeight ->
                                "To Lose" to "${kotlin.math.abs(currentWeight - goalWeight).roundToInt()} lbs"
                            currentWeight < goalWeight ->
                                "To Gain" to "${kotlin.math.abs(goalWeight - currentWeight).roundToInt()} lbs"
                            else -> "On Goal" to "🎉"
                        }
                        Text(
                            centerLabel,
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            centerValue,
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
                            if (goalWeight > 0f) "${goalWeight.roundToInt()} lbs" else "—",
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
                // Chart needs oldest-to-newest left→right so a real weight loss
                // reads as a downward slope. weightHistory comes in newest-first
                // (matches the Recent Entries list below); reverse for plotting.
                val chartHistory = weightHistory.sortedBy { it.date }

                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp)
                ) {
                    val padding = 40.dp.toPx()
                    val chartWidth = size.width - (padding * 2)
                    val chartHeight = size.height - padding

                    val weights = chartHistory.map { it.weight.toFloat() }
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

                    // Draw weight line — use chronological list, not the
                    // newest-first weightHistory used by the entry list.
                    if (chartHistory.isNotEmpty()) {
                        val path = Path()
                        chartHistory.forEachIndexed { index, entry ->
                            val x = padding + (index.toFloat() / (chartHistory.size - 1)) * chartWidth
                            val y = chartHeight - ((entry.weight.toFloat() - minWeight) / weightRange * chartHeight)

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
                    java.time.Instant.ofEpochMilli(entry.date.time).atZone(java.time.ZoneId.systemDefault()).toLocalDate().format(DateTimeFormatter.ofPattern("MMM d, yyyy")),
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                if (!entry.notes.isNullOrEmpty()) {
                    Text(
                        entry.notes ?: "",
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddWeightDialog(
    onDismiss: () -> Unit,
    onAdd: (Float, String, java.util.Date) -> Unit
) {
    var weight by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedDate by remember { mutableStateOf(java.util.Date()) }
    var showDatePicker by remember { mutableStateOf(false) }
    val dateFmt = remember { java.text.SimpleDateFormat("MMM d, yyyy", java.util.Locale.getDefault()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Log Weight") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = weight,
                    onValueChange = { weight = it },
                    label = { Text("Weight (lbs)") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Notes (optional)") },
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = dateFmt.format(selectedDate),
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Date") },
                    trailingIcon = {
                        IconButton(onClick = { showDatePicker = true }) {
                            Icon(Icons.Default.CalendarMonth, contentDescription = "Pick date")
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { showDatePicker = true }
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    weight.toFloatOrNull()?.let { onAdd(it, notes, selectedDate) }
                }
            ) {
                Text("Add", color = MochaBrown)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )

    if (showDatePicker) {
        // Material3 1.1.2 doesn't have SelectableDates yet; future dates are
        // selectable here, but a stale future weight is harmless.
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = selectedDate.time
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let {
                        selectedDate = java.util.Date(it)
                    }
                    showDatePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Cancel") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }
}