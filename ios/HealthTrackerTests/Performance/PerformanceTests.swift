//
//  PerformanceTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker
import CoreData

final class PerformanceTests: XCTestCase {
    
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        container = TestHelpers.createInMemoryContainer()
        context = container.viewContext
    }
    
    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }
    
    func testFoodSearchPerformance() throws {
        // Given - Create a large dataset
        for i in 0..<1000 {
            _ = TestHelpers.createMockFoodEntry(
                name: "Food Item \(i)",
                calories: Double(100 + i),
                in: context
            )
        }
        try context.save()
        
        // Measure search performance
        measure {
            let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", "Item 50")
            
            do {
                let results = try context.fetch(fetchRequest)
                XCTAssertGreaterThan(results.count, 0)
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }
    }
    
    func testDashboardLoadPerformance() {
        measure {
            let viewModel = DashboardViewModel()
            
            // Simulate loading all dashboard data
            _ = viewModel.aiGreeting
            _ = viewModel.healthScore
            _ = viewModel.nutritionData
            _ = viewModel.weeklyData
            _ = viewModel.aiInsights
            _ = viewModel.recommendations
            _ = viewModel.nutrientBreakdown
            
            // Verify data is loaded
            XCTAssertGreaterThan(viewModel.nutritionData.count, 0)
        }
    }
    
    func testImageAnalysisPerformance() async throws {
        let service = FoodRecognitionService.shared
        let testImage = createLargeTestImage()
        
        // Measure image analysis performance
        let start = CFAbsoluteTimeGetCurrent()
        let result = try await service.analyzeDish(from: testImage)
        let end = CFAbsoluteTimeGetCurrent()
        
        let processingTime = end - start
        
        // Assert processing completes within reasonable time
        XCTAssertLessThan(processingTime, 2.0, "Image analysis took too long: \(processingTime)s")
        XCTAssertGreaterThan(result.identifiedFoods.count, 0)
    }
    
    func testBulkDataSavePerformance() throws {
        measure {
            // Create and save 100 food entries
            for i in 0..<100 {
                _ = TestHelpers.createMockFoodEntry(
                    name: "Bulk Food \(i)",
                    calories: Double(50 + i),
                    in: context
                )
            }
            
            do {
                try context.save()
            } catch {
                XCTFail("Bulk save failed: \(error)")
            }
        }
    }
    
    func testCalorieCalculationPerformance() throws {
        // Given - Create many food entries for a week
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            
            for meal in 0..<5 {
                let entry = TestHelpers.createMockFoodEntry(
                    name: "Meal \(meal)",
                    calories: Double(200 + meal * 50),
                    in: context
                )
                entry.timestamp = date
            }
        }
        
        try context.save()
        
        // Measure weekly calorie calculation
        measure {
            let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
            fetchRequest.predicate = NSPredicate(
                format: "timestamp >= %@ AND timestamp <= %@",
                weekAgo as NSDate,
                today as NSDate
            )
            
            do {
                let results = try context.fetch(fetchRequest)
                let totalCalories = results.reduce(0) { $0 + $1.calories }
                XCTAssertGreaterThan(totalCalories, 0)
            } catch {
                XCTFail("Calorie calculation failed: \(error)")
            }
        }
    }
    
    // Helper methods
    private func createLargeTestImage() -> UIImage {
        let size = CGSize(width: 1024, height: 1024)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        
        // Draw multiple food-like shapes
        for i in 0..<10 {
            let hue = CGFloat(i) / 10.0
            context?.setFillColor(UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0).cgColor)
            let rect = CGRect(x: CGFloat(i * 100), y: CGFloat(i * 100), width: 80, height: 80)
            context?.fillEllipse(in: rect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}