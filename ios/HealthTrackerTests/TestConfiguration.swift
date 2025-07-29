//
//  TestConfiguration.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
@testable import HealthTracker

/// Test configuration and constants
struct TestConfiguration {
    
    // MARK: - Test Data
    
    struct MockUsers {
        static let defaultUser = UserProfile(
            name: "Test User",
            gender: .male,
            birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!
        )
        
        static let pregnantUser: UserProfile = {
            var user = UserProfile(
                name: "Test Pregnant User",
                gender: .female,
                birthDate: Calendar.current.date(byAdding: .year, value: -28, to: Date())!
            )
            user.isPregnant = true
            return user
        }()
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
            category: "Outdoor"
        )
        
        static let weightLifting = ExerciseTemplate(
            name: "Weight Lifting",
            type: .strength,
            caloriesPerMinute: 6,
            category: "Gym"
        )
        
        static let yoga = ExerciseTemplate(
            name: "Yoga",
            type: .flexibility,
            caloriesPerMinute: 3,
            category: "Home"
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
            #if canImport(UIKit)
            UIView.setAnimationsEnabled(false)
            #endif
            
            // Use mock API responses - Note: environment is read-only at runtime
            // This would need to be set in the scheme's environment variables
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