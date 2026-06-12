package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.BundledFoodDatabase
import com.mochasmindlab.mlhealth.data.database.FoodItemDao
import com.mochasmindlab.mlhealth.data.models.FoodItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import com.mochasmindlab.mlhealth.utils.DateConverter
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FoodRepository @Inject constructor(
    private val foodDao: FoodItemDao,
    private val bundledFoodDatabase: BundledFoodDatabase
) {
    suspend fun insertFoodItem(foodItem: FoodItem) = foodDao.insertFoodItem(foodItem)
    
    suspend fun updateFoodItem(foodItem: FoodItem) = foodDao.updateFoodItem(foodItem)
    
    suspend fun deleteFoodItem(foodItem: FoodItem) = foodDao.deleteFoodItem(foodItem)
    
    fun getAllFoodItems(): Flow<List<FoodItem>> = foodDao.getAllFoodItems()
    
    fun getFoodItemById(id: Long): Flow<FoodItem?> = foodDao.getFoodItemById(id)
    
    fun searchFoodItems(query: String): Flow<List<FoodItem>> = foodDao.searchFoodItems(query)

    fun getFavoriteFoodItems(): Flow<List<FoodItem>> = foodDao.getFavoriteFoodItems()

    fun getRecentFoodItems(limit: Int = 10): Flow<List<FoodItem>> = foodDao.getRecentFoodItems(limit)

    fun getCustomFoodItems(): Flow<List<FoodItem>> = foodDao.getCustomFoodItems()

    /**
     * Search the bundled USDA food database (~53K rows) plus the user's custom foods.
     * Custom foods come first, then bundled results, deduplicated by case-insensitive name+brand.
     */
    suspend fun searchAllFoods(query: String, limit: Int = 50): List<FoodItem> = withContext(Dispatchers.IO) {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) return@withContext emptyList()

        val bundled = bundledFoodDatabase.search(trimmed, limit)
        val customFoods = foodDao.getAllCustomFoodsMatching(trimmed)

        val seen = mutableSetOf<String>()
        val merged = mutableListOf<FoodItem>()
        (customFoods + bundled).forEach { item ->
            val key = (item.name + "|" + (item.brand ?: "")).lowercase()
            if (seen.add(key)) merged += item
        }
        merged
    }
    
    fun getFoodItemsByBarcode(barcode: String): Flow<List<FoodItem>> = foodDao.getFoodItemsByBarcode(barcode)

    suspend fun getFoodItemByBarcode(barcode: String): FoodItem? = foodDao.getFoodItemByBarcodeDirect(barcode)

    /**
     * Marks a food (e.g. a freshly scanned barcode result with id=0) as a
     * favourite. De-dupes by barcode so toggling the star doesn't litter the
     * food_items table with copies; otherwise inserts a fresh favourite row.
     */
    suspend fun setFavorite(food: FoodItem, favorite: Boolean) {
        val existing = food.barcode?.takeIf { it.isNotBlank() }?.let { foodDao.getFoodItemByBarcodeDirect(it) }
        when {
            existing != null -> foodDao.updateFoodItem(existing.copy(isFavorite = favorite))
            favorite -> foodDao.insertFoodItem(food.copy(id = 0, isFavorite = true))
        }
    }

    suspend fun toggleFavorite(foodId: Long) {
        val foodItem = foodDao.getFoodItemByIdDirect(foodId)
        foodItem?.let {
            foodDao.updateFoodItem(it.copy(isFavorite = !it.isFavorite))
        }
    }
    
    suspend fun logFoodItem(foodItem: FoodItem, mealType: String, date: LocalDate) {
        val updatedItem = foodItem.copy(
            lastLogged = DateConverter.localDateToDate(date),
            logCount = foodItem.logCount + 1
        )
        foodDao.updateFoodItem(updatedItem)
    }
}