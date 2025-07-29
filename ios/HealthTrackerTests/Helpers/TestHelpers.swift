//
//  TestHelpers.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import Foundation
import CoreData
@testable import HealthTracker

class TestHelpers {
    
    // MARK: - Core Data
    
    static func createInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "HealthTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container
    }
    
    // MARK: - Mock Data
    
    static func createMockFoodEntry(
        name: String = "Test Food",
        calories: Double = 100,
        protein: Double = 10,
        carbs: Double = 20,
        fat: Double = 5,
        in context: NSManagedObjectContext
    ) -> FoodEntry {
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.timestamp = Date()
        return entry
    }
    
    static func createMockExerciseEntry(
        name: String = "Test Exercise",
        duration: Int32 = 30,
        caloriesBurned: Double = 200,
        type: String = "Cardio",
        in context: NSManagedObjectContext
    ) -> ExerciseEntry {
        let entry = ExerciseEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.duration = duration
        entry.caloriesBurned = caloriesBurned
        entry.type = type
        entry.date = Date()
        entry.timestamp = Date()
        return entry
    }
    
    static func createMockNutritionInfo(
        calories: Double = 250,
        protein: Double = 20,
        carbs: Double = 30,
        fat: Double = 10
    ) -> NutritionInfo {
        return NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: 5,
            sugar: 10,
            sodium: 200
        )
    }
    
    static func createMockIdentifiedFood(
        name: String = "Mock Food",
        confidence: Double = 0.9,
        calories: Double = 150
    ) -> IdentifiedFood {
        return IdentifiedFood(
            name: name,
            confidence: confidence,
            estimatedWeight: 100,
            calories: calories,
            protein: 15,
            carbs: 20,
            fat: 5,
            category: .other
        )
    }
    
    // MARK: - Date Helpers
    
    static func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
    
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    // MARK: - Async Test Helpers
    
    static func waitForAsync(
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        line: UInt = #line,
        test: @escaping () async throws -> Void
    ) async throws {
        let expectation = XCTestExpectation(description: "Async operation")
        
        Task {
            do {
                try await test()
                expectation.fulfill()
            } catch {
                XCTFail("Async test failed: \(error)", file: file, line: line)
            }
        }
        
        await fulfillment(of: [expectation], timeout: timeout)
    }
}