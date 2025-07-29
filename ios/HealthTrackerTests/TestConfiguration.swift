//
//  TestConfiguration.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import Foundation
@testable import HealthTracker

/// Test configuration and constants
struct TestConfiguration {
    
    // MARK: - Test Data
    
    struct MockUsers {
        static let defaultUser = UserProfile(
            name: "Test User",
            age: 30,
            gender: .male,
            isPregnant: false,
            isLactating: false,
            healthConditions: []
        )
        
        static let pregnantUser = UserProfile(
            name: "Test Pregnant User",
            age: 28,
            gender: .female,
            isPregnant: true,
            isLactating: false,
            healthConditions: []
        )
    }
    
    struct MockFoods {
        static let apple = IdentifiedFood(
            name: "Apple",
            confidence: 0.95,
            estimatedWeight: 150,
            calories: 95,
            protein: 0.5,
            carbs: 25,
            fat: 0.3,
            category: .fruits
        )
        
        static let chickenBreast = IdentifiedFood(
            name: "Grilled Chicken Breast",
            confidence: 0.92,
            estimatedWeight: 150,
            calories: 250,
            protein: 46,
            carbs: 0,
            fat: 5.5,
            category: .protein
        )
        
        static let brownRice = IdentifiedFood(
            name: "Brown Rice",
            confidence: 0.94,
            estimatedWeight: 100,
            calories: 110,
            protein: 2.5,
            carbs: 23,
            fat: 0.9,
            category: .grains
        )
    }
    
    struct MockExercises {
        static let running = ExerciseTemplate(
            name: "Running",
            type: .cardio,
            caloriesPerMinute: 10,
            defaultDuration: 30
        )
        
        static let weightLifting = ExerciseTemplate(
            name: "Weight Lifting",
            type: .strength,
            caloriesPerMinute: 6,
            defaultDuration: 45
        )
        
        static let yoga = ExerciseTemplate(
            name: "Yoga",
            type: .flexibility,
            caloriesPerMinute: 3,
            defaultDuration: 60
        )
    }
    
    // MARK: - Test Timeouts
    
    struct Timeouts {
        static let standard: TimeInterval = 5
        static let extended: TimeInterval = 10
        static let network: TimeInterval = 30
    }
    
    // MARK: - Test Environment
    
    static var isRunningTests: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        NSClassFromString("XCTest") != nil
    }
    
    static func setupTestEnvironment() {
        // Set up any test-specific configurations
        if isRunningTests {
            // Disable animations for faster UI tests
            UIView.setAnimationsEnabled(false)
            
            // Use mock API responses
            ProcessInfo.processInfo.environment["USE_MOCK_DATA"] = "true"
        }
    }
    
    // MARK: - Validation Thresholds
    
    struct Thresholds {
        static let minimumConfidence = 0.7
        static let maximumProcessingTime = 2.0
        static let minimumCalories = 0.0
        static let maximumCalories = 5000.0
        static let minimumWeight = 0.1
        static let maximumWeight = 1000.0
    }
}