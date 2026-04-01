import Foundation
import WatchConnectivity
import CoreData

class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published var isWatchReachable: Bool = false

    private let session: WCSession
    private let persistenceController = PersistenceController.shared

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    func sendDailyUpdate() {
        guard session.isWatchAppInstalled else { return }

        let context = persistenceController.container.viewContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Fetch today's data
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "date >= %@", today as NSDate)

        let waterRequest: NSFetchRequest<WaterEntry> = WaterEntry.fetchRequest()
        waterRequest.predicate = NSPredicate(format: "timestamp >= %@", today as NSDate)

        do {
            let foodEntries = try context.fetch(foodRequest)
            let waterEntries = try context.fetch(waterRequest)

            let totalCalories = foodEntries.reduce(0.0) { $0 + $1.calories }
            let totalProtein = foodEntries.reduce(0.0) { $0 + $1.protein }
            let totalCarbs = foodEntries.reduce(0.0) { $0 + $1.carbs }
            let totalFat = foodEntries.reduce(0.0) { $0 + $1.fat }
            let totalWater = waterEntries.reduce(0.0) { $0 + Double($1.amount) }

            let dailyData: [String: Any] = [
                "currentCalories": totalCalories,
                "calorieGoal": UserDefaults.standard.double(forKey: "dailyCalorieGoal") > 0 ?
                               UserDefaults.standard.double(forKey: "dailyCalorieGoal") : 2000,
                "currentWater": totalWater,
                "waterGoal": UserDefaults.standard.double(forKey: "dailyWaterGoal") > 0 ?
                            UserDefaults.standard.double(forKey: "dailyWaterGoal") : 64,
                "currentProtein": totalProtein,
                "currentCarbs": totalCarbs,
                "currentFat": totalFat,
                "lastUpdated": Date().timeIntervalSince1970
            ]

            // Try multiple methods to ensure data reaches the watch
            if session.isReachable {
                session.sendMessage(dailyData, replyHandler: nil) { error in
                    print("Error sending message to watch: \(error)")
                }
            }

            // Also update application context for when watch app launches
            do {
                try session.updateApplicationContext(dailyData)
            } catch {
                print("Error updating application context: \(error)")
            }

            // Send as user info for background delivery
            session.transferUserInfo(dailyData)

        } catch {
            print("Error fetching data for watch: \(error)")
        }
    }

    func handleWaterEntry(amount: Double, timestamp: TimeInterval) {
        let context = persistenceController.container.viewContext

        let waterEntry = WaterEntry(context: context)
        waterEntry.id = UUID()
        waterEntry.amount = amount
        waterEntry.unit = "oz"
        waterEntry.timestamp = Date(timeIntervalSince1970: timestamp)

        do {
            try context.save()
            // Send updated data back to watch
            sendDailyUpdate()
        } catch {
            print("Error saving water entry from watch: \(error)")
        }
    }

    func handleQuickFoodEntry(name: String, calories: Int, timestamp: TimeInterval) {
        let context = persistenceController.container.viewContext

        let foodEntry = FoodEntry(context: context)
        foodEntry.id = UUID()
        foodEntry.name = name
        foodEntry.calories = Double(calories)
        foodEntry.date = Date(timeIntervalSince1970: timestamp)
        foodEntry.mealType = determineMealType(for: Date(timeIntervalSince1970: timestamp))

        do {
            try context.save()
            // Send updated data back to watch
            sendDailyUpdate()
        } catch {
            print("Error saving food entry from watch: \(error)")
        }
    }

    func handleExerciseEntry(_ data: [String: Any]) {
        guard let activity = data["activity"] as? String,
              let duration = data["duration"] as? TimeInterval,
              let calories = data["calories"] as? Int,
              let timestamp = data["timestamp"] as? TimeInterval else { return }

        let context = persistenceController.container.viewContext

        let exercise = ExerciseEntry(context: context)
        exercise.id = UUID()
        exercise.name = activity
        exercise.duration = Int32(duration)
        exercise.caloriesBurned = Double(calories)
        exercise.date = Date(timeIntervalSince1970: timestamp)

        if let heartRate = data["heartRate"] as? Int {
            exercise.notes = "Avg HR: \(heartRate) bpm"
        }

        do {
            try context.save()
            // Send updated data back to watch
            sendDailyUpdate()
        } catch {
            print("Error saving exercise from watch: \(error)")
        }
    }

    private func determineMealType(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        if hour < 11 {
            return "Breakfast"
        } else if hour < 15 {
            return "Lunch"
        } else if hour < 20 {
            return "Dinner"
        } else {
            return "Snack"
        }
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error)")
            return
        }

        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }

        // Send initial data to watch
        sendDailyUpdate()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
            if session.isReachable {
                self.sendDailyUpdate()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let type = message["type"] as? String else { return }

        DispatchQueue.main.async {
            switch type {
            case "waterEntry":
                if let amount = message["amount"] as? Double,
                   let timestamp = message["timestamp"] as? TimeInterval {
                    self.handleWaterEntry(amount: amount, timestamp: timestamp)
                }

            case "quickFood":
                if let name = message["name"] as? String,
                   let calories = message["calories"] as? Int,
                   let timestamp = message["timestamp"] as? TimeInterval {
                    self.handleQuickFoodEntry(name: name, calories: calories, timestamp: timestamp)
                }

            case "exercise":
                self.handleExerciseEntry(message)

            case "refreshRequest":
                self.sendDailyUpdate()

            default:
                print("Unknown message type from watch: \(type)")
            }
        }
    }
}