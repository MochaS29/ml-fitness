//
//  FoodTrackingUITests.swift
//  HealthTrackerUITests
//
//  Created by Test Suite
//

import XCTest

final class FoodTrackingUITests: XCTestCase {
    
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
    
    func testAddFoodManually() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Log Food"
        app.buttons["Log Food"].tap()
        
        // Fill in food details
        let foodNameField = app.textFields["Food name"]
        XCTAssertTrue(foodNameField.waitForExistence(timeout: 3))
        foodNameField.tap()
        foodNameField.typeText("Apple")
        
        // Enter calories
        let caloriesField = app.textFields.containing(.staticText, identifier: "Calories").element
        caloriesField.tap()
        caloriesField.typeText("95")
        
        // Save
        app.buttons["Save"].tap()
        
        // Verify we're back at main screen
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 3))
    }
    
    func testFoodSearch() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Log Food"
        app.buttons["Log Food"].tap()
        
        // Tap search
        let searchButton = app.buttons["Search foods"]
        if searchButton.exists {
            searchButton.tap()
            
            // Enter search query
            let searchField = app.searchFields.firstMatch
            XCTAssertTrue(searchField.waitForExistence(timeout: 3))
            searchField.tap()
            searchField.typeText("chicken")
            
            // Verify results appear
            XCTAssertTrue(app.staticTexts["Grilled Chicken Breast"].waitForExistence(timeout: 3))
        }
    }
    
    func testScanDish() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Scan Dish"
        app.buttons["Scan Dish"].tap()
        
        // In UI test, we can't actually take a photo, but verify the screen appears
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 3))
        
        // Cancel to go back
        app.buttons["Cancel"].tap()
    }
    
    func testQuickAdd() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Quick Add"
        app.buttons["Quick Add"].tap()
        
        // Verify quick add options appear
        XCTAssertTrue(app.staticTexts["Common Foods"].waitForExistence(timeout: 3))
        
        // Select a preset food
        if app.buttons["Banana"].exists {
            app.buttons["Banana"].tap()
            
            // Verify it was added
            XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 3))
        }
    }
    
    // Helper methods
    private func navigateToAddMenu() {
        // Look for add button (usually a plus icon)
        let addButton = app.buttons["Add"]
        if !addButton.exists {
            // Try tab bar
            let addTab = app.tabBars.buttons["Add"]
            if addTab.exists {
                addTab.tap()
            }
        } else {
            addButton.tap()
        }
    }
}