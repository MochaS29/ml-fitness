package com.mochasmindlab.mlhealth.ui.screens.recipes

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.CustomRecipe
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.PlanRecipe
import com.mochasmindlab.mlhealth.services.MealPlanLoader
import com.mochasmindlab.mlhealth.ui.components.ServingSizeSheet
import com.mochasmindlab.mlhealth.ui.theme.MochaBrown
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Date
import java.util.UUID
import javax.inject.Inject

// ---------------------------------------------------------------------------
// TODO – Route wiring:
//   "recipe_detail/{recipeId}" → RecipeDetailScreen(navController, recipeId)
//   Register in MLFitnessNavigation:
//     composable("recipe_detail/{recipeId}") { backStack ->
//         val recipeId = backStack.arguments?.getString("recipeId") ?: return@composable
//         RecipeDetailScreen(navController = navController, recipeId = recipeId)
//     }
// ---------------------------------------------------------------------------

// ============================================================
// ViewModel
// ============================================================

sealed class RecipeDetailState {
    object Loading : RecipeDetailState()
    data class Custom(val recipe: CustomRecipe) : RecipeDetailState()
    data class Bundled(val recipe: PlanRecipe) : RecipeDetailState()
    data class Error(val message: String) : RecipeDetailState()
}

@HiltViewModel
class RecipeDetailViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    private val mealPlanLoader: MealPlanLoader
) : ViewModel() {

    private val _state = MutableStateFlow<RecipeDetailState>(RecipeDetailState.Loading)
    val state: StateFlow<RecipeDetailState> = _state.asStateFlow()

    private val _loggedSuccessfully = MutableStateFlow(false)
    val loggedSuccessfully: StateFlow<Boolean> = _loggedSuccessfully.asStateFlow()

    fun load(recipeId: String) {
        viewModelScope.launch {
            // Try parsing as UUID → custom recipe in DB
            val uuid = runCatching { UUID.fromString(recipeId) }.getOrNull()
            if (uuid != null) {
                val custom = withContext(Dispatchers.IO) {
                    database.customRecipeDao().getAllRecipes().firstOrNull { it.id == uuid }
                }
                if (custom != null) {
                    _state.value = RecipeDetailState.Custom(custom)
                    return@launch
                }
            }
            // Otherwise search bundled plans by slug id
            val plans = withContext(Dispatchers.IO) { mealPlanLoader.loadAll() }
            for (plan in plans) {
                for (week in plan.weeks) {
                    for (day in week.days) {
                        val allRecipes = listOf(day.breakfast, day.lunch, day.dinner, day.snack)
                        val match = allRecipes.firstOrNull { it.id == recipeId }
                        if (match != null) {
                            _state.value = RecipeDetailState.Bundled(match)
                            return@launch
                        }
                    }
                }
            }
            _state.value = RecipeDetailState.Error("Recipe not found")
        }
    }

    fun logToDiary(
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        servings: Double,
        mealType: String
    ) {
        viewModelScope.launch {
            val entry = FoodEntry(
                id          = UUID.randomUUID(),
                name        = name,
                date        = Date(),
                mealType    = mealType,
                servingSize = "1",
                servingUnit = "serving",
                servingCount = servings,
                calories    = calories * servings,
                protein     = protein * servings,
                carbs       = carbs * servings,
                fat         = fat * servings
            )
            withContext(Dispatchers.IO) { database.foodDao().insert(entry) }
            _loggedSuccessfully.value = true
        }
    }
}

// ============================================================
// Screen
// ============================================================

private enum class RecipeTab { INGREDIENTS, STEPS, NUTRITION }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeDetailScreen(
    navController: NavController,
    recipeId: String,
    viewModel: RecipeDetailViewModel = hiltViewModel()
) {
    LaunchedEffect(recipeId) { viewModel.load(recipeId) }

    val detailState by viewModel.state.collectAsState()
    val loggedOk by viewModel.loggedSuccessfully.collectAsState()

    var activeTab by remember { mutableStateOf(RecipeTab.INGREDIENTS) }
    var showServingSheet by remember { mutableStateOf(false) }

    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(loggedOk) {
        if (loggedOk) snackbarHostState.showSnackbar("Logged to diary!")
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = {
                    val title = when (val s = detailState) {
                        is RecipeDetailState.Custom  -> s.recipe.name
                        is RecipeDetailState.Bundled -> s.recipe.name
                        else -> "Recipe"
                    }
                    Text(title, maxLines = 1, fontWeight = FontWeight.Bold)
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        bottomBar = {
            if (detailState !is RecipeDetailState.Loading && detailState !is RecipeDetailState.Error) {
                Surface(shadowElevation = 8.dp) {
                    Button(
                        onClick = { showServingSheet = true },
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        contentPadding = PaddingValues(vertical = 14.dp)
                    ) {
                        Icon(Icons.Default.Book, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Log to Diary", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }
        }
    ) { padding ->
        when (val s = detailState) {
            RecipeDetailState.Loading -> LoadingContent(Modifier.padding(padding))
            is RecipeDetailState.Error -> ErrorContent(s.message, Modifier.padding(padding))
            is RecipeDetailState.Custom -> RecipeContent(
                name         = s.recipe.name,
                description  = "",
                calories     = s.recipe.calories.toInt(),
                protein      = s.recipe.protein,
                carbs        = s.recipe.carbs,
                fat          = s.recipe.fat,
                fiber        = s.recipe.fiber,
                sugar        = s.recipe.sugar,
                sodium       = s.recipe.sodium,
                prepTime     = s.recipe.prepTime,
                cookTime     = s.recipe.cookTime,
                servings     = s.recipe.servings,
                ingredients  = s.recipe.ingredients,
                instructions = s.recipe.instructions,
                activeTab    = activeTab,
                onTabSelect  = { activeTab = it },
                modifier     = Modifier.padding(padding)
            )
            is RecipeDetailState.Bundled -> RecipeContent(
                name         = s.recipe.name,
                description  = s.recipe.description,
                calories     = s.recipe.calories,
                protein      = s.recipe.protein,
                carbs        = s.recipe.carbs,
                fat          = s.recipe.fat,
                fiber        = s.recipe.fiber,
                sugar        = null,
                sodium       = null,
                prepTime     = s.recipe.prepTime,
                cookTime     = s.recipe.cookTime,
                servings     = 2,
                ingredients  = s.recipe.ingredients,
                instructions = s.recipe.instructions,
                activeTab    = activeTab,
                onTabSelect  = { activeTab = it },
                modifier     = Modifier.padding(padding)
            )
        }
    }

    // Serving size sheet
    if (showServingSheet) {
        data class LogInfo(val name: String, val kcal: Int, val prot: Double, val carbs: Double, val fat: Double)
        val info: LogInfo = when (val s = detailState) {
            is RecipeDetailState.Custom  -> LogInfo(s.recipe.name, s.recipe.calories.toInt(), s.recipe.protein, s.recipe.carbs, s.recipe.fat)
            is RecipeDetailState.Bundled -> LogInfo(s.recipe.name, s.recipe.calories, s.recipe.protein, s.recipe.carbs, s.recipe.fat)
            else -> LogInfo("Recipe", 0, 0.0, 0.0, 0.0)
        }
        ServingSizeSheet(
            title = info.name,
            subtitle = "Per serving",
            perServingCalories = info.kcal,
            perServingProtein  = info.prot,
            perServingCarbs    = info.carbs,
            perServingFat      = info.fat,
            onConfirm = { servings, mealType ->
                viewModel.logToDiary(
                    name     = info.name,
                    calories = info.kcal,
                    protein  = info.prot,
                    carbs    = info.carbs,
                    fat      = info.fat,
                    servings = servings,
                    mealType = mealType
                )
                showServingSheet = false
            },
            onDismiss = { showServingSheet = false }
        )
    }
}

// ============================================================
// Inner composables
// ============================================================

@Composable
private fun RecipeContent(
    name: String,
    description: String,
    calories: Int,
    protein: Double,
    carbs: Double,
    fat: Double,
    fiber: Double?,
    sugar: Double?,
    sodium: Double?,
    prepTime: Int,
    cookTime: Int,
    servings: Int,
    ingredients: List<String>,
    instructions: List<String>,
    activeTab: RecipeTab,
    onTabSelect: (RecipeTab) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxSize()) {
        // Quick stats row
        if (calories > 0 || prepTime > 0 || cookTime > 0) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                if (prepTime + cookTime > 0) {
                    StatChip(Icons.Default.Timer, "${prepTime + cookTime} min")
                }
                if (calories > 0) {
                    StatChip(Icons.Default.LocalFireDepartment, "$calories cal")
                }
                if (servings > 0) {
                    StatChip(Icons.Default.People, "$servings servings")
                }
            }
        }

        if (description.isNotBlank()) {
            Text(
                description,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Divider(modifier = Modifier.padding(top = 8.dp))

        // Tab row
        TabRow(selectedTabIndex = activeTab.ordinal) {
            RecipeTab.entries.forEach { tab ->
                Tab(
                    selected = activeTab == tab,
                    onClick = { onTabSelect(tab) },
                    text = { Text(tab.name.lowercase().replaceFirstChar { it.uppercase() }) }
                )
            }
        }

        // Tab content
        when (activeTab) {
            RecipeTab.INGREDIENTS -> IngredientsTab(ingredients)
            RecipeTab.STEPS       -> StepsTab(instructions)
            RecipeTab.NUTRITION   -> NutritionTab(calories, protein, carbs, fat, fiber, sugar, sodium)
        }
    }
}

@Composable
private fun IngredientsTab(ingredients: List<String>) {
    if (ingredients.isEmpty()) {
        EmptyTabMessage("No ingredients listed")
        return
    }
    LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        itemsIndexed(ingredients) { _, ingredient ->
            Row(verticalAlignment = Alignment.Top) {
                Text("• ", color = MochaBrown, fontWeight = FontWeight.Bold)
                Text(ingredient)
            }
        }
    }
}

@Composable
private fun StepsTab(instructions: List<String>) {
    if (instructions.isEmpty()) {
        EmptyTabMessage("No steps listed")
        return
    }
    LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        itemsIndexed(instructions) { index, step ->
            Row(verticalAlignment = Alignment.Top) {
                Surface(
                    shape = MaterialTheme.shapes.small,
                    color = MochaBrown,
                    modifier = Modifier.padding(end = 12.dp, top = 2.dp)
                ) {
                    Text(
                        "${index + 1}",
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }
                Text(step, modifier = Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun NutritionTab(
    calories: Int,
    protein: Double,
    carbs: Double,
    fat: Double,
    fiber: Double?,
    sugar: Double?,
    sodium: Double?
) {
    LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        item {
            Text("Per Serving", fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(8.dp))
        }
        item { NutritionRow("Calories", "$calories kcal") }
        item { Divider() }
        item { NutritionRow("Protein", "${protein.formatNutrient()}g") }
        item { Divider() }
        item { NutritionRow("Carbohydrates", "${carbs.formatNutrient()}g") }
        item { Divider() }
        item { NutritionRow("Fat", "${fat.formatNutrient()}g") }
        if (fiber != null && fiber > 0) {
            item { Divider() }
            item { NutritionRow("Fiber", "${fiber.formatNutrient()}g") }
        }
        if (sugar != null && sugar > 0) {
            item { Divider() }
            item { NutritionRow("Sugar", "${sugar.formatNutrient()}g") }
        }
        if (sodium != null && sodium > 0) {
            item { Divider() }
            item { NutritionRow("Sodium", "${sodium.formatNutrient()}mg") }
        }
    }
}

@Composable
private fun NutritionRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label)
        Text(value, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun StatChip(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String) {
    Surface(color = MochaBrown.copy(alpha = 0.1f), shape = MaterialTheme.shapes.small) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(icon, contentDescription = null, modifier = Modifier.size(14.dp), tint = MochaBrown)
            Spacer(Modifier.width(4.dp))
            Text(label, fontSize = 12.sp, color = MochaBrown, fontWeight = FontWeight.SemiBold)
        }
    }
}

@Composable
private fun EmptyTabMessage(msg: String) {
    Box(modifier = Modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.Center) {
        Text(msg, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun LoadingContent(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(color = MochaBrown)
    }
}

@Composable
private fun ErrorContent(message: String, modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(Icons.Default.ErrorOutline, contentDescription = null, modifier = Modifier.size(48.dp), tint = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(8.dp))
            Text(message, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

private fun Double.formatNutrient(): String {
    return if (this == kotlin.math.floor(this)) this.toInt().toString()
    else "%.1f".format(this)
}
