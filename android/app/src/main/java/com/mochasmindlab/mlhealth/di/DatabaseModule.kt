package com.mochasmindlab.mlhealth.di

import android.content.Context
import androidx.room.Room
import com.mochasmindlab.mlhealth.data.database.*
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideMLFitnessDatabase(
        @ApplicationContext context: Context
    ): MLFitnessDatabase {
        return Room.databaseBuilder(
            context,
            MLFitnessDatabase::class.java,
            "mlfitness_database"
        )
        .fallbackToDestructiveMigration()
        .build()
    }
    
    @Provides
    fun provideExerciseDao(database: MLFitnessDatabase): ExerciseDao {
        return database.exerciseDao()
    }
    
    @Provides
    fun provideFoodDao(database: MLFitnessDatabase): FoodDao {
        return database.foodDao()
    }
    
    @Provides
    fun provideSupplementDao(database: MLFitnessDatabase): SupplementDao {
        return database.supplementDao()
    }
    
    @Provides
    fun provideWeightDao(database: MLFitnessDatabase): WeightDao {
        return database.weightDao()
    }
    
    @Provides
    fun provideWaterDao(database: MLFitnessDatabase): WaterDao {
        return database.waterDao()
    }
    
    @Provides
    fun provideCustomFoodDao(database: MLFitnessDatabase): CustomFoodDao {
        return database.customFoodDao()
    }
    
    @Provides
    fun provideCustomRecipeDao(database: MLFitnessDatabase): CustomRecipeDao {
        return database.customRecipeDao()
    }
    
    @Provides
    fun provideFavoriteRecipeDao(database: MLFitnessDatabase): FavoriteRecipeDao {
        return database.favoriteRecipeDao()
    }
    
    @Provides
    fun provideMealPlanDao(database: MLFitnessDatabase): MealPlanDao {
        return database.mealPlanDao()
    }
    
    @Provides
    fun provideGroceryListDao(database: MLFitnessDatabase): GroceryListDao {
        return database.groceryListDao()
    }
}