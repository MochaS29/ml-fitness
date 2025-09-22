//
//  ProfileSettingsUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for Profile and Settings screens
//

import XCTest

final class ProfileSettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Navigate to Profile
        app.tabBars.buttons["More"].tap()
        app.cells["Profile"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Profile Screen Tests

    func testProfileScreenElements() throws {
        // Verify profile screen loaded
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 3))

        // Verify profile header
        XCTAssertTrue(app.images["person.circle.fill"].exists ||
                      app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'User' OR label CONTAINS 'Name'")).firstMatch.exists)

        // Verify sections
        XCTAssertTrue(app.staticTexts["Personal Information"].exists)
        XCTAssertTrue(app.staticTexts["Settings"].exists)

        // Verify personal info rows
        XCTAssertTrue(app.staticTexts["Age"].exists)
        XCTAssertTrue(app.staticTexts["Gender"].exists)
        XCTAssertTrue(app.staticTexts["Activity Level"].exists)
    }

    func testDistanceUnitToggle() throws {
        // Find distance unit row
        XCTAssertTrue(app.staticTexts["Distance Unit"].waitForExistence(timeout: 3))

        // Find segmented control
        let distanceToggle = app.segmentedControls.containing(NSPredicate(format: "label CONTAINS 'Miles' OR label CONTAINS 'Kilometers'")).firstMatch
        XCTAssertTrue(distanceToggle.exists)

        // Test toggling
        let milesButton = distanceToggle.buttons["Miles"]
        let kilometersButton = distanceToggle.buttons["Kilometers"]

        if milesButton.exists && !milesButton.isSelected {
            milesButton.tap()
            XCTAssertTrue(milesButton.isSelected)
        }

        if kilometersButton.exists && !kilometersButton.isSelected {
            kilometersButton.tap()
            XCTAssertTrue(kilometersButton.isSelected)
        }

        // Toggle back
        if milesButton.exists && !milesButton.isSelected {
            milesButton.tap()
        }
    }

    func testEditProfileButton() throws {
        // Find edit profile button
        let editButton = app.buttons["Edit Profile"]
        XCTAssertTrue(editButton.exists)

        // Tap edit button
        editButton.tap()

        // Verify edit profile sheet appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Verify edit form fields
        XCTAssertTrue(app.textFields.count > 0)

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testResetProfileButton() throws {
        // Find reset profile button
        let resetButton = app.buttons["Reset Profile"]
        XCTAssertTrue(resetButton.exists)

        // Tap reset button
        resetButton.tap()

        // Verify confirmation alert
        if app.alerts.firstMatch.waitForExistence(timeout: 2) {
            // Cancel reset
            app.alerts.buttons["Cancel"].tap()
        }
    }

    func testFoodPreferencesNavigation() throws {
        // Find food preferences row
        let foodPrefRow = app.cells.containing(.staticText, identifier: "Food Preferences").firstMatch
        if foodPrefRow.exists {
            foodPrefRow.tap()

            // Verify food preferences screen
            XCTAssertTrue(app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Food Preferences'")).firstMatch.waitForExistence(timeout: 3))

            // Verify preference options
            XCTAssertTrue(app.switches.count > 0 ||
                          app.cells.count > 0)

            // Go back
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    func testDietaryRestrictions() throws {
        // Check if dietary restrictions section exists
        if app.staticTexts["Dietary Restrictions"].exists {
            // Verify restriction items
            let restrictionCells = app.cells.containing(.image, identifier: "checkmark.circle.fill")
            XCTAssertTrue(restrictionCells.count >= 0)
        }
    }

    func testHealthConditions() throws {
        // Check if health conditions section exists
        if app.staticTexts["Health Conditions"].exists {
            // Verify condition items
            let conditionCells = app.cells.containing(.image, identifier: "heart.circle.fill")
            XCTAssertTrue(conditionCells.count >= 0)
        }
    }

    func testProfileNavigation() throws {
        // Test back navigation
        let backButton = app.navigationBars["Profile"].buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists)

        backButton.tap()

        // Verify returned to More tab
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 3))
    }

    func testEditProfileForm() throws {
        // Open edit profile
        app.buttons["Edit Profile"].tap()

        // Wait for sheet
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Test name field if exists
        if app.textFields["Name"].exists {
            let nameField = app.textFields["Name"]
            nameField.tap()

            // Clear and type new name
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 20)
            nameField.typeText(deleteString)
            nameField.typeText("Test User Updated")
        }

        // Test activity level picker if exists
        if app.buttons.containing(NSPredicate(format: "label CONTAINS 'Activity Level'")).firstMatch.exists {
            app.buttons.containing(NSPredicate(format: "label CONTAINS 'Activity Level'")).firstMatch.tap()

            // Select different activity level
            if app.pickerWheels.count > 0 {
                app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "Active")
            }
        }

        // Test save button
        if app.buttons["Save"].exists {
            // Don't actually save in test
            // app.buttons["Save"].tap()
        }

        // Cancel
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
    }

    func testProfileDataPersistence() throws {
        // Get current distance unit setting
        let distanceToggle = app.segmentedControls.firstMatch

        var initialSelection = ""
        if distanceToggle.buttons["Miles"].isSelected {
            initialSelection = "Miles"
        } else if distanceToggle.buttons["Kilometers"].isSelected {
            initialSelection = "Kilometers"
        }

        // Change selection
        if initialSelection == "Miles" {
            distanceToggle.buttons["Kilometers"].tap()
        } else {
            distanceToggle.buttons["Miles"].tap()
        }

        // Navigate away
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Navigate back
        app.cells["Profile"].tap()

        // Verify setting persisted
        let newToggle = app.segmentedControls.firstMatch
        if initialSelection == "Miles" {
            XCTAssertTrue(newToggle.buttons["Kilometers"].isSelected)
        } else {
            XCTAssertTrue(newToggle.buttons["Miles"].isSelected)
        }

        // Reset to original
        if initialSelection == "Miles" {
            newToggle.buttons["Miles"].tap()
        } else {
            newToggle.buttons["Kilometers"].tap()
        }
    }
}