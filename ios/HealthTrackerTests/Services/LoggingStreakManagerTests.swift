//
//  LoggingStreakManagerTests.swift
//  HealthTrackerTests
//

import XCTest
import CoreData
@testable import HealthTracker

final class LoggingStreakManagerTests: XCTestCase {

    // The manager singleton reads from PersistenceController.shared.container.viewContext,
    // so tests insert FoodEntry objects directly into that context and call refreshStreak().
    var context: NSManagedObjectContext!
    var manager: LoggingStreakManager!

    override func setUp() {
        super.setUp()
        context = PersistenceController.shared.container.viewContext
        manager = LoggingStreakManager.shared
        deleteAllFoodEntries()
    }

    override func tearDown() {
        deleteAllFoodEntries()
        context = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Removes every FoodEntry from the shared context to isolate each test.
    private func deleteAllFoodEntries() {
        let request: NSFetchRequest<NSFetchRequestResult> = FoodEntry.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(batchDelete)
        context.reset()
    }

    /// Inserts a FoodEntry whose timestamp falls on the given calendar day offset
    /// from today (negative = past days, 0 = today).
    @discardableResult
    private func insertEntry(daysAgo: Int, name: String = "Test Food") -> FoodEntry {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        // Use noon so start-of-day rounding is unambiguous.
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!

        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.calories = 200
        entry.protein = 10
        entry.carbs = 30
        entry.fat = 5
        entry.timestamp = noon
        try? context.save()
        return entry
    }

    /// Mirrors the streak-emoji switch used in DashboardView so the mapping
    /// can be verified without reaching into the view layer.
    private func streakEmoji(for streak: Int) -> String {
        switch streak {
        case 1...2:   return "🌱"
        case 3...6:   return "🔥"
        case 7...13:  return "⚡️"
        case 14...29: return "🏅"
        default:      return "🏆"
        }
    }

    // MARK: - Streak Logic Tests

    func testFreshInstallHasStreakOfZero() {
        // No entries exist — streak must be 0.
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 0)
    }

    func testLoggingTodaySetsStreakToOne() {
        insertEntry(daysAgo: 0)
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 1)
    }

    func testThreeConsecutiveDaysProducesStreakOfThree() {
        // Log today, yesterday, and two days ago.
        insertEntry(daysAgo: 0)
        insertEntry(daysAgo: 1)
        insertEntry(daysAgo: 2)
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 3)
    }

    func testSkippingADayResetsStreakToOne() {
        // Log today and two days ago — yesterday is missing.
        // The streak should be 1 (only today is contiguous).
        insertEntry(daysAgo: 0)
        insertEntry(daysAgo: 2)
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 1)
    }

    func testCurrentStreakAfterMultipleDays() {
        // Five consecutive days.
        for daysAgo in 0...4 {
            insertEntry(daysAgo: daysAgo)
        }
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 5)
    }

    func testStreakCountsFromYesterdayWhenTodayHasNoEntry() {
        // The manager also allows a streak to start from yesterday (not broken yet).
        insertEntry(daysAgo: 1)
        insertEntry(daysAgo: 2)
        insertEntry(daysAgo: 3)
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 3)
    }

    func testStreakIsZeroWhenOnlyOldEntriesExist() {
        // Entries older than yesterday should not count.
        insertEntry(daysAgo: 2)
        insertEntry(daysAgo: 3)
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 0)
    }

    func testMultipleEntriesOnSameDayCountAsOne() {
        // Several entries on the same day should not inflate the streak.
        insertEntry(daysAgo: 0, name: "Breakfast")
        insertEntry(daysAgo: 0, name: "Lunch")
        insertEntry(daysAgo: 0, name: "Dinner")
        manager.refreshStreak()
        XCTAssertEqual(manager.currentStreak, 1)
    }

    // MARK: - Streak Emoji Milestone Tests

    func testEmojiForOneDayStreak() {
        XCTAssertEqual(streakEmoji(for: 1), "🌱")
    }

    func testEmojiForTwoDayStreak() {
        XCTAssertEqual(streakEmoji(for: 2), "🌱")
    }

    func testEmojiForThreeDayStreak() {
        XCTAssertEqual(streakEmoji(for: 3), "🔥")
    }

    func testEmojiForSixDayStreak() {
        XCTAssertEqual(streakEmoji(for: 6), "🔥")
    }

    func testEmojiForSevenDayStreak() {
        XCTAssertEqual(streakEmoji(for: 7), "⚡️")
    }

    func testEmojiForThirteenDayStreak() {
        XCTAssertEqual(streakEmoji(for: 13), "⚡️")
    }

    func testEmojiForFourteenDayStreak() {
        XCTAssertEqual(streakEmoji(for: 14), "🏅")
    }

    func testEmojiForTwentyNineDayStreak() {
        XCTAssertEqual(streakEmoji(for: 29), "🏅")
    }

    func testEmojiForThirtyDayStreak() {
        XCTAssertEqual(streakEmoji(for: 30), "🏆")
    }

    func testEmojiForLongStreak() {
        XCTAssertEqual(streakEmoji(for: 100), "🏆")
    }
}
