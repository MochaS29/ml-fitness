//
//  FoodEntryUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for food search and entry flows
//

import XCTest

final class FoodEntryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Navigate to Diary and open food search
        app.tabBars.buttons["Diary"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Food Search Tests

    func testFoodSearchOpens() throws {
        // Tap add food button
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Verify food search sheet opens
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Verify search bar exists
        XCTAssertTrue(app.searchFields.firstMatch.exists)

        // Verify tabs exist
        XCTAssertTrue(app.buttons["Search"].exists)
        XCTAssertTrue(app.buttons["Favorites"].exists)
        XCTAssertTrue(app.buttons["Recent"].exists)
        XCTAssertTrue(app.buttons["Custom"].exists)

        // Dismiss
        app.swipeDown()
    }

    func testFoodSearchInput() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Type in search field
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Apple")

        // Verify search results appear
        XCTAssertTrue(app.cells.count > 0)

        // Verify result cells contain search term
        XCTAssertTrue(app.cells.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'apple'")).firstMatch.exists)

        // Dismiss
        app.swipeDown()
    }

    func testFoodSearchTabs() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Test Favorites tab
        app.buttons["Favorites"].tap()
        // Would show favorite foods

        // Test Recent tab
        app.buttons["Recent"].tap()
        // Would show recent foods

        // Test Custom tab
        app.buttons["Custom"].tap()
        // Would show custom foods or add button
        XCTAssertTrue(app.buttons["Add Custom Food"].exists ||
                      app.buttons["Create Custom Food"].exists ||
                      app.staticTexts["No custom foods"].exists)

        // Go back to Search
        app.buttons["Search"].tap()

        // Dismiss
        app.swipeDown()
    }

    func testFoodSelection() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Search for food
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Banana")

        // Wait for results
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 3))

        // Tap first result
        app.cells.firstMatch.tap()

        // Verify food detail view or confirmation
        XCTAssertTrue(app.buttons["Add"].exists ||
                      app.buttons["Add to Diary"].exists ||
                      app.navigationBars.buttons["Done"].exists)

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testCreateCustomFood() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Go to Custom tab
        app.buttons["Custom"].tap()

        // Tap add custom food if available
        if app.buttons["Add Custom Food"].exists {
            app.buttons["Add Custom Food"].tap()

            // Verify custom food form
            XCTAssertTrue(app.textFields["Food Name"].waitForExistence(timeout: 3))
            XCTAssertTrue(app.textFields["Calories"].exists)
            XCTAssertTrue(app.textFields["Protein"].exists)
            XCTAssertTrue(app.textFields["Carbs"].exists)
            XCTAssertTrue(app.textFields["Fat"].exists)

            // Test entering data
            app.textFields["Food Name"].tap()
            app.textFields["Food Name"].typeText("Test Food")

            app.textFields["Calories"].tap()
            app.textFields["Calories"].typeText("100")

            // Verify save button
            XCTAssertTrue(app.buttons["Save"].exists)

            // Cancel
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            }
        }

        // Dismiss search
        app.swipeDown()
    }

    func testBarcodeScanner() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Look for barcode scanner button
        if app.buttons["barcode.viewfinder"].exists ||
           app.buttons["Scan Barcode"].exists {
            app.buttons["barcode.viewfinder"].tap()

            // Verify camera view or permission request
            // Note: Can't test actual camera in simulator

            // Would show camera view
            XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 3) ||
                          app.navigationBars.buttons.firstMatch.exists)

            // Cancel scanner
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            }
        }

        // Dismiss
        app.swipeDown()
    }

    func testFoodServingSize() throws {
        // Open food search
        let breakfastSection = app.otherElements.containing(.staticText, identifier: "Breakfast").firstMatch
        breakfastSection.buttons["plus.circle.fill"].tap()

        // Search and select food
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Rice")

        // Wait and tap result
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 3))
        app.cells.firstMatch.tap()

        // If serving size selector exists
        if app.textFields["Serving Size"].exists ||
           app.textFields.containing(NSPredicate(format: "value CONTAINS 'serving' OR value CONTAINS 'cup' OR value CONTAINS 'gram'")).firstMatch.exists {

            // Verify serving size can be edited
            let servingField = app.textFields.containing(NSPredicate(format: "value CONTAINS 'serving' OR value CONTAINS '1'")).firstMatch
            servingField.tap()
            servingField.typeText("2")
        }

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testQuickAddFood() throws {
        // Navigate to add menu from center tab button
        app.tabBars.buttons.element(boundBy: 2).tap()

        // Verify quick add menu
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Tap Food option
        app.buttons["Food"].tap()

        // Verify food entry sheet
        XCTAssertTrue(app.sheets.firstMatch.exists ||
                      app.searchFields.firstMatch.exists)

        // Dismiss
        app.swipeDown()
    }
}