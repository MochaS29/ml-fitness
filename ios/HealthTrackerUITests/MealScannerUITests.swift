//
//  MealScannerUITests.swift
//  HealthTrackerUITests
//
//  UI tests for the AI-powered meal scanner feature
//

import XCTest

final class MealScannerUITests: XCTestCase {

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

        // Tap the center add button
        let addButton = tabBar.buttons.element(boundBy: 2)
        addButton.tap()

        // Wait for menu to appear
        XCTAssertTrue(app.navigationBars["Add to Diary"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Food"].waitForExistence(timeout: 3))
    }

    // MARK: - Meal Scanner Access Tests

    func testMealScannerButtonExists() throws {
        openAddMenu()

        // Look for the scan meal button
        let scanButton = app.buttons["Scan Meal with Camera"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 3), "Scan Meal button should exist in add menu")
    }

    func testMealScannerOpens() throws {
        openAddMenu()

        // Tap scan meal button
        let scanButton = app.buttons["Scan Meal with Camera"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 3))
        scanButton.tap()

        // Verify meal scanner view opens - check for navigation title or camera buttons
        XCTAssertTrue(
            app.navigationBars["Meal Scanner"].waitForExistence(timeout: 3) ||
            app.buttons["Camera"].waitForExistence(timeout: 3) ||
            app.buttons["Library"].waitForExistence(timeout: 3) ||
            app.staticTexts["Take or select a photo of your meal"].waitForExistence(timeout: 3)
        )
    }

    func testMealScannerHasCameraOption() throws {
        openAddMenu()

        app.buttons["Scan Meal with Camera"].tap()

        // Wait for scanner to open
        Thread.sleep(forTimeInterval: 1)

        // Verify camera button exists
        let cameraButton = app.buttons["Camera"]
        XCTAssertTrue(cameraButton.waitForExistence(timeout: 3), "Camera button should exist")
    }

    func testMealScannerHasLibraryOption() throws {
        openAddMenu()

        app.buttons["Scan Meal with Camera"].tap()

        // Wait for scanner to open
        Thread.sleep(forTimeInterval: 1)

        // Verify library button exists
        let libraryButton = app.buttons["Library"]
        XCTAssertTrue(libraryButton.waitForExistence(timeout: 3), "Library button should exist")
    }

    func testMealScannerCanBeDismissed() throws {
        openAddMenu()

        app.buttons["Scan Meal with Camera"].tap()

        // Wait for scanner to fully open
        let mealScannerNavBar = app.navigationBars["Meal Scanner"]
        XCTAssertTrue(mealScannerNavBar.waitForExistence(timeout: 5))

        // Find the Cancel button specifically in the Meal Scanner nav bar
        let cancelButton = mealScannerNavBar.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3), "Cancel button should exist in nav bar")

        // Tap cancel to dismiss
        cancelButton.tap()

        // Wait for the Meal Scanner nav bar to disappear
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: mealScannerNavBar
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "Meal Scanner should be dismissed after tapping Cancel")
    }

    // MARK: - Food Section Tests

    func testFoodSectionExists() throws {
        openAddMenu()

        // Verify food section header exists - it's a section header in the list
        // Look for any indicator we're in the add menu
        XCTAssertTrue(
            app.staticTexts["Food"].waitForExistence(timeout: 3) ||
            app.buttons["Search Food Database"].waitForExistence(timeout: 3)
        )
    }

    func testMealTypePickerExists() throws {
        openAddMenu()

        // Verify meal type picker (segmented control) exists
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3), "Meal type picker should exist")
    }

    func testMealTypePickerOptions() throws {
        openAddMenu()

        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3))

        // Check for at least one meal type option
        let hasBreakfast = segmentedControl.buttons["Breakfast"].exists
        let hasLunch = segmentedControl.buttons["Lunch"].exists
        let hasDinner = segmentedControl.buttons["Dinner"].exists

        XCTAssertTrue(hasBreakfast || hasLunch || hasDinner, "At least one meal type option should exist")
    }

    func testSearchFoodDatabaseButtonExists() throws {
        openAddMenu()

        let searchButton = app.buttons["Search Food Database"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3), "Search Food Database button should exist")
    }

    // MARK: - Integration Flow Tests

    func testFullMealScannerFlow() throws {
        // This test verifies the complete flow without actually using the camera
        openAddMenu()

        // Select a meal type
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.waitForExistence(timeout: 3) {
            if segmentedControl.buttons["Lunch"].exists {
                segmentedControl.buttons["Lunch"].tap()
            }
        }

        // Open meal scanner
        let scanButton = app.buttons["Scan Meal with Camera"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 3))
        scanButton.tap()

        // Wait for scanner to fully open
        XCTAssertTrue(app.navigationBars["Meal Scanner"].waitForExistence(timeout: 5))

        // Verify scanner UI elements are present
        let cameraButton = app.buttons["Camera"]
        let libraryButton = app.buttons["Library"]
        XCTAssertTrue(cameraButton.waitForExistence(timeout: 3), "Camera button should exist")
        XCTAssertTrue(libraryButton.waitForExistence(timeout: 3), "Library button should exist")

        // Verify instruction text is shown
        XCTAssertTrue(app.staticTexts["Take or select a photo of your meal"].exists)

        // Test passes - we've verified the full scanner UI is present
        // Don't test dismissal here as it's covered by testMealScannerCanBeDismissed
    }

    // MARK: - Accessibility Tests

    func testMealScannerAccessibility() throws {
        openAddMenu()

        // Verify scan button is accessible
        let scanButton = app.buttons["Scan Meal with Camera"]
        XCTAssertTrue(scanButton.waitForExistence(timeout: 3))
        XCTAssertTrue(scanButton.isEnabled, "Scan button should be enabled")
        XCTAssertTrue(scanButton.isHittable, "Scan button should be hittable")
    }

    // MARK: - Navigation Title Test

    func testMealScannerNavigationTitle() throws {
        openAddMenu()

        app.buttons["Scan Meal with Camera"].tap()

        // Verify navigation bar title
        XCTAssertTrue(app.navigationBars["Meal Scanner"].waitForExistence(timeout: 3))
    }

    // MARK: - Instruction Text Test

    func testMealScannerInstructionText() throws {
        openAddMenu()

        app.buttons["Scan Meal with Camera"].tap()

        Thread.sleep(forTimeInterval: 1)

        // Verify instruction text
        XCTAssertTrue(
            app.staticTexts["Take or select a photo of your meal"].waitForExistence(timeout: 3)
        )
    }
}
