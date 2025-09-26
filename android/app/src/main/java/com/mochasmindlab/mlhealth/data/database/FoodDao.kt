package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.models.FoodItem
import kotlinx.coroutines.flow.Flow

@Dao
interface FoodDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFoodItem(foodItem: FoodItem): Long
    
    @Update
    suspend fun updateFoodItem(foodItem: FoodItem)
    
    @Delete
    suspend fun deleteFoodItem(foodItem: FoodItem)
    
    @Query("SELECT * FROM food_items ORDER BY lastLogged DESC")
    fun getAllFoodItems(): Flow<List<FoodItem>>
    
    @Query("SELECT * FROM food_items WHERE id = :id")
    fun getFoodItemById(id: Long): Flow<FoodItem?>
    
    @Query("SELECT * FROM food_items WHERE id = :id")
    suspend fun getFoodItemByIdDirect(id: Long): FoodItem?
    
    @Query("SELECT * FROM food_items WHERE name LIKE '%' || :query || '%' OR brand LIKE '%' || :query || '%' ORDER BY logCount DESC")
    fun searchFoodItems(query: String): Flow<List<FoodItem>>
    
    @Query("SELECT * FROM food_items WHERE isFavorite = 1 ORDER BY name ASC")
    fun getFavoriteFoodItems(): Flow<List<FoodItem>>
    
    @Query("SELECT * FROM food_items WHERE logCount > 0 ORDER BY lastLogged DESC LIMIT :limit")
    fun getRecentFoodItems(limit: Int): Flow<List<FoodItem>>
    
    @Query("SELECT * FROM food_items WHERE barcode = :barcode")
    fun getFoodItemsByBarcode(barcode: String): Flow<List<FoodItem>>
    
    @Query("DELETE FROM food_items")
    suspend fun deleteAllFoodItems()
}