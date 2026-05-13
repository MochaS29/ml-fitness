package com.mochasmindlab.mlhealth.ui.screens.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.DashboardViewModel
import com.mochasmindlab.mlhealth.viewmodel.DashboardUiState
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    navController: NavController,
    viewModel: DashboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val aiInsights by viewModel.aiInsights.collectAsState()

    // Refresh totals whenever we return to the dashboard — picks up entries logged
    // (or deleted) on other screens since the VM doesn't observe DAO Flows.
    val lifecycleOwner = androidx.compose.ui.platform.LocalLifecycleOwner.current
    androidx.compose.runtime.DisposableEffect(lifecycleOwner) {
        val observer = androidx.lifecycle.LifecycleEventObserver { _, event ->
            if (event == androidx.lifecycle.Lifecycle.Event.ON_RESUME) {
                viewModel.refreshData()
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
                        "Dashboard",
                        fontWeight = FontWeight.Bold
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
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
            // Date Header
            item {
                DateHeader()
            }

            // AI Insights carousel — only renders when there's something to show.
            if (aiInsights.isNotEmpty()) {
                item {
                    InsightsCarousel(aiInsights, navController)
                }
            }

            // Daily Summary Cards (matching iOS)
            item {
                DailySummaryCards(uiState, navController)
            }

            // Calories Card
            item {
                CaloriesCard(
                    consumed = uiState.caloriesConsumed,
                    goal = uiState.calorieGoal,
                    remaining = uiState.calorieGoal - uiState.caloriesConsumed,
                    onClick = { navController.navigate("nutrition_detail") }
                )
            }

            // Macros Card
            item {
                MacrosCard(
                    protein = uiState.proteinGrams,
                    carbs = uiState.carbsGrams,
                    fat = uiState.fatGrams,
                    onClick = { navController.navigate("nutrition_detail") }
                )
            }

            // Water Card
            item {
                WaterCard(
                    consumed = uiState.waterCups,
                    goal = 8,
                    onClick = { navController.navigate("water") }
                )
            }

            // Weight Card
            item {
                WeightCard(
                    currentWeight = uiState.currentWeight.toFloat(),
                    weightChange = uiState.weightChange,
                    lastUpdated = uiState.lastWeightDate,
                    onClick = { navController.navigate("weight") }
                )
            }

            // Exercise Card
            item {
                ExerciseCard(
                    minutes = uiState.exerciseMinutes,
                    caloriesBurned = uiState.exerciseCalories,
                    onClick = { navController.navigate("exercise") }
                )
            }

            // Steps Card
            item {
                StepsCard(
                    steps = uiState.steps,
                    goal = 10000,
                    onClick = { navController.navigate("exercise") }
                )
            }
        }
    }
}

@Composable
fun DateHeader() {
    val today = LocalDate.now()
    val formatter = DateTimeFormatter.ofPattern("EEEE, MMMM d")

    Column(
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = "Today",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = today.format(formatter),
            fontSize = 16.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun InsightsCarousel(
    insights: List<com.mochasmindlab.mlhealth.viewmodel.AIInsight>,
    navController: NavController
) {
    Column {
        Text(
            text = "Today's insights",
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
            color = MochaBrown,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            items(insights.size) { i ->
                val insight = insights[i]
                val (emoji, color, route) = when (insight.type) {
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.HYDRATION ->
                        Triple("💧", Color(0xFF00BCD4), "water")
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.NUTRITION ->
                        Triple("🍎", MochaBrown, "nutrition_detail")
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.EXERCISE ->
                        Triple("💪", Color(0xFFFF5722), "exercise")
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.WEIGHT ->
                        Triple("⚖️", MochaBrown, "weight")
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.SLEEP ->
                        Triple("😴", Color(0xFF7E57C2), "sleep")
                    com.mochasmindlab.mlhealth.viewmodel.InsightType.GENERAL ->
                        Triple("✨", MochaBrown, null)
                }
                Card(
                    modifier = Modifier
                        .width(220.dp)
                        .clickable(enabled = route != null) {
                            route?.let { navController.navigate(it) }
                        },
                    colors = CardDefaults.cardColors(containerColor = color.copy(alpha = 0.08f))
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(emoji, fontSize = 18.sp)
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                insight.title,
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp,
                                color = color
                            )
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            insight.description,
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun DailySummaryCards(uiState: DashboardUiState, navController: NavController) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            SummaryCard(
                title = "Calories",
                value = "${uiState.caloriesConsumed}",
                subtitle = "of ${uiState.calorieGoal}",
                color = MochaBrown,
                onClick = { navController.navigate("nutrition_detail") }
            )
        }
        item {
            SummaryCard(
                title = "Water",
                value = "${uiState.waterCups}",
                subtitle = "cups",
                color = Color(0xFF00BCD4),
                onClick = { navController.navigate("water") }
            )
        }
        item {
            SummaryCard(
                title = "Steps",
                value = "${uiState.steps}",
                subtitle = "steps",
                color = Color(0xFF4CAF50),
                onClick = { navController.navigate("exercise") }
            )
        }
    }
}

@Composable
fun SummaryCard(
    title: String,
    value: String,
    subtitle: String,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .width(120.dp)
            .height(100.dp)
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = color.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = title,
                fontSize = 12.sp,
                color = color
            )
            Text(
                text = value,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = color
            )
            Text(
                text = subtitle,
                fontSize = 11.sp,
                color = color.copy(alpha = 0.7f)
            )
        }
    }
}

@Composable
fun CaloriesCard(
    consumed: Int,
    goal: Int,
    remaining: Int,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
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
                        text = "Calories",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "$consumed / $goal kcal",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Text(
                    text = "$remaining remaining",
                    fontSize = 14.sp,
                    color = if (remaining > 0) Color(0xFF4CAF50) else Color(0xFFFF5722)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Progress bar
            LinearProgressIndicator(
                progress = (consumed.toFloat() / goal.toFloat()).coerceIn(0f, 1f),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp),
                color = MochaBrown,
                trackColor = MochaBrown.copy(alpha = 0.2f)
            )
        }
    }
}

@Composable
fun MacrosCard(
    protein: Float,
    carbs: Float,
    fat: Float,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text(
                text = "Macronutrients",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                MacroItem(
                    name = "Protein",
                    value = "${protein.toInt()}g",
                    color = Color(0xFF2196F3)
                )
                MacroItem(
                    name = "Carbs",
                    value = "${carbs.toInt()}g",
                    color = Color(0xFF4CAF50)
                )
                MacroItem(
                    name = "Fat",
                    value = "${fat.toInt()}g",
                    color = Color(0xFFFFC107)
                )
            }
        }
    }
}

@Composable
fun MacroItem(
    name: String,
    value: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = name,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun WaterCard(
    consumed: Int,
    goal: Int,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF00BCD4).copy(alpha = 0.1f)
        )
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
                    text = "Water Intake",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "$consumed of $goal cups",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Text(
                text = "💧",
                fontSize = 32.sp
            )
        }
    }
}

@Composable
fun WeightCard(
    currentWeight: Float,
    weightChange: Float,
    lastUpdated: String?,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
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
                    text = "Weight",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "${currentWeight} lbs",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = MochaBrown
                )
                if (lastUpdated != null) {
                    Text(
                        text = "Updated $lastUpdated",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            if (weightChange != 0f) {
                Text(
                    text = if (weightChange > 0) "+${weightChange} lbs" else "${weightChange} lbs",
                    fontSize = 16.sp,
                    color = if (weightChange < 0) Color(0xFF4CAF50) else Color(0xFFFF5722)
                )
            }
        }
    }
}

@Composable
fun ExerciseCard(
    minutes: Int,
    caloriesBurned: Int,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
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
                    text = "Exercise",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "$minutes minutes",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Text(
                text = "$caloriesBurned kcal burned",
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFFFF5722)
            )
        }
    }
}

@Composable
fun StepsCard(
    steps: Int,
    goal: Int,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF4CAF50).copy(alpha = 0.1f)
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
                        text = "Steps",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "$steps / $goal",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Text(
                    text = "👟",
                    fontSize = 32.sp
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            LinearProgressIndicator(
                progress = (steps.toFloat() / goal.toFloat()).coerceIn(0f, 1f),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp),
                color = Color(0xFF4CAF50),
                trackColor = Color(0xFF4CAF50).copy(alpha = 0.2f)
            )
        }
    }
}