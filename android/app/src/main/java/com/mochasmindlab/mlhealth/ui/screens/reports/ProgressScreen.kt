package com.mochasmindlab.mlhealth.ui.screens.reports

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.ui.theme.WaterBlue
import com.mochasmindlab.mlhealth.ui.theme.ExerciseOrange
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Calendar
import java.util.Date
import javax.inject.Inject

data class ProgressUiState(
    val weightSeries: List<Float> = emptyList(),
    val caloriesSeries: List<Int> = emptyList(),
    val waterSeries: List<Int> = emptyList(),
    val exerciseSeries: List<Int> = emptyList(),
    val totalFoodLogs: Int = 0,
    val totalExerciseMinutes: Int = 0,
    val totalWaterOz: Int = 0
)

@HiltViewModel
class ProgressViewModel @Inject constructor(
    private val db: MLFitnessDatabase
) : ViewModel() {
    private val _state = MutableStateFlow(ProgressUiState())
    val state: StateFlow<ProgressUiState> = _state.asStateFlow()

    init { load() }

    private fun load() {
        viewModelScope.launch {
            // Past 14 days, oldest → newest.
            val days = (13 downTo 0).map { offset ->
                Calendar.getInstance().apply {
                    add(Calendar.DAY_OF_YEAR, -offset)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.time
            }

            val cals = days.map { runCatching { db.foodDao().getTotalCaloriesForDate(it) ?: 0.0 }.getOrDefault(0.0).toInt() }
            val water = days.map { runCatching { db.waterDao().getTotalForDate(it) ?: 0.0 }.getOrDefault(0.0).toInt() }
            val exercise = days.map { runCatching { db.exerciseDao().getTotalMinutesForDate(it) ?: 0 }.getOrDefault(0) }
            val weights = runCatching { db.weightDao().getRecentEntries(14) }.getOrDefault(emptyList())
                .reversed()
                .map { it.weight.toFloat() }

            _state.value = ProgressUiState(
                weightSeries = weights,
                caloriesSeries = cals,
                waterSeries = water,
                exerciseSeries = exercise,
                totalFoodLogs = runCatching { db.foodDao().getTotalFoodEntryCount() }.getOrDefault(0),
                totalExerciseMinutes = exercise.sum(),
                totalWaterOz = water.sum()
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProgressScreen(
    navController: NavController,
    viewModel: ProgressViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Progress", fontWeight = FontWeight.Bold) },
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
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Last 14 days", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)

            ChartCard(
                title = "Calories",
                series = state.caloriesSeries.map { it.toFloat() },
                color = MochaBrown,
                trailing = "${state.caloriesSeries.lastOrNull() ?: 0} today"
            )
            ChartCard(
                title = "Water (oz)",
                series = state.waterSeries.map { it.toFloat() },
                color = WaterBlue,
                trailing = "${state.waterSeries.lastOrNull() ?: 0} oz today"
            )
            ChartCard(
                title = "Exercise (min)",
                series = state.exerciseSeries.map { it.toFloat() },
                color = ExerciseOrange,
                trailing = "${state.exerciseSeries.lastOrNull() ?: 0} min today"
            )
            if (state.weightSeries.isNotEmpty()) {
                ChartCard(
                    title = "Weight (lbs)",
                    series = state.weightSeries,
                    color = MochaBrown,
                    trailing = "${state.weightSeries.last()} lbs"
                )
            }

            // All-time totals
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MochaBrown.copy(alpha = 0.08f))
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("All-time", fontWeight = FontWeight.Bold)
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Food entries logged"); Text("${state.totalFoodLogs}", fontWeight = FontWeight.SemiBold)
                    }
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Exercise (last 14d)"); Text("${state.totalExerciseMinutes} min", fontWeight = FontWeight.SemiBold)
                    }
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Water (last 14d)"); Text("${state.totalWaterOz} oz", fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }
}

@Composable
private fun ChartCard(
    title: String,
    series: List<Float>,
    color: Color,
    trailing: String
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(title, fontWeight = FontWeight.Bold)
                Text(trailing, color = color, fontWeight = FontWeight.SemiBold)
            }
            LineSparkline(series = series, color = color)
        }
    }
}

@Composable
private fun LineSparkline(series: List<Float>, color: Color) {
    if (series.isEmpty() || series.all { it == 0f }) {
        Box(modifier = Modifier.fillMaxWidth().height(80.dp), contentAlignment = Alignment.Center) {
            Text("No data yet", color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 12.sp)
        }
        return
    }
    Canvas(modifier = Modifier.fillMaxWidth().height(80.dp)) {
        val maxV = series.max().coerceAtLeast(1f)
        val minV = series.min().coerceAtMost(0f)
        val range = (maxV - minV).coerceAtLeast(1f)
        val stepX = if (series.size > 1) size.width / (series.size - 1) else size.width
        val path = Path()
        series.forEachIndexed { i, v ->
            val x = i * stepX
            val y = size.height - ((v - minV) / range) * size.height
            if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }
        drawPath(path, color = color, style = Stroke(width = 4f))
        // dots
        series.forEachIndexed { i, v ->
            val x = i * stepX
            val y = size.height - ((v - minV) / range) * size.height
            drawCircle(color = color, radius = 4f, center = Offset(x, y))
        }
    }
}
