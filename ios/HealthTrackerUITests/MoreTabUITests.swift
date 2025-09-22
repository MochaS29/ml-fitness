//
//  MoreTabUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for More tab and all its screens
//

import XCTest

final class MoreTabUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Navigate to More tab
        app.tabBars.buttons["More"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - More Tab Tests

    func testMoreTabMenuOptions() throws {
        // Verify all menu options exist
        XCTAssertTrue(app.cells["Profile"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.cells["Goals"].exists)
        XCTAssertTrue(app.cells["Weight Tracking"].exists)
        XCTAssertTrue(app.cells["Exercise Tracking"].exists)
        XCTAssertTrue(app.cells["Water Tracking"].exists)
        XCTAssertTrue(app.cells["Sleep Tracking"].exists)
        XCTAssertTrue(app.cells["Supplement Tracking"].exists)
        XCTAssertTrue(app.cells["Intermittent Fasting"].exists)
        XCTAssertTrue(app.cells["Reminders"].exists)
        XCTAssertTrue(app.cells["My Recipe Book"].exists)
        XCTAssertTrue(app.cells["Grocery List Generator"].exists)
    }

    func testProfileNavigation() throws {
        app.cells["Profile"].tap()

        // Verify profile screen
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 3))

        // Verify profile sections
        XCTAssertTrue(app.staticTexts["Personal Information"].exists)
        XCTAssertTrue(app.staticTexts["Settings"].exists)

        // Verify distance unit toggle
        XCTAssertTrue(app.staticTexts["Distance Unit"].exists)
        XCTAssertTrue(app.segmentedControls.containing(NSPredicate(format: "label CONTAINS 'Miles' OR label CONTAINS 'Kilometers'")).firstMatch.exists)

        // Test Edit Profile button
        XCTAssertTrue(app.buttons["Edit Profile"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testGoalsNavigation() throws {
        app.cells["Goals"].tap()

        // Verify goals screen
        XCTAssertTrue(app.navigationBars["Goals"].waitForExistence(timeout: 3))

        // Verify goal sections
        XCTAssertTrue(app.staticTexts["Daily Goals"].exists ||
                      app.staticTexts["Nutrition Goals"].exists)

        // Verify input fields
        XCTAssertTrue(app.textFields.count > 0)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testWeightTrackingNavigation() throws {
        app.cells["Weight Tracking"].tap()

        // Verify weight tracking screen
        XCTAssertTrue(app.navigationBars["Weight Tracking"].waitForExistence(timeout: 3))

        // Verify add button
        XCTAssertTrue(app.navigationBars["Weight Tracking"].buttons["plus"].exists)

        // Verify chart or list
        XCTAssertTrue(app.scrollViews.firstMatch.exists)

        // Test add button
        app.navigationBars["Weight Tracking"].buttons["plus"].tap()

        // Verify add weight sheet
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(app.textFields.firstMatch.exists)

        // Cancel
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testExerciseTrackingNavigation() throws {
        app.cells["Exercise Tracking"].tap()

        // Verify exercise tracking screen
        XCTAssertTrue(app.navigationBars["Exercise Tracking"].waitForExistence(timeout: 3))

        // Verify add button
        XCTAssertTrue(app.buttons["Add Exercise"].exists ||
                      app.navigationBars["Exercise Tracking"].buttons["plus"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testWaterTrackingNavigation() throws {
        app.cells["Water Tracking"].tap()

        // Verify water tracking screen
        XCTAssertTrue(app.navigationBars["Water Tracking"].waitForExistence(timeout: 3))

        // Verify water drops
        XCTAssertTrue(app.images.matching(NSPredicate(format: "identifier CONTAINS 'drop'")).count > 0)

        // Verify quick add buttons
        XCTAssertTrue(app.buttons["8 oz"].exists ||
                      app.buttons["+8 oz"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testSleepTrackingNavigation() throws {
        app.cells["Sleep Tracking"].tap()

        // Verify sleep tracking screen
        XCTAssertTrue(app.navigationBars["Sleep Tracking"].waitForExistence(timeout: 3))

        // Verify sleep entry elements
        XCTAssertTrue(app.datePickers.count > 0 ||
                      app.buttons["Add Sleep"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testSupplementTrackingNavigation() throws {
        app.cells["Supplement Tracking"].tap()

        // Verify supplement tracking screen
        XCTAssertTrue(app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Supplement'")).firstMatch.waitForExistence(timeout: 3))

        // Verify add button or supplement list
        XCTAssertTrue(app.buttons["Add Supplement"].exists ||
                      app.navigationBars.buttons["plus"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testIntermittentFastingNavigation() throws {
        app.cells["Intermittent Fasting"].tap()

        // Verify fasting screen
        XCTAssertTrue(app.navigationBars["Intermittent Fasting"].waitForExistence(timeout: 3))

        // Verify fasting timer or controls
        XCTAssertTrue(app.buttons["Start Fast"].exists ||
                      app.buttons["End Fast"].exists ||
                      app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'hours'")).firstMatch.exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testRemindersNavigation() throws {
        app.cells["Reminders"].tap()

        // Verify reminders screen
        XCTAssertTrue(app.navigationBars["Reminders"].waitForExistence(timeout: 3))

        // Verify add reminder button
        XCTAssertTrue(app.navigationBars["Reminders"].buttons["plus"].exists ||
                      app.buttons["Add Reminder"].exists)

        // Verify reminder types
        XCTAssertTrue(app.staticTexts["Meal Reminders"].exists ||
                      app.staticTexts["Water Reminders"].exists ||
                      app.switches.count > 0)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testRecipeBookNavigation() throws {
        app.cells["My Recipe Book"].tap()

        // Verify recipe book screen
        XCTAssertTrue(app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Recipe'")).firstMatch.waitForExistence(timeout: 3))

        // Verify add recipe button
        XCTAssertTrue(app.navigationBars.buttons["plus"].exists ||
                      app.buttons["Add Recipe"].exists ||
                      app.buttons["Import Recipe"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testGroceryListGeneratorNavigation() throws {
        app.cells["Grocery List Generator"].tap()

        // Verify grocery list screen
        XCTAssertTrue(app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Grocery'")).firstMatch.waitForExistence(timeout: 3))

        // Verify generate button or list
        XCTAssertTrue(app.buttons["Generate List"].exists ||
                      app.buttons["Add Item"].exists ||
                      app.textFields.count > 0)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
}