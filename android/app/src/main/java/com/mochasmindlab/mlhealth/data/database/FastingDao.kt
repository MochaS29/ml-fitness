package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.FastingSession
import kotlinx.coroutines.flow.Flow

@Dao
interface FastingDao {

    @Insert
    suspend fun insert(session: FastingSession)

    @Update
    suspend fun update(session: FastingSession)

    @Delete
    suspend fun delete(session: FastingSession)

    @Query("SELECT * FROM fasting_sessions WHERE endTime IS NULL ORDER BY startTime DESC LIMIT 1")
    suspend fun getActive(): FastingSession?

    @Query("SELECT * FROM fasting_sessions WHERE endTime IS NULL ORDER BY startTime DESC LIMIT 1")
    fun activeFlow(): Flow<FastingSession?>

    @Query("SELECT * FROM fasting_sessions ORDER BY startTime DESC")
    fun getAll(): Flow<List<FastingSession>>

    @Query("SELECT * FROM fasting_sessions ORDER BY startTime DESC LIMIT 30")
    suspend fun getRecent(): List<FastingSession>
}
