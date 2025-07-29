//
//  FoodScanResultTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker

final class FoodScanResultTests: XCTestCase {
    
    func testFoodScanResultInitialization() {
        // Given
        let id = UUID()
        let timestamp = Date()
        let identifiedFoods = [
            IdentifiedFood(
                name: "Chicken Breast",
                confidence: 0.95,
                estimatedWeight: 150,
                calories: 250,
                protein: 46,
                carbs: 0,
                fat: 5.5,
                category: .protein
            )
        ]
        let totalNutrition = NutritionInfo(
            calories: 250,
            protein: 46,
            carbs: 0,
            fat: 5.5,
            fiber: 0,
            sugar: 0,
            sodium: 100
        )
        
        // When
        let scanResult = FoodScanResult(
            id: id,
            timestamp: timestamp,
            identifiedFoods: identifiedFoods,
            totalNutrition: totalNutrition
        )
        
        // Then
        XCTAssertEqual(scanResult.id, id)
        XCTAssertEqual(scanResult.timestamp, timestamp)
        XCTAssertEqual(scanResult.identifiedFoods.count, 1)
        XCTAssertEqual(scanResult.identifiedFoods.first?.name, "Chicken Breast")
        XCTAssertEqual(scanResult.totalNutrition.calories, 250)
    }
    
    func testMultipleFoodItems() {
        // Given
        let foods = [
            IdentifiedFood(
                name: "Rice",
                confidence: 0.9,
                estimatedWeight: 100,
                calories: 130,
                protein: 2.7,
                carbs: 28,
                fat: 0.3,
                category: .grains
            ),
            IdentifiedFood(
                name: "Broccoli",
                confidence: 0.85,
                estimatedWeight: 80,
                calories: 27,
                protein: 2.2,
                carbs: 5.5,
                fat: 0.3,
                category: .vegetables
            )
        ]
        
        // When
        let scanResult = FoodScanResult(
            id: UUID(),
            timestamp: Date(),
            identifiedFoods: foods,
            totalNutrition: NutritionInfo(
                calories: 157,
                protein: 4.9,
                carbs: 33.5,
                fat: 0.6,
                fiber: 2.1,
                sugar: 1.5,
                sodium: 45
            )
        )
        
        // Then
        XCTAssertEqual(scanResult.identifiedFoods.count, 2)
        XCTAssertEqual(scanResult.totalNutrition.calories, 157)
        XCTAssertEqual(scanResult.totalNutrition.protein, 4.9, accuracy: 0.1)
    }
}