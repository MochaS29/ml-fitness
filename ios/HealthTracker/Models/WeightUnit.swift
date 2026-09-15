import Foundation
import SwiftUI

/// The unit a person wants to see their weight in.
///
/// Weights are **always stored in pounds**, whatever this is set to. Existing
/// entries were written in pounds, so treating pounds as the canonical unit
/// means switching display units never rewrites history and never risks
/// double-converting saved data. Conversion happens at two boundaries only:
/// when a value is shown, and when a value is typed in.
enum WeightUnit: String, CaseIterable, Identifiable {
    case pounds = "lbs"
    case kilograms = "kg"

    var id: String { rawValue }

    /// Short form shown next to a number.
    var symbol: String { rawValue }

    /// Long form for the settings picker.
    var displayName: String {
        switch self {
        case .pounds: return "Pounds (lbs)"
        case .kilograms: return "Kilograms (kg)"
        }
    }

    private static let poundsPerKilogram = 2.20462262185

    /// UserDefaults key. Views should read it with `@AppStorage` so the whole
    /// app redraws the moment the setting changes.
    static let storageKey = "preferredWeightUnit"

    /// For code that is not a SwiftUI view and cannot use `@AppStorage`.
    static var current: WeightUnit {
        WeightUnit(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .pounds
    }

    /// Stored pounds to whatever this unit is.
    func fromPounds(_ pounds: Double) -> Double {
        switch self {
        case .pounds: return pounds
        case .kilograms: return pounds / Self.poundsPerKilogram
        }
    }

    /// A number the person typed, back to pounds for storage.
    func toPounds(_ value: Double) -> Double {
        switch self {
        case .pounds: return value
        case .kilograms: return value * Self.poundsPerKilogram
        }
    }

    /// Formats a stored pounds value for display, symbol included.
    /// `signed` is for deltas, where a leading "+" carries meaning.
    func format(pounds: Double, decimals: Int = 1, signed: Bool = false) -> String {
        let value = fromPounds(pounds)
        let format = signed ? "%+.\(decimals)f %@" : "%.\(decimals)f %@"
        return String(format: format, value, symbol)
    }

    /// The number alone, for when the symbol is drawn separately.
    func value(pounds: Double, decimals: Int = 1) -> String {
        String(format: "%.\(decimals)f", fromPounds(pounds))
    }
}
