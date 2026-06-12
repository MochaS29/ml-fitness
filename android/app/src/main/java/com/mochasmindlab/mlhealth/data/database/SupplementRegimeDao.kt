package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.SupplementRegime
import kotlinx.coroutines.flow.Flow
import java.util.UUID

@Dao
interface SupplementRegimeDao {
    
    @Query("SELECT * FROM supplement_regimes WHERE isActive = 1 ORDER BY name ASC")
    fun getActiveRegimes(): Flow<List<SupplementRegime>>
    
    @Query("SELECT * FROM supplement_regimes ORDER BY name ASC")
    fun getAllRegimes(): Flow<List<SupplementRegime>>
    
    @Query("SELECT * FROM supplement_regimes WHERE id = :id")
    suspend fun getRegimeById(id: UUID): SupplementRegime?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(regime: SupplementRegime)
    
    @Update
    suspend fun update(regime: SupplementRegime)
    
    @Delete
    suspend fun delete(regime: SupplementRegime)
    
    @Query("UPDATE supplement_regimes SET isActive = :isActive WHERE id = :id")
    suspend fun setRegimeActive(id: UUID, isActive: Boolean)
    
    @Query("DELETE FROM supplement_regimes")
    suspend fun deleteAll()
}