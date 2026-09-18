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
        case paywallDismissed   = "paywall_dismissed"
        case buyTapped          = "buy_tapped"
        case purchaseSuccess    = "purchase_success"
        case purchaseFailed     = "purchase_failed"
        case screenView         = "screen_view"
    }

    /// Screens reported through `screenView`. The raw value is the `context`
    /// sent with the event. Mirrored on Android by `FunnelAnalytics.Screen`;
    /// keep the shared names identical on both platforms. Onboarding steps are
    /// per platform because the two onboarding flows differ.
    enum Screen: String {
        case dashboard            = "dashboard"
        case diary                = "diary"
        case addToDiary           = "add_to_diary"
        case mealScanner          = "meal_scanner"
        case mealPlan             = "meal_plan"
        case more                 = "more"
        case paywall              = "paywall"
        case onboardingWelcome    = "onboarding_welcome"
        case onboardingQuickSetup = "onboarding_quick_setup"
        case onboardingReminders  = "onboarding_reminders"
    }

    /// Same domain as the meal-scan proxy; events land at /api/v1/event.
    private let endpoint = URL(string: "https://mochasmindlab.com/api/v1/event")

    private var screenThrottle = ScreenViewThrottle()

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
    /// scanned, so both are denominators: one per install or they count nothing.
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

    /// Records one `screenView` per appearance of `screen`.
    ///
    /// Call it from the screen's `onAppear`. SwiftUI can fire `onAppear` more
    /// than once for a single visible appearance (tab restores, sheet dismissals
    /// re-presenting the view underneath), so repeats of the same screen inside
    /// a two second window are dropped. A different screen always logs.
    /// Mirrored on Android by `FunnelAnalytics.logScreen`.
    func logScreen(_ screen: Screen) {
        guard screenThrottle.admit(screen.rawValue) else { return }
        log(.screenView, context: screen.rawValue)
    }
}

/// Drops repeats of the same screen name that arrive within `window` seconds of
/// the last one that was admitted. Pure value type so the rule is unit-testable
/// without touching the network.
struct ScreenViewThrottle {
    static let defaultWindow: TimeInterval = 2

    let window: TimeInterval
    private var lastScreen: String?
    private var lastAdmittedAt: Date?

    init(window: TimeInterval = ScreenViewThrottle.defaultWindow) {
        self.window = window
    }

    /// Returns true when `screen` should be logged, and remembers it if so.
    mutating func admit(_ screen: String, now: Date = Date()) -> Bool {
        if let last = lastScreen, let at = lastAdmittedAt,
           last == screen, now.timeIntervalSince(at) < window {
            return false
        }
        lastScreen = screen
        lastAdmittedAt = now
        return true
    }
}

extension PaywallTrigger {
    /// Stable snake_case label for analytics (decoupled from UI copy).
    var analyticsName: String {
        switch self {
        case .mealScanner:         return "meal_scanner"
        case .mealScannerLastScan: return "meal_scanner_last_scan"
        case .mealPlan:            return "meal_plan"
        case .recipeBook:          return "recipe_book"
        case .barcodeScanner:      return "barcode_scanner"
        case .supplements:         return "supplements"
        case .fasting:             return "fasting"
        case .settings:            return "settings"
        case .general:             return "general"
        }
    }
}
