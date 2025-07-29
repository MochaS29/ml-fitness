//
//  CoreDataTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
import CoreData
@testable import HealthTracker

final class CoreDataTests: XCTestCase {
    
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        container = NSPersistentContainer(name: "HealthTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        context = container.viewContext
    }
    
    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }
    
    func testCreateFoodEntry() throws {
        // Given
        let foodEntry = FoodEntry(context: context)
        foodEntry.id = UUID()
        foodEntry.name = "Test Apple"
        foodEntry.calories = 95
        foodEntry.protein = 0.5
        foodEntry.carbs = 25
        foodEntry.fat = 0.3
        foodEntry.timestamp = Date()
        
        // When
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Test Apple")
        XCTAssertEqual(results.first?.calories, 95)
    }
    
    func testCreateExerciseEntry() throws {
        // Given
        let exercise = ExerciseEntry(context: context)
        exercise.id = UUID()
        exercise.name = "Running"
        exercise.type = "Cardio"
        exercise.duration = 30
        exercise.caloriesBurned = 300
        exercise.date = Date()
        exercise.timestamp = Date()
        
        // When
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Running")
        XCTAssertEqual(results.first?.duration, 30)
        XCTAssertEqual(results.first?.caloriesBurned, 300)
    }
    
    func testFetchFoodEntriesForDate() throws {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Create entries for different dates
        let todayFood = FoodEntry(context: context)
        todayFood.id = UUID()
        todayFood.name = "Today's Food"
        todayFood.calories = 200
        todayFood.timestamp = today
        
        let yesterdayFood = FoodEntry(context: context)
        yesterdayFood.id = UUID()
        yesterdayFood.name = "Yesterday's Food"
        yesterdayFood.calories = 150
        yesterdayFood.timestamp = yesterday
        
        try context.save()
        
        // When - Fetch only today's entries
        let startOfToday = calendar.startOfDay(for: today)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp < %@",
            startOfToday as NSDate,
            endOfToday as NSDate
        )
        
        let results = try context.fetch(fetchRequest)
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Today's Food")
    }
    
    func testCalculateDailyCalories() throws {
        // Given
        let foods = [
            ("Breakfast", 350.0),
            ("Lunch", 550.0),
            ("Dinner", 650.0),
            ("Snack", 150.0)
        ]
        
        for (name, calories) in foods {
            let entry = FoodEntry(context: context)
            entry.id = UUID()
            entry.name = name
            entry.calories = calories
            entry.timestamp = Date()
        }
        
        try context.save()
        
        // When
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        let results = try context.fetch(fetchRequest)
        let totalCalories = results.reduce(0) { $0 + $1.calories }
        
        // Then
        XCTAssertEqual(totalCalories, 1700)
    }
    
    func testDeleteEntry() throws {
        // Given
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = "To Delete"
        entry.calories = 100
        entry.timestamp = Date()
        
        try context.save()
        
        // When
        context.delete(entry)
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 0)
    }
}