//
//  AppScreenshots.swift
//  HealthTrackerUITests
//
//  Automated screenshot capture for App Store submissions
//

import XCTest

class AppScreenshots: XCTestCase {

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

    func testCaptureScreenshots() throws {
        // 1. Dashboard
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.buttons["Dashboard"].tap()
        Thread.sleep(forTimeInterval: 1)
        takeScreenshot(named: "01_Dashboard")

        // 2. Diary
        app.tabBars.buttons["Diary"].tap()
        Thread.sleep(forTimeInterval: 1)
        takeScreenshot(named: "02_Diary")

        // 3. Add Menu
        let addButton = app.tabBars.buttons.element(boundBy: 2)
        addButton.tap()
        Thread.sleep(forTimeInterval: 1)
        takeScreenshot(named: "03_AddMenu")

        // 4. Meal Scanner (if accessible)
        if app.buttons["Scan Meal with Camera"].waitForExistence(timeout: 2) {
            app.buttons["Scan Meal with Camera"].tap()
            Thread.sleep(forTimeInterval: 1)
            takeScreenshot(named: "04_MealScanner")

            // Dismiss
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            } else {
                app.swipeDown()
            }
        }

        // Dismiss add menu
        if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        }

        // 5. Meal Planning
        app.tabBars.buttons["Plan"].tap()
        Thread.sleep(forTimeInterval: 1)
        takeScreenshot(named: "05_MealPlanning")

        // 6. More Options
        app.tabBars.buttons["More"].tap()
        Thread.sleep(forTimeInterval: 1)
        takeScreenshot(named: "06_MoreOptions")
    }

    func testCaptureDashboardWidgets() throws {
        app.tabBars.buttons["Dashboard"].tap()
        Thread.sleep(forTimeInterval: 2)

        // Capture full dashboard
        takeScreenshot(named: "Dashboard_Full")

        // Scroll to see more widgets
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        takeScreenshot(named: "Dashboard_Scrolled")
    }

    func testCaptureAddFoodFlow() throws {
        // Open add menu
        let addButton = app.tabBars.buttons.element(boundBy: 2)
        addButton.tap()
        Thread.sleep(forTimeInterval: 1)

        // Search food
        if app.buttons["Search Food Database"].waitForExistence(timeout: 2) {
            app.buttons["Search Food Database"].tap()
            Thread.sleep(forTimeInterval: 1)
            takeScreenshot(named: "FoodSearch")

            // Dismiss
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            } else {
                app.swipeDown()
            }
        }
    }

    // MARK: - Helper

    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
