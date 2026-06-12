package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.BodyMeasurementEntry
import kotlinx.coroutines.flow.Flow

@Dao
interface BodyMeasurementDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: BodyMeasurementEntry)

    @Update
    suspend fun update(entry: BodyMeasurementEntry)

    @Delete
    suspend fun delete(entry: BodyMeasurementEntry)

    @Query("SELECT * FROM body_measurement_entries ORDER BY date DESC")
    fun getAll(): Flow<List<BodyMeasurementEntry>>

    @Query("SELECT * FROM body_measurement_entries ORDER BY date DESC LIMIT 1")
    suspend fun getLatest(): BodyMeasurementEntry?
}
