import SwiftUI
import Charts

struct StepGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("dailyStepGoal") private var dailyStepGoal = 10000

    @State private var tempGoal: Double = 10000
    @State private var viewMode: ViewMode = .today
    @State private var isEditingGoal = false

    @State private var todaySteps = 0
    @State private var hourlySteps: [Int] = Array(repeating: 0, count: 24)
    @State private var weeklyData: [(label: String, steps: Int, isToday: Bool)] = []

    enum ViewMode: String, CaseIterable {
        case today = "Today"
        case hourly = "Hourly"
        case weekly = "Weekly"
    }

    var progressPercentage: Double {
        Double(todaySteps) / Double(dailyStepGoal)
    }

    var stepsRemaining: Int {
        max(0, dailyStepGoal - todaySteps)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Circle
                    progressCircle
                        .padding(.top)

                    // Quick Stats
                    quickStats

                    // View Mode Selector
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Content based on view mode
                    Group {
                        switch viewMode {
                        case .today:
                            todayView
                        case .hourly:
                            hourlyView
                        case .weekly:
                            weeklyView
                        }
                    }

                    // Goal Settings
                    goalSettingsCard
                }
                .padding(.bottom)
            }
            .navigationTitle("Step Goal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadData() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditingGoal ? "Save" : "Edit") {
                        if isEditingGoal {
                            saveGoal()
                        }
                        isEditingGoal.toggle()
                    }
                }
            }
        }
    }

    private var progressCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)

            // Progress circle
            Circle()
                .trim(from: 0, to: min(progressPercentage, 1.0))
                .stroke(
                    progressPercentage >= 1.0 ? Color.green : Color.blue,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progressPercentage)

            // Center text
            VStack(spacing: 8) {
                Text("\(todaySteps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("of \(dailyStepGoal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(Int(progressPercentage * 100))%")
                    .font(.headline)
                    .foregroundColor(progressPercentage >= 1.0 ? .green : .blue)
            }
        }
    }

    private var quickStats: some View {
        HStack(spacing: 20) {
            StepStatCard(
                title: "Remaining",
                value: "\(stepsRemaining)",
                icon: "target",
                color: .orange
            )

            StepStatCard(
                title: "Average/Hour",
                value: "\(todaySteps / max(1, Calendar.current.component(.hour, from: Date())))",
                icon: "clock",
                color: .purple
            )

            StepStatCard(
                title: "Distance",
                value: String(format: "%.1f mi", Double(todaySteps) * 0.0005),
                icon: "location",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private var todayView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Progress")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "sunrise")
                        .foregroundColor(.orange)
                    Text("Morning")
                    Spacer()
                    Text("\(hourlySteps[6...11].reduce(0, +)) steps")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "sun.max")
                        .foregroundColor(.yellow)
                    Text("Afternoon")
                    Spacer()
                    Text("\(hourlySteps[12...17].reduce(0, +)) steps")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "moon")
                        .foregroundColor(.indigo)
                    Text("Evening")
                    Spacer()
                    Text("\(hourlySteps[18...23].reduce(0, +)) steps")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private var hourlyView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Hourly Breakdown")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(Array(hourlySteps.enumerated()), id: \.offset) { hour, steps in
                    BarMark(
                        x: .value("Hour", hour),
                        y: .value("Steps", steps)
                    )
                    .foregroundStyle(
                        steps > 0 ? Color.blue : Color.gray.opacity(0.3)
                    )
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text("\(hour):00")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }

    private var weeklyView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Trend")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(weeklyData, id: \.label) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Steps", item.steps)
                    )
                    .foregroundStyle(
                        item.isToday ? Color.blue :
                        (item.steps >= dailyStepGoal ? Color.green : Color.green.opacity(0.5))
                    )
                }
                RuleMark(y: .value("Goal", dailyStepGoal))
                    .foregroundStyle(Color.red.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
            }
            .frame(height: 200)
            .padding(.horizontal)

            HStack(spacing: 16) {
                Label("Today", systemImage: "circle.fill").foregroundColor(.blue)
                Label("Goal met", systemImage: "circle.fill").foregroundColor(.green)
                Label("Below goal", systemImage: "circle.fill").foregroundColor(.green.opacity(0.5))
            }
            .font(.caption)
            .padding(.horizontal)
        }
    }

    private var goalSettingsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Daily Goal")
                    .font(.headline)

                Spacer()

                if isEditingGoal {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }

            if isEditingGoal {
                VStack(spacing: 15) {
                    HStack {
                        Text("\(Int(tempGoal)) steps")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }

                    Slider(value: $tempGoal, in: 1000...30000, step: 500)
                        .accentColor(.blue)

                    HStack {
                        Text("1,000")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("30,000")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Quick select buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach([5000, 8000, 10000, 12000, 15000], id: \.self) { goal in
                                Button(action: { tempGoal = Double(goal) }) {
                                    Text("\(goal / 1000)k")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            tempGoal == Double(goal) ? Color.blue : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            tempGoal == Double(goal) ? .white : .primary
                                        )
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dailyStepGoal) steps")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Tap Edit to change")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "figure.walk")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func loadData() {
        // Today's steps
        HealthKitManager.shared.fetchTodaySteps { steps in
            todaySteps = Int(steps ?? 0)
        }

        // Hourly steps
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        HealthKitManager.shared.fetchHourlySteps(from: startOfDay, to: Date()) { hkHourly in
            hourlySteps = (0..<24).map { i in i < hkHourly.count ? Int(hkHourly[i]) : 0 }
        }

        // Rolling 7 days ending today — today is rightmost
        let today = calendar.startOfDay(for: Date())
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE" // Mon, Tue, Wed etc.

        let group = DispatchGroup()
        var results: [(index: Int, label: String, steps: Int, isToday: Bool)] = []

        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today)!
            let end  = calendar.date(byAdding: .day, value: 1, to: date)!
            let label = dayFormatter.string(from: date)
            let isToday = calendar.isDateInToday(date)
            group.enter()
            HealthKitManager.shared.fetchSteps(from: date, to: min(end, Date())) { steps in
                results.append((index: offset, label: label, steps: Int(steps), isToday: isToday))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            weeklyData = results.sorted { $0.index < $1.index }
                .map { (label: $0.label, steps: $0.steps, isToday: $0.isToday) }
        }
    }

    private func saveGoal() {
        dailyStepGoal = Int(tempGoal)
        // Here you would also save to Core Data or UserDefaults
    }
}

struct StepStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StepGoalView_Previews: PreviewProvider {
    static var previews: some View {
        StepGoalView()
    }
}