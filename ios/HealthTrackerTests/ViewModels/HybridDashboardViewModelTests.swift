//
//  HybridDashboardViewModelTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker
import SwiftUI

final class HybridDashboardViewModelTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DashboardViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialValues() {
        // Then
        XCTAssertEqual(viewModel.userName, "Mocha")
        XCTAssertEqual(viewModel.healthScore, 85)
        XCTAssertEqual(viewModel.todayCalories, 1650)
        XCTAssertEqual(viewModel.calorieGoal, 2200)
        XCTAssertEqual(viewModel.currentWeight, 165.5)
        XCTAssertEqual(viewModel.targetWeight, 160.0)
    }
    
    func testWeightProgress() {
        // Given
        viewModel.currentWeight = 165.5
        viewModel.targetWeight = 160.0
        
        // When
        let progress = viewModel.weightProgress
        
        // Then
        // Starting weight: 170, Target: 160, Current: 165.5
        // Total to lose: 10, Lost: 4.5, Progress: 45%
        XCTAssertEqual(progress, 45.0, accuracy: 0.1)
    }
    
    func testWaterPercentage() {
        // Given
        viewModel.todayWater = 6
        viewModel.waterGoal = 8
        
        // When
        let percentage = viewModel.waterPercentage
        
        // Then
        XCTAssertEqual(percentage, 75)
    }
    
    func testAIGreeting() {
        // When
        let greeting = viewModel.aiGreeting
        
        // Then
        XCTAssertFalse(greeting.isEmpty)
        XCTAssertTrue(greeting.contains("!") || greeting.contains("💪") || greeting.contains("🌟"))
    }
    
    func testHealthTrendPositive() {
        // Given
        viewModel.healthScore = 85
        
        // Then
        XCTAssertEqual(viewModel.healthTrend, "Excellent Progress")
        XCTAssertEqual(viewModel.healthTrendColor, .green)
        XCTAssertEqual(viewModel.healthTrendIcon, "arrow.up.right.circle.fill")
    }
    
    func testHealthTrendNegative() {
        // Given
        viewModel.healthScore = 75
        
        // Then
        XCTAssertEqual(viewModel.healthTrend, "Room for Improvement")
        XCTAssertEqual(viewModel.healthTrendColor, .orange)
        XCTAssertEqual(viewModel.healthTrendIcon, "arrow.right.circle.fill")
    }
    
    func testNutritionData() {
        // When
        let nutritionData = viewModel.nutritionData
        
        // Then
        XCTAssertEqual(nutritionData.count, 3)
        
        let totalPercentage = nutritionData.reduce(0) { $0 + $1.percentage }
        XCTAssertEqual(totalPercentage, 100)
        
        let carbs = nutritionData.first { $0.name == "Carbs" }
        XCTAssertNotNil(carbs)
        XCTAssertEqual(carbs?.percentage, 45)
    }
    
    func testWeeklyData() {
        // When
        let weeklyData = viewModel.weeklyData
        
        // Then
        XCTAssertEqual(weeklyData.count, 7)
        XCTAssertEqual(weeklyData.first?.day, "Mon")
        XCTAssertEqual(weeklyData.last?.day, "Sun")
    }
    
    func testAIInsights() {
        // When
        let insights = viewModel.aiInsights
        
        // Then
        XCTAssertEqual(insights.count, 4)
        
        let newInsights = insights.filter { $0.isNew }
        XCTAssertEqual(newInsights.count, 2)
        
        let highImpactInsights = insights.filter { $0.impact.contains("High") }
        XCTAssertEqual(highImpactInsights.count, 2)
    }
    
    func testRecommendations() {
        // When
        let recommendations = viewModel.recommendations
        
        // Then
        XCTAssertEqual(recommendations.count, 4)
        
        for recommendation in recommendations {
            XCTAssertFalse(recommendation.title.isEmpty)
            XCTAssertFalse(recommendation.description.isEmpty)
            XCTAssertNotNil(recommendation.actionText)
        }
    }
    
    func testNutrientBreakdown() {
        // When
        let breakdown = viewModel.nutrientBreakdown
        
        // Then
        XCTAssertEqual(breakdown.count, 10)
        
        let overLimit = breakdown.filter { $0.percentage > 100 }
        XCTAssertEqual(overLimit.count, 1) // Only sodium should be over
        XCTAssertEqual(overLimit.first?.name, "Sodium")
    }
}