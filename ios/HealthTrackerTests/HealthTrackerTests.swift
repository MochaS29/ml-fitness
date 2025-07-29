//
//  HealthTrackerTests.swift
//  HealthTrackerTests
//
//  Created by Mocha Shmigelsky on 2025-07-18.
//

import XCTest
@testable import HealthTracker

final class HealthTrackerTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        TestConfiguration.setupTestEnvironment()
    }
    
    // MARK: - App Launch Tests
    
    func testAppLaunches() {
        XCTAssertTrue(TestConfiguration.isRunningTests)
    }
    
    // MARK: - Model Validation Tests
    
    func testFoodCategoryEnum() {
        let categories: [FoodCategory] = [.fruits, .vegetables, .protein, .grains, .dairy, .desserts, .other]
        XCTAssertEqual(categories.count, 7)
        
        for category in categories {
            XCTAssertFalse(category.rawValue.isEmpty)
        }
    }
    
    func testExerciseTypeEnum() {
        let types: [ExerciseType] = [.cardio, .strength, .flexibility, .sports, .other]
        XCTAssertEqual(types.count, 5)
    }
    
    // MARK: - Color Extension Tests
    
    func testCustomColors() {
        XCTAssertNotNil(UIColor.wellnessGreen)
        XCTAssertNotNil(UIColor.mindfulTeal)
        XCTAssertNotNil(UIColor.deepCharcoal)
        XCTAssertNotNil(UIColor.softCream)
    }
    
    // MARK: - Validation Tests
    
    func testCalorieValidation() {
        let validCalories = [0, 100, 500, 1000, 5000]
        let invalidCalories = [-100, 10000]
        
        for calories in validCalories {
            XCTAssertTrue(isValidCalorieAmount(Double(calories)))
        }
        
        for calories in invalidCalories {
            XCTAssertFalse(isValidCalorieAmount(Double(calories)))
        }
    }
    
    func testWeightValidation() {
        let validWeights = [0.1, 50, 100, 500, 1000]
        let invalidWeights = [-10, 0, 2000]
        
        for weight in validWeights {
            XCTAssertTrue(isValidWeight(weight))
        }
        
        for weight in invalidWeights {
            XCTAssertFalse(isValidWeight(weight))
        }
    }
    
    // MARK: - Date Formatting Tests
    
    func testDateFormatting() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let formatted = formatter.string(from: date)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    // MARK: - Helper Functions
    
    private func isValidCalorieAmount(_ calories: Double) -> Bool {
        return calories >= TestConfiguration.Thresholds.minimumCalories &&
               calories <= TestConfiguration.Thresholds.maximumCalories
    }
    
    private func isValidWeight(_ weight: Double) -> Bool {
        return weight >= TestConfiguration.Thresholds.minimumWeight &&
               weight <= TestConfiguration.Thresholds.maximumWeight
    }
}
