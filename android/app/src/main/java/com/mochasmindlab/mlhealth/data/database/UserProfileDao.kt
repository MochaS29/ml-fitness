package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.models.UserProfile
import kotlinx.coroutines.flow.Flow

@Dao
interface UserProfileDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUserProfile(profile: UserProfile): Long
    
    @Update
    suspend fun updateUserProfile(profile: UserProfile)
    
    @Query("SELECT * FROM user_profiles LIMIT 1")
    fun getUserProfile(): Flow<UserProfile?>
    
    @Query("SELECT * FROM user_profiles LIMIT 1")
    suspend fun getUserProfileDirect(): UserProfile?
    
    @Query("DELETE FROM user_profiles")
    suspend fun deleteUserProfile()
}