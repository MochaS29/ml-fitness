//
//  NSPredicateDateRangeTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
import CoreData
@testable import HealthTracker

// Helper object whose properties are evaluated by NSPredicate.
// NSPredicate.evaluate(with:) works against KVC-compliant objects; a simple
// NSObject subclass with @objc properties satisfies this without CoreData.
@objc private class TimestampObject: NSObject {
    @objc var timestamp: Date
    @objc var date: Date

    init(timestamp: Date, date: Date? = nil) {
        self.timestamp = timestamp
        self.date = date ?? timestamp
    }
}

final class NSPredicateDateRangeTests: XCTestCase {

    private let calendar = Calendar.current

    // Convenience: build a Date from year/month/day/hour/minute components.
    private func date(
        year: Int, month: Int, day: Int,
        hour: Int = 0, minute: Int = 0, second: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components)!
    }

    // MARK: - forDay() with no args uses today

    func testForDayNoArgsMatchesToday() {
        // A timestamp of "right now" must match a predicate built with no arguments.
        let predicate = NSPredicate.forDay()
        let now = TimestampObject(timestamp: Date())
        XCTAssertTrue(predicate.evaluate(with: now),
            "forDay() with no arguments must match the current moment")
    }

    func testForDayNoArgsDoesNotMatchYesterday() {
        let predicate = NSPredicate.forDay()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let obj = TimestampObject(timestamp: yesterday)
        XCTAssertFalse(predicate.evaluate(with: obj),
            "forDay() with no arguments must not match a timestamp from yesterday")
    }

    // MARK: - forDay(date) matches a timestamp on that day

    func testForDaySpecificDateMatchesMidnightOfThatDay() {
        let targetDay = date(year: 2025, month: 6, day: 15)
        let predicate = NSPredicate.forDay(targetDay)

        // Midnight on target day
        let midnightObj = TimestampObject(timestamp: date(year: 2025, month: 6, day: 15, hour: 0))
        XCTAssertTrue(predicate.evaluate(with: midnightObj),
            "Midnight on the target day must match forDay(date)")
    }

    func testForDaySpecificDateMatchesMiddleOfDay() {
        let targetDay = date(year: 2025, month: 6, day: 15)
        let predicate = NSPredicate.forDay(targetDay)

        let noon = TimestampObject(timestamp: date(year: 2025, month: 6, day: 15, hour: 12))
        XCTAssertTrue(predicate.evaluate(with: noon),
            "A noon timestamp on the target day must match forDay(date)")
    }

    func testForDaySpecificDateMatchesLastSecondOfDay() {
        let targetDay = date(year: 2025, month: 6, day: 15)
        let predicate = NSPredicate.forDay(targetDay)

        // 23:59:59 on the target day is still within the day.
        let lastSecond = TimestampObject(timestamp: date(year: 2025, month: 6, day: 15, hour: 23, minute: 59, second: 59))
        XCTAssertTrue(predicate.evaluate(with: lastSecond),
            "23:59:59 on the target day must match forDay(date)")
    }

    // MARK: - forDay(date) does NOT match the previous day

    func testForDaySpecificDateDoesNotMatchPreviousDay() {
        let targetDay = date(year: 2025, month: 6, day: 15)
        let predicate = NSPredicate.forDay(targetDay)

        // Noon on June 14 must not match a predicate for June 15.
        let previousDay = TimestampObject(timestamp: date(year: 2025, month: 6, day: 14, hour: 12))
        XCTAssertFalse(predicate.evaluate(with: previousDay),
            "A timestamp from the day before must not match forDay(date)")
    }

    func testForDaySpecificDateDoesNotMatchNextDay() {
        let targetDay = date(year: 2025, month: 6, day: 15)
        let predicate = NSPredicate.forDay(targetDay)

        // Midnight on June 16 is the exclusive upper bound — must not match.
        let nextDayMidnight = TimestampObject(timestamp: date(year: 2025, month: 6, day: 16, hour: 0))
        XCTAssertFalse(predicate.evaluate(with: nextDayMidnight),
            "Midnight of the next day (exclusive upper bound) must not match forDay(date)")
    }

    // MARK: - forDay(date, key:) uses a custom key

    func testForDayCustomKeyMatchesCorrectProperty() {
        let targetDay = date(year: 2025, month: 9, day: 1)
        let predicate = NSPredicate.forDay(targetDay, key: "date")

        // timestamp is set to a different day; only `date` matters.
        let obj = TimestampObject(
            timestamp: date(year: 2000, month: 1, day: 1),
            date: date(year: 2025, month: 9, day: 1, hour: 8)
        )
        XCTAssertTrue(predicate.evaluate(with: obj),
            "forDay(_:key:) must evaluate against the specified key ('date'), not the default")
    }

    func testForDayCustomKeyDoesNotFallBackToTimestamp() {
        let targetDay = date(year: 2025, month: 9, day: 1)
        let predicate = NSPredicate.forDay(targetDay, key: "date")

        // `date` is on a different day; `timestamp` happens to be on the target day.
        let obj = TimestampObject(
            timestamp: date(year: 2025, month: 9, day: 1, hour: 10),
            date: date(year: 2025, month: 9, day: 2, hour: 10)
        )
        XCTAssertFalse(predicate.evaluate(with: obj),
            "forDay(_:key:) must not fall back to 'timestamp' when a custom key is specified")
    }

    func testForDayDefaultKeyUsesTimestamp() {
        let targetDay = date(year: 2025, month: 3, day: 20)
        let predicate = NSPredicate.forDay(targetDay) // default key = "timestamp"

        let obj = TimestampObject(
            timestamp: date(year: 2025, month: 3, day: 20, hour: 7),
            date: date(year: 2000, month: 1, day: 1) // irrelevant
        )
        XCTAssertTrue(predicate.evaluate(with: obj),
            "forDay(_:) default key must be 'timestamp'")
    }

    // MARK: - dayBounds(for:) returns midnight and next midnight

    func testDayBoundsStartIsMidnight() {
        let reference = date(year: 2025, month: 11, day: 5, hour: 14, minute: 30)
        let bounds = NSPredicate.dayBounds(for: reference)

        let components = calendar.dateComponents([.hour, .minute, .second], from: bounds.start)
        XCTAssertEqual(components.hour, 0, "dayBounds start hour must be 0 (midnight)")
        XCTAssertEqual(components.minute, 0, "dayBounds start minute must be 0")
        XCTAssertEqual(components.second, 0, "dayBounds start second must be 0")
    }

    func testDayBoundsEndIsNextMidnight() {
        let reference = date(year: 2025, month: 11, day: 5, hour: 14, minute: 30)
        let bounds = NSPredicate.dayBounds(for: reference)

        let startComponents = calendar.dateComponents([.year, .month, .day], from: bounds.start)
        let endComponents   = calendar.dateComponents([.year, .month, .day], from: bounds.end)

        // End day should be start day + 1.
        XCTAssertEqual(endComponents.day, (startComponents.day ?? 0) + 1,
            "dayBounds end must be the start of the following day")

        let endTimeComponents = calendar.dateComponents([.hour, .minute, .second], from: bounds.end)
        XCTAssertEqual(endTimeComponents.hour, 0, "dayBounds end hour must be 0 (midnight)")
        XCTAssertEqual(endTimeComponents.minute, 0)
        XCTAssertEqual(endTimeComponents.second, 0)
    }

    func testDayBoundsSpansExactly24Hours() {
        let reference = date(year: 2025, month: 7, day: 4)
        let bounds = NSPredicate.dayBounds(for: reference)

        let interval = bounds.end.timeIntervalSince(bounds.start)
        XCTAssertEqual(interval, 24 * 60 * 60, accuracy: 1,
            "dayBounds must span exactly 24 hours (excluding DST edge-cases within 1s)")
    }

    func testDayBoundsNoArgsUsesToday() {
        let today = Date()
        let boundsImplicit = NSPredicate.dayBounds()
        let boundsExplicit = NSPredicate.dayBounds(for: today)

        // Both calls should produce the same start/end within a second of each other.
        XCTAssertEqual(boundsImplicit.start.timeIntervalSinceReferenceDate,
                       boundsExplicit.start.timeIntervalSinceReferenceDate,
                       accuracy: 1,
                       "dayBounds() with no args must default to today")
    }

    // MARK: - Integration: predicate matches CoreData in-memory entries

    func testForDayPredicateFiltersInMemoryCoreDataEntries() throws {
        let container = TestHelpers.createInMemoryContainer()
        let ctx = container.viewContext

        let today = date(year: 2025, month: 8, day: 10)
        let yesterday = date(year: 2025, month: 8, day: 9, hour: 12)

        let todayEntry = FoodEntry(context: ctx)
        todayEntry.id = UUID()
        todayEntry.name = "Today Food"
        todayEntry.calories = 200
        todayEntry.timestamp = date(year: 2025, month: 8, day: 10, hour: 9)

        let yesterdayEntry = FoodEntry(context: ctx)
        yesterdayEntry.id = UUID()
        yesterdayEntry.name = "Yesterday Food"
        yesterdayEntry.calories = 300
        yesterdayEntry.timestamp = yesterday

        try ctx.save()

        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.predicate = .forDay(today)
        let results = try ctx.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Today Food")
    }
}
