//
//  MealPlanningUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for Meal Planning screen
//

import XCTest

final class MealPlanningUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Navigate to Plan tab
        app.tabBars.buttons["Plan"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Meal Planning Screen Tests

    func testMealPlanningSegmentedControl() throws {
        // Verify segmented control exists
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3))

        // Verify all segments
        XCTAssertTrue(segmentedControl.buttons["Today"].exists)
        XCTAssertTrue(segmentedControl.buttons["Week"].exists)
        XCTAssertTrue(segmentedControl.buttons["Month"].exists)

        // Test segment selection
        segmentedControl.buttons["Week"].tap()
        // Would verify week view loads

        segmentedControl.buttons["Month"].tap()
        // Would verify month view loads

        segmentedControl.buttons["Today"].tap()
        // Would verify today view loads
    }

    func testMealPlanningToolbarMenu() throws {
        // Verify toolbar menu button
        let menuButton = app.navigationBars["Meal Planning"].buttons["ellipsis.circle"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3))

        menuButton.tap()

        // Verify menu options
        XCTAssertTrue(app.buttons["Change Plan"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Shopping List"].exists)
        XCTAssertTrue(app.buttons["Reset to Week 1"].exists)

        // Dismiss menu
        app.tap() // Tap outside to dismiss
    }

    func testMealPlanningNoPlanView() throws {
        // If no plan selected, verify empty state
        if app.staticTexts["No meal plan selected"].exists {
            XCTAssertTrue(app.buttons.containing(NSPredicate(format: "label CONTAINS 'Select'")).firstMatch.exists)

            // Tap to select plan
            app.buttons.containing(NSPredicate(format: "label CONTAINS 'Select'")).firstMatch.tap()

            // Verify plan selector sheet appears
            XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

            // Dismiss
            app.swipeDown()
        }
    }

    func testMealPlanningTodayView() throws {
        // Select Today tab
        app.segmentedControls.firstMatch.buttons["Today"].tap()

        // If meal plan exists, verify meal cards
        if !app.staticTexts["No meals available for today"].exists {
            // Verify meal cards
            XCTAssertTrue(app.staticTexts["Breakfast"].exists ||
                          app.buttons.containing(NSPredicate(format: "label CONTAINS 'Breakfast'")).firstMatch.exists)

            // Verify Add to Diary buttons
            let addButtons = app.buttons.matching(identifier: "Add to Diary")
            XCTAssertTrue(addButtons.count > 0)

            // Test Add to Diary button
            app.buttons["Add to Diary"].firstMatch.tap()

            // Verify confirmation alert
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
            app.alerts.buttons["OK"].tap()
        }
    }

    func testMealPlanningWeekView() throws {
        // Select Week tab
        app.segmentedControls.firstMatch.buttons["Week"].tap()

        // Verify week view elements
        if !app.staticTexts["No meal plan selected"].exists {
            // Should show days of week
            XCTAssertTrue(app.staticTexts["Monday"].exists ||
                          app.staticTexts["Tuesday"].exists ||
                          app.staticTexts["Day 1"].exists)
        }
    }

    func testMealPlanningMonthView() throws {
        // Select Month tab
        app.segmentedControls.firstMatch.buttons["Month"].tap()

        // Verify month view elements
        if !app.staticTexts["No meal plan selected"].exists {
            // Should show calendar or month overview
            XCTAssertTrue(app.staticTexts["Week 1"].exists ||
                          app.collectionViews.firstMatch.exists)
        }
    }

    func testMealCardInteraction() throws {
        // Select Today tab
        app.segmentedControls.firstMatch.buttons["Today"].tap()

        // If meals exist
        if !app.staticTexts["No meals available for today"].exists {
            // Find first meal card
            let mealCards = app.scrollViews.buttons
            if mealCards.count > 0 {
                // Tap meal card
                mealCards.firstMatch.tap()

                // Verify meal detail sheet appears
                XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

                // Verify detail elements
                XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'cal'")).firstMatch.exists)
                XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'protein'")).firstMatch.exists)

                // Dismiss
                app.swipeDown()
            }
        }
    }

    func testMealPlanningAddToDiary() throws {
        // Select Today tab
        app.segmentedControls.firstMatch.buttons["Today"].tap()

        // If meals exist with Add to Diary button
        let addButtons = app.buttons.matching(identifier: "Add to Diary")
        if addButtons.count > 0 {
            let addButton = app.buttons["Add to Diary"].firstMatch
            addButton.tap()

            // Verify confirmation alert
            XCTAssertTrue(app.alerts["Added to Diary"].waitForExistence(timeout: 3))

            // Verify alert message
            XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS 'has been added to your food diary'")).firstMatch.exists)

            // Dismiss alert
            app.alerts.buttons["OK"].tap()
        }
    }

    func testShoppingListAccess() throws {
        // Open toolbar menu
        let menuButton = app.navigationBars["Meal Planning"].buttons["ellipsis.circle"]
        menuButton.tap()

        // Tap Shopping List
        app.buttons["Shopping List"].tap()

        // Verify shopping list view appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3) ||
                      app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Shopping'")).firstMatch.exists)

        // Dismiss
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        } else {
            app.swipeDown()
        }
    }
}