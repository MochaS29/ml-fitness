package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.FoodItemDao
import com.mochasmindlab.mlhealth.data.models.FoodItem
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FoodRepository @Inject constructor(
    private val foodDao: FoodItemDao
) {
    suspend fun insertFoodItem(foodItem: FoodItem) = foodDao.insertFoodItem(foodItem)
    
    suspend fun updateFoodItem(foodItem: FoodItem) = foodDao.updateFoodItem(foodItem)
    
    suspend fun deleteFoodItem(foodItem: FoodItem) = foodDao.deleteFoodItem(foodItem)
    
    fun getAllFoodItems(): Flow<List<FoodItem>> = foodDao.getAllFoodItems()
    
    fun getFoodItemById(id: Long): Flow<FoodItem?> = foodDao.getFoodItemById(id)
    
    fun searchFoodItems(query: String): Flow<List<FoodItem>> = foodDao.searchFoodItems(query)
    
    fun getFavoriteFoodItems(): Flow<List<FoodItem>> = foodDao.getFavoriteFoodItems()
    
    fun getRecentFoodItems(limit: Int = 10): Flow<List<FoodItem>> = foodDao.getRecentFoodItems(limit)
    
    fun getFoodItemsByBarcode(barcode: String): Flow<List<FoodItem>> = foodDao.getFoodItemsByBarcode(barcode)
    
    suspend fun toggleFavorite(foodId: Long) {
        val foodItem = foodDao.getFoodItemByIdDirect(foodId)
        foodItem?.let {
            foodDao.updateFoodItem(it.copy(isFavorite = !it.isFavorite))
        }
    }
    
    suspend fun logFoodItem(foodItem: FoodItem, mealType: String, date: LocalDate) {
        val updatedItem = foodItem.copy(
            lastLogged = date,
            logCount = foodItem.logCount + 1
        )
        foodDao.updateFoodItem(updatedItem)
    }
}