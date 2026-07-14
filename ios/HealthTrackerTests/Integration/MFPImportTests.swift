//
//  MFPImportTests.swift
//  HealthTrackerTests
//
//  Exercises the real MFPImporter end-to-end against Core Data: parse + detect +
//  map + insert + dedupe, using the same sample data bundled in the app.
//

import XCTest
import CoreData
@testable import HealthTracker

final class MFPImportTests: XCTestCase {

    private func newContainer() -> NSPersistentContainer {
        PersistenceController(inMemory: true).container
    }

    private func count(_ entity: String, in container: NSPersistentContainer) throws -> Int {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        return try container.viewContext.count(for: req)
    }

    // MARK: Nutrition

    func testNutritionImportAndDedupe() async throws {
        let container = newContainer()
        let summary = try MFPImporter.preview(csvText: Self.nutritionCSV)

        XCTAssertEqual(summary.kind, .nutrition)
        XCTAssertEqual(summary.importableRows, 18)
        XCTAssertEqual(summary.mealCounts[.breakfast], 5)
        XCTAssertEqual(summary.mealCounts[.snack], 3)

        let inserted = try await MFPImporter.importSummary(summary, weightUnit: .pounds, container: container) { _ in }
        XCTAssertEqual(inserted, 18, "all 18 food rows should insert")
        XCTAssertEqual(try count("FoodEntry", in: container), 18, "diary should hold 18 entries")

        // Re-import the same file -> dedupe -> nothing added.
        let again = try await MFPImporter.importSummary(summary, weightUnit: .pounds, container: container) { _ in }
        XCTAssertEqual(again, 0, "re-import should insert 0 (dedupe)")
        XCTAssertEqual(try count("FoodEntry", in: container), 18, "still 18 after re-import")
    }

    // MARK: Exercise

    func testExerciseImport() async throws {
        let container = newContainer()
        let summary = try MFPImporter.preview(csvText: Self.exerciseCSV)

        XCTAssertEqual(summary.kind, .exercise)
        XCTAssertEqual(summary.importableRows, 7)

        let inserted = try await MFPImporter.importSummary(summary, weightUnit: .pounds, container: container) { _ in }
        XCTAssertEqual(inserted, 7)
        XCTAssertEqual(try count("ExerciseEntry", in: container), 7)

        let again = try await MFPImporter.importSummary(summary, weightUnit: .pounds, container: container) { _ in }
        XCTAssertEqual(again, 0, "re-import should dedupe")
    }

    // MARK: Weight (+ unit handling)

    func testWeightImportPounds() async throws {
        let container = newContainer()
        let summary = try MFPImporter.preview(csvText: Self.weightCSV)
        XCTAssertEqual(summary.kind, .weight)
        XCTAssertEqual(summary.importableRows, 8)

        let inserted = try await MFPImporter.importSummary(summary, weightUnit: .pounds, container: container) { _ in }
        XCTAssertEqual(inserted, 8)

        // First row is 165.2; stored as-is in pounds.
        let req = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let entries = try container.viewContext.fetch(req)
        XCTAssertEqual(entries.first?.weight ?? 0, 165.2, accuracy: 0.01)
    }

    func testWeightImportKilogramsConverts() async throws {
        let container = newContainer()
        let summary = try MFPImporter.preview(csvText: Self.weightCSV)

        // Same file, interpreted as kg -> should be converted to pounds on insert.
        let inserted = try await MFPImporter.importSummary(summary, weightUnit: .kilograms, container: container) { _ in }
        XCTAssertEqual(inserted, 8)

        let req = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let entries = try container.viewContext.fetch(req)
        // 165.2 kg -> ~364.2 lb
        XCTAssertEqual(entries.first?.weight ?? 0, 165.2 * 2.2046226218, accuracy: 0.1)
    }

    // MARK: Parser edge case — embedded comma in a quoted field

    func testQuotedCommaNamePreserved() throws {
        let summary = try MFPImporter.preview(csvText: Self.nutritionCSV)
        let names = summary.foodEntries.map { $0.name }
        XCTAssertTrue(names.contains("Oatmeal, rolled oats - 1 cup cooked"),
                      "the RFC-4180 parser must keep the comma inside the quoted food name")
    }

    // MARK: Unrecognized file

    func testUnrecognizedThrows() {
        let junk = "Foo,Bar\n1,2\n"
        XCTAssertThrowsError(try MFPImporter.preview(csvText: junk))
    }
}

// MARK: - Sample data (mirrors the bundled Sample*.csv files)

private extension MFPImportTests {
    static let nutritionCSV = """
Date,Meal,Food,Calories,"Fat (g)","Saturated Fat","Polyunsaturated Fat","Monounsaturated Fat","Trans Fat","Cholesterol","Sodium (mg)","Potassium","Carbohydrates (g)",Fiber,Sugar,"Protein (g)","Vitamin A","Vitamin C",Calcium,Iron
2026-06-01,Breakfast,"Oatmeal, rolled oats - 1 cup cooked",166,3.6,0.6,1.3,1.1,0,0,9,164,28,4,1,6,0,0,2,10
2026-06-01,Breakfast,"Blueberries, raw - 1/2 cup",42,0.2,0,0.1,0,0,0,1,57,11,2,7,1,1,7,1,1
2026-06-01,Lunch,"Chicken breast, grilled - 6 oz",276,6,1.7,1.3,2.1,0,144,124,440,0,0,0,52,0,0,2,6
2026-06-01,Lunch,"Brown rice, cooked - 1 cup",216,1.8,0.4,0.6,0.6,0,0,10,84,45,4,0,5,0,0,2,5
2026-06-01,Dinner,"Salmon, Atlantic, baked - 5 oz",280,12.5,2.5,5,3.8,0,90,86,628,0,0,0,39,2,0,2,4
2026-06-01,Dinner,"Asparagus, boiled - 1 cup",40,0.4,0.1,0.2,0,0,0,26,404,7,3,2,4,20,14,4,16
2026-06-01,Snacks,"Greek yogurt, plain, nonfat - 1 container (170g)",100,0.7,0.2,0,0.2,0,10,68,240,6,0,4,17,0,0,20,0
2026-06-02,Breakfast,"Eggs, scrambled - 2 large",182,13,3.9,2.5,5,0,372,180,138,2,0,2,12,10,0,8,8
2026-06-02,Breakfast,"Whole wheat toast - 2 slices",138,2,0.4,0.8,0.4,0,0,264,140,24,4,3,7,0,0,6,8
2026-06-02,Lunch,"Turkey sandwich, deli - 1 sandwich",320,9,2.5,2,3,0.2,45,910,320,38,4,6,24,4,8,15,12
2026-06-02,Lunch,"Apple, medium - 1 apple",95,0.3,0.1,0.1,0,0,0,2,195,25,4,19,0,2,14,1,1
2026-06-02,Dinner,"Spaghetti with marinara, homemade - 1.5 cups",340,6,1.2,2,2.5,0,5,620,480,60,6,10,12,12,20,6,14
2026-06-02,Snacks,"Almonds, raw - 1 oz (23 nuts)",164,14,1.1,3.5,9,0,0,0,208,6,3.5,1,6,0,0,7,6
2026-06-03,Breakfast,"Protein smoothie, banana & whey - 1 serving",290,4,1.5,0.5,1,0,30,180,600,34,4,20,30,4,20,25,6
2026-06-03,Lunch,"Caesar salad with chicken - 1 bowl",470,32,7,6,15,0.3,95,1080,520,14,4,4,32,60,12,20,10
2026-06-03,Dinner,"Beef stir-fry with vegetables - 1.5 cups",410,18,5,3,8,0.5,80,890,720,26,5,9,38,80,60,6,22
2026-06-03,Dinner,"Jasmine rice, cooked - 1 cup",205,0.4,0.1,0.1,0.1,0,0,2,55,45,1,0,4,0,0,2,10
2026-06-03,Snacks,"Dark chocolate, 70% - 1 oz",170,12,7,0.4,3.5,0,5,6,200,13,3,7,2,0,0,3,20
"""

    static let exerciseCSV = """
Date,Exercise,Type,"Exercise Calories","Exercise Minutes",Sets,Reps,Weight
2026-06-01,Running,Cardiovascular,320,30,,,
2026-06-01,"Cycling, stationary",Cardiovascular,250,40,,,
2026-06-02,"Walking, brisk",Cardiovascular,180,45,,,
2026-06-02,Bench Press,Strength Training,0,0,3,10,135
2026-06-03,Swimming,Cardiovascular,410,35,,,
2026-06-03,"Yoga, Hatha",Cardiovascular,120,50,,,
2026-06-03,Squats,Strength Training,0,0,4,8,185
"""

    static let weightCSV = """
Date,Weight
2026-06-01,165.2
2026-06-05,164.1
2026-06-09,163.5
2026-06-13,162.8
2026-06-17,161.9
2026-06-21,161.2
2026-06-25,160.4
2026-06-29,159.7
"""
}
