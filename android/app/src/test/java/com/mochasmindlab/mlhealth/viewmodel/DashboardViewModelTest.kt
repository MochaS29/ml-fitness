package com.mochasmindlab.mlhealth.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import app.cash.turbine.test
import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
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
class DashboardViewModelTest {
    
    @get:Rule
    val instantExecutorRule = InstantTaskExecutorRule()
    
    private val testDispatcher = StandardTestDispatcher()
    private lateinit var database: MLFitnessDatabase
    private lateinit var viewModel: DashboardViewModel
    
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
    fun `initial state should have default values`() = runTest {
        // Given
        setupMockDatabase()
        
        // When
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.userName).isEqualTo("You")
            assertThat(state.caloriesGoal).isEqualTo(2200)
            assertThat(state.waterGoal).isEqualTo(8)
            assertThat(state.exerciseGoal).isEqualTo(60)
            assertThat(state.selectedPeriod).isEqualTo(DashboardPeriod.DAY)
        }
    }
    
    @Test
    fun `loadDashboardData should update state with database values`() = runTest {
        // Given
        val mockWeight = WeightEntry(
            id = UUID.randomUUID(),
            weight = 75.5,
            date = Date(),
            timestamp = Date()
        )
        
        coEvery { database.foodDao().getTotalCaloriesForDate(any()) } returns 1500.0
        coEvery { database.waterDao().getTotalForDate(any()) } returns 48.0 // 6 cups
        coEvery { database.exerciseDao().getTotalDurationForDate(any()) } returns 45
        coEvery { database.weightDao().getLatestEntry() } returns mockWeight
        
        // When
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.caloriesConsumed).isEqualTo(1500)
            assertThat(state.waterCups).isEqualTo(6)
            assertThat(state.exerciseMinutes).isEqualTo(45)
            assertThat(state.currentWeight).isEqualTo(75.5)
        }
    }
    
    @Test
    fun `selectPeriod should update selected period`() = runTest {
        // Given
        setupMockDatabase()
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.selectPeriod(DashboardPeriod.WEEK)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state.selectedPeriod).isEqualTo(DashboardPeriod.WEEK)
        }
    }
    
    @Test
    fun `generateAIInsights should create hydration alert when water intake is low`() = runTest {
        // Given
        coEvery { database.waterDao().getTotalForDate(any()) } returns 16.0 // 2 cups (low)
        coEvery { database.foodDao().getTotalCaloriesForDate(any()) } returns 1000.0
        coEvery { database.exerciseDao().getTotalDurationForDate(any()) } returns 60
        
        // When
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.aiInsights.test {
            val insights = awaitItem()
            assertThat(insights).isNotEmpty()
            
            val hydrationInsight = insights.find { it.type == InsightType.HYDRATION }
            assertThat(hydrationInsight).isNotNull()
            assertThat(hydrationInsight?.title).isEqualTo("Hydration Alert")
            assertThat(hydrationInsight?.priority).isEqualTo(InsightPriority.HIGH)
        }
    }
    
    @Test
    fun `generateAIInsights should create calorie alert when exceeding goal`() = runTest {
        // Given
        coEvery { database.waterDao().getTotalForDate(any()) } returns 64.0 // 8 cups
        coEvery { database.foodDao().getTotalCaloriesForDate(any()) } returns 2500.0 // Over goal
        coEvery { database.exerciseDao().getTotalDurationForDate(any()) } returns 60
        
        // When
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.aiInsights.test {
            val insights = awaitItem()
            
            val calorieInsight = insights.find { it.type == InsightType.NUTRITION }
            assertThat(calorieInsight).isNotNull()
            assertThat(calorieInsight?.title).isEqualTo("Calorie Alert")
            assertThat(calorieInsight?.priority).isEqualTo(InsightPriority.MEDIUM)
        }
    }
    
    @Test
    fun `refreshData should reload dashboard data`() = runTest {
        // Given
        setupMockDatabase()
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // When
        viewModel.refreshData()
        advanceUntilIdle()
        
        // Then - init calls once, refreshData calls once more
        coVerify(atLeast = 2) { database.foodDao().getTotalCaloriesForDate(any()) }
        coVerify(atLeast = 2) { database.waterDao().getTotalForDate(any()) }
        coVerify(atLeast = 2) { database.exerciseDao().getTotalDurationForDate(any()) }
    }
    
    @Test
    fun `database error should be handled gracefully`() = runTest {
        // Given
        coEvery { database.foodDao().getTotalCaloriesForDate(any()) } throws Exception("Database error")
        
        // When
        viewModel = DashboardViewModel(database)
        advanceUntilIdle()
        
        // Then
        viewModel.uiState.test {
            val state = awaitItem()
            // Should have default values when error occurs
            assertThat(state.caloriesConsumed).isEqualTo(0)
            assertThat(state.waterCups).isEqualTo(0)
            assertThat(state.exerciseMinutes).isEqualTo(0)
        }
    }
    
    private fun setupMockDatabase() {
        coEvery { database.foodDao().getTotalCaloriesForDate(any()) } returns 0.0
        coEvery { database.waterDao().getTotalForDate(any()) } returns 0.0
        coEvery { database.exerciseDao().getTotalDurationForDate(any()) } returns 0
        coEvery { database.weightDao().getLatestEntry() } returns null
    }
}