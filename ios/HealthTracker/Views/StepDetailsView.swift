import SwiftUI
import Charts
import Combine
import CoreMotion

struct StepDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StepDetailsViewModel()
    @State private var selectedTab = 0
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Card
                        summaryCard

                        // Chart based on selected tab
                        if selectedTab == 0 {
                            hourlyStepsChart
                        } else if selectedTab == 1 {
                            weeklyStepsChart
                        } else {
                            monthlyStepsChart
                        }

                        // Detailed breakdown
                        detailedBreakdown
                    }
                    .padding()
                }
            }
            .navigationTitle("Step Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.fetchStepData()
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Steps")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("\(viewModel.todaySteps)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trendIcon)
                            .font(.caption)
                        Text(viewModel.trendText)
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.trendColor)
                }

                Spacer()

                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: min(Double(viewModel.todaySteps) / Double(viewModel.stepGoal), 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int((Double(viewModel.todaySteps) / Double(viewModel.stepGoal)) * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("of goal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // Quick Stats
            HStack {
                VStack(spacing: 4) {
                    Text("Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.averageSteps)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f mi", viewModel.distanceInMiles))
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("Active Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.activeTime)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var hourlyStepsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Breakdown")
                .font(.headline)
                .foregroundColor(.deepCharcoal)

            Chart(viewModel.hourlySteps) { dataPoint in
                BarMark(
                    x: .value("Hour", dataPoint.date, unit: .hour),
                    y: .value("Steps", dataPoint.value)
                )
                .foregroundStyle(
                    dataPoint.isCurrentHour ?
                    Color.green :
                    Color.green.opacity(0.6)
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour())
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var weeklyStepsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Trend")
                .font(.headline)
                .foregroundColor(.deepCharcoal)

            Chart(viewModel.weeklySteps) { dataPoint in
                BarMark(
                    x: .value("Day", dataPoint.date, unit: .day),
                    y: .value("Steps", dataPoint.value)
                )
                .foregroundStyle(
                    Calendar.current.isDateInToday(dataPoint.date) ?
                    Color.green :
                    Color.green.opacity(0.6)
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
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var monthlyStepsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.deepCharcoal)

            Chart(viewModel.monthlySteps) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Steps", dataPoint.value)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Steps", dataPoint.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.green.opacity(0.05)],
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
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var detailedBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Breakdown")
                .font(.headline)
                .foregroundColor(.deepCharcoal)

            if selectedTab == 0 {
                // Hourly breakdown list
                ForEach(viewModel.hourlyBreakdown) { item in
                    HStack {
                        Text(item.timeRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(item.steps) steps")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        // Activity indicator
                        Circle()
                            .fill(item.activityColor)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            } else {
                // Daily breakdown for week/month view
                ForEach(viewModel.dailyBreakdown) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.date, format: .dateTime.weekday(.wide))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(item.date, format: .dateTime.month().day())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(item.steps)")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 2) {
                                if item.steps >= 10000 {
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.yellow)
                                }
                                Text("steps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - View Model
class StepDetailsViewModel: ObservableObject {
    @Published var todaySteps = 0
    @Published var stepGoal = 10000
    @Published var averageSteps = 0
    @Published var distanceInMiles = 0.0
    @Published var activeTime = "--"

    @Published var hourlySteps: [StepDetailDataPoint] = []
    @Published var weeklySteps: [StepDetailDataPoint] = []
    @Published var monthlySteps: [StepDetailDataPoint] = []

    @Published var hourlyBreakdown: [HourlyBreakdownItem] = []
    @Published var dailyBreakdown: [DailyBreakdownItem] = []

    private let stepCounter = StepCounterService.shared
    private var cancellables = Set<AnyCancellable>()

    var trendIcon: String {
        todaySteps > averageSteps ? "arrow.up.right" : "arrow.down.right"
    }

    var trendText: String {
        let difference = abs(todaySteps - averageSteps)
        let percentage = Int((Double(difference) / Double(averageSteps)) * 100)
        return todaySteps > averageSteps ?
            "+\(percentage)% vs average" :
            "-\(percentage)% vs average"
    }

    var trendColor: Color {
        todaySteps > averageSteps ? .green : .orange
    }

    init() {
        setupBindings()
        fetchStepData()
    }

    private func setupBindings() {
        // Bind to step counter service
        stepCounter.$todaySteps
            .sink { [weak self] steps in
                self?.todaySteps = steps
            }
            .store(in: &cancellables)

        stepCounter.$todayDistance
            .sink { [weak self] distance in
                self?.distanceInMiles = distance
            }
            .store(in: &cancellables)

        stepCounter.$hourlySteps
            .sink { [weak self] hourlyData in
                self?.updateHourlySteps(hourlyData)
            }
            .store(in: &cancellables)

        // Calculate active time based on steps
        stepCounter.$todaySteps
            .sink { [weak self] steps in
                self?.activeTime = self?.calculateActiveTime(steps: steps) ?? "--"
            }
            .store(in: &cancellables)
    }

    private func calculateActiveTime(steps: Int) -> String {
        // Estimate: 100 steps per minute while walking
        let minutes = steps / 100
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    private func updateHourlySteps(_ hourlyData: [Int]) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)

        hourlySteps = hourlyData.enumerated().map { index, stepCount in
            let date = calendar.date(byAdding: .hour, value: index, to: startOfDay)!
            let isCurrentHour = index == currentHour
            return StepDetailDataPoint(date: date, value: Double(stepCount), isCurrentHour: isCurrentHour)
        }
    }

    func fetchStepData() {
        // Start real-time step counting
        stepCounter.startStepCounting()

        // Fetch historical data
        fetchHourlySteps()
        fetchWeeklySteps()
        fetchMonthlySteps()
        generateHourlyBreakdown()
        generateDailyBreakdown()

        // Calculate average
        calculateAverageSteps()
    }

    private func calculateAverageSteps() {
        stepCounter.queryWeeklySteps { [weak self] weeklyData in
            let total = weeklyData.reduce(0, +)
            self?.averageSteps = weeklyData.isEmpty ? 0 : total / weeklyData.count
        }
    }

    private func fetchHourlySteps() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)

        hourlySteps = (0..<24).map { hour in
            let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay)!
            let isCurrentHour = hour == currentHour
            let isFuture = hour > currentHour

            // TODO: Replace with real HealthKit data
            // Mock data temporarily disabled - showing zeros
            let steps: Double = 0
            /*
            let steps: Double = {
                if isFuture {
                    return 0
                } else if hour < 6 {
                    return Double.random(in: 0...50)
                } else if hour < 9 {
                    return Double.random(in: 200...500)
                } else if hour < 12 {
                    return Double.random(in: 300...800)
                } else if hour < 14 {
                    return Double.random(in: 400...900)
                } else if hour < 18 {
                    return Double.random(in: 300...700)
                } else if hour < 21 {
                    return Double.random(in: 200...600)
                } else {
                    return Double.random(in: 50...200)
                }
            }()
            */

            return StepDetailDataPoint(date: date, value: steps, isCurrentHour: isCurrentHour)
        }
    }

    private func fetchWeeklySteps() {
        let calendar = Calendar.current

        weeklySteps = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            // TODO: Replace with real HealthKit data
            // let steps = Double([8547, 9200, 7500, 10200, 8800, 9100, 7900][dayOffset % 7])
            let steps = 0.0 // Mock data disabled
            return StepDetailDataPoint(date: date, value: steps, isCurrentHour: false)
        }.reversed()
    }

    private func fetchMonthlySteps() {
        let calendar = Calendar.current

        monthlySteps = (0..<30).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            // TODO: Replace with real HealthKit data
            // let steps = Double.random(in: 6000...12000)
            let steps = 0.0 // Mock data disabled
            return StepDetailDataPoint(date: date, value: steps, isCurrentHour: false)
        }.reversed()
    }

    private func generateHourlyBreakdown() {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"

        hourlyBreakdown = hourlySteps.enumerated().compactMap { index, dataPoint in
            guard dataPoint.value > 0 else { return nil }

            let endHour = Calendar.current.date(byAdding: .hour, value: 1, to: dataPoint.date)!
            let timeRange = "\(formatter.string(from: dataPoint.date)) - \(formatter.string(from: endHour))"

            let activityColor: Color = {
                if dataPoint.value < 100 { return .gray }
                else if dataPoint.value < 300 { return .orange }
                else if dataPoint.value < 500 { return .yellow }
                else { return .green }
            }()

            return HourlyBreakdownItem(
                id: UUID(),
                timeRange: timeRange,
                steps: Int(dataPoint.value),
                activityColor: activityColor
            )
        }
    }

    private func generateDailyBreakdown() {
        let calendar = Calendar.current

        if calendar.component(.weekday, from: Date()) == 1 {
            // If today is Sunday, show last 7 days
            dailyBreakdown = weeklySteps.map { dataPoint in
                DailyBreakdownItem(
                    id: UUID(),
                    date: dataPoint.date,
                    steps: Int(dataPoint.value)
                )
            }
        } else {
            // Show current week or month based on selected tab
            dailyBreakdown = weeklySteps.suffix(7).map { dataPoint in
                DailyBreakdownItem(
                    id: UUID(),
                    date: dataPoint.date,
                    steps: Int(dataPoint.value)
                )
            }
        }
    }
}

// MARK: - Data Models
struct StepDetailDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isCurrentHour: Bool
}

struct HourlyBreakdownItem: Identifiable {
    let id: UUID
    let timeRange: String
    let steps: Int
    let activityColor: Color
}

struct DailyBreakdownItem: Identifiable {
    let id: UUID
    let date: Date
    let steps: Int
}