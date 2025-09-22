import Foundation
import CoreMotion
import Combine

class StepCounterService: ObservableObject {
    static let shared = StepCounterService()

    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    private var updateTimer: Timer?

    // Published properties for UI updates
    @Published var todaySteps: Int = 0
    @Published var todayDistanceInMeters: Double = 0.0 // Raw value in meters
    @Published var todayDistance: Double = 0.0 // Converted to user's preferred unit
    @Published var distanceUnit: DistanceUnit = .miles
    @Published var todayFloorsAscended: Int = 0
    @Published var todayFloorsDescended: Int = 0
    @Published var currentPace: Double? = nil // meters per second
    @Published var currentCadence: Double? = nil // steps per second
    @Published var isStepCountingAvailable = false
    @Published var lastUpdateTime = Date()

    // Hourly tracking
    @Published var hourlySteps: [Int] = Array(repeating: 0, count: 24)

    // Activity state
    @Published var currentActivity: String = "Unknown"
    @Published var isWalking = false
    @Published var isRunning = false
    @Published var isStationary = true

    // Error handling
    @Published var errorMessage: String?

    enum DistanceUnit: String, CaseIterable {
        case miles = "mi"
        case kilometers = "km"

        var conversionFactor: Double {
            switch self {
            case .miles: return 0.000621371 // meters to miles
            case .kilometers: return 0.001 // meters to kilometers
            }
        }
    }

    private init() {
        checkAvailability()
        loadDistancePreference()
    }

    private func loadDistancePreference() {
        // Check user defaults for saved preference
        if let savedUnit = UserDefaults.standard.string(forKey: "distanceUnit"),
           let unit = DistanceUnit(rawValue: savedUnit) {
            distanceUnit = unit
        } else {
            // Default based on locale
            let locale = Locale.current
            let isMetric = locale.usesMetricSystem
            distanceUnit = isMetric ? .kilometers : .miles
        }
    }

    func setDistanceUnit(_ unit: DistanceUnit) {
        distanceUnit = unit
        UserDefaults.standard.set(unit.rawValue, forKey: "distanceUnit")

        // Recalculate current distance with new unit
        todayDistance = todayDistanceInMeters * unit.conversionFactor
    }

    // MARK: - Setup and Permissions

    func checkAvailability() {
        isStepCountingAvailable = CMPedometer.isStepCountingAvailable()

        if !isStepCountingAvailable {
            errorMessage = "Step counting is not available on this device"
        }
    }

    func startStepCounting() {
        guard isStepCountingAvailable else {
            errorMessage = "Step counting is not available"
            return
        }

        // Check and request permission first
        checkAndRequestPermission { [weak self] authorized in
            guard authorized else {
                self?.errorMessage = "Permission denied for motion tracking"
                return
            }

            DispatchQueue.main.async {
                // Start real-time pedometer updates
                self?.startPedometerUpdates()

                // Start activity monitoring
                self?.startActivityUpdates()

                // Query today's accumulated steps
                self?.queryTodaysSteps()

                // Set up hourly update timer
                self?.setupHourlyTimer()

                // Query hourly breakdown
                self?.queryHourlySteps()
            }
        }
    }

    private func checkAndRequestPermission(completion: @escaping (Bool) -> Void) {
        // Core Motion doesn't require explicit permission request
        // but we should check if it's available and handle errors gracefully
        if CMPedometer.isStepCountingAvailable() {
            // Test if we can access pedometer data
            let testDate = Date()
            pedometer.queryPedometerData(from: testDate, to: testDate) { _, error in
                DispatchQueue.main.async {
                    if error != nil {
                        // Might be first time, just proceed
                        completion(true)
                    } else {
                        completion(true)
                    }
                }
            }
        } else {
            completion(false)
        }
    }

    func stopStepCounting() {
        pedometer.stopUpdates()
        activityManager.stopActivityUpdates()
        updateTimer?.invalidate()
        updateTimer = nil
    }

    // MARK: - Real-time Updates

    private func startPedometerUpdates() {
        let startOfDay = Calendar.current.startOfDay(for: Date())

        pedometer.startUpdates(from: startOfDay) { [weak self] pedometerData, error in
            // Process on background queue to avoid blocking UI
            DispatchQueue.global(qos: .background).async {
                guard let self = self else { return }

                // Update on main queue only when needed
                DispatchQueue.main.async { [weak self] in
                    if let error = error {
                        self?.errorMessage = "Step counting error: \(error.localizedDescription)"
                        return
                    }

                guard let data = pedometerData else { return }

                // Update step count
                self?.todaySteps = data.numberOfSteps.intValue

                // Update distance
                if let distance = data.distance {
                    self?.todayDistanceInMeters = distance.doubleValue
                    self?.todayDistance = distance.doubleValue * (self?.distanceUnit.conversionFactor ?? 0.000621371)
                }

                // Update floors
                if let floorsAscended = data.floorsAscended {
                    self?.todayFloorsAscended = floorsAscended.intValue
                }
                if let floorsDescended = data.floorsDescended {
                    self?.todayFloorsDescended = floorsDescended.intValue
                }

                // Update pace and cadence
                self?.currentPace = data.currentPace?.doubleValue
                self?.currentCadence = data.currentCadence?.doubleValue

                    self?.lastUpdateTime = Date()
                    self?.errorMessage = nil
                }
            }
        }
    }

    private func startActivityUpdates() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }

        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }

            self?.isStationary = activity.stationary
            self?.isWalking = activity.walking
            self?.isRunning = activity.running

            // Update current activity string
            if activity.running {
                self?.currentActivity = "Running"
            } else if activity.walking {
                self?.currentActivity = "Walking"
            } else if activity.cycling {
                self?.currentActivity = "Cycling"
            } else if activity.automotive {
                self?.currentActivity = "Driving"
            } else if activity.stationary {
                self?.currentActivity = "Stationary"
            } else {
                self?.currentActivity = "Unknown"
            }
        }
    }

    // MARK: - Historical Queries

    func queryTodaysSteps() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        pedometer.queryPedometerData(from: startOfDay, to: now) { [weak self] data, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch today's steps: \(error.localizedDescription)"
                    return
                }

                guard let data = data else { return }

                self?.todaySteps = data.numberOfSteps.intValue

                if let distance = data.distance {
                    self?.todayDistance = distance.doubleValue * 0.000621371 // meters to miles
                }

                self?.errorMessage = nil
            }
        }
    }

    func queryHourlySteps() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)

        var hourlyData = Array(repeating: 0, count: 24)
        let group = DispatchGroup()

        for hour in 0...currentHour {
            guard let hourStart = calendar.date(byAdding: .hour, value: hour, to: startOfDay),
                  let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) else {
                continue
            }

            group.enter()

            pedometer.queryPedometerData(from: hourStart, to: min(hourEnd, now)) { data, error in
                defer { group.leave() }

                if let data = data {
                    hourlyData[hour] = data.numberOfSteps.intValue
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.hourlySteps = hourlyData
        }
    }

    func querySteps(from startDate: Date, to endDate: Date, completion: @escaping (Int?, Error?) -> Void) {
        pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                let steps = data?.numberOfSteps.intValue ?? 0
                completion(steps, nil)
            }
        }
    }

    func queryWeeklySteps(completion: @escaping ([Int]) -> Void) {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [Int] = []
        let group = DispatchGroup()

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            group.enter()

            querySteps(from: startOfDay, to: min(endOfDay, Date())) { steps, error in
                weeklyData.append(steps ?? 0)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(weeklyData.reversed())
        }
    }

    // MARK: - Timer for Regular Updates

    private func setupHourlyTimer() {
        updateTimer?.invalidate()

        // Update every 15 minutes instead of 5 to reduce load
        updateTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .background).async {
                self?.queryTodaysSteps()
                self?.queryHourlySteps()
            }
        }
    }

    // MARK: - Helper Methods

    func formattedDistance() -> String {
        return String(format: "%.1f %@", todayDistance, distanceUnit.rawValue)
    }

    func formattedDistanceWithUnit() -> String {
        let unitLabel = distanceUnit == .miles ? "miles" : "kilometers"
        return String(format: "%.1f %@", todayDistance, unitLabel)
    }

    func formattedPace() -> String {
        guard let pace = currentPace else { return "--" }

        if distanceUnit == .miles {
            let milesPerHour = pace * 2.23694 // meters/sec to mph
            return String(format: "%.1f mph", milesPerHour)
        } else {
            let kmPerHour = pace * 3.6 // meters/sec to km/h
            return String(format: "%.1f km/h", kmPerHour)
        }
    }

    func estimatedCaloriesBurned() -> Int {
        // Rough estimate: 0.04 calories per step
        return Int(Double(todaySteps) * 0.04)
    }

    func stepGoalProgress(goal: Int = 10000) -> Double {
        return min(Double(todaySteps) / Double(goal), 1.0)
    }

    func getActivityLevel() -> String {
        if todaySteps < 3000 {
            return "Sedentary"
        } else if todaySteps < 7000 {
            return "Lightly Active"
        } else if todaySteps < 10000 {
            return "Active"
        } else {
            return "Very Active"
        }
    }
}