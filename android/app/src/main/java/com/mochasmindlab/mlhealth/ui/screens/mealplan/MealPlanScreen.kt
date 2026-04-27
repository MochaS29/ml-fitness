package com.mochasmindlab.mlhealth.ui.screens.mealplan

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.DietPlan
import com.mochasmindlab.mlhealth.data.models.PlanRecipe
import com.mochasmindlab.mlhealth.viewmodel.MealPlanViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MealPlanScreen(
    navController: NavController,
    viewModel: MealPlanViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()
    var detailPlanRecipe by remember { mutableStateOf<PlanRecipe?>(null) }

    val snackbarHostState = remember { SnackbarHostState() }
    LaunchedEffect(Unit) {
        viewModel.toast.collect { message ->
            snackbarHostState.showSnackbar(message)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Meal Plans", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        if (state.isLoading) {
            Box(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
            return@Scaffold
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item { DietSelector(state.diets, state.selectedDiet, viewModel::selectDiet) }

            state.selectedDiet?.let { diet ->
                item { DietHeader(diet) }
                item { WeekSelector(diet.weeks.size, state.selectedWeekIndex, viewModel::selectWeek) }
                state.selectedWeek?.let { week ->
                    item {
                        DaySelector(
                            week.days.map { it.dayName },
                            state.selectedDayIndex,
                            viewModel::selectDay
                        )
                    }
                }
                state.selectedDay?.let { day ->
                    item {
                        DailyTotals(
                            calories = day.totalCalories,
                            protein = day.totalProtein,
                            carbs = day.totalCarbs,
                            fat = day.totalFat
                        )
                    }
                    item { MealRow("Breakfast", day.breakfast) { detailPlanRecipe = day.breakfast } }
                    item { MealRow("Lunch", day.lunch) { detailPlanRecipe = day.lunch } }
                    item { MealRow("Dinner", day.dinner) { detailPlanRecipe = day.dinner } }
                    item { MealRow("Snack", day.snack) { detailPlanRecipe = day.snack } }
                }
            }
        }
    }

    detailPlanRecipe?.let { recipe ->
        PlanRecipeDetailSheet(
            recipe = recipe,
            onDismiss = { detailPlanRecipe = null },
            onLog = { mealType ->
                viewModel.logRecipeToDiary(recipe, mealType)
                detailPlanRecipe = null
            }
        )
    }
}

@Composable
private fun DietSelector(
    diets: List<DietPlan>,
    selected: DietPlan?,
    onSelect: (String) -> Unit
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(diets, key = { it.id }) { diet ->
            val isSelected = diet.id == selected?.id
            FilterChip(
                selected = isSelected,
                onClick = { onSelect(diet.id) },
                label = { Text(diet.name) }
            )
        }
    }
}

@Composable
private fun DietHeader(diet: DietPlan) {
    Card(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(diet.name, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(6.dp))
            Text(diet.description, fontSize = 14.sp, color = Color.Gray)
        }
    }
}

@Composable
private fun WeekSelector(weekCount: Int, selectedIndex: Int, onSelect: (Int) -> Unit) {
    if (weekCount <= 1) return
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(weekCount) { i ->
            FilterChip(
                selected = i == selectedIndex,
                onClick = { onSelect(i) },
                label = { Text("Week ${i + 1}") }
            )
        }
    }
}

@Composable
private fun DaySelector(dayNames: List<String>, selectedIndex: Int, onSelect: (Int) -> Unit) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        itemsIndexed(dayNames) { index, name ->
            val isSelected = index == selectedIndex
            Card(
                modifier = Modifier.clickable { onSelect(index) },
                colors = CardDefaults.cardColors(
                    containerColor = if (isSelected)
                        MaterialTheme.colorScheme.primary
                    else
                        MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Text(
                    name.take(3),
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                    color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
private fun DailyTotals(calories: Int, protein: Double, carbs: Double, fat: Double) {
    Card(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            StatBlock(calories.toString(), "kcal")
            StatBlock("${protein.toInt()}g", "protein")
            StatBlock("${carbs.toInt()}g", "carbs")
            StatBlock("${fat.toInt()}g", "fat")
        }
    }
}

@Composable
private fun StatBlock(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Text(label, fontSize = 12.sp, color = Color.Gray)
    }
}

@Composable
private fun MealRow(label: String, recipe: PlanRecipe, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp).clickable { onClick() }
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(label.uppercase(), fontSize = 11.sp, color = Color.Gray, fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(4.dp))
            Text(recipe.name, fontSize = 17.sp, fontWeight = FontWeight.Medium)
            if (recipe.description.isNotBlank()) {
                Spacer(Modifier.height(4.dp))
                Text(
                    recipe.description,
                    fontSize = 13.sp,
                    color = Color.Gray,
                    maxLines = 2
                )
            }
            Spacer(Modifier.height(8.dp))
            Text(
                "${recipe.calories} kcal • ${recipe.totalTime} min • P${recipe.protein.toInt()}/C${recipe.carbs.toInt()}/F${recipe.fat.toInt()}",
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PlanRecipeDetailSheet(
    recipe: PlanRecipe,
    onDismiss: () -> Unit,
    onLog: (mealType: String) -> Unit
) {
    ModalBottomSheet(onDismissRequest = onDismiss) {
        LazyColumn(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp),
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(recipe.name, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                }
            }

            if (recipe.description.isNotBlank()) {
                item {
                    Spacer(Modifier.height(4.dp))
                    Text(recipe.description, color = Color.Gray, fontSize = 14.sp)
                }
            }

            item {
                Spacer(Modifier.height(12.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    StatBlock("${recipe.calories}", "kcal")
                    StatBlock("${recipe.protein.toInt()}g", "protein")
                    StatBlock("${recipe.carbs.toInt()}g", "carbs")
                    StatBlock("${recipe.fat.toInt()}g", "fat")
                }
            }

            item {
                Spacer(Modifier.height(12.dp))
                Text(
                    "Prep ${recipe.prepTime} min • Cook ${recipe.cookTime} min",
                    color = Color.Gray,
                    fontSize = 13.sp
                )
            }

            if (recipe.ingredients.isNotEmpty()) {
                item {
                    Spacer(Modifier.height(20.dp))
                    Text("Ingredients", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
                items(recipe.ingredients) { ing ->
                    Row(modifier = Modifier.padding(vertical = 4.dp)) {
                        Box(
                            modifier = Modifier
                                .padding(top = 7.dp, end = 10.dp)
                                .size(6.dp)
                                .clip(RoundedCornerShape(3.dp))
                                .background(MaterialTheme.colorScheme.primary)
                        )
                        Text(ing, fontSize = 14.sp)
                    }
                }
            }

            if (recipe.instructions.isNotEmpty()) {
                item {
                    Spacer(Modifier.height(20.dp))
                    Text("Instructions", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
                itemsIndexed(recipe.instructions) { index, step ->
                    Row(modifier = Modifier.padding(vertical = 6.dp)) {
                        Text(
                            "${index + 1}.",
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.padding(end = 8.dp)
                        )
                        Text(step, fontSize = 14.sp, lineHeight = 20.sp)
                    }
                }
            }

            if (recipe.tags.isNotEmpty()) {
                item {
                    Spacer(Modifier.height(16.dp))
                    Text(
                        recipe.tags.joinToString(" • "),
                        fontSize = 12.sp,
                        color = Color.Gray
                    )
                }
            }

            item {
                Spacer(Modifier.height(20.dp))
                Text("Log to today's diary", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    listOf("Breakfast", "Lunch", "Dinner", "Snack").forEach { mt ->
                        Button(
                            onClick = { onLog(mt) },
                            modifier = Modifier.weight(1f),
                            contentPadding = PaddingValues(vertical = 12.dp, horizontal = 4.dp)
                        ) {
                            Text(mt.take(1), fontWeight = FontWeight.Bold)
                        }
                    }
                }
                Spacer(Modifier.height(4.dp))
                Text(
                    "B / L / D / S",
                    fontSize = 11.sp,
                    color = Color.Gray
                )
            }
        }
    }
}
