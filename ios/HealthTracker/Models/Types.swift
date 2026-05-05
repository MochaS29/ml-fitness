import Foundation

// Shared enums and types used across the app

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    /// Returns the most likely meal for the given hour of day.
    /// 5–10 = breakfast, 11–14 = lunch, 17–21 = dinner, otherwise snack.
    static func defaultForCurrentTime(_ date: Date = Date()) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5...10: return .breakfast
        case 11...14: return .lunch
        case 17...21: return .dinner
        default: return .snack
        }
    }
}

enum TimeRange: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}