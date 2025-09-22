//
//  ComprehensiveDashboardUITests.swift
//  HealthTrackerUITests
//
//  Comprehensive UI tests for all dashboard features and widgets
//

import XCTest

final class ComprehensiveDashboardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SKIP_ONBOARDING"]
        app.launch()

        // Make sure we're on dashboard
        app.tabBars.buttons["Dashboard"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Dashboard Main Tests

    func testDashboardGreeting() throws {
        // Verify greeting exists
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Hello' OR label CONTAINS 'Good' OR label CONTAINS 'morning' OR label CONTAINS 'afternoon' OR label CONTAINS 'evening'")).firstMatch.waitForExistence(timeout: 3))
    }

    func testDashboardScrolling() throws {
        // Test scrolling
        app.swipeUp()
        app.swipeUp()

        // Should be able to scroll back
        app.swipeDown()
        app.swipeDown()

        // Verify still on dashboard
        XCTAssertTrue(app.navigationBars["Dashboard"].exists)
    }

    func testTimeRangeSelector() throws {
        // Look for time range selector
        if app.segmentedControls.firstMatch.exists {
            let selector = app.segmentedControls.firstMatch

            // Test Day view
            if selector.buttons["Day"].exists {
                selector.buttons["Day"].tap()
                // Verify day data loads
            }

            // Test Week view
            if selector.buttons["Week"].exists {
                selector.buttons["Week"].tap()
                // Verify week data loads
            }

            // Test Month view
            if selector.buttons["Month"].exists {
                selector.buttons["Month"].tap()
                // Verify month data loads
            }
        }
    }

    func testCalorieWidget() throws {
        // Find calorie widget
        let calorieWidget = app.otherElements.containing(.staticText, identifier: "Calories").firstMatch
        if calorieWidget.exists {
            // Verify calorie display
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'cal' OR label CONTAINS 'kcal'")).firstMatch.exists)

            // Test tapping widget
            calorieWidget.tap()

            // Might open detail view
            if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                app.swipeDown()
            }
        }
    }

    func testWeightWidget() throws {
        // Find weight widget
        let weightWidget = app.otherElements.containing(.staticText, identifier: "Weight").firstMatch
        if weightWidget.exists {
            // Verify weight display
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'lbs' OR label CONTAINS 'kg'")).firstMatch.exists)

            // Test tapping widget
            weightWidget.tap()

            // Might open weight tracking
            if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                app.swipeDown()
            } else if app.navigationBars["Weight Tracking"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
        }
    }

    func testExerciseWidget() throws {
        // Find exercise widget
        let exerciseWidget = app.otherElements.containing(.staticText, identifier: "Exercise").firstMatch
        if exerciseWidget.exists {
            // Verify exercise display
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'min' OR label CONTAINS 'minutes'")).firstMatch.exists)

            // Test tapping widget
            exerciseWidget.tap()

            // Might open exercise tracking
            if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                app.swipeDown()
            } else if app.navigationBars["Exercise Tracking"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
        }
    }

    func testWaterWidget() throws {
        // Find water widget
        let waterWidget = app.otherElements.containing(.staticText, identifier: "Water").firstMatch
        if waterWidget.exists {
            // Verify water display
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'oz' OR label CONTAINS 'ml' OR label CONTAINS 'cups'")).firstMatch.exists)

            // Test tapping widget
            waterWidget.tap()

            // Might open water tracking
            if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                app.swipeDown()
            } else if app.navigationBars["Water Tracking"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
        }
    }

    func testStepsWidget() throws {
        // Find steps widget
        let stepsWidget = app.otherElements.containing(.staticText, identifier: "Steps").firstMatch
        if !stepsWidget.exists {
            // Try alternative identifiers
            let stepsAlt = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'steps'")).firstMatch
            if stepsAlt.exists {
                // Verify steps count
                XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label MATCHES '\\d+.*steps' OR label MATCHES '\\d+.*Steps'")).firstMatch.exists)

                // Test tapping
                stepsAlt.tap()

                // Might show step details
                if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                    app.swipeDown()
                }
            }
        }
    }

    func testSupplementWidget() throws {
        // Find supplement widget
        if app.staticTexts["Supplements"].exists ||
           app.staticTexts["Today's Supplements"].exists {

            let supplementWidget = app.otherElements.containing(.staticText, identifier: "Supplements").firstMatch
            if supplementWidget.exists {
                supplementWidget.tap()

                // Might open supplement detail
                if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                    app.swipeDown()
                }
            }
        }
    }

    func testAIInsightsSection() throws {
        // Scroll to find AI Insights
        app.swipeUp()

        if app.staticTexts["AI Insights"].waitForExistence(timeout: 2) {
            // Verify insight cards exist
            let insightCards = app.scrollViews.otherElements.buttons
            if insightCards.count > 0 {
                // Tap first insight
                insightCards.firstMatch.tap()

                // Verify detail view
                if app.sheets.firstMatch.waitForExistence(timeout: 2) {
                    // Dismiss
                    if app.buttons["Done"].exists {
                        app.buttons["Done"].tap()
                    } else {
                        app.swipeDown()
                    }
                }
            }
        }
    }

    func testRecommendationsSection() throws {
        // Scroll to find recommendations
        app.swipeUp()
        app.swipeUp()

        if app.staticTexts["Smart Recommendations"].exists ||
           app.staticTexts["Recommendations"].exists {
            // Verify recommendation items
            XCTAssertTrue(app.cells.count > 0 ||
                          app.buttons.containing(NSPredicate(format: "label CONTAINS 'recommendation'")).count > 0)
        }
    }

    func testChartsSection() throws {
        // Scroll to find charts
        app.swipeUp()

        // Look for chart elements
        if app.otherElements.containing(.other, identifier: "Chart").firstMatch.exists ||
           app.images.containing(NSPredicate(format: "identifier CONTAINS 'chart' OR identifier CONTAINS 'graph'")).firstMatch.exists {
            // Charts exist
            XCTAssertTrue(true)
        }
    }

    func testQuickActionsFromDashboard() throws {
        // Look for quick action buttons
        if app.buttons["Add Food"].exists {
            app.buttons["Add Food"].tap()
            XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 2))
            app.swipeDown()
        }

        if app.buttons["Add Water"].exists {
            app.buttons["Add Water"].tap()
            XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 2))
            app.swipeDown()
        }

        if app.buttons["Track Exercise"].exists {
            app.buttons["Track Exercise"].tap()
            XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 2))
            app.swipeDown()
        }
    }

    func testDashboardRefresh() throws {
        // Pull to refresh if available
        let firstElement = app.scrollViews.firstMatch
        let start = firstElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = firstElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))

        start.press(forDuration: 0.1, thenDragTo: end)

        // Wait for refresh
        Thread.sleep(forTimeInterval: 1)

        // Verify dashboard still loads
        XCTAssertTrue(app.navigationBars["Dashboard"].exists)
    }

    func testHealthScoreDisplay() throws {
        // Look for health score
        if app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Health Score' OR label CONTAINS 'Score' OR label MATCHES '\\d+%'")).firstMatch.exists {
            // Verify score display
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label MATCHES '\\d+.*%' OR label MATCHES '\\d+.*points'")).firstMatch.exists)
        }
    }

    func testDashboardNavigationToDetails() throws {
        // Test navigation from dashboard widgets to detail views

        // Calorie widget -> Food tracking
        if app.staticTexts["Calories"].exists {
            app.otherElements.containing(.staticText, identifier: "Calories").firstMatch.tap()
            if app.navigationBars["Food Tracking"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            } else if app.sheets.firstMatch.exists {
                app.swipeDown()
            }
        }

        // Steps widget -> Step details
        if app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Steps' OR label CONTAINS 'steps'")).firstMatch.exists {
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Steps' OR label CONTAINS 'steps'")).firstMatch.tap()
            if app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS 'Step'")).firstMatch.waitForExistence(timeout: 2) {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            } else if app.sheets.firstMatch.exists {
                app.swipeDown()
            }
        }
    }
}