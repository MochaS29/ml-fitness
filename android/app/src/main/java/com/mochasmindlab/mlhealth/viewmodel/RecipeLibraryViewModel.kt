package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.CustomRecipe
import com.mochasmindlab.mlhealth.data.models.LibraryTab
import com.mochasmindlab.mlhealth.data.models.RecipeCategory
import com.mochasmindlab.mlhealth.data.models.RecipeListItem
import com.mochasmindlab.mlhealth.services.MealPlanLoader
import com.mochasmindlab.mlhealth.services.RecipeImportService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject

@HiltViewModel
class RecipeLibraryViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    private val mealPlanLoader: MealPlanLoader,
    private val importService: RecipeImportService
) : ViewModel() {

    // ---------- UI state ----------

    private val _tab = MutableStateFlow(LibraryTab.LIBRARY)
    val tab: StateFlow<LibraryTab> = _tab.asStateFlow()

    private val _category = MutableStateFlow<RecipeCategory?>(null)
    val category: StateFlow<RecipeCategory?> = _category.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _libraryRecipes = MutableStateFlow<List<RecipeListItem.Bundled>>(emptyList())
    val libraryRecipes: StateFlow<List<RecipeListItem.Bundled>> = _libraryRecipes.asStateFlow()

    private val _myRecipes = MutableStateFlow<List<CustomRecipe>>(emptyList())
    val myRecipes: StateFlow<List<CustomRecipe>> = _myRecipes.asStateFlow()

    private val _isImporting = MutableStateFlow(false)
    val isImporting: StateFlow<Boolean> = _isImporting.asStateFlow()

    // ---------- Derived (filtered) lists ----------

    val filteredLibraryRecipes: StateFlow<List<RecipeListItem.Bundled>> =
        combine(_libraryRecipes, _category, _searchQuery) { all, cat, q ->
            all.filter { item ->
                (cat == null || item.category == cat) &&
                (q.isBlank() || item.name.contains(q, ignoreCase = true))
            }
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    val filteredMyRecipes: StateFlow<List<CustomRecipe>> =
        combine(_myRecipes, _category, _searchQuery) { all, cat, q ->
            all.filter { recipe ->
                val recipeCategory = RecipeCategory.fromString(recipe.category)
                (cat == null || recipeCategory == cat) &&
                (q.isBlank() || recipe.name.contains(q, ignoreCase = true))
            }
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    // ---------- Init ----------

    init {
        loadLibraryRecipes()
        loadMyRecipes()
    }

    // ---------- Loaders ----------

    private fun loadLibraryRecipes() {
        viewModelScope.launch {
            val plans = withContext(Dispatchers.IO) { mealPlanLoader.loadAll() }
            val seen = mutableSetOf<String>()
            val items = mutableListOf<RecipeListItem.Bundled>()
            for (plan in plans) {
                for (week in plan.weeks) {
                    for (day in week.days) {
                        val slots = listOf(
                            day.breakfast to "breakfast",
                            day.lunch     to "lunch",
                            day.dinner    to "dinner",
                            day.snack     to "snack"
                        )
                        for ((recipe, position) in slots) {
                            val key = recipe.name.lowercase().trim()
                            if (seen.add(key)) {
                                items.add(RecipeListItem.Bundled(recipe, position))
                            }
                        }
                    }
                }
            }
            _libraryRecipes.value = items
        }
    }

    private fun loadMyRecipes() {
        viewModelScope.launch {
            val recipes = withContext(Dispatchers.IO) {
                database.customRecipeDao().getAllRecipes()
            }
            _myRecipes.value = recipes
        }
    }

    // ---------- Actions ----------

    fun selectTab(tab: LibraryTab) { _tab.value = tab }

    fun selectCategory(cat: RecipeCategory?) { _category.value = cat }

    fun setSearch(query: String) { _searchQuery.value = query }

    fun refreshMyRecipes() { loadMyRecipes() }

    fun deleteCustomRecipe(recipe: CustomRecipe) {
        viewModelScope.launch {
            withContext(Dispatchers.IO) { database.customRecipeDao().delete(recipe) }
            _myRecipes.value = _myRecipes.value.filter { it.id != recipe.id }
        }
    }

    fun toggleFavorite(recipe: CustomRecipe) {
        viewModelScope.launch {
            val updated = recipe.copy(isFavorite = !recipe.isFavorite)
            withContext(Dispatchers.IO) { database.customRecipeDao().update(updated) }
            _myRecipes.value = _myRecipes.value.map { if (it.id == recipe.id) updated else it }
        }
    }

    fun importFromUrl(url: String, onResult: (Result<CustomRecipe>) -> Unit) {
        viewModelScope.launch {
            _isImporting.value = true
            val result = importService.importFromUrl(url)
            if (result.isSuccess) {
                val recipe = result.getOrThrow()
                withContext(Dispatchers.IO) { database.customRecipeDao().insert(recipe) }
                loadMyRecipes()
            }
            _isImporting.value = false
            onResult(result)
        }
    }
}
