package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.FoodItem
import com.mochasmindlab.mlhealth.data.repository.FoodRepository
import com.mochasmindlab.mlhealth.di.ApplicationScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.Date
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class FoodSearchViewModel @Inject constructor(
    private val foodRepository: FoodRepository,
    private val database: MLFitnessDatabase,
    @ApplicationScope private val appScope: CoroutineScope
) : ViewModel() {

    private val _searchResults = MutableStateFlow<List<FoodItem>>(emptyList())
    val searchResults: StateFlow<List<FoodItem>> = _searchResults.asStateFlow()

    private val _recentFoods = MutableStateFlow<List<FoodItem>>(emptyList())
    val recentFoods: StateFlow<List<FoodItem>> = _recentFoods.asStateFlow()

    private val _favoriteFoods = MutableStateFlow<List<FoodItem>>(emptyList())
    val favoriteFoods: StateFlow<List<FoodItem>> = _favoriteFoods.asStateFlow()

    private val _customFoods = MutableStateFlow<List<FoodItem>>(emptyList())
    val customFoods: StateFlow<List<FoodItem>> = _customFoods.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        loadRecentFoods()
        loadFavoriteFoods()
        loadCustomFoods()
    }

    fun searchFoods(query: String) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                _searchResults.value = foodRepository.searchAllFoods(query)
            } catch (e: Exception) {
                _searchResults.value = emptyList()
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun loadRecentFoods() {
        viewModelScope.launch {
            foodRepository.getRecentFoodItems(limit = 10).collect { foods ->
                _recentFoods.value = foods
            }
        }
    }

    private fun loadFavoriteFoods() {
        viewModelScope.launch {
            foodRepository.getFavoriteFoodItems().collect { foods ->
                _favoriteFoods.value = foods
            }
        }
    }

    private fun loadCustomFoods() {
        viewModelScope.launch {
            foodRepository.getCustomFoodItems().collect { foods ->
                _customFoods.value = foods
            }
        }
    }

    fun toggleFavorite(foodId: Long) {
        viewModelScope.launch {
            foodRepository.toggleFavorite(foodId)
        }
    }

    private val _logged = MutableSharedFlow<String>(extraBufferCapacity = 1)
    val logged: SharedFlow<String> = _logged.asSharedFlow()

    /**
     * Insert a FoodItem (search result, recent, favorite, or custom) as a FoodEntry
     * on today's date with the given meal type and serving count.
     */
    fun logFoodToDiary(food: FoodItem, mealType: String, servings: Double = 1.0) {
        // Use the application-scoped coroutine: viewModelScope gets cancelled
        // when the FoodSearchScreen pops back, which races with the DB insert.
        appScope.launch {
            withContext(Dispatchers.IO) {
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                val entry = FoodEntry(
                    id = UUID.randomUUID(),
                    name = food.name,
                    brand = food.brand,
                    barcode = food.barcode,
                    date = cal.time,
                    timestamp = Date(),
                    mealType = mealType.lowercase(),
                    servingSize = food.servingSize,
                    servingUnit = food.servingUnit,
                    servingCount = servings,
                    calories = food.calories.toDouble(),
                    protein = food.protein.toDouble(),
                    carbs = food.carbs.toDouble(),
                    fat = food.fat.toDouble(),
                    fiber = food.fiber.toDouble(),
                    sugar = food.sugar.toDouble(),
                    sodium = food.sodium.toDouble()
                )
                database.foodDao().insert(entry)
            }
            _logged.tryEmit(food.name)
        }
    }
}
