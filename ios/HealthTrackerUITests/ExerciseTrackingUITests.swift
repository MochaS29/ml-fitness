//
//  ExerciseTrackingUITests.swift
//  HealthTrackerUITests
//
//  Created by Test Suite
//

import XCTest

final class ExerciseTrackingUITests: XCTestCase {
    
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
    
    func testAddExercise() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Log Exercise"
        app.buttons["Log Exercise"].tap()
        
        // Search for exercise
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("running")
        
        // Select from results
        let runningOption = app.buttons["Running"]
        XCTAssertTrue(runningOption.waitForExistence(timeout: 3))
        runningOption.tap()
        
        // Enter duration
        let durationField = app.textFields["Duration (minutes)"]
        durationField.tap()
        durationField.typeText("30")
        
        // Save
        app.buttons["Save"].tap()
        
        // Verify we're back at main screen
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 3))
    }
    
    func testExerciseCategories() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Log Exercise"
        app.buttons["Log Exercise"].tap()
        
        // Verify categories exist
        let categories = ["All", "Cardio", "Strength", "Flexibility", "Sports"]
        
        for category in categories {
            XCTAssertTrue(app.buttons[category].exists)
        }
        
        // Test category filtering
        app.buttons["Cardio"].tap()
        
        // Verify cardio exercises appear
        XCTAssertTrue(app.staticTexts["Running"].exists || 
                     app.staticTexts["Cycling"].exists ||
                     app.staticTexts["Swimming"].exists)
    }
    
    func testCustomExercise() throws {
        // Navigate to add menu
        navigateToAddMenu()
        
        // Select "Log Exercise"
        app.buttons["Log Exercise"].tap()
        
        // Look for custom exercise option
        let customButton = app.buttons["Add Custom Exercise"]
        if customButton.exists {
            customButton.tap()
            
            // Fill in custom exercise
            let nameField = app.textFields["Exercise name"]
            nameField.tap()
            nameField.typeText("Rock Climbing")
            
            // Select type
            app.buttons["Exercise type"].tap()
            app.buttons["Sports"].tap()
            
            // Enter calories per minute
            let caloriesField = app.textFields["Calories per minute"]
            caloriesField.tap()
            caloriesField.typeText("12")
            
            // Save
            app.buttons["Save"].tap()
        }
    }
    
    // Helper methods
    private func navigateToAddMenu() {
        let addButton = app.buttons["Add"]
        if !addButton.exists {
            let addTab = app.tabBars.buttons["Add"]
            if addTab.exists {
                addTab.tap()
            }
        } else {
            addButton.tap()
        }
    }
}