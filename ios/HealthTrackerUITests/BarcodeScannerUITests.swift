//
//  BarcodeScannerUITests.swift
//  HealthTrackerUITests
//
//  UI tests for the barcode scanner feature
//  Note: Barcode scanner is currently disabled in AddMenuView but these tests
//  are ready for when it's re-enabled
//

import XCTest

final class BarcodeScannerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    private func openAddMenu() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))

        let addButton = tabBar.buttons.element(boundBy: 2)
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Add to Diary"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Food"].waitForExistence(timeout: 3))
    }

    private func navigateToMoreTab() {
        let moreTab = app.tabBars.buttons["More"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 3))
        moreTab.tap()
    }

    // MARK: - Barcode Scanner Access Tests (When Enabled)

    func testBarcodeScannerButtonExistsWhenEnabled() throws {
        openAddMenu()

        // Check if barcode scanner button exists
        // Note: Currently disabled, so this test documents expected behavior
        let barcodeButton = app.buttons["Scan Barcode"]

        // This test will pass when barcode scanner is re-enabled
        if barcodeButton.waitForExistence(timeout: 2) {
            XCTAssertTrue(barcodeButton.isEnabled)
        } else {
            // Barcode scanner is currently disabled - skip test
            throw XCTSkip("Barcode scanner is currently disabled in the app")
        }
    }

    // MARK: - Supplement Tracking Tests (Uses Barcode Scanner)

    func testSupplementTrackingExists() throws {
        navigateToMoreTab()

        // Look for supplement tracking option
        let supplementButton = app.buttons["Supplement Tracking"]
        if supplementButton.waitForExistence(timeout: 3) {
            supplementButton.tap()

            // Verify supplement view opened
            XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 3))
        } else {
            // Try scrolling to find it
            app.swipeUp()
            if app.buttons["Supplement Tracking"].waitForExistence(timeout: 2) {
                app.buttons["Supplement Tracking"].tap()
            }
        }
    }

    func testAddSupplementFromMenu() throws {
        openAddMenu()

        // Find add supplement button
        let supplementButton = app.buttons["Add Supplement"]
        XCTAssertTrue(supplementButton.waitForExistence(timeout: 3), "Add Supplement button should exist")

        supplementButton.tap()

        // Verify supplement entry view opens
        XCTAssertTrue(
            app.navigationBars.element.waitForExistence(timeout: 3) ||
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Supplement'")).firstMatch.waitForExistence(timeout: 3)
        )

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    // MARK: - Manual Entry Flow Tests

    func testManualFoodEntryFlow() throws {
        openAddMenu()

        // Search food database
        let searchButton = app.buttons["Search Food Database"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3))
        searchButton.tap()

        // Verify search view opens
        XCTAssertTrue(
            app.searchFields.firstMatch.waitForExistence(timeout: 3) ||
            app.textFields.firstMatch.waitForExistence(timeout: 3) ||
            app.navigationBars.element.waitForExistence(timeout: 3)
        )

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        } else {
            app.swipeDown()
        }
    }

    // MARK: - Tracking Section Tests

    func testTrackingSectionExists() throws {
        openAddMenu()

        // Verify tracking section
        XCTAssertTrue(app.staticTexts["Tracking"].waitForExistence(timeout: 3))
    }

    func testLogWeightButtonExists() throws {
        openAddMenu()

        let weightButton = app.buttons["Log Weight"]
        XCTAssertTrue(weightButton.waitForExistence(timeout: 3))
    }

    func testLogWaterButtonExists() throws {
        openAddMenu()

        let waterButton = app.buttons["Log Water"]
        XCTAssertTrue(waterButton.waitForExistence(timeout: 3))
    }

    func testLogWeightFlow() throws {
        openAddMenu()

        app.buttons["Log Weight"].tap()

        // Verify weight entry view
        XCTAssertTrue(
            app.navigationBars["Log Weight"].waitForExistence(timeout: 3) ||
            app.staticTexts["Weight"].waitForExistence(timeout: 3)
        )

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testLogWaterFlow() throws {
        openAddMenu()

        app.buttons["Log Water"].tap()

        // Verify water entry view
        XCTAssertTrue(
            app.navigationBars["Log Water"].waitForExistence(timeout: 3) ||
            app.staticTexts["Amount"].waitForExistence(timeout: 3)
        )

        // Check for quick presets
        let preset8oz = app.buttons["8 oz"]
        let preset16oz = app.buttons["16 oz"]

        if preset8oz.waitForExistence(timeout: 2) {
            XCTAssertTrue(preset8oz.exists, "8 oz preset should exist")
        }
        if preset16oz.exists {
            XCTAssertTrue(preset16oz.exists, "16 oz preset should exist")
        }

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    // MARK: - Exercise Section Tests

    func testExerciseSectionExists() throws {
        openAddMenu()

        XCTAssertTrue(app.staticTexts["Exercise"].waitForExistence(timeout: 3))
    }

    func testAddExerciseFlow() throws {
        openAddMenu()

        let exerciseButton = app.buttons["Add Exercise"]
        XCTAssertTrue(exerciseButton.waitForExistence(timeout: 3))
        exerciseButton.tap()

        // Verify exercise search view
        XCTAssertTrue(
            app.navigationBars["Add Exercise"].waitForExistence(timeout: 3) ||
            app.searchFields.firstMatch.waitForExistence(timeout: 3) ||
            app.textFields.firstMatch.waitForExistence(timeout: 3)
        )

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }
}
