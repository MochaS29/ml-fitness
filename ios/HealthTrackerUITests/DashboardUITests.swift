//
//  DashboardUITests.swift
//  HealthTrackerUITests
//
//  Created by Test Suite
//

import XCTest

final class DashboardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testDashboardSelectorFlow() throws {
        // Given - App launches with dashboard selector
        
        // When - User can see all dashboard options
        let hybridOption = app.buttons["Hybrid Pro"]
        XCTAssertTrue(hybridOption.waitForExistence(timeout: 5))
        
        // Then - User can select hybrid dashboard
        hybridOption.tap()
        
        // Verify dashboard loads
        let dashboardTitle = app.navigationBars["Dashboard"]
        XCTAssertTrue(dashboardTitle.exists)
    }
    
    func testHybridDashboardElements() throws {
        // Navigate to hybrid dashboard
        selectHybridDashboard()
        
        // Verify key elements exist
        XCTAssertTrue(app.staticTexts["Hello, Mocha!"].exists)
        XCTAssertTrue(app.staticTexts["AI Insights"].exists)
        XCTAssertTrue(app.staticTexts["Smart Recommendations"].exists)
        
        // Verify metric cards
        XCTAssertTrue(app.staticTexts["Calories"].exists)
        XCTAssertTrue(app.staticTexts["Weight"].exists)
        XCTAssertTrue(app.staticTexts["Exercise"].exists)
        XCTAssertTrue(app.staticTexts["Water"].exists)
    }
    
    func testAIInsightInteraction() throws {
        // Navigate to hybrid dashboard
        selectHybridDashboard()
        
        // Find and tap an AI insight
        let insightCards = app.scrollViews.containing(.staticText, identifier: "AI Insights").children(matching: .other)
        if insightCards.count > 0 {
            insightCards.element(boundBy: 0).tap()
            
            // Verify detail view appears
            XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 3))
            
            // Dismiss
            app.buttons["Done"].tap()
        }
    }
    
    func testTimeRangeSelector() throws {
        // Navigate to hybrid dashboard
        selectHybridDashboard()
        
        // Test time range selector
        let weekButton = app.buttons["Week"]
        if weekButton.exists {
            weekButton.tap()
            // Verify data updates (in real app, would check for different values)
            XCTAssertTrue(app.staticTexts["Weekly Summary"].exists)
        }
    }
    
    // Helper methods
    private func selectHybridDashboard() {
        if app.buttons["Hybrid Pro"].exists {
            app.buttons["Hybrid Pro"].tap()
        }
        // Wait for dashboard to load
        _ = app.navigationBars["Dashboard"].waitForExistence(timeout: 5)
    }
}