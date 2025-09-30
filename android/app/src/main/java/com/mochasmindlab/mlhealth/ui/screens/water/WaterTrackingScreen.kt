package com.mochasmindlab.mlhealth.ui.screens.water

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.entities.WaterUnit
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.WaterTrackingViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WaterTrackingScreen(
    navController: NavController,
    viewModel: WaterTrackingViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showAddCustomDialog by remember { mutableStateOf(false) }
    var showGoalSettingDialog by remember { mutableStateOf(false) }
    var showReminderSettings by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Water Tracking") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { showReminderSettings = true }) {
                        Icon(
                            Icons.Default.Notifications,
                            contentDescription = "Reminder Settings",
                            tint = if (uiState.remindersEnabled) WaterBlue else Color.Gray
                        )
                    }
                    IconButton(onClick = { showGoalSettingDialog = true }) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onSurface
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
            // Header Section
            item {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        "Stay Hydrated",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        "Track your daily water intake",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Reminder Badge
            if (uiState.remindersEnabled) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = WaterBlue.copy(alpha = 0.1f)
                        )
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.NotificationImportant,
                                contentDescription = null,
                                tint = WaterBlue
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                "Reminders: ${uiState.reminderInterval}",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }

            // Progress Circle
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(250.dp),
                    contentAlignment = Alignment.Center
                ) {
                    WaterProgressCircle(
                        progress = uiState.progressPercentage / 100f,
                        totalOunces = uiState.totalOuncesToday,
                        goalOunces = uiState.waterGoalOz,
                        glassesConsumed = uiState.glassesConsumed,
                        totalGlasses = uiState.waterGoalOz / 8
                    )
                }
            }

            // Quick Add Section
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            "Quick Add",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(12.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            QuickAddButton(
                                icon = Icons.Default.LocalDrink,
                                label = "Glass",
                                amount = "8 oz",
                                onClick = { viewModel.addGlass() }
                            )
                            QuickAddButton(
                                icon = Icons.Default.WaterDrop,
                                label = "Bottle",
                                amount = "16.9 oz",
                                onClick = { viewModel.addBottle() }
                            )
                            QuickAddButton(
                                icon = Icons.Default.Add,
                                label = "Custom",
                                amount = "",
                                onClick = { showAddCustomDialog = true }
                            )
                        }
                    }
                }
            }

            // Water Droplets Grid
            item {
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            "Today's Progress",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(12.dp))

                        LazyVerticalGrid(
                            columns = GridCells.Fixed(8),
                            modifier = Modifier.height(100.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            val totalGlasses = uiState.waterGoalOz / 8
                            items(totalGlasses) { index ->
                                WaterDroplet(
                                    isFilled = index < uiState.glassesConsumed,
                                    onClick = {
                                        if (index == uiState.glassesConsumed) {
                                            viewModel.addGlass()
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }

            // Today's Entries
            if (uiState.todayEntries.isNotEmpty()) {
                item {
                    Text(
                        "Today's Entries",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }

                items(uiState.todayEntries) { entry ->
                    WaterEntryCard(
                        entry = entry,
                        onDelete = { viewModel.deleteWaterEntry(entry) }
                    )
                }
            }
        }
    }

    // Dialogs
    if (showAddCustomDialog) {
        AddCustomWaterDialog(
            onDismiss = { showAddCustomDialog = false },
            onAdd = { amount, unit ->
                viewModel.addCustomAmount(amount, unit)
                showAddCustomDialog = false
            }
        )
    }

    if (showGoalSettingDialog) {
        WaterGoalSettingDialog(
            currentGoal = uiState.waterGoalOz,
            onDismiss = { showGoalSettingDialog = false },
            onSave = { newGoal ->
                viewModel.updateWaterGoal(newGoal)
                showGoalSettingDialog = false
            }
        )
    }

    if (showReminderSettings) {
        ReminderSettingsDialog(
            enabled = uiState.remindersEnabled,
            currentInterval = uiState.reminderInterval,
            onDismiss = { showReminderSettings = false },
            onToggle = { viewModel.toggleReminders() },
            onIntervalChange = { interval ->
                viewModel.updateReminderInterval(interval)
            }
        )
    }

    // Error handling
    uiState.errorMessage?.let { error ->
        LaunchedEffect(error) {
            // Show snackbar or toast
            viewModel.clearErrorMessage()
        }
    }
}

@Composable
fun WaterProgressCircle(
    progress: Float,
    totalOunces: Float,
    goalOunces: Int,
    glassesConsumed: Int,
    totalGlasses: Int,
    modifier: Modifier = Modifier
) {
    val animatedProgress by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        ),
        label = "progress"
    )

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
    ) {
        Canvas(
            modifier = Modifier.size(200.dp)
        ) {
            drawCircleBackground()
            drawWaterProgress(animatedProgress)
        }

        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "${totalOunces.toInt()}",
                style = MaterialTheme.typography.displayMedium,
                fontWeight = FontWeight.Bold,
                color = WaterBlue
            )
            Text(
                "oz",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                "$glassesConsumed / $totalGlasses glasses",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

fun DrawScope.drawCircleBackground() {
    drawArc(
        color = Color.LightGray.copy(alpha = 0.3f),
        startAngle = 0f,
        sweepAngle = 360f,
        useCenter = false,
        style = Stroke(width = 20.dp.toPx(), cap = StrokeCap.Round)
    )
}

fun DrawScope.drawWaterProgress(progress: Float) {
    drawArc(
        color = WaterBlue,
        startAngle = -90f,
        sweepAngle = 360f * progress,
        useCenter = false,
        style = Stroke(width = 20.dp.toPx(), cap = StrokeCap.Round)
    )
}

@Composable
fun WaterDroplet(
    isFilled: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Icon(
        Icons.Default.WaterDrop,
        contentDescription = null,
        modifier = modifier
            .size(24.dp)
            .clickable { onClick() },
        tint = if (isFilled) WaterBlue else Color.LightGray.copy(alpha = 0.5f)
    )
}

@Composable
fun QuickAddButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    amount: String,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .clip(RoundedCornerShape(12.dp))
            .clickable { onClick() }
            .padding(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(WaterBlue.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                icon,
                contentDescription = label,
                tint = WaterBlue,
                modifier = Modifier.size(28.dp)
            )
        }
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            label,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.Medium
        )
        if (amount.isNotEmpty()) {
            Text(
                amount,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun WaterEntryCard(
    entry: com.mochasmindlab.mlhealth.data.entities.WaterEntry,
    onDelete: () -> Unit
) {
    val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                Icons.Default.WaterDrop,
                contentDescription = null,
                tint = WaterBlue,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(12.dp))
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    "${entry.getAmountInOz()} oz",
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium
                )
                Text(
                    timeFormat.format(entry.timestamp),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            IconButton(onClick = onDelete) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

@Composable
fun AddCustomWaterDialog(
    onDismiss: () -> Unit,
    onAdd: (Float, WaterUnit) -> Unit
) {
    var amount by remember { mutableStateOf("") }
    var selectedUnit by remember { mutableStateOf(WaterUnit.OZ) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Custom Amount") },
        text = {
            Column {
                OutlinedTextField(
                    value = amount,
                    onValueChange = { amount = it },
                    label = { Text("Amount") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(16.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    WaterUnit.values().forEach { unit ->
                        FilterChip(
                            selected = selectedUnit == unit,
                            onClick = { selectedUnit = unit },
                            label = { Text(unit.name) }
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    amount.toFloatOrNull()?.let { value ->
                        onAdd(value, selectedUnit)
                    }
                }
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun WaterGoalSettingDialog(
    currentGoal: Int,
    onDismiss: () -> Unit,
    onSave: (Int) -> Unit
) {
    var goalText by remember { mutableStateOf(currentGoal.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Set Daily Water Goal") },
        text = {
            Column {
                Text(
                    "Enter your daily water goal in ounces",
                    style = MaterialTheme.typography.bodyMedium
                )
                Spacer(modifier = Modifier.height(16.dp))
                OutlinedTextField(
                    value = goalText,
                    onValueChange = { goalText = it },
                    label = { Text("Goal (oz)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    "Recommended: 64 oz (8 glasses of 8 oz)",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    goalText.toIntOrNull()?.let { goal ->
                        if (goal > 0) onSave(goal)
                    }
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
fun ReminderSettingsDialog(
    enabled: Boolean,
    currentInterval: String,
    onDismiss: () -> Unit,
    onToggle: () -> Unit,
    onIntervalChange: (String) -> Unit
) {
    val intervals = listOf(
        "Every hour",
        "Every 2 hours",
        "Every 3 hours",
        "Every 4 hours"
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Water Reminder Settings") },
        text = {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Enable Reminders")
                    Switch(
                        checked = enabled,
                        onCheckedChange = { onToggle() }
                    )
                }

                if (enabled) {
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        "Reminder Interval",
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(modifier = Modifier.height(8.dp))

                    intervals.forEach { interval ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onIntervalChange(interval) }
                                .padding(vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = currentInterval == interval,
                                onClick = { onIntervalChange(interval) }
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(interval)
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Done")
            }
        }
    )
}