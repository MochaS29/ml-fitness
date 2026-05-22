import Foundation

/// Loads API keys from the bundled Secrets.plist at runtime.
/// Falls back to environment variables for simulator/CI builds.
enum SecretsManager {
    private static let secrets: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            print("SecretsManager: Secrets.plist not found — using environment variables")
            return [:]
        }
        return dict
    }()

    static func value(for key: String) -> String {
        // 1. Check bundled Secrets.plist
        if let value = secrets[key] as? String, !value.isEmpty, !value.hasPrefix("YOUR_") {
            return value
        }
        // 2. Fall back to environment variable (works in Xcode scheme / CI)
        return ProcessInfo.processInfo.environment[key] ?? ""
    }

    // Convenience accessors

    static var usdaAPIKey: String { value(for: "USDA_API_KEY").isEmpty ? "DEMO_KEY" : value(for: "USDA_API_KEY") }

    // Proxy auth — paired with a per-install UUID (see `installId`). The shared
    // secret is rotated only on major releases; the install UUID is unique per
    // device and used for per-install rate limiting at the proxy.
    static var appSharedSecret: String { value(for: "APP_SHARED_SECRET") }

    static var mealScanEndpoint: String {
        let v = value(for: "MEAL_SCAN_ENDPOINT")
        return v.isEmpty ? "https://mochasmindlab.com/api/v1/meal-scan" : v
    }

    // Per-install identifier stored in UserDefaults. Generated on first read
    // and never changes for the life of the install (resets only on uninstall
    // or explicit "Clear Data"). Not personally identifying.
    private static let installIdKey = "install_id"
    static var installId: String {
        if let cached = UserDefaults.standard.string(forKey: installIdKey), !cached.isEmpty {
            return cached
        }
        let fresh = UUID().uuidString
        UserDefaults.standard.set(fresh, forKey: installIdKey)
        return fresh
    }
}
