//
//  SupplementSaveTests.swift
//  HealthTrackerTests
//
//  Determines whether the supplement add failure is a Core Data save problem
//  (transformable nutrients) or a UI problem. Mirrors addPresetSupplement's
//  Core Data operations against a real in-memory stack.
//

import XCTest
import CoreData
@testable import HealthTracker

final class SupplementSaveTests: XCTestCase {

    func testSaveSupplementWithNutrients() throws {
        let container = PersistenceController(inMemory: true).container
        let ctx = container.viewContext

        let s = SupplementEntry(context: ctx)
        s.id = UUID()
        s.name = "Magnesium Glycinate"
        s.brand = "Sleep Support"
        s.servingSize = "1"
        s.servingUnit = "serving"
        s.timestamp = Date()
        s.date = Date()
        s.nutrients = ["magnesium": 400]   // [String: Double] transformable

        XCTAssertNoThrow(try ctx.save(), "saving a supplement with a nutrients dictionary must not throw")

        // And it should be fetchable by the same predicate the view uses.
        let req = NSFetchRequest<SupplementEntry>(entityName: "SupplementEntry")
        req.predicate = NSPredicate(format: "timestamp >= %@", Calendar.current.startOfDay(for: Date()) as NSDate)
        XCTAssertEqual(try ctx.count(for: req), 1)
    }

    func testSaveSupplementEmptyNutrients() throws {
        let container = PersistenceController(inMemory: true).container
        let ctx = container.viewContext
        let s = SupplementEntry(context: ctx)
        s.id = UUID()
        s.name = "Probiotic Complex"
        s.timestamp = Date()
        s.date = Date()
        s.nutrients = [:]   // empty dictionary (the Probiotic preset)
        XCTAssertNoThrow(try ctx.save(), "saving with an empty nutrients dictionary must not throw")
    }
}
