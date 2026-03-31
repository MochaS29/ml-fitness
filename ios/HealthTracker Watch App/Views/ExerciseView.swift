import SwiftUI
import WatchKit
import WatchConnectivity

struct ExerciseView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var selectedActivity = "Walking"
    @State private var heartRate: Int = 0

    let activities = ["Walking", "Running", "Cycling", "Weights", "Yoga", "Other"]

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var estimatedCalories: Int {
        let caloriesPerMinute: Double
        switch selectedActivity {
        case "Running": caloriesPerMinute = 10
        case "Cycling": caloriesPerMinute = 8
        case "Walking": caloriesPerMinute = 4
        case "Weights": caloriesPerMinute = 6
        case "Yoga": caloriesPerMinute = 3
        default: caloriesPerMinute = 5
        }
        return Int((elapsedTime / 60) * caloriesPerMinute)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Exercise")
                    .font(.title3)
                    .bold()

                Picker("Activity", selection: $selectedActivity) {
                    ForEach(activities, id: \.self) { activity in
                        Text(activity).tag(activity)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 60)

                VStack(spacing: 8) {
                    Text(formattedTime)
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                        .monospacedDigit()

                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(estimatedCalories)")
                                .font(.footnote)
                                .bold()
                            Text("cal")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(heartRate)")
                                .font(.footnote)
                                .bold()
                            Text("bpm")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 10)

                HStack(spacing: 15) {
                    Button(action: toggleTimer) {
                        Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .frame(width: 60, height: 60)
                            .background(isTimerRunning ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    if !isTimerRunning && elapsedTime > 0 {
                        Button(action: saveWorkout) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                if !isTimerRunning && elapsedTime > 0 {
                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            simulateHeartRate()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func toggleTimer() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            if Int.random(in: 0...10) < 3 {
                simulateHeartRate()
            }
        }
        WKInterfaceDevice.current().play(.start)
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        WKInterfaceDevice.current().play(.stop)
    }

    private func resetTimer() {
        elapsedTime = 0
        heartRate = 0
    }

    private func saveWorkout() {
        let workout: [String: Any] = [
            "type": "exercise",
            "activity": selectedActivity,
            "duration": elapsedTime,
            "calories": estimatedCalories,
            "heartRate": heartRate,
            "timestamp": Date().timeIntervalSince1970
        ]

        connectivity.session.sendMessage(workout, replyHandler: nil) { error in
            print("Error saving workout: \(error)")
        }

        connectivity.currentCalories += Double(estimatedCalories)

        WKInterfaceDevice.current().play(.success)
        resetTimer()
    }

    private func simulateHeartRate() {
        let baseRate: Int
        switch selectedActivity {
        case "Running": baseRate = 140
        case "Cycling": baseRate = 125
        case "Walking": baseRate = 90
        case "Weights": baseRate = 110
        case "Yoga": baseRate = 75
        default: baseRate = 100
        }

        if isTimerRunning {
            heartRate = baseRate + Int.random(in: -10...15)
        } else {
            heartRate = 72 + Int.random(in: -5...5)
        }
    }
}

extension WatchConnectivityManager {
    var session: WCSession {
        WCSession.default
    }
}

#Preview {
    ExerciseView()
        .environmentObject(WatchConnectivityManager())
}