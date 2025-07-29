//
//  APIIntegrationTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker

final class APIIntegrationTests: XCTestCase {
    
    func testSpoonacularAPIConfiguration() {
        // Then
        XCTAssertNotNil(APIConfiguration.Spoonacular.baseURL)
        XCTAssertEqual(APIConfiguration.Spoonacular.baseURL, "https://api.spoonacular.com")
        XCTAssertNotNil(APIConfiguration.Spoonacular.Endpoints.imageAnalysis)
    }
    
    func testUSDAAPIConfiguration() {
        // Then
        XCTAssertNotNil(APIConfiguration.USDA.baseURL)
        XCTAssertTrue(APIConfiguration.USDA.isConfigured)
        XCTAssertEqual(APIConfiguration.USDA.apiKey, "DEMO_KEY") // Default demo key
    }
    
    func testNutritionixAPIConfiguration() {
        // Then
        XCTAssertNotNil(APIConfiguration.Nutritionix.baseURL)
        XCTAssertEqual(APIConfiguration.Nutritionix.baseURL, "https://trackapi.nutritionix.com/v2")
        
        // Check if configured (will be false without env vars)
        if !APIConfiguration.Nutritionix.appId.isEmpty {
            XCTAssertTrue(APIConfiguration.Nutritionix.isConfigured)
        } else {
            XCTAssertFalse(APIConfiguration.Nutritionix.isConfigured)
        }
    }
    
    func testAPIErrorHandling() async {
        // Given
        let service = FoodRecognitionService.shared
        let invalidImage = UIImage() // Empty image
        
        // When/Then
        do {
            _ = try await service.analyzeDish(from: invalidImage)
            XCTFail("Should throw an error for invalid image")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testMockDataFallback() async throws {
        // Given - No API key configured
        let service = FoodRecognitionService.shared
        let mockImage = createTestImage()
        
        // When
        let result = try await service.analyzeDish(from: mockImage)
        
        // Then - Should return mock data
        XCTAssertGreaterThan(result.identifiedFoods.count, 0)
        XCTAssertTrue(result.identifiedFoods.allSatisfy { $0.confidence > 0 })
    }
    
    // Helper methods
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        // Draw a simple food-like shape
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.orange.cgColor)
        context?.fillEllipse(in: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}