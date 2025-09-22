//
//  OnboardingUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for onboarding flow
//

import XCTest

final class OnboardingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_ONBOARDING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Screen Tests

    func testOnboardingWelcomeScreen() throws {
        // Verify welcome screen elements
        XCTAssertTrue(app.staticTexts["Welcome to Health Tracker"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Quick Setup"].exists)

        // Verify buttons
        XCTAssertTrue(app.buttons["Start Using App"].exists)
        XCTAssertTrue(app.buttons["Skip Setup"].exists)
    }

    func testOnboardingNameEntry() throws {
        // Find and tap name field
        let nameField = app.textFields["Enter your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))

        nameField.tap()
        nameField.typeText("Test User")

        // Verify text was entered
        XCTAssertEqual(nameField.value as? String, "Test User")
    }

    func testOnboardingGenderSelection() throws {
        // Test gender picker
        let genderPicker = app.segmentedControls.firstMatch
        XCTAssertTrue(genderPicker.exists)

        // Test each option
        let maleButton = genderPicker.buttons["Male"]
        let femaleButton = genderPicker.buttons["Female"]
        let otherButton = genderPicker.buttons["Other"]

        XCTAssertTrue(maleButton.exists)
        XCTAssertTrue(femaleButton.exists)
        XCTAssertTrue(otherButton.exists)

        // Test selection
        maleButton.tap()
        XCTAssertTrue(maleButton.isSelected)

        femaleButton.tap()
        XCTAssertTrue(femaleButton.isSelected)
    }

    func testOnboardingDatePicker() throws {
        // Test birth date picker
        let datePickers = app.datePickers
        XCTAssertTrue(datePickers.count > 0)

        // Tap to open date picker
        datePickers.firstMatch.tap()

        // Verify date picker wheels exist
        XCTAssertTrue(app.pickerWheels.count > 0)
    }

    func testOnboardingStartButton() throws {
        // Enter name
        let nameField = app.textFields["Enter your name"]
        nameField.tap()
        nameField.typeText("Test User")

        // Tap Get Started button
        let startButton = app.buttons["Start Using App"]
        XCTAssertTrue(startButton.exists)
        XCTAssertTrue(startButton.isEnabled)

        startButton.tap()

        // Verify navigation to main app
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testOnboardingSkipButton() throws {
        // Test Skip Setup button
        let skipButton = app.buttons["Skip Setup"]
        XCTAssertTrue(skipButton.exists)

        skipButton.tap()

        // Verify navigation to main app
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}