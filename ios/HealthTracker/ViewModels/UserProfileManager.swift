import Foundation
import SwiftUI

class UserProfileManager: ObservableObject {
    @Published var currentProfile: UserProfile?
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        
        if let data = userDefaults.data(forKey: profileKey) {
            do {
                currentProfile = try JSONDecoder().decode(UserProfile.self, from: data)
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }
    
    func saveProfile(_ profile: UserProfile) {
        currentProfile = profile
        
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: profileKey)
            userDefaults.set(true, forKey: onboardingKey)
            hasCompletedOnboarding = true
        } catch {
            print("Error saving profile: \(error)")
        }
    }
    
    func updateProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        saveProfile(updatedProfile)
    }
    
    func resetProfile() {
        currentProfile = nil
        hasCompletedOnboarding = false
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.removeObject(forKey: onboardingKey)
    }
    
    func checkForLifeStageTransitions() -> [LifeStageAlert] {
        guard let profile = currentProfile else { return [] }
        
        var alerts: [LifeStageAlert] = []
        
        // Check for age milestones
        if profile.age == 51 && profile.gender == .female {
            alerts.append(.rdaChange("Your calcium needs have increased to 1200mg daily"))
            alerts.append(.newRecommendation("Consider adding Vitamin D3 for bone health"))
        }
        
        if profile.age == 71 {
            alerts.append(.rdaChange("Your Vitamin D needs have increased to 800 IU daily"))
        }
        
        return alerts
    }
}

enum LifeStageAlert {
    case rdaChange(String)
    case newRecommendation(String)
    
    var message: String {
        switch self {
        case .rdaChange(let text), .newRecommendation(let text):
            return text
        }
    }
    
    var icon: String {
        switch self {
        case .rdaChange:
            return "exclamationmark.triangle"
        case .newRecommendation:
            return "lightbulb"
        }
    }
}