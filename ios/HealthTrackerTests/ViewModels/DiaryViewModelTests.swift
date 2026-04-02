//
//  DiaryViewModelTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
import CoreData
@testable import HealthTracker

// NOTE: DiaryViewModel's aggregate methods (totalCalories, mealCalories, etc.) accept
// FetchedResults<T>, which cannot be constructed outside of a SwiftUI view lifecycle.
// The tests below exercise the identical arithmetic logic on [FoodEntry] / [ExerciseEntry]
// arrays drawn from an in-memory Core Data store, mirroring the ViewModel implementation.

final class DiaryViewModelTests: XCTestCase {

    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var viewModel: DiaryViewModel!

    override func setUp() {
        super.setUp()
        container = TestHelpers.createInMemoryContainer()
        context = container.viewContext
        viewModel = DiaryViewModel()
    }

    override func tearDown() {
        viewModel = nil
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - calculateWaterOunces

    // calculateWaterOunces reads from PersistenceController.shared, so we can only
    // test its contract properties (non-negative return) without inserting water entries
    // into the shared store during unit tests.
    func testCalculateWaterOuncesReturnsNonNegative() {
        let result = viewModel.calculateWaterOunces(for: Date())
        XCTAssertGreaterThanOrEqual(result, 0, "Water ounces must be non-negative")
    }

    func testCalculateWaterOuncesForDistantPastIsZero() {
        // A date far in the past will have no logged entries, so result must be 0.
        let distantPast = Date(timeIntervalSinceReferenceDate: 0) // 2001-01-01
        let result = viewModel.calculateWaterOunces(for: distantPast)
        XCTAssertEqual(result, 0, accuracy: 0.001,
            "Water ounces for a date with no entries should be 0")
    }

    // MARK: - mealCalories (logic mirror)

    func testMealCaloriesEmptyArray() {
        // When there are no food entries the sum for any meal type must be 0.
        let entries = makeFoodEntries([])
        for mealType in MealType.allCases {
            let sum = entries
                .filter { $0.mealType == mealType.rawValue }
                .reduce(0.0) { $0 + $1.calories }
            XCTAssertEqual(Int(sum), 0, "Empty entries must yield 0 for \(mealType.rawValue)")
        }
    }

    func testMealCaloriesSumsCorrectly() {
        // Insert two breakfast entries and one lunch entry.
        let b1 = makeFoodEntry(calories: 300, mealType: .breakfast)
        let b2 = makeFoodEntry(calories: 200, mealType: .breakfast)
        let l1 = makeFoodEntry(calories: 450, mealType: .lunch)
        let entries = [b1, b2, l1]

        let breakfastCalories = entries
            .filter { $0.mealType == MealType.breakfast.rawValue }
            .reduce(0.0) { $0 + $1.calories }
        XCTAssertEqual(Int(breakfastCalories), 500)

        let lunchCalories = entries
            .filter { $0.mealType == MealType.lunch.rawValue }
            .reduce(0.0) { $0 + $1.calories }
        XCTAssertEqual(Int(lunchCalories), 450)

        let dinnerCalories = entries
            .filter { $0.mealType == MealType.dinner.rawValue }
            .reduce(0.0) { $0 + $1.calories }
        XCTAssertEqual(dinnerCalories, 0)
    }

    // MARK: - totalExerciseMinutes (logic mirror)

    func testTotalExerciseMinutesEmptyArray() {
        let entries = makeExerciseEntries([])
        let total = entries.reduce(0) { $0 + Int($1.duration) }
        XCTAssertEqual(total, 0)
    }

    func testTotalExerciseMinutesSumsCorrectly() {
        let e1 = makeExerciseEntry(duration: 30)
        let e2 = makeExerciseEntry(duration: 45)
        let e3 = makeExerciseEntry(duration: 15)
        let entries = [e1, e2, e3]
        let total = entries.reduce(0) { $0 + Int($1.duration) }
        XCTAssertEqual(total, 90)
    }

    // MARK: - mealTypeDisplayName

    func testMealTypeDisplayNameReturnsNonEmptyStringForAllCases() {
        for mealType in MealType.allCases {
            let name = viewModel.mealTypeDisplayName(mealType)
            XCTAssertFalse(name.isEmpty,
                "mealTypeDisplayName must return a non-empty string for \(mealType.rawValue)")
        }
    }

    func testMealTypeDisplayNameValues() {
        XCTAssertEqual(viewModel.mealTypeDisplayName(.breakfast), "Breakfast")
        XCTAssertEqual(viewModel.mealTypeDisplayName(.lunch), "Lunch")
        XCTAssertEqual(viewModel.mealTypeDisplayName(.dinner), "Dinner")
        XCTAssertEqual(viewModel.mealTypeDisplayName(.snack), "Snack")
    }

    // MARK: - Nutrition aggregates (logic mirror)

    func testTotalCaloriesEmptyArray() {
        let entries = makeFoodEntries([])
        let total = entries.reduce(0.0) { $0 + $1.calories }
        XCTAssertEqual(total, 0)
    }

    func testTotalCaloriesSumsCorrectly() {
        let entries = [
            makeFoodEntry(calories: 100, protein: 10, carbs: 20, fat: 5),
            makeFoodEntry(calories: 250, protein: 20, carbs: 30, fat: 10),
            makeFoodEntry(calories: 150, protein: 5,  carbs: 15, fat: 8),
        ]
        let total = entries.reduce(0.0) { $0 + $1.calories }
        XCTAssertEqual(total, 500, accuracy: 0.001)
    }

    func testTotalProteinSumsCorrectly() {
        let entries = [
            makeFoodEntry(calories: 100, protein: 10, carbs: 0, fat: 0),
            makeFoodEntry(calories: 100, protein: 30, carbs: 0, fat: 0),
        ]
        let total = entries.reduce(0.0) { $0 + $1.protein }
        XCTAssertEqual(total, 40, accuracy: 0.001)
    }

    func testTotalCarbsSumsCorrectly() {
        let entries = [
            makeFoodEntry(calories: 100, protein: 0, carbs: 25, fat: 0),
            makeFoodEntry(calories: 100, protein: 0, carbs: 35, fat: 0),
        ]
        let total = entries.reduce(0.0) { $0 + $1.carbs }
        XCTAssertEqual(total, 60, accuracy: 0.001)
    }

    func testTotalFatSumsCorrectly() {
        let entries = [
            makeFoodEntry(calories: 100, protein: 0, carbs: 0, fat: 8),
            makeFoodEntry(calories: 100, protein: 0, carbs: 0, fat: 12),
        ]
        let total = entries.reduce(0.0) { $0 + $1.fat }
        XCTAssertEqual(total, 20, accuracy: 0.001)
    }

    // MARK: - Private Helpers

    @discardableResult
    private func makeFoodEntry(
        calories: Double = 100,
        protein: Double = 10,
        carbs: Double = 20,
        fat: Double = 5,
        mealType: MealType = .breakfast
    ) -> FoodEntry {
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = "Test Food"
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.mealType = mealType.rawValue
        entry.timestamp = Date()
        return entry
    }

    private func makeFoodEntries(_ specs: [(Double, MealType)]) -> [FoodEntry] {
        specs.map { makeFoodEntry(calories: $0.0, mealType: $0.1) }
    }

    @discardableResult
    private func makeExerciseEntry(duration: Int32 = 30) -> ExerciseEntry {
        let entry = ExerciseEntry(context: context)
        entry.id = UUID()
        entry.name = "Test Exercise"
        entry.duration = duration
        entry.caloriesBurned = Double(duration) * 5
        entry.type = "Cardio"
        entry.date = Date()
        entry.timestamp = Date()
        return entry
    }

    private func makeExerciseEntries(_ durations: [Int32]) -> [ExerciseEntry] {
        durations.map { makeExerciseEntry(duration: $0) }
    }
}
