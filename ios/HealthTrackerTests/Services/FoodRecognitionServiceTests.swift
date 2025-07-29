//
//  FoodRecognitionServiceTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker
import UIKit

final class FoodRecognitionServiceTests: XCTestCase {
    
    var service: FoodRecognitionService!
    
    override func setUp() {
        super.setUp()
        service = FoodRecognitionService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testAnalyzeDishWithMockImage() async throws {
        // Given
        let image = createMockImage()
        
        // When
        let result = try await service.analyzeDish(from: image)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.identifiedFoods.count, 0)
        XCTAssertGreaterThan(result.totalNutrition.calories, 0)
    }
    
    func testSearchFood() async throws {
        // Given
        let query = "chicken"
        
        // When
        let results = try await service.searchFood(query: query)
        
        // Then
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertTrue(results.contains { $0.name.localizedCaseInsensitiveContains(query) })
    }
    
    func testSearchFoodWithNoResults() async throws {
        // Given
        let query = "xyzabc123"
        
        // When
        let results = try await service.searchFood(query: query)
        
        // Then
        XCTAssertEqual(results.count, 0)
    }
    
    func testFoodCategoryMapping() {
        // Given
        let categories = [
            ("apple fruit", FoodCategory.fruits),
            ("chicken meat", FoodCategory.protein),
            ("bread grain", FoodCategory.grains),
            ("milk dairy", FoodCategory.dairy),
            ("cake dessert", FoodCategory.desserts),
            ("unknown", FoodCategory.other)
        ]
        
        // When/Then
        for (input, expected) in categories {
            let mapped = mapCategoryString(input)
            XCTAssertEqual(mapped, expected)
        }
    }
    
    // Helper methods
    private func createMockImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        UIColor.brown.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    private func mapCategoryString(_ category: String) -> FoodCategory {
        switch category.lowercased() {
        case let cat where cat.contains("fruit"): return .fruits
        case let cat where cat.contains("vegetable"): return .vegetables
        case let cat where cat.contains("meat") || cat.contains("protein"): return .protein
        case let cat where cat.contains("grain") || cat.contains("bread"): return .grains
        case let cat where cat.contains("dairy"): return .dairy
        case let cat where cat.contains("dessert") || cat.contains("sweet"): return .desserts
        default: return .other
        }
    }
}