import SwiftUI

struct SimpleGoalsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var stepGoalText = ""
    @State private var calorieGoalText = ""
    @State private var waterGoalText = ""
    @State private var weightGoalText = ""

    // Load current goals from UserDefaults
    private var currentStepGoal: Int {
        UserDefaults.standard.integer(forKey: "dailyStepGoal") > 0 ?
        UserDefaults.standard.integer(forKey: "dailyStepGoal") : 8000
    }

    private var currentCalorieGoal: Int {
        UserDefaults.standard.integer(forKey: "dailyCalorieGoal") > 0 ?
        UserDefaults.standard.integer(forKey: "dailyCalorieGoal") : 2000
    }

    private var currentWaterGoal: Int {
        UserDefaults.standard.integer(forKey: "dailyWaterGoal") > 0 ?
        UserDefaults.standard.integer(forKey: "dailyWaterGoal") : 8
    }

    private var currentWeightGoal: Double {
        UserDefaults.standard.double(forKey: "weightGoal")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Daily Goals") {
                    HStack {
                        Label("Steps", systemImage: "figure.walk")
                            .frame(width: 120, alignment: .leading)
                        TextField("Step Goal", text: $stepGoalText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("steps")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Calories", systemImage: "flame")
                            .frame(width: 120, alignment: .leading)
                        TextField("Calorie Goal", text: $calorieGoalText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("cal")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Water", systemImage: "drop")
                            .frame(width: 120, alignment: .leading)
                        TextField("Water Goal", text: $waterGoalText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("glasses")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Target Weight") {
                    HStack {
                        Label("Target", systemImage: "scalemass")
                            .frame(width: 120, alignment: .leading)
                        TextField("Target Weight", text: $weightGoalText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Text("These are simple daily goals to help track your progress. You can update them anytime.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Set Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            // Load current goals
            stepGoalText = String(currentStepGoal)
            calorieGoalText = String(currentCalorieGoal)
            waterGoalText = String(currentWaterGoal)
            if currentWeightGoal > 0 {
                weightGoalText = String(format: "%.1f", currentWeightGoal)
            }
        }
    }

    private func saveGoals() {
        // Save step goal
        if let stepGoal = Int(stepGoalText), stepGoal > 0 {
            UserDefaults.standard.set(stepGoal, forKey: "dailyStepGoal")
            print("Saved step goal: \(stepGoal)")
        }

        // Save calorie goal
        if let calorieGoal = Int(calorieGoalText), calorieGoal > 0 {
            UserDefaults.standard.set(calorieGoal, forKey: "dailyCalorieGoal")
            print("Saved calorie goal: \(calorieGoal)")
        }

        // Save water goal
        if let waterGoal = Int(waterGoalText), waterGoal > 0 {
            UserDefaults.standard.set(waterGoal, forKey: "dailyWaterGoal")
            print("Saved water goal: \(waterGoal)")
        }

        // Save weight goal
        if let weightGoal = Double(weightGoalText), weightGoal > 0 {
            UserDefaults.standard.set(weightGoal, forKey: "weightGoal")
            print("Saved weight goal: \(weightGoal)")
        }

        // Force synchronization
        UserDefaults.standard.synchronize()

        // Post notification to update dashboard
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
    }
}