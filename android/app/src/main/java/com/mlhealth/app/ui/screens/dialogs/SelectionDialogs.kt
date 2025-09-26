package com.mlhealth.app.ui.screens.dialogs

import androidx.compose.runtime.*
import androidx.hilt.navigation.compose.hiltViewModel
import com.mlhealth.app.data.Supplement
import com.mlhealth.app.data.SupplementDatabase
import com.mlhealth.app.ui.components.SearchableSelectionDialog
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

// Supplement Selection Dialog
@Composable
fun SupplementSelectionDialog(
    onSupplementSelected: (Supplement) -> Unit,
    onCreateNew: ((String) -> Unit)? = null,
    onDismiss: () -> Unit,
    viewModel: SupplementSelectionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    SearchableSelectionDialog(
        title = "Supplement",
        items = uiState.allSupplements,
        recentItems = uiState.recentSupplements,
        favoriteItems = uiState.favoriteSupplements,
        onItemSelected = onSupplementSelected,
        onCreateNew = onCreateNew,
        onDismiss = onDismiss,
        searchableText = { supplement ->
            "${supplement.brand} ${supplement.name} ${supplement.category}"
        },
        displayName = { it.name },
        displaySubtitle = { supplement ->
            "${supplement.brand} • ${supplement.servingSize}"
        },
        itemKey = { it.id }
    )
}

// Food Selection Dialog
@Composable
fun FoodSelectionDialog(
    mealType: String,
    onFoodSelected: (FoodItem) -> Unit,
    onCreateNew: ((String) -> Unit)? = null,
    onDismiss: () -> Unit,
    viewModel: FoodSelectionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(mealType) {
        viewModel.loadFoods(mealType)
    }

    SearchableSelectionDialog(
        title = "Food",
        items = uiState.allFoods,
        recentItems = uiState.recentFoods,
        favoriteItems = uiState.favoriteFoods,
        onItemSelected = onFoodSelected,
        onCreateNew = onCreateNew,
        onDismiss = onDismiss,
        searchableText = { food ->
            "${food.name} ${food.brand ?: ""}"
        },
        displayName = { it.name },
        displaySubtitle = { food ->
            val brandPart = food.brand?.let { "$it • " } ?: ""
            "${brandPart}${food.calories.toInt()} cal • ${food.servingSize}"
        },
        itemKey = { it.id }
    )
}

// Exercise Selection Dialog
@Composable
fun ExerciseSelectionDialog(
    onExerciseSelected: (ExerciseItem) -> Unit,
    onCreateNew: ((String) -> Unit)? = null,
    onDismiss: () -> Unit,
    viewModel: ExerciseSelectionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    SearchableSelectionDialog(
        title = "Exercise",
        items = uiState.allExercises,
        recentItems = uiState.recentExercises,
        favoriteItems = uiState.favoriteExercises,
        onItemSelected = onExerciseSelected,
        onCreateNew = onCreateNew,
        onDismiss = onDismiss,
        searchableText = { exercise ->
            "${exercise.name} ${exercise.category}"
        },
        displayName = { it.name },
        displaySubtitle = { exercise ->
            val caloriesFor30Min = (exercise.caloriesPerMinute * 30).toInt()
            "${exercise.category} • ~$caloriesFor30Min cal for 30 min"
        },
        itemKey = { it.id }
    )
}

// Data classes
data class FoodItem(
    val id: String,
    val name: String,
    val brand: String?,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val servingSize: String,
    val barcode: String? = null
)

data class ExerciseItem(
    val id: String,
    val name: String,
    val category: String,
    val caloriesPerMinute: Double,
    val defaultDuration: Int,
    val metValue: Double
)

// View Models
data class SupplementSelectionUiState(
    val allSupplements: List<Supplement> = emptyList(),
    val recentSupplements: List<Supplement> = emptyList(),
    val favoriteSupplements: List<Supplement> = emptyList()
)

@HiltViewModel
class SupplementSelectionViewModel @Inject constructor() : ViewModel() {
    private val _uiState = MutableStateFlow(SupplementSelectionUiState())
    val uiState: StateFlow<SupplementSelectionUiState> = _uiState.asStateFlow()

    init {
        loadSupplements()
    }

    private fun loadSupplements() {
        viewModelScope.launch {
            val allSupplements = SupplementDatabase.supplements.value

            // Get user's recent supplements (would come from database)
            val recentSupplements = allSupplements.filter {
                listOf(
                    "one-a-day-womens-personal",
                    "superbelly-probiotic",
                    "magnesium-citrate-personal"
                ).contains(it.id)
            }

            // Get favorites (would come from preferences)
            val favoriteSupplements = allSupplements.filter {
                listOf("one-a-day-womens-personal", "estrosmart").contains(it.id)
            }

            _uiState.value = SupplementSelectionUiState(
                allSupplements = allSupplements,
                recentSupplements = recentSupplements,
                favoriteSupplements = favoriteSupplements
            )
        }
    }
}

data class FoodSelectionUiState(
    val allFoods: List<FoodItem> = emptyList(),
    val recentFoods: List<FoodItem> = emptyList(),
    val favoriteFoods: List<FoodItem> = emptyList()
)

@HiltViewModel
class FoodSelectionViewModel @Inject constructor() : ViewModel() {
    private val _uiState = MutableStateFlow(FoodSelectionUiState())
    val uiState: StateFlow<FoodSelectionUiState> = _uiState.asStateFlow()

    fun loadFoods(mealType: String) {
        viewModelScope.launch {
            // This would load from database
            val allFoods = listOf(
                FoodItem("1", "Apple", null, 95.0, 0.5, 25.0, 0.3, "1 medium"),
                FoodItem("2", "Greek Yogurt", "Chobani", 100.0, 18.0, 6.0, 0.0, "1 cup", "818290014122"),
                FoodItem("3", "Chicken Breast", null, 165.0, 31.0, 0.0, 3.6, "100g"),
                FoodItem("4", "Brown Rice", null, 216.0, 5.0, 45.0, 1.8, "1 cup cooked"),
                FoodItem("5", "Protein Bar", "Quest", 200.0, 20.0, 21.0, 9.0, "1 bar", "888849008506"),
                FoodItem("6", "Banana", null, 105.0, 1.3, 27.0, 0.4, "1 medium"),
                FoodItem("7", "Almonds", null, 164.0, 6.0, 6.0, 14.0, "1 oz (28g)"),
                FoodItem("8", "Salmon", null, 206.0, 22.0, 0.0, 12.0, "100g"),
                FoodItem("9", "Oatmeal", "Quaker", 150.0, 5.0, 27.0, 3.0, "1 cup cooked"),
                FoodItem("10", "Eggs", null, 155.0, 13.0, 1.1, 11.0, "2 large")
            )

            val recentFoods = allFoods.take(3)
            val favoriteFoods = listOf(allFoods[1], allFoods[2])

            _uiState.value = FoodSelectionUiState(
                allFoods = allFoods,
                recentFoods = recentFoods,
                favoriteFoods = favoriteFoods
            )
        }
    }
}

data class ExerciseSelectionUiState(
    val allExercises: List<ExerciseItem> = emptyList(),
    val recentExercises: List<ExerciseItem> = emptyList(),
    val favoriteExercises: List<ExerciseItem> = emptyList()
)

@HiltViewModel
class ExerciseSelectionViewModel @Inject constructor() : ViewModel() {
    private val _uiState = MutableStateFlow(ExerciseSelectionUiState())
    val uiState: StateFlow<ExerciseSelectionUiState> = _uiState.asStateFlow()

    init {
        loadExercises()
    }

    private fun loadExercises() {
        viewModelScope.launch {
            val allExercises = listOf(
                ExerciseItem("1", "Running", "Cardio", 10.0, 30, 8.0),
                ExerciseItem("2", "Walking", "Cardio", 4.0, 30, 3.5),
                ExerciseItem("3", "Cycling", "Cardio", 8.0, 30, 6.0),
                ExerciseItem("4", "Swimming", "Cardio", 11.0, 30, 8.0),
                ExerciseItem("5", "Weight Training", "Strength", 6.0, 45, 5.0),
                ExerciseItem("6", "Yoga", "Flexibility", 3.0, 60, 2.5),
                ExerciseItem("7", "Pilates", "Strength", 4.0, 45, 3.0),
                ExerciseItem("8", "HIIT", "Cardio", 12.0, 20, 8.5),
                ExerciseItem("9", "Elliptical", "Cardio", 7.0, 30, 5.0),
                ExerciseItem("10", "Rowing", "Cardio", 9.0, 30, 7.0),
                ExerciseItem("11", "Jump Rope", "Cardio", 12.0, 15, 11.0),
                ExerciseItem("12", "Dancing", "Cardio", 5.0, 45, 4.5)
            )

            val recentExercises = allExercises.take(3)
            val favoriteExercises = listOf(allExercises[0], allExercises[4])

            _uiState.value = ExerciseSelectionUiState(
                allExercises = allExercises,
                recentExercises = recentExercises,
                favoriteExercises = favoriteExercises
            )
        }
    }
}