//
//  NutritionInfoTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker

final class NutritionInfoTests: XCTestCase {
    
    func testNutritionInfoInitialization() {
        // Given
        let calories = 250.0
        let protein = 20.0
        let carbs = 30.0
        let fat = 10.0
        let fiber = 5.0
        let sugar = 8.0
        let sodium = 300.0
        
        // When
        let nutrition = NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium
        )
        
        // Then
        XCTAssertEqual(nutrition.calories, calories)
        XCTAssertEqual(nutrition.protein, protein)
        XCTAssertEqual(nutrition.carbs, carbs)
        XCTAssertEqual(nutrition.fat, fat)
        XCTAssertEqual(nutrition.fiber, fiber)
        XCTAssertEqual(nutrition.sugar, sugar)
        XCTAssertEqual(nutrition.sodium, sodium)
    }
    
    func testNutritionInfoAddition() {
        // Given
        let nutrition1 = NutritionInfo(
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            fiber: 2,
            sugar: 5,
            sodium: 100
        )
        
        let nutrition2 = NutritionInfo(
            calories: 150,
            protein: 15,
            carbs: 25,
            fat: 8,
            fiber: 3,
            sugar: 10,
            sodium: 200
        )
        
        // When
        let total = nutrition1 + nutrition2
        
        // Then
        XCTAssertEqual(total.calories, 250)
        XCTAssertEqual(total.protein, 25)
        XCTAssertEqual(total.carbs, 45)
        XCTAssertEqual(total.fat, 13)
        XCTAssertEqual(total.fiber, 5)
        XCTAssertEqual(total.sugar, 15)
        XCTAssertEqual(total.sodium, 300)
    }
    
    func testCaloriesFromMacros() {
        // Given
        let nutrition = NutritionInfo(
            calories: 0, // Will be calculated
            protein: 25,   // 25g * 4 = 100 cal
            carbs: 50,     // 50g * 4 = 200 cal
            fat: 10,       // 10g * 9 = 90 cal
            fiber: 5,
            sugar: 10,
            sodium: 300
        )
        
        // When
        let calculatedCalories = (nutrition.protein * 4) + (nutrition.carbs * 4) + (nutrition.fat * 9)
        
        // Then
        XCTAssertEqual(calculatedCalories, 390)
    }
}