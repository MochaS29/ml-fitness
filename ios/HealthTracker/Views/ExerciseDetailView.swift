import SwiftUI
import Charts
import CoreData

struct ExerciseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var selectedTab = 0
    @State private var showingAddExercise = false

    // Fetch all exercise entries
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        animation: .default)
    private var allExercises: FetchedResults<ExerciseEntry>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        chartSection
                        breakdownSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseEntrySheet()
            }
            .fullScreenCover(isPresented: $achievementManager.showingCelebration) {
                if let celebration = achievementManager.currentCelebration {
                    CelebrationView(
                        achievement: CelebrationAchievement.from(celebration),
                        isPresented: $achievementManager.showingCelebration
                    )
                    .presentationBackground(.clear)
                }
            }
        }
    }

    // MARK: - Data Helpers

    private var todayExercises: [ExerciseEntry] {
        let calendar = Calendar.current
        return allExercises.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDateInToday(timestamp)
        }
    }

    private func exercisesForDay(_ date: Date) -> [ExerciseEntry] {
        let calendar = Calendar.current
        return allExercises.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: date)
        }
    }

    private func exercisesInRange(days: Int) -> [ExerciseEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: Date()))!
        return allExercises.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= startDate
        }
    }

    private var relevantExercises: [ExerciseEntry] {
        switch selectedTab {
        case 0: return todayExercises
        case 1: return exercisesInRange(days: 7)
        case 2: return exercisesInRange(days: 30)
        default: return todayExercises
        }
    }

    private var totalMinutes: Int {
        relevantExercises.reduce(0) { $0 + Int($1.duration) }
    }

    private var totalCalories: Int {
        Int(relevantExercises.reduce(0) { $0 + $1.caloriesBurned })
    }

    private var totalSessions: Int {
        relevantExercises.count
    }

    private var averageMinutesPerDay: Int {
        let days: Int
        switch selectedTab {
        case 0: days = 1
        case 1: days = 7
        case 2: days = 30
        default: days = 1
        }
        return days > 0 ? totalMinutes / days : 0
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedTab == 0 ? "Today's Exercise" : selectedTab == 1 ? "This Week" : "This Month")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("\(totalMinutes) min")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)

                    if selectedTab > 0 {
                        Text("Avg \(averageMinutesPerDay) min/day")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: min(Double(selectedTab == 0 ? totalMinutes : averageMinutesPerDay) / 30.0, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(min(Int(Double(selectedTab == 0 ? totalMinutes : averageMinutesPerDay) / 30.0 * 100), 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("of 30m")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            HStack {
                VStack(spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalCalories)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalSessions)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("Avg/Session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalSessions > 0 ? totalMinutes / totalSessions : 0) min")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        Group {
            if selectedTab == 0 {
                todayChart
            } else if selectedTab == 1 {
                weeklyChart
            } else {
                monthlyChart
            }
        }
    }

    private var todayChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Activities")
                .font(.headline)
                .foregroundColor(.primary)

            if todayExercises.isEmpty {
                emptyChartView
            } else {
                Chart(todayExercises) { entry in
                    BarMark(
                        x: .value("Exercise", entry.name ?? "Unknown"),
                        y: .value("Minutes", entry.duration)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange.opacity(0.8), .yellow.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Trend")
                .font(.headline)
                .foregroundColor(.primary)

            Chart(weeklyChartData()) { dataPoint in
                BarMark(
                    x: .value("Day", dataPoint.date, unit: .day),
                    y: .value("Minutes", dataPoint.value)
                )
                .foregroundStyle(
                    Calendar.current.isDateInToday(dataPoint.date) ?
                    Color.orange :
                    Color.orange.opacity(0.6)
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.weekday(.abbreviated))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.primary)

            Chart(monthlyChartData()) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Minutes", dataPoint.value)
                )
                .foregroundStyle(Color.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Minutes", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            let day = Calendar.current.component(.day, from: date)
                            if day == 1 || day % 5 == 0 {
                                Text("\(day)")
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text("No exercises logged")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Tap + to add an exercise")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }

    // MARK: - Chart Data Helpers

    private func weeklyChartData() -> [ExerciseChartDataPoint] {
        let calendar = Calendar.current
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let minutes = exercisesForDay(dayStart).reduce(0) { $0 + Int($1.duration) }
            return ExerciseChartDataPoint(date: dayStart, value: Double(minutes))
        }
    }

    private func monthlyChartData() -> [ExerciseChartDataPoint] {
        let calendar = Calendar.current
        return (0..<30).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -(29 - dayOffset), to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let minutes = exercisesForDay(dayStart).reduce(0) { $0 + Int($1.duration) }
            return ExerciseChartDataPoint(date: dayStart, value: Double(minutes))
        }
    }

    // MARK: - Breakdown Section

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Breakdown")
                .font(.headline)
                .foregroundColor(.primary)

            if relevantExercises.isEmpty {
                Text("No exercises in this period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if selectedTab == 0 {
                // Today: show individual exercises
                ForEach(todayExercises) { entry in
                    exerciseBreakdownRow(entry)
                }
            } else {
                // Week/Month: show daily summaries
                let data = selectedTab == 1 ? weeklyChartData() : monthlyChartData()
                ForEach(data.filter { $0.value > 0 }) { dataPoint in
                    dailySummaryRow(dataPoint)
                }
            }

            // Category breakdown
            if !relevantExercises.isEmpty {
                categoryBreakdown
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private func exerciseBreakdownRow(_ entry: ExerciseEntry) -> some View {
        HStack {
            Image(systemName: exerciseIcon(for: entry.type ?? ""))
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let timestamp = entry.timestamp {
                    Text(timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.duration) min")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(Int(entry.caloriesBurned)) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private func dailySummaryRow(_ dataPoint: ExerciseChartDataPoint) -> some View {
        let dayExercises = exercisesForDay(dataPoint.date)
        let calories = Int(dayExercises.reduce(0) { $0 + $1.caloriesBurned })
        let sessions = dayExercises.count

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dataPoint.date, format: .dateTime.weekday(.wide))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(dataPoint.date, format: .dateTime.month().day())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(dataPoint.value)) min")
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Text("\(calories) cal")
                    Text("\(sessions) session\(sessions == 1 ? "" : "s")")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()

            Text("By Category")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            let categories = Dictionary(grouping: relevantExercises) { $0.type ?? "Other" }
            ForEach(categories.sorted(by: { $0.value.count > $1.value.count }), id: \.key) { category, entries in
                let minutes = entries.reduce(0) { $0 + Int($1.duration) }
                let calories = Int(entries.reduce(0) { $0 + $1.caloriesBurned })

                HStack {
                    Image(systemName: exerciseIcon(for: category))
                        .foregroundColor(.orange)
                        .frame(width: 24)

                    Text(category)
                        .font(.subheadline)

                    Spacer()

                    Text("\(minutes) min")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("(\(calories) cal)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func exerciseIcon(for type: String) -> String {
        switch type.lowercased() {
        case "cardio": return "heart.fill"
        case "strength", "strength training": return "dumbbell.fill"
        case "flexibility": return "figure.yoga"
        case "sports": return "sportscourt.fill"
        default: return "figure.run"
        }
    }
}

// MARK: - Data Model

struct ExerciseChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
