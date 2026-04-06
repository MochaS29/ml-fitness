import Foundation

/// Manages the 7-day free Pro trial.
/// Trial starts when the user taps "Try Free · 7 Days" on the paywall.
/// ProFeatureGate checks isUnlocked (isPro || isTrialActive).
final class TrialManager: ObservableObject {
    static let shared = TrialManager()
    private init() {}

    static let trialDurationDays = 7
    private let trialStartKey = "proTrialStartDate"

    var isTrialActive: Bool {
        guard let start = UserDefaults.standard.object(forKey: trialStartKey) as? Date else { return false }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return days < Self.trialDurationDays
    }

    var hasStartedTrial: Bool {
        UserDefaults.standard.object(forKey: trialStartKey) != nil
    }

    var daysRemaining: Int {
        guard let start = UserDefaults.standard.object(forKey: trialStartKey) as? Date else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, Self.trialDurationDays - days)
    }

    func startTrial() {
        guard !hasStartedTrial else { return }
        UserDefaults.standard.set(Date(), forKey: trialStartKey)
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
    }
}
