import Foundation

enum AppConstants {
    enum Defaults {
        static let dailyCalorieGoal = 2000
        static let dailyStepGoal = 8000
        static let dailyWaterGlasses = 8
        static let waterGlassOunces = 8.0
    }
    enum MET {
        // MET values used in exercise calorie estimation
        static let cardio = 7.5
        static let strength = 5.0
        static let flexibility = 3.0
        static let sports = 7.0
        static let other = 5.0
    }
    enum AppStore {
        static let appId = "6752837101"
        static let reviewURL = "https://apps.apple.com/app/id\(appId)?action=write-review"
    }
}
