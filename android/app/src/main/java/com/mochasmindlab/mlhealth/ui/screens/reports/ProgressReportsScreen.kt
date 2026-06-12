package com.mochasmindlab.mlhealth.ui.screens.reports

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.ProgressReportsViewModel

// TODO route name: "progress_reports"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProgressReportsScreen(
    navController: NavController,
    viewModel: ProgressReportsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Progress Reports", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = viewModel::refresh) {
                        Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                    }
                }
            )
        }
    ) { paddingValues ->
        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = MochaBrown)
                }
            }

            uiState.errorMessage != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            uiState.errorMessage ?: "Unknown error",
                            color = MaterialTheme.colorScheme.error,
                            textAlign = TextAlign.Center
                        )
                        Spacer(Modifier.height(12.dp))
                        Button(onClick = viewModel::refresh) { Text("Retry") }
                    }
                }
            }

            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(20.dp)
                ) {
                    item {
                        Text(
                            "Last 7 Days",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    // ---- Calories Bar Chart ----
                    item {
                        ChartCard(title = "Calories Logged", subtitle = "kcal per day") {
                            BarChart(
                                values = uiState.caloriesPerDay.map { it.calories.toFloat() },
                                labels = uiState.caloriesPerDay.map { it.label },
                                barColor = EnergeticOrange,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(160.dp)
                            )
                        }
                    }

                    // ---- Weight Trend Dot Chart ----
                    item {
                        ChartCard(title = "Weight Trend", subtitle = "kg") {
                            if (uiState.weightPoints.isEmpty()) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(160.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        "No weight data for this period",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            } else {
                                WeightDotChart(
                                    points = uiState.weightPoints.map { it.weight.toFloat() },
                                    labels = uiState.weightPoints.map { it.label },
                                    lineColor = ProteinBlue,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(160.dp)
                                )
                            }
                        }
                    }

                    // ---- Exercise Bar Chart ----
                    item {
                        ChartCard(title = "Exercise Minutes", subtitle = "minutes per day") {
                            BarChart(
                                values = uiState.exercisePerDay.map { it.minutes.toFloat() },
                                labels = uiState.exercisePerDay.map { it.label },
                                barColor = ExerciseGreen,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(160.dp)
                            )
                        }
                    }

                    item { Spacer(Modifier.height(16.dp)) }
                }
            }
        }
    }
}

// ---- Shared card wrapper ----

@Composable
private fun ChartCard(
    title: String,
    subtitle: String,
    content: @Composable () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(bottom = 12.dp)
            )
            content()
        }
    }
}

// ---- Bar Chart (Compose Canvas) ----

@Composable
private fun BarChart(
    values: List<Float>,
    labels: List<String>,
    barColor: Color,
    modifier: Modifier = Modifier
) {
    if (values.isEmpty()) return

    val maxValue = values.maxOrNull()?.takeIf { it > 0f } ?: 1f
    val barCount = values.size

    Column(modifier = modifier) {
        Canvas(modifier = Modifier.weight(1f).fillMaxWidth()) {
            val canvasWidth = size.width
            val canvasHeight = size.height
            val barWidth = canvasWidth / (barCount * 1.8f)
            val gap = (canvasWidth - barWidth * barCount) / (barCount + 1)

            values.forEachIndexed { index, value ->
                val barHeight = (value / maxValue) * canvasHeight
                val left = gap + index * (barWidth + gap)
                val top = canvasHeight - barHeight

                drawRoundRect(
                    color = barColor,
                    topLeft = Offset(left, top),
                    size = androidx.compose.ui.geometry.Size(barWidth, barHeight),
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(6f, 6f)
                )
            }
        }

        // X-axis labels
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            labels.forEach { label ->
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    fontSize = 10.sp,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

// ---- Weight Dot / Line Chart (Compose Canvas) ----

@Composable
private fun WeightDotChart(
    points: List<Float>,
    labels: List<String>,
    lineColor: Color,
    modifier: Modifier = Modifier
) {
    if (points.isEmpty()) return

    val minValue = points.minOrNull() ?: 0f
    val maxValue = points.maxOrNull() ?: 1f
    val range = (maxValue - minValue).takeIf { it > 0f } ?: 1f
    val count = points.size

    Column(modifier = modifier) {
        Canvas(modifier = Modifier.weight(1f).fillMaxWidth()) {
            val canvasWidth = size.width
            val canvasHeight = size.height
            val paddingPx = 20f
            val usableWidth = canvasWidth - paddingPx * 2
            val usableHeight = canvasHeight - paddingPx * 2

            val xStep = if (count > 1) usableWidth / (count - 1) else usableWidth / 2f

            // Compute pixel positions
            val coords = points.mapIndexed { i, v ->
                val x = paddingPx + i * xStep
                val y = paddingPx + (1f - (v - minValue) / range) * usableHeight
                Offset(x, y)
            }

            // Draw connecting line
            if (coords.size > 1) {
                val path = Path().apply {
                    moveTo(coords[0].x, coords[0].y)
                    coords.drop(1).forEach { lineTo(it.x, it.y) }
                }
                drawPath(
                    path = path,
                    color = lineColor.copy(alpha = 0.5f),
                    style = androidx.compose.ui.graphics.drawscope.Stroke(
                        width = 3f,
                        cap = StrokeCap.Round
                    )
                )
            }

            // Draw dots
            coords.forEach { offset ->
                drawCircle(color = lineColor, radius = 8f, center = offset)
                drawCircle(
                    color = Color.White,
                    radius = 4f,
                    center = offset
                )
            }
        }

        // X-axis labels
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            labels.forEach { label ->
                Text(
                    text = label,
                    style = MaterialTheme.typography.labelSmall,
                    fontSize = 10.sp,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}
