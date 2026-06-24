package com.mochasmindlab.mlhealth.ui.screens.nutrition

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.Period
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import com.mochasmindlab.mlhealth.viewmodel.NutritionDetailViewModel
import androidx.compose.foundation.lazy.LazyColumn

// TODO: add this composable to MLFitnessNavigation.kt:
//   composable("nutrition_detail") { NutritionDetailScreen(navController) }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NutritionDetailScreen(
    navController: NavController,
    viewModel: NutritionDetailViewModel = hiltViewModel()
) {
    val period     by viewModel.period.collectAsState()
    val today      by viewModel.dailyTotals.collectAsState()
    val weekDays   by viewModel.weekDays.collectAsState()
    val monthDays  by viewModel.monthDays.collectAsState()
    val goals      by viewModel.goals.collectAsState()
    val isLoading  by viewModel.isLoading.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Nutrition", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->

        if (isLoading) {
            Box(
                Modifier.fillMaxSize().padding(padding),
                contentAlignment = Alignment.Center
            ) { CircularProgressIndicator(color = MochaBrown) }
            return@Scaffold
        }

        Column(Modifier.fillMaxSize().padding(padding)) {

            // ---- Tab row ----
            val tabs = listOf("Today", "Week", "Month")
            TabRow(
                selectedTabIndex = period.ordinal,
                containerColor  = MaterialTheme.colorScheme.surface,
                contentColor    = MochaBrown
            ) {
                tabs.forEachIndexed { i, title ->
                    Tab(
                        selected = period.ordinal == i,
                        onClick  = { viewModel.selectPeriod(Period.values()[i]) },
                        text     = {
                            Text(
                                title,
                                fontWeight = if (period.ordinal == i) FontWeight.Bold
                                             else FontWeight.Normal
                            )
                        }
                    )
                }
            }

            // ---- Scrollable content ----
            LazyColumn(
                Modifier.fillMaxSize(),
                contentPadding         = PaddingValues(16.dp),
                verticalArrangement    = Arrangement.spacedBy(16.dp)
            ) {

                when (period) {
                    // ---- TODAY ----
                    Period.DAY -> {
                        item {
                            SummaryCard(
                                title    = "Today's Summary",
                                calories = today.calories,
                                protein  = today.protein,
                                carbs    = today.carbs,
                                fat      = today.fat,
                                showAvg  = false
                            )
                        }
                        item { MacrosProgressCard(today, goals) }
                        item {
                            MealBarChartCard(
                                meals        = today.mealBreakdown,
                                calorieGoal  = goals.calories.toDouble()
                            )
                        }
                        if (today.micronutrients.isNotEmpty()) {
                            item { MicronutrientsCard(today.micronutrients) }
                        }
                    }

                    // ---- WEEK ----
                    Period.WEEK -> {
                        val labels = viewModel.labelsFor(weekDays, Period.WEEK)
                        val avg    = averageOf(weekDays)
                        item {
                            SummaryCard(
                                title    = "This Week — Avg / Day",
                                calories = avg.calories,
                                protein  = avg.protein,
                                carbs    = avg.carbs,
                                fat      = avg.fat,
                                showAvg  = true
                            )
                        }
                        item {
                            DailyCalorieChartCard(
                                title    = "Daily Calories (7 days)",
                                values   = weekDays.map { it.calories.toFloat() },
                                labels   = labels,
                                goalLine = goals.calories.toFloat()
                            )
                        }
                    }

                    // ---- MONTH ----
                    Period.MONTH -> {
                        val labels = viewModel.labelsFor(monthDays, Period.MONTH)
                        val avg    = averageOf(monthDays)
                        item {
                            SummaryCard(
                                title    = "This Month — Avg / Day",
                                calories = avg.calories,
                                protein  = avg.protein,
                                carbs    = avg.carbs,
                                fat      = avg.fat,
                                showAvg  = true
                            )
                        }
                        item {
                            DailyCalorieChartCard(
                                title     = "Daily Calories (30 days)",
                                values    = monthDays.map { it.calories.toFloat() },
                                labels    = labels,
                                goalLine  = goals.calories.toFloat(),
                                maxLabels = 10
                            )
                        }
                    }
                }

                // ---- Nutrient table — all tabs ----
                item {
                    val (totals, divider, isAvg) = when (period) {
                        Period.DAY ->
                            Triple(today.toSimpleTotals(), 1.0, false)
                        Period.WEEK ->
                            Triple(sumOf(weekDays).toSimpleTotals(),
                                   weekDays.size.coerceAtLeast(1).toDouble(), true)
                        Period.MONTH ->
                            Triple(sumOf(monthDays).toSimpleTotals(),
                                   monthDays.size.coerceAtLeast(1).toDouble(), true)
                    }
                    NutrientTableCard(totals = totals, divider = divider,
                                      goals = goals, showAvg = isAvg)
                }

                item { Spacer(Modifier.height(16.dp)) }
            }
        }
    }
}

// =====================================================================
// CARDS  (thin wrappers that call components from NutritionComponents.kt)
// =====================================================================

@Composable
private fun SummaryCard(
    title: String, calories: Double, protein: Double,
    carbs: Double, fat: Double, showAvg: Boolean
) {
    NutritionCard(title = title) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            StatChip(
                if (showAvg) "Avg Cal" else "Calories",
                "%.0f".format(calories), "kcal",
                com.mochasmindlab.mlhealth.ui.theme.EnergeticOrange, Modifier.weight(1f)
            )
            StatChip(
                if (showAvg) "Avg Protein" else "Protein",
                "%.1f".format(protein), "g",
                com.mochasmindlab.mlhealth.ui.theme.ProteinBlue, Modifier.weight(1f)
            )
        }
        Spacer(Modifier.height(8.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            StatChip(
                if (showAvg) "Avg Carbs" else "Carbs",
                "%.1f".format(carbs), "g",
                com.mochasmindlab.mlhealth.ui.theme.CarbsGreen, Modifier.weight(1f)
            )
            StatChip(
                if (showAvg) "Avg Fat" else "Fat",
                "%.1f".format(fat), "g",
                com.mochasmindlab.mlhealth.ui.theme.FatYellow, Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun MacrosProgressCard(
    totals: com.mochasmindlab.mlhealth.data.models.NutritionDailyTotals,
    goals: com.mochasmindlab.mlhealth.data.models.MacroGoals
) {
    NutritionCard(title = "Today's Macros") {
        MacroBar("Protein", totals.protein, goals.protein, "g",
                 com.mochasmindlab.mlhealth.ui.theme.ProteinBlue)
        Spacer(Modifier.height(8.dp))
        MacroBar("Carbs", totals.carbs, goals.carbs, "g",
                 com.mochasmindlab.mlhealth.ui.theme.CarbsGreen)
        Spacer(Modifier.height(8.dp))
        MacroBar("Fat", totals.fat, goals.fat, "g",
                 com.mochasmindlab.mlhealth.ui.theme.FatYellow)
        Spacer(Modifier.height(8.dp))
        MacroBar("Fiber", totals.fiber, goals.fiber, "g",
                 com.mochasmindlab.mlhealth.ui.theme.NutritionGreen)
        if (totals.sodium > 0) {
            Spacer(Modifier.height(8.dp))
            MacroBar("Sodium", totals.sodium, goals.sodium, "mg",
                     androidx.compose.ui.graphics.Color(0xFF9E9E9E))
        }
    }
}

@Composable
private fun MicronutrientsCard(micros: Map<String, Double>) {
    NutritionCard(title = "Vitamins & Minerals") {
        // Stable alphabetical order so the list doesn't jump around between loads.
        micros.entries.sortedBy { it.key }.forEach { (key, value) ->
            Row(
                Modifier.fillMaxWidth().padding(vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    prettyNutrientName(key),
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    "%.1f".format(value),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

private fun prettyNutrientName(key: String): String =
    key.split('_', ' ').filter { it.isNotBlank() }.joinToString(" ") { part ->
        when (part.lowercase()) {
            "a", "c", "d", "e", "k", "b1", "b2", "b3", "b6", "b12" -> part.uppercase()
            else -> part.replaceFirstChar { it.uppercase() }
        }
    }

@Composable
private fun MealBarChartCard(
    meals: List<com.mochasmindlab.mlhealth.data.models.MealTotals>,
    calorieGoal: Double
) {
    if (meals.isEmpty()) return
    NutritionCard(title = "Calories by Meal") {
        NutritionBarChart(
            values   = meals.map { it.calories.toFloat() },
            labels   = meals.map { it.mealType },
            barColor = com.mochasmindlab.mlhealth.ui.theme.EnergeticOrange,
            goalLine = calorieGoal.toFloat(),
            modifier = Modifier.fillMaxWidth().height(160.dp)
        )
    }
}

@Composable
private fun DailyCalorieChartCard(
    title: String,
    values: List<Float>,
    labels: List<String>,
    goalLine: Float,
    maxLabels: Int = values.size
) {
    val displayLabels = if (values.size > maxLabels) {
        val step = values.size / maxLabels
        labels.mapIndexed { i, l -> if (i % step == 0) l else "" }
    } else labels
    NutritionCard(title = title) {
        NutritionBarChart(
            values   = values,
            labels   = displayLabels,
            barColor = com.mochasmindlab.mlhealth.ui.theme.EnergeticOrange,
            goalLine = goalLine,
            modifier = Modifier.fillMaxWidth().height(180.dp)
        )
    }
}

@Composable
private fun NutrientTableCard(
    totals: SimpleTotals,
    divider: Double,
    goals: com.mochasmindlab.mlhealth.data.models.MacroGoals,
    showAvg: Boolean
) {
    val avg = if (showAvg) "avg/day" else null
    NutritionCard(
        title = if (showAvg) "Average Nutrients" else "Full Nutrient Breakdown"
    ) {
        NutrientRow("Calories",      totals.calories / divider, "kcal",
                    com.mochasmindlab.mlhealth.ui.theme.EnergeticOrange, avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Protein",       totals.protein  / divider, "g",
                    com.mochasmindlab.mlhealth.ui.theme.ProteinBlue, avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Carbohydrates", totals.carbs    / divider, "g",
                    com.mochasmindlab.mlhealth.ui.theme.CarbsGreen, avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Fat",           totals.fat      / divider, "g",
                    com.mochasmindlab.mlhealth.ui.theme.FatYellow, avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Fiber",         totals.fiber    / divider, "g",
                    com.mochasmindlab.mlhealth.ui.theme.NutritionGreen, avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Sugar",         totals.sugar    / divider, "g",
                    androidx.compose.ui.graphics.Color(0xFFEC407A), avg)
        Divider(Modifier.padding(start = 16.dp))
        NutrientRow("Sodium",        totals.sodium   / divider, "mg",
                    androidx.compose.ui.graphics.Color(0xFF9E9E9E), avg)
    }
}
