package com.mochasmindlab.mlhealth.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.screens.FoodEntryDisplay
import io.mockk.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.util.*

@ExperimentalCoroutinesApi
class DiaryViewModelTest {
    
    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()
    
    private val testDispatcher = StandardTestDispatcher()
    private lateinit var database: MLFitnessDatabase
    private lateinit var viewModel: DiaryViewModel
    
    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        database = mockk(relaxed = true)
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
        unmockkAll()
    }
    
    @Test
    fun `initial state should load today's data`() = runTest {
        // Given
        val mockFoodEntries = listOf(
            createMockFoodEntry("Oatmeal", MealType.BREAKFAST, 300.0),
            createMockFoodEntry("Salad", MealType.LUNCH, 250.0)
        )
        coEvery { database.foodDao().getEntriesForDate(any()) } returns mockFoodEntries
        coEvery { database.waterDao().getTotalForDate(any()) } returns 32.0 // 4 cups
        
        // When
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.totalCalories).isEqualTo(550)
            assertThat(state.waterCups).isEqualTo(4)
            assertThat(state.mealEntries[MealType.BREAKFAST]).hasSize(1)
            assertThat(state.mealEntries[MealType.LUNCH]).hasSize(1)
        }
    }
    
    @Test
    fun `selectToday should reset date to today`() = runTest {
        // Given
        setupMockDatabase()
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.previousDay() // Go to yesterday
        viewModel.selectToday() // Back to today
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            val today = Calendar.getInstance()
            val stateDate = Calendar.getInstance().apply { time = state.selectedDate }
            
            assertThat(stateDate.get(Calendar.DAY_OF_YEAR))
                .isEqualTo(today.get(Calendar.DAY_OF_YEAR))
            assertThat(stateDate.get(Calendar.YEAR))
                .isEqualTo(today.get(Calendar.YEAR))
        }
    }
    
    @Test
    fun `previousDay should move date back one day`() = runTest {
        // Given
        setupMockDatabase()
        viewModel = DiaryViewModel(database)
        val initialDate = Date()
        advanceUntilIdle()
        
        // When
        viewModel.previousDay()
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            val calendar = Calendar.getInstance()
            calendar.time = initialDate
            calendar.add(Calendar.DAY_OF_YEAR, -1)
            
            assertThat(state.selectedDate.day).isEqualTo(calendar.time.day)
        }
    }
    
    @Test
    fun `nextDay should move date forward one day`() = runTest {
        // Given
        setupMockDatabase()
        viewModel = DiaryViewModel(database)
        val initialDate = Date()
        advanceUntilIdle()
        
        // When
        viewModel.nextDay()
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            val calendar = Calendar.getInstance()
            calendar.time = initialDate
            calendar.add(Calendar.DAY_OF_YEAR, 1)
            
            assertThat(state.selectedDate.day).isEqualTo(calendar.time.day)
        }
    }
    
    @Test
    fun `addWaterCup should increase water intake by 8oz`() = runTest {
        // Given
        setupMockDatabase()
        coEvery { database.waterDao().getTotalForDate(any()) } returns 16.0 // 2 cups initially
        
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.addWaterCup()
        coEvery { database.waterDao().getTotalForDate(any()) } returns 24.0 // 3 cups after
        advanceUntilIdle()
        
        // Then
        coVerify { database.waterDao().insert(any()) }
        
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.waterCups).isEqualTo(3)
        }
    }
    
    @Test
    fun `removeWaterCup should decrease water intake when cups greater than 0`() = runTest {
        // Given
        val waterEntries = listOf(
            WaterEntry(id = UUID.randomUUID(), amount = 8.0),
            WaterEntry(id = UUID.randomUUID(), amount = 8.0)
        )
        coEvery { database.waterDao().getEntriesForDate(any()) } returns waterEntries
        coEvery { database.waterDao().getTotalForDate(any()) } returns 16.0 andThen 8.0
        
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.removeWaterCup()
        advanceUntilIdle()
        
        // Then
        coVerify { database.waterDao().delete(waterEntries.last()) }
    }
    
    @Test
    fun `deleteFoodEntry should remove food entry from database`() = runTest {
        // Given
        val foodId = UUID.randomUUID()
        val mockFoodEntry = createMockFoodEntry("Test Food", MealType.BREAKFAST, 200.0, foodId)
        val displayEntry = FoodEntryDisplay(
            id = foodId.toString(),
            name = "Test Food",
            quantity = 1f,
            unit = "serving",
            calories = 200,
            protein = 10f,
            carbs = 30f,
            fat = 5f
        )
        
        coEvery { database.foodDao().getEntriesForDate(any()) } returns listOf(mockFoodEntry)
        
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.deleteFoodEntry(displayEntry)
        advanceUntilIdle()
        
        // Then
        coVerify { database.foodDao().delete(mockFoodEntry) }
    }
    
    @Test
    fun `meal entries should be grouped by meal type`() = runTest {
        // Given
        val mockFoodEntries = listOf(
            createMockFoodEntry("Eggs", MealType.BREAKFAST, 200.0),
            createMockFoodEntry("Toast", MealType.BREAKFAST, 150.0),
            createMockFoodEntry("Chicken", MealType.LUNCH, 300.0),
            createMockFoodEntry("Rice", MealType.DINNER, 250.0),
            createMockFoodEntry("Apple", MealType.SNACK, 80.0)
        )
        coEvery { database.foodDao().getEntriesForDate(any()) } returns mockFoodEntries
        
        // When
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.mealEntries[MealType.BREAKFAST]).hasSize(2)
            assertThat(state.mealEntries[MealType.LUNCH]).hasSize(1)
            assertThat(state.mealEntries[MealType.DINNER]).hasSize(1)
            assertThat(state.mealEntries[MealType.SNACK]).hasSize(1)
        }
    }
    
    @Test
    fun `totals should calculate correctly with serving counts`() = runTest {
        // Given
        val mockFoodEntries = listOf(
            FoodEntry(
                id = UUID.randomUUID(),
                name = "Rice",
                date = Date(),
                mealType = "lunch",
                servingSize = "100g",
                servingUnit = "g",
                servingCount = 2.0, // Double serving
                calories = 130.0,
                protein = 3.0,
                carbs = 28.0,
                fat = 0.5
            )
        )
        coEvery { database.foodDao().getEntriesForDate(any()) } returns mockFoodEntries
        
        // When
        viewModel = DiaryViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.totalCalories).isEqualTo(260) // 130 * 2
            assertThat(state.totalProtein).isEqualTo(6.0f) // 3 * 2
            assertThat(state.totalCarbs).isEqualTo(56.0f) // 28 * 2
            assertThat(state.totalFat).isEqualTo(1.0f) // 0.5 * 2
        }
    }
    
    private fun setupMockDatabase() {
        coEvery { database.foodDao().getEntriesForDate(any()) } returns emptyList()
        coEvery { database.waterDao().getTotalForDate(any()) } returns 0.0
        coEvery { database.waterDao().getEntriesForDate(any()) } returns emptyList()
    }
    
    private fun createMockFoodEntry(
        name: String,
        mealType: MealType,
        calories: Double,
        id: UUID = UUID.randomUUID()
    ): FoodEntry {
        return FoodEntry(
            id = id,
            name = name,
            date = Date(),
            mealType = mealType.name.lowercase(),
            servingSize = "1",
            servingUnit = "serving",
            servingCount = 1.0,
            calories = calories,
            protein = 10.0,
            carbs = 30.0,
            fat = 5.0
        )
    }
}