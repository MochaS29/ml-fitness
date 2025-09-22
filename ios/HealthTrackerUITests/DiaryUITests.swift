//
//  DiaryUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for Diary screen and all interactions
//

import XCTest

final class DiaryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Navigate to Diary tab
        app.tabBars.buttons["Diary"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Diary Screen Tests

    func testDiaryDateSelector() throws {
        // Verify date navigation buttons
        XCTAssertTrue(app.buttons["chevron.left"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["chevron.right"].exists)

        // Test previous day navigation
        app.buttons["chevron.left"].tap()
        // In a real test, would verify date changed

        // Test next day navigation
        app.buttons["chevron.right"].tap()
        app.buttons["chevron.right"].tap()
        // Should be at tomorrow, verify can't go further
    }

    func testDiaryMealSections() throws {
        // Verify all meal sections exist
        XCTAssertTrue(app.staticTexts["Breakfast"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lunch"].exists)
        XCTAssertTrue(app.staticTexts["Dinner"].exists)
        XCTAssertTrue(app.staticTexts["Snack"].exists)

        // Verify add buttons for each meal
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        XCTAssertTrue(breakfastSection.buttons["plus.circle.fill"].exists)
    }

    func testDiaryExerciseSection() throws {
        // Scroll to exercise section
        app.swipeUp()

        // Verify exercise section
        XCTAssertTrue(app.staticTexts["Exercise"].waitForExistence(timeout: 3))

        // Verify add button
        let exerciseSection = app.otherElements.containing(.staticText, identifier: "Exercise").firstMatch
        XCTAssertTrue(exerciseSection.buttons["plus.circle.fill"].exists)
    }

    func testDiarySupplementsSection() throws {
        // Scroll to supplements section
        app.swipeUp()

        // Verify supplements section
        XCTAssertTrue(app.staticTexts["Supplements"].waitForExistence(timeout: 3))

        // Verify add button
        let supplementSection = app.otherElements.containing(.staticText, identifier: "Supplements").firstMatch
        XCTAssertTrue(supplementSection.buttons["plus.circle.fill"].exists)
    }

    func testDiaryWaterSection() throws {
        // Scroll to water section
        app.swipeUp()

        // Verify water section
        XCTAssertTrue(app.staticTexts["Water"].waitForExistence(timeout: 3))

        // Verify water drops exist
        let waterDrops = app.images.matching(identifier: "drop")
        XCTAssertTrue(waterDrops.count > 0)

        // Test tapping water drop
        if waterDrops.count > 0 {
            waterDrops.element(boundBy: 0).tap()
            // Would verify water amount updated
        }

        // Verify add button
        let waterSection = app.otherElements.containing(.staticText, identifier: "Water").firstMatch
        XCTAssertTrue(waterSection.buttons["plus.circle.fill"].exists)
    }

    func testDiaryNotesSection() throws {
        // Scroll to bottom
        app.swipeUp()
        app.swipeUp()

        // Verify notes section
        XCTAssertTrue(app.staticTexts["Notes"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'notes about your day'")).firstMatch.exists)
    }

    func testDiaryAddFoodButton() throws {
        // Tap add button in breakfast section
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Verify food search sheet appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Verify search bar exists
        XCTAssertTrue(app.searchFields.firstMatch.exists)

        // Dismiss sheet
        app.swipeDown()
    }

    func testDiaryAddExerciseButton() throws {
        // Scroll to exercise section
        app.swipeUp()

        // Tap add exercise button
        let exerciseSection = app.otherElements.containing(.staticText, identifier: "Exercise").firstMatch
        exerciseSection.buttons["plus.circle.fill"].tap()

        // Verify exercise entry sheet appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars["Add Exercise"].exists)

        // Verify input fields
        XCTAssertTrue(app.textFields["Exercise Name"].exists)

        // Dismiss sheet
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testDiaryAddWaterButton() throws {
        // Scroll to water section
        app.swipeUp()

        // Tap add water button
        let waterSection = app.otherElements.containing(.staticText, identifier: "Water").firstMatch
        waterSection.buttons["plus.circle.fill"].tap()

        // Verify water entry sheet appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars["Add Water"].exists)

        // Verify quick add buttons
        XCTAssertTrue(app.buttons["8 oz"].exists)
        XCTAssertTrue(app.buttons["16 oz"].exists)

        // Dismiss sheet
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testDiaryAddSupplementButton() throws {
        // Scroll to supplements section
        app.swipeUp()

        // Tap add supplement button
        let supplementSection = app.otherElements.containing(.staticText, identifier: "Supplements").firstMatch
        supplementSection.buttons["plus.circle.fill"].tap()

        // Verify supplement entry sheet appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars["Add Supplement"].exists)

        // Verify common supplements list
        XCTAssertTrue(app.staticTexts["Multivitamin"].exists ||
                      app.staticTexts["Vitamin D3"].exists)

        // Dismiss sheet
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testDiaryDailySummary() throws {
        // Verify daily summary section exists at top
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'cal'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'g'")).firstMatch.exists)
    }
}