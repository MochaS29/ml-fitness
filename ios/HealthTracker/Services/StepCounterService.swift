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
    @Published var todayDistance: Double = 0.0 // in meters
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

    private init() {
        checkAvailability()
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

        // Start real-time pedometer updates
        startPedometerUpdates()

        // Start activity monitoring
        startActivityUpdates()

        // Query today's accumulated steps
        queryTodaysSteps()

        // Set up hourly update timer
        setupHourlyTimer()

        // Query hourly breakdown
        queryHourlySteps()
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
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Step counting error: \(error.localizedDescription)"
                    return
                }

                guard let data = pedometerData else { return }

                // Update step count
                self?.todaySteps = data.numberOfSteps.intValue

                // Update distance (convert to miles for US users)
                if let distance = data.distance {
                    self?.todayDistance = distance.doubleValue * 0.000621371 // meters to miles
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

        // Update every 5 minutes
        updateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.queryTodaysSteps()
            self?.queryHourlySteps()
        }
    }

    // MARK: - Helper Methods

    func formattedDistance() -> String {
        return String(format: "%.1f mi", todayDistance)
    }

    func formattedPace() -> String {
        guard let pace = currentPace else { return "--" }
        let milesPerHour = pace * 2.23694 // meters/sec to mph
        return String(format: "%.1f mph", milesPerHour)
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