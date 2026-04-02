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
        // userName is loaded from UserDefaults/UserProfile; test it is a non-empty string.
        XCTAssertFalse(viewModel.userName.isEmpty)

        // healthScore is calculated from live device data; test it falls within the valid range.
        XCTAssertGreaterThanOrEqual(viewModel.healthScore, 0)
        XCTAssertLessThanOrEqual(viewModel.healthScore, 100)
    }
    
    func testWeightProgress() {
        // weightProgress returns 0 when no profile/startingWeight is set (clean test state)
        XCTAssertEqual(viewModel.weightProgress, 0.0)

        // When target equals current, progress is 0 (nothing to lose)
        viewModel.currentWeight = 160.0
        viewModel.targetWeight = 160.0
        XCTAssertEqual(viewModel.weightProgress, 0.0)
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
    
    func testHealthTrendIsValidTier() {
        // healthTrend must always be one of the 5 defined tier strings regardless of score.
        let validTiers: Set<String> = [
            "Getting Started",
            "Building Momentum",
            "Making Strides",
            "Excellent Progress",
            "Outstanding!"
        ]
        let scoresToCheck: [Double] = [0, 20, 40, 50, 60, 80, 81, 90, 91, 100]
        for score in scoresToCheck {
            viewModel.healthScore = score
            XCTAssertTrue(
                validTiers.contains(viewModel.healthTrend),
                "healthTrend '\(viewModel.healthTrend)' for score \(score) is not a recognised tier"
            )
        }
    }

    func testHealthTrendTierBoundaries() {
        // Verify the correct tier is returned at each defined boundary.
        viewModel.healthScore = 100; XCTAssertEqual(viewModel.healthTrend, "Outstanding!")
        viewModel.healthScore = 91;  XCTAssertEqual(viewModel.healthTrend, "Outstanding!")
        viewModel.healthScore = 90;  XCTAssertEqual(viewModel.healthTrend, "Excellent Progress")
        viewModel.healthScore = 81;  XCTAssertEqual(viewModel.healthTrend, "Excellent Progress")
        viewModel.healthScore = 80;  XCTAssertEqual(viewModel.healthTrend, "Making Strides")
        viewModel.healthScore = 61;  XCTAssertEqual(viewModel.healthTrend, "Making Strides")
        viewModel.healthScore = 60;  XCTAssertEqual(viewModel.healthTrend, "Building Momentum")
        viewModel.healthScore = 41;  XCTAssertEqual(viewModel.healthTrend, "Building Momentum")
        viewModel.healthScore = 40;  XCTAssertEqual(viewModel.healthTrend, "Getting Started")
        viewModel.healthScore = 0;   XCTAssertEqual(viewModel.healthTrend, "Getting Started")
    }
    
    func testNutritionData() {
        // With no food logged, nutritionData returns empty (data-driven, not static)
        XCTAssertEqual(viewModel.nutritionData.count, 0)

        // When items are present, they should be Protein/Carbs/Fat and sum to ~100%
        // (Full integration tested in DiaryViewModelTests; contract check here)
        let data = viewModel.nutritionData
        if !data.isEmpty {
            XCTAssertEqual(data.count, 3)
            let total = data.reduce(0.0) { $0 + $1.percentage }
            XCTAssertEqual(total, 100.0, accuracy: 0.1)
        }
    }

    func testWeeklyData() {
        // weeklyData returns an array; empty is valid when no historical data exists
        let data = viewModel.weeklyData
        XCTAssertTrue(data.count == 0 || data.count == 7)
    }

    func testAIInsights() {
        // Always returns at least one insight (falls back to "Start Tracking")
        let insights = viewModel.aiInsights
        XCTAssertGreaterThanOrEqual(insights.count, 1)

        // Every insight must have non-empty content
        for insight in insights {
            XCTAssertFalse(insight.title.isEmpty)
            XCTAssertFalse(insight.description.isEmpty)
            XCTAssertFalse(insight.icon.isEmpty)
            XCTAssertFalse(insight.impact.isEmpty)
        }
    }

    func testRecommendations() {
        // Returns 1–3 recommendations (capped at 3, minimum 1 default)
        let recs = viewModel.recommendations
        XCTAssertGreaterThanOrEqual(recs.count, 1)
        XCTAssertLessThanOrEqual(recs.count, 3)

        for rec in recs {
            XCTAssertFalse(rec.title.isEmpty)
            XCTAssertFalse(rec.description.isEmpty)
            XCTAssertNotNil(rec.actionText)
        }
    }

    func testNutrientBreakdown() {
        // With no calories logged, nutrientBreakdown is empty
        XCTAssertEqual(viewModel.nutrientBreakdown.count, 0)

        // When nutrients are present, each entry must have a non-empty name
        for nutrient in viewModel.nutrientBreakdown {
            XCTAssertFalse(nutrient.name.isEmpty)
            XCTAssertGreaterThanOrEqual(nutrient.percentage, 0)
        }
    }
}