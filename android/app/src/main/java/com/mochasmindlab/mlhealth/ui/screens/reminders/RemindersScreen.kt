package com.mochasmindlab.mlhealth.ui.screens.reminders

import android.Manifest
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.DirectionsRun
import androidx.compose.material.icons.filled.LocalDrink
import androidx.compose.material.icons.filled.MonitorWeight
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.viewmodel.RemindersViewModel
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RemindersScreen(
    navController: NavController,
    viewModel: RemindersViewModel = hiltViewModel()
) {
    val settings by viewModel.settings.collectAsState()

    // Android 13+ runtime notification permission
    var permissionAsked by remember { mutableStateOf(false) }
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { /* result discarded — system shows the actual notification anyway */ }

    LaunchedEffect(Unit) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !permissionAsked) {
            permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
            permissionAsked = true
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Reminders", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            ReminderCard(
                icon = Icons.Default.LocalDrink,
                accent = Color(0xFF2E86C1),
                title = "Water",
                subtitle = if (settings.waterEnabled)
                    "Every ${settings.waterIntervalMinutes} min · ${formatHour(settings.waterStartHour)}–${formatHour(settings.waterEndHour)}"
                else "Stay hydrated through the day",
                checked = settings.waterEnabled,
                onCheckedChange = viewModel::setWaterEnabled,
                expandedContent = {
                    StepperRow(
                        label = "Every",
                        value = "${settings.waterIntervalMinutes} min",
                        onMinus = {
                            val next = (settings.waterIntervalMinutes - 15).coerceAtLeast(15)
                            viewModel.setWaterInterval(next)
                        },
                        onPlus = {
                            val next = (settings.waterIntervalMinutes + 15).coerceAtMost(240)
                            viewModel.setWaterInterval(next)
                        }
                    )
                    HourRangeRow(
                        startHour = settings.waterStartHour,
                        endHour = settings.waterEndHour,
                        onChangeStart = { h -> viewModel.setWaterWindow(h, settings.waterEndHour) },
                        onChangeEnd = { h -> viewModel.setWaterWindow(settings.waterStartHour, h) }
                    )
                }
            )

            ReminderCard(
                icon = Icons.Default.Restaurant,
                accent = Color(0xFF27AE60),
                title = "Meals",
                subtitle = if (settings.mealsEnabled)
                    "B ${formatHour(settings.breakfastHour)} · L ${formatHour(settings.lunchHour)} · D ${formatHour(settings.dinnerHour)}"
                else "Reminders to log breakfast, lunch & dinner",
                checked = settings.mealsEnabled,
                onCheckedChange = viewModel::setMealsEnabled,
                expandedContent = {
                    HourRow(
                        label = "Breakfast",
                        hour = settings.breakfastHour,
                        onChange = { h -> viewModel.setMealHours(h, settings.lunchHour, settings.dinnerHour) }
                    )
                    HourRow(
                        label = "Lunch",
                        hour = settings.lunchHour,
                        onChange = { h -> viewModel.setMealHours(settings.breakfastHour, h, settings.dinnerHour) }
                    )
                    HourRow(
                        label = "Dinner",
                        hour = settings.dinnerHour,
                        onChange = { h -> viewModel.setMealHours(settings.breakfastHour, settings.lunchHour, h) }
                    )
                }
            )

            ReminderCard(
                icon = Icons.Default.MonitorWeight,
                accent = Color(0xFFAF7AC5),
                title = "Weigh-in",
                subtitle = if (settings.weightEnabled)
                    "Daily at ${formatHourMinute(settings.weightHour, settings.weightMinute)}"
                else "Daily nudge to log your weight",
                checked = settings.weightEnabled,
                onCheckedChange = viewModel::setWeightEnabled,
                expandedContent = {
                    HourRow(
                        label = "Time",
                        hour = settings.weightHour,
                        onChange = { h -> viewModel.setWeightTime(h, settings.weightMinute) }
                    )
                }
            )

            ReminderCard(
                icon = Icons.Default.DirectionsRun,
                accent = Color(0xFFE67E22),
                title = "Exercise",
                subtitle = if (settings.exerciseEnabled)
                    "Daily at ${formatHourMinute(settings.exerciseHour, settings.exerciseMinute)}"
                else "Daily nudge to move",
                checked = settings.exerciseEnabled,
                onCheckedChange = viewModel::setExerciseEnabled,
                expandedContent = {
                    HourRow(
                        label = "Time",
                        hour = settings.exerciseHour,
                        onChange = { h -> viewModel.setExerciseTime(h, settings.exerciseMinute) }
                    )
                }
            )
        }
    }
}

@Composable
private fun ReminderCard(
    icon: ImageVector,
    accent: Color,
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    expandedContent: @Composable ColumnScope.() -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    Card(modifier = Modifier.fillMaxWidth()) {
        Column {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(accent.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(icon, contentDescription = title, tint = accent)
                }
                Spacer(Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(title, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Spacer(Modifier.height(2.dp))
                    Text(subtitle, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Switch(checked = checked, onCheckedChange = onCheckedChange)
            }
            if (checked) {
                TextButton(
                    onClick = { expanded = !expanded },
                    modifier = Modifier.padding(start = 8.dp)
                ) {
                    Text(if (expanded) "Hide settings" else "Edit settings")
                }
                if (expanded) {
                    Column(
                        modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        content = expandedContent
                    )
                }
            }
        }
    }
}

@Composable
private fun StepperRow(label: String, value: String, onMinus: () -> Unit, onPlus: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(label, modifier = Modifier.weight(1f))
        OutlinedButton(onClick = onMinus) { Text("−") }
        Spacer(Modifier.width(12.dp))
        Text(value, fontWeight = FontWeight.Bold, modifier = Modifier.widthIn(min = 60.dp))
        Spacer(Modifier.width(12.dp))
        OutlinedButton(onClick = onPlus) { Text("+") }
    }
}

@Composable
private fun HourRow(label: String, hour: Int, onChange: (Int) -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(label, modifier = Modifier.weight(1f))
        OutlinedButton(onClick = { onChange((hour - 1 + 24) % 24) }) { Text("−") }
        Spacer(Modifier.width(12.dp))
        Text(formatHour(hour), fontWeight = FontWeight.Bold, modifier = Modifier.widthIn(min = 60.dp))
        Spacer(Modifier.width(12.dp))
        OutlinedButton(onClick = { onChange((hour + 1) % 24) }) { Text("+") }
    }
}

@Composable
private fun HourRangeRow(
    startHour: Int,
    endHour: Int,
    onChangeStart: (Int) -> Unit,
    onChangeEnd: (Int) -> Unit
) {
    HourRow(label = "Start", hour = startHour, onChange = onChangeStart)
    HourRow(label = "End", hour = endHour, onChange = onChangeEnd)
}

private fun formatHour(hour: Int): String =
    String.format(Locale.getDefault(), "%d:00", hour)

private fun formatHourMinute(hour: Int, minute: Int): String =
    String.format(Locale.getDefault(), "%d:%02d", hour, minute)

// TODO: wire route "reminders" in MLFitnessNavigation.kt:
//   composable("reminders") { RemindersScreen(navController) }
// (Currently routes to ComingSoonScreen at MLFitnessNavigation.kt line 204.)
