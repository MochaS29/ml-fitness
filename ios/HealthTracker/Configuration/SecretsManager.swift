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
    static var anthropicAPIKey: String { value(for: "ANTHROPIC_API_KEY") }
    static var usdaAPIKey: String { value(for: "USDA_API_KEY").isEmpty ? "DEMO_KEY" : value(for: "USDA_API_KEY") }
}
