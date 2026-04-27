package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.SleepEntry
import kotlinx.coroutines.flow.Flow
import java.util.Date

@Dao
interface SleepDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: SleepEntry)

    @Update
    suspend fun update(entry: SleepEntry)

    @Delete
    suspend fun delete(entry: SleepEntry)

    /** Live list of all sleep entries, newest bed-time first. */
    @Query("SELECT * FROM sleep_entries ORDER BY bedTime DESC")
    fun getAll(): Flow<List<SleepEntry>>

    /** One-shot query for the most recent entry (by bed-time). */
    @Query("SELECT * FROM sleep_entries ORDER BY bedTime DESC LIMIT 1")
    suspend fun getLatest(): SleepEntry?

    /**
     * One-shot range query. [start] and [end] are epoch-millisecond values stored by
     * the [Converters] TypeConverter (Date ↔ Long).
     */
    @Query("SELECT * FROM sleep_entries WHERE bedTime BETWEEN :start AND :end ORDER BY bedTime DESC")
    suspend fun getInRange(start: Date, end: Date): List<SleepEntry>
}
