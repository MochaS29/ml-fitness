import Foundation

/// Minimal, privacy-respecting funnel analytics.
///
/// Fire-and-forget anonymous events to the first-party Vercel endpoint so we can
/// see WHERE users drop in the paywall / purchase funnel (the app is otherwise
/// account-free and unmonetized-by-tracking). No PII is sent: only the anonymous
/// per-install UUID already used for meal-scan rate limiting, the event name, an
/// optional context label, the platform, and a timestamp. It never blocks the UI
/// and silently ignores failures.
final class FunnelAnalytics {
    static let shared = FunnelAnalytics()
    private init() {}

    enum Event: String {
        case onboardingComplete = "onboarding_complete"
        case firstScan          = "first_scan"
        case paywallShown       = "paywall_shown"
        case buyTapped          = "buy_tapped"
        case purchaseSuccess    = "purchase_success"
        case purchaseFailed     = "purchase_failed"
    }

    /// Same domain as the meal-scan proxy; events land at /api/v1/event.
    private let endpoint = URL(string: "https://mochasmindlab.com/api/v1/event")

    func log(_ event: Event, trigger: PaywallTrigger?) {
        log(event, context: trigger?.analyticsName)
    }

    func log(_ event: Event, context: String? = nil) {
        guard let url = endpoint else { return }

        var body: [String: Any] = [
            "event": event.rawValue,
            "ts": Int(Date().timeIntervalSince1970),
        ]
        if let context = context { body["context"] = context }
        guard let data = try? JSONSerialization.data(withJSONObject: body) else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(SecretsManager.appSharedSecret, forHTTPHeaderField: "X-App-Secret")
        req.setValue(SecretsManager.installId, forHTTPHeaderField: "X-Install-Id")
        req.setValue("ios", forHTTPHeaderField: "X-Platform")
        req.httpBody = data
        req.timeoutInterval = 8

        // Fire-and-forget: analytics must never block, retry, or crash the app.
        URLSession.shared.dataTask(with: req).resume()
    }

    /// Sends `event` at most once per install.
    ///
    /// The top-of-funnel milestones are "first time" events: `onboardingComplete`
    /// marks an activated install and `firstScan` marks the first meal actually
    /// scanned, so both are denominators — one per install or they count nothing.
    /// Onboarding has three exits and the scanner runs many times, so the guard
    /// lives here rather than at each call site. The flag is a plain UserDefaults
    /// bool, so it is wiped by an uninstall or a Clear Data, exactly like the
    /// anonymous install ID it is reported against. Mirrored on Android by
    /// `FunnelAnalytics.logOnce`.
    func logOnce(_ event: Event, context: String? = nil) {
        let key = "funnel_logged_\(event.rawValue)"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        log(event, context: context)
    }
}

extension PaywallTrigger {
    /// Stable snake_case label for analytics (decoupled from UI copy).
    var analyticsName: String {
        switch self {
        case .mealScanner:         return "meal_scanner"
        case .mealScannerLastScan: return "meal_scanner_last_scan"
        case .mealPlan:            return "meal_plan"
        case .general:             return "general"
        }
    }
}
