package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.FoodItem
import com.mochasmindlab.mlhealth.data.repository.FoodRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class FoodSearchViewModel @Inject constructor(
    private val foodRepository: FoodRepository
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
                val results = foodRepository.searchFoods(query)
                _searchResults.value = results
            } catch (e: Exception) {
                _searchResults.value = emptyList()
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun loadRecentFoods() {
        viewModelScope.launch {
            foodRepository.getRecentFoods().collect { foods ->
                _recentFoods.value = foods
            }
        }
    }

    private fun loadFavoriteFoods() {
        viewModelScope.launch {
            foodRepository.getFavoriteFoods().collect { foods ->
                _favoriteFoods.value = foods
            }
        }
    }

    private fun loadCustomFoods() {
        viewModelScope.launch {
            foodRepository.getCustomFoods().collect { foods ->
                _customFoods.value = foods
            }
        }
    }

    fun toggleFavorite(foodId: Long) {
        viewModelScope.launch {
            foodRepository.toggleFavorite(foodId)
        }
    }
}