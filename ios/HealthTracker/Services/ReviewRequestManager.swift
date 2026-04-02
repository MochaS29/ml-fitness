import StoreKit
import UIKit

/// Manages App Store review request prompts for both free and Pro users.
/// Rules:
///  - Free: request after 10th food log, 50th food log, then every 100 thereafter
///  - Pro: request after upgrading + after first AI meal scan
///  - Minimum 30 days between any two requests
final class ReviewRequestManager {
    static let shared = ReviewRequestManager()
    private init() {}

    private let foodLogCountKey = "rrm_foodLogCount"
    private let lastRequestDateKey = "rrm_lastRequestDate"
    private let proUpgradeReviewedKey = "rrm_proUpgradeReviewed"
    private let mealScanReviewedKey = "rrm_mealScanReviewed"

    // MARK: - Trigger points

    /// Call after every food entry is saved.
    func recordFoodLogged() {
        let count = UserDefaults.standard.integer(forKey: foodLogCountKey) + 1
        UserDefaults.standard.set(count, forKey: foodLogCountKey)

        let milestones = [10, 50, 150, 300, 500]
        if milestones.contains(count) {
            requestReviewIfEligible()
        }
    }

    /// Call immediately after a successful Pro upgrade.
    func recordProUpgrade() {
        guard !UserDefaults.standard.bool(forKey: proUpgradeReviewedKey) else { return }
        UserDefaults.standard.set(true, forKey: proUpgradeReviewedKey)
        requestReviewIfEligible()
    }

    /// Call after the first successful AI meal scan.
    func recordMealScanned() {
        guard !UserDefaults.standard.bool(forKey: mealScanReviewedKey) else { return }
        UserDefaults.standard.set(true, forKey: mealScanReviewedKey)
        requestReviewIfEligible()
    }

    // MARK: - Private

    private func requestReviewIfEligible() {
        let last = UserDefaults.standard.object(forKey: lastRequestDateKey) as? Date
        let daysSince = last.map {
            Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0
        } ?? Int.max

        guard daysSince >= 30 else { return }

        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }

            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(Date(), forKey: self.lastRequestDateKey)
        }
    }
}
