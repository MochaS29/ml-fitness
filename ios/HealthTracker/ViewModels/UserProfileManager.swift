import Foundation
import SwiftUI
import UIKit

// MARK: - Bundled Avatar Definitions

struct BundledAvatar: Identifiable {
    let id: String
    let name: String
    let sfSymbol: String
    let color: Color

    static let all: [BundledAvatar] = [
        BundledAvatar(id: "avatar_runner", name: "Runner", sfSymbol: "figure.walk", color: .orange),
        BundledAvatar(id: "avatar_yoga", name: "Yoga", sfSymbol: "sparkles", color: .purple),
        BundledAvatar(id: "avatar_lifter", name: "Lifter", sfSymbol: "bolt.fill", color: .red),
        BundledAvatar(id: "avatar_cyclist", name: "Cyclist", sfSymbol: "bicycle", color: .blue),
        BundledAvatar(id: "avatar_swimmer", name: "Swimmer", sfSymbol: "drop.fill", color: .cyan),
        BundledAvatar(id: "avatar_hiker", name: "Hiker", sfSymbol: "map.fill", color: .green),
        BundledAvatar(id: "avatar_heart", name: "Wellness", sfSymbol: "heart.fill", color: .pink),
        BundledAvatar(id: "avatar_leaf", name: "Nature", sfSymbol: "leaf.fill", color: Color(red: 0.2, green: 0.7, blue: 0.3)),
        BundledAvatar(id: "avatar_star", name: "Star", sfSymbol: "star.fill", color: .yellow),
        BundledAvatar(id: "avatar_flame", name: "Energy", sfSymbol: "flame.fill", color: Color(red: 1.0, green: 0.4, blue: 0.1))
    ]

    func renderImage(size: CGFloat = 400) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.45, weight: .medium)
        let symbolImage = UIImage(systemName: sfSymbol, withConfiguration: config) ?? UIImage(systemName: "person.fill", withConfiguration: config)!

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let uiColor = UIColor(color)
            uiColor.withAlphaComponent(0.15).setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).fill()

            uiColor.setFill()
            let symbolSize = symbolImage.size
            let x = (size - symbolSize.width) / 2
            let y = (size - symbolSize.height) / 2
            symbolImage.withTintColor(uiColor, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))
        }
    }
}

// MARK: - User Profile Manager

class UserProfileManager: ObservableObject {
    @Published var currentProfile: UserProfile?
    @Published var hasCompletedOnboarding: Bool = false
    @Published var avatarImage: UIImage?
    @Published var avatarType: String = "none"

    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    private let onboardingKey = "hasCompletedOnboarding"
    private let avatarTypeKey = "avatarType"

    private var avatarFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("profile_avatar.jpg")
    }

    init() {
        loadProfile()
        loadAvatar()
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

    // MARK: - Avatar Management

    func loadAvatar() {
        let typeString = userDefaults.string(forKey: avatarTypeKey) ?? "none"
        avatarType = typeString

        if typeString == "photo" {
            if let data = try? Data(contentsOf: avatarFileURL) {
                avatarImage = UIImage(data: data)
            } else {
                avatarType = "none"
                avatarImage = nil
            }
        } else if typeString.hasPrefix("bundled:") {
            let avatarId = String(typeString.dropFirst("bundled:".count))
            if let bundled = BundledAvatar.all.first(where: { $0.id == avatarId }) {
                avatarImage = bundled.renderImage(size: 400)
            } else {
                avatarType = "none"
                avatarImage = nil
            }
        } else {
            avatarImage = nil
        }
    }

    func savePhotoAvatar(_ image: UIImage) {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        if let data = resized.jpegData(compressionQuality: 0.8) {
            try? data.write(to: avatarFileURL)
            avatarImage = resized
            avatarType = "photo"
            userDefaults.set("photo", forKey: avatarTypeKey)
        }
    }

    func selectBundledAvatar(_ avatarId: String) {
        if let bundled = BundledAvatar.all.first(where: { $0.id == avatarId }) {
            avatarImage = bundled.renderImage(size: 400)
            avatarType = "bundled:\(avatarId)"
            userDefaults.set("bundled:\(avatarId)", forKey: avatarTypeKey)
            // Remove any photo file
            try? FileManager.default.removeItem(at: avatarFileURL)
        }
    }

    func removeAvatar() {
        avatarImage = nil
        avatarType = "none"
        userDefaults.set("none", forKey: avatarTypeKey)
        try? FileManager.default.removeItem(at: avatarFileURL)
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
        removeAvatar()
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