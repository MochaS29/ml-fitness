import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var currentCalories: Double = 0
    @Published var calorieGoal: Double = 2000
    @Published var currentWater: Double = 0
    @Published var waterGoal: Double = 64
    @Published var currentProtein: Int = 0
    @Published var currentCarbs: Int = 0
    @Published var currentFat: Int = 0
    @Published var isPhoneReachable: Bool = false

    var calorieProgress: Double {
        min(currentCalories / calorieGoal, 1.0)
    }

    var waterProgress: Double {
        min(currentWater / waterGoal, 1.0)
    }

    private let session: WCSession

    override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    func sendWaterEntry(amount: Double) {
        guard session.isReachable else { return }

        let message = [
            "type": "waterEntry",
            "amount": amount,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending water entry: \(error)")
        }
    }

    func sendQuickFoodEntry(name: String, calories: Int) {
        guard session.isReachable else { return }

        let message = [
            "type": "quickFood",
            "name": name,
            "calories": calories,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending food entry: \(error)")
        }
    }

    func requestDataRefresh() {
        guard session.isReachable else { return }

        let message = ["type": "refreshRequest"]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error requesting refresh: \(error)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error)")
            return
        }

        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }

        // Request initial data
        requestDataRefresh()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
            if session.isReachable {
                self.requestDataRefresh()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedData(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleReceivedData(userInfo)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleReceivedData(applicationContext)
    }

    private func handleReceivedData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            if let calories = data["currentCalories"] as? Double {
                self.currentCalories = calories
            }
            if let goal = data["calorieGoal"] as? Double {
                self.calorieGoal = goal
            }
            if let water = data["currentWater"] as? Double {
                self.currentWater = water
            }
            if let waterGoal = data["waterGoal"] as? Double {
                self.waterGoal = waterGoal
            }
            if let protein = data["currentProtein"] as? Int {
                self.currentProtein = protein
            }
            if let carbs = data["currentCarbs"] as? Int {
                self.currentCarbs = carbs
            }
            if let fat = data["currentFat"] as? Int {
                self.currentFat = fat
            }
        }
    }
}