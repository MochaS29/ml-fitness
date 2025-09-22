//
//  TabBarNavigationUITests.swift
//  HealthTrackerUITests
//
//  Tests for tab bar navigation and all main tabs
//

import XCTest

final class TabBarNavigationUITests: XCTestCase {

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

    // MARK: - Tab Bar Tests

    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // Verify all tabs exist
        XCTAssertTrue(tabBar.buttons["Dashboard"].exists)
        XCTAssertTrue(tabBar.buttons["Diary"].exists)
        XCTAssertTrue(tabBar.buttons["Plan"].exists)
        XCTAssertTrue(tabBar.buttons["More"].exists)

        // Verify add button (center tab)
        let addButton = tabBar.buttons.element(boundBy: 2)
        XCTAssertTrue(addButton.exists)
    }

    func testDashboardTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Dashboard"].tap()

        // Verify dashboard screen loads
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 3))

        // Verify dashboard elements
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
    }

    func testDiaryTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Diary"].tap()

        // Verify diary screen loads
        XCTAssertTrue(app.navigationBars["Diary"].waitForExistence(timeout: 3))

        // Verify diary elements
        XCTAssertTrue(app.staticTexts["Breakfast"].exists ||
                      app.staticTexts["Lunch"].exists ||
                      app.staticTexts["Dinner"].exists)
    }

    func testPlanTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Plan"].tap()

        // Verify meal planning screen loads
        XCTAssertTrue(app.navigationBars["Meal Planning"].waitForExistence(timeout: 3))

        // Verify plan elements
        XCTAssertTrue(app.segmentedControls.firstMatch.exists) // Today/Week/Month selector
    }

    func testMoreTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["More"].tap()

        // Verify more screen loads
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 3))

        // Verify more menu options
        XCTAssertTrue(app.cells.count > 0)
    }

    func testAddButtonOpensMenu() throws {
        let tabBar = app.tabBars.firstMatch
        let addButton = tabBar.buttons.element(boundBy: 2) // Center button

        addButton.tap()

        // Verify add menu appears
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 3))

        // Verify menu options
        XCTAssertTrue(app.buttons["Food"].exists)
        XCTAssertTrue(app.buttons["Exercise"].exists)
        XCTAssertTrue(app.buttons["Water"].exists)
        XCTAssertTrue(app.buttons["Supplement"].exists)

        // Dismiss menu
        app.swipeDown()
    }

    func testTabPersistence() throws {
        let tabBar = app.tabBars.firstMatch

        // Navigate to Diary
        tabBar.buttons["Diary"].tap()
        XCTAssertTrue(app.navigationBars["Diary"].exists)

        // Navigate to Plan
        tabBar.buttons["Plan"].tap()
        XCTAssertTrue(app.navigationBars["Meal Planning"].exists)

        // Go back to Diary
        tabBar.buttons["Diary"].tap()
        XCTAssertTrue(app.navigationBars["Diary"].exists)
    }
}