//
//  TabBarNavigationUITests.swift
//  HealthTrackerUITests
//
//  Fixed to match current app tab structure
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
        // Verify tab bar is visible
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testDashboardTabNavigation() throws {
        // Dashboard is default tab
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 3))
        dashboardTab.tap()

        // Verify we're on dashboard
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 3) ||
                      app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Hello' OR label CONTAINS 'Good'")).firstMatch.waitForExistence(timeout: 3))
    }

    func testDiaryTabNavigation() throws {
        let diaryTab = app.tabBars.buttons["Diary"]
        XCTAssertTrue(diaryTab.waitForExistence(timeout: 3))
        diaryTab.tap()

        // Verify we're on diary
        XCTAssertTrue(app.navigationBars["Diary"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Diary"].waitForExistence(timeout: 3))
    }

    func testAddButtonOpensMenu() throws {
        // The add button (center tab) should open a sheet
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))

        // Find the plus button (it's the middle tab item)
        let addButton = tabBar.buttons.element(boundBy: 2)
        addButton.tap()

        // Verify add menu sheet appears
        XCTAssertTrue(app.navigationBars["Add to Diary"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Food"].waitForExistence(timeout: 3))

        // Dismiss
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        }
    }

    func testPlanTabNavigation() throws {
        let planTab = app.tabBars.buttons["Plan"]
        XCTAssertTrue(planTab.waitForExistence(timeout: 3))
        planTab.tap()

        // Verify we're on meal planning
        XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 3))
    }

    func testMoreTabNavigation() throws {
        let moreTab = app.tabBars.buttons["More"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 3))
        moreTab.tap()

        // Verify we're on more screen
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 3) ||
                      app.staticTexts["More"].waitForExistence(timeout: 3))
    }

    func testTabPersistence() throws {
        // Navigate to Diary
        app.tabBars.buttons["Diary"].tap()

        // Navigate to More
        app.tabBars.buttons["More"].tap()

        // Go back to Diary
        app.tabBars.buttons["Diary"].tap()

        // Verify we're back on Diary
        XCTAssertTrue(app.navigationBars["Diary"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Diary"].waitForExistence(timeout: 3))
    }

    func testAllTabsAccessible() throws {
        let tabs = ["Dashboard", "Diary", "Plan", "More"]

        for tabName in tabs {
            let tab = app.tabBars.buttons[tabName]
            XCTAssertTrue(tab.waitForExistence(timeout: 2), "Tab '\(tabName)' should exist")
            tab.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
}
