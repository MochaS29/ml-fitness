import SwiftUI
import Charts
import CoreData

struct DashboardView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTimeRange = TimeRange.today
    @State private var nutrientAnalyses: [NutrientAnalysis] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome card
                    WelcomeCard(profile: profileManager.currentProfile)
                    
                    // Time range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary card
                    SummaryCard(timeRange: selectedTimeRange)

                    // Step Chart
                    StepChartCard(timeRange: selectedTimeRange)

                    // Nutrient status
                    NutrientStatusCard(analyses: nutrientAnalyses)
                    
                    // Life stage alerts
                    let alerts = profileManager.checkForLifeStageTransitions()
                    if !alerts.isEmpty {
                        LifeStageAlertsCard(alerts: alerts)
                    }
                    
                    // Recent activities
                    RecentActivitiesCard()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                loadNutrientAnalyses()
            }
            .onChange(of: selectedTimeRange) {
                loadNutrientAnalyses()
            }
        }
    }
    
    func loadNutrientAnalyses() {
        // This would load actual data from Core Data
        // For now, using sample data
        guard let profile = profileManager.currentProfile else { return }
        
        let calculator = RDACalculator()
        let sampleIntakes = [
            NutrientIntake(nutrientId: "vitamin_c", amount: 209, unit: .mg),
            NutrientIntake(nutrientId: "iron", amount: 18.1, unit: .mg),
            NutrientIntake(nutrientId: "calcium", amount: 205, unit: .mg),
            NutrientIntake(nutrientId: "vitamin_d", amount: 300, unit: .iu),
            NutrientIntake(nutrientId: "folate", amount: 665, unit: .mcg)
        ]
        
        nutrientAnalyses = calculator.analyzeIntake(sampleIntakes, for: profile)
    }
}

struct WelcomeCard: View {
    let profile: UserProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome back, \(profile?.name ?? "User")!")
                .font(.title2)
                .fontWeight(.bold)
            
            if let profile = profile {
                HStack {
                    Label("\(profile.age) years", systemImage: "person")
                    Label(profile.gender.rawValue, systemImage: "figure.stand")
                    if profile.isPregnant {
                        Label("Pregnant", systemImage: "heart.fill")
                            .foregroundColor(.pink)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct SummaryCard: View {
    let timeRange: TimeRange
    @StateObject private var fastingManager = FastingManager()
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var totalCalories: Double = 0
    @State private var totalCaloriesBurned: Double = 0
    @State private var totalSteps: Int = 0
    @State private var totalWater: Double = 0
    
    var fastingStatus: String {
        if let session = fastingManager.currentSession {
            let hours = Int(session.currentDuration) / 3600
            let minutes = (Int(session.currentDuration) % 3600) / 60
            return "\(hours)h \(minutes)m"
        } else {
            return "Not fasting"
        }
    }
    
    var fastingColor: Color {
        fastingManager.currentSession != nil ? .wellnessGreen : .secondary
    }
    
    var summaryTitle: String {
        switch timeRange {
        case .today:
            return "Today's Summary"
        case .week:
            return "Weekly Summary"
        case .month:
            return "Monthly Summary"
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(summaryTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                DashboardSummaryMetric(
                    icon: "flame",
                    value: "\(Int(totalCalories))",
                    label: "Calories",
                    color: .orange
                )

                DashboardSummaryMetric(
                    icon: "flame.fill",
                    value: "\(Int(totalCaloriesBurned))",
                    label: "Burned",
                    color: .red
                )

                DashboardSummaryMetric(
                    icon: "drop.fill",
                    value: "\(Int(totalWater)) oz",
                    label: "Water",
                    color: .blue
                )

                DashboardSummaryMetric(
                    icon: "figure.walk",
                    value: "\(totalSteps)",
                    label: "Steps",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .onAppear {
            loadSummaryData()
        }
        .onChange(of: timeRange) {
            loadSummaryData()
        }
    }
    
    private func loadSummaryData() {
        // Refresh data in UnifiedDataManager
        dataManager.refreshAllData()

        // Use data from UnifiedDataManager based on time range
        switch timeRange {
        case .today:
            totalCalories = dataManager.todayCalories
            totalCaloriesBurned = dataManager.todayCaloriesBurned
            totalWater = dataManager.todayWater
            totalSteps = dataManager.todaySteps
        case .week, .month:
            // For week/month, fetch historical data
            fetchHistoricalData()
        }
    }

    private func fetchHistoricalData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date

        switch timeRange {
        case .today:
            return // Handled above
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        }

        // Use UnifiedDataManager's context for consistency
        let context = PersistenceController.shared.container.viewContext

        // Fetch historical data
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as CVarArg, endDate as CVarArg)

        let exerciseRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        exerciseRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as CVarArg, endDate as CVarArg)

        let waterRequest: NSFetchRequest<WaterEntry> = WaterEntry.fetchRequest()
        waterRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as CVarArg, endDate as CVarArg)

        do {
            let foodEntries = try context.fetch(foodRequest)
            totalCalories = foodEntries.reduce(0) { $0 + $1.calories }

            let exerciseEntries = try context.fetch(exerciseRequest)
            totalCaloriesBurned = exerciseEntries.reduce(0) { $0 + $1.caloriesBurned }

            let waterEntries = try context.fetch(waterRequest)
            totalWater = waterEntries.reduce(0) { sum, entry in
                let amount = entry.unit == "ml" ? entry.amount / 29.5735 : entry.amount
                return sum + amount
            }

            HealthKitManager.shared.fetchSteps(from: startDate, to: endDate) { steps in
                DispatchQueue.main.async {
                    self.totalSteps = Int(steps)
                }
            }
        } catch {
            print("Error fetching historical data: \(error)")
        }
    }
}

struct DashboardSummaryMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NutrientStatusCard: View {
    let analyses: [NutrientAnalysis]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Nutrient Status")
                .font(.headline)
            
            if analyses.isEmpty {
                Text("No supplement data yet")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(analyses, id: \.nutrientId) { analysis in
                    NutrientRow(analysis: analysis)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct NutrientRow: View {
    let analysis: NutrientAnalysis
    
    var statusColor: Color {
        switch analysis.status.color {
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        case "darkred": return Color(red: 0.5, green: 0, blue: 0)
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(analysis.nutrientName)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(analysis.percentageOfRDA))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(analysis.status.symbol)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: min(geometry.size.width * (analysis.percentageOfRDA / 100), geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            if let recommendation = analysis.recommendation {
                Text(recommendation)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
    }
}

struct LifeStageAlertsCard: View {
    let alerts: [LifeStageAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Life Stage Updates")
                .font(.headline)
            
            ForEach(alerts, id: \.message) { alert in
                HStack {
                    Image(systemName: alert.icon)
                        .foregroundColor(.accentColor)
                    
                    Text(alert.message)
                        .font(.subheadline)
                    
                    Spacer()
                }
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct RecentActivitiesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activities")
                .font(.headline)
            
            VStack(spacing: 10) {
                ActivityRow(
                    icon: "fork.knife",
                    title: "Breakfast",
                    subtitle: "Oatmeal with berries",
                    time: "8:30 AM",
                    color: .orange
                )
                
                ActivityRow(
                    icon: "pills",
                    title: "Supplements",
                    subtitle: "Multivitamin + Omega-3",
                    time: "9:00 AM",
                    color: .purple
                )
                
                ActivityRow(
                    icon: "figure.run",
                    title: "Morning Run",
                    subtitle: "5.2 km in 28 minutes",
                    time: "6:45 AM",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct StepChartCard: View {
    let timeRange: TimeRange
    @State private var stepData: [StepDataPoint] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Step Activity")
                .font(.headline)

            if stepData.isEmpty {
                // Placeholder when no data
                VStack {
                    Image(systemName: "figure.walk")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No step data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                Chart(stepData) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Steps", dataPoint.steps)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYAxisLabel("Steps", position: .leading)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatDateForChart(date))
                            }
                        }
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .onAppear {
            loadStepData()
        }
        .onChange(of: timeRange) {
            loadStepData()
        }
    }

    private func loadStepData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date
        let interval: Calendar.Component

        switch timeRange {
        case .today:
            // Hourly data for today
            startDate = calendar.startOfDay(for: endDate)
            interval = .hour

            // Generate hourly data points for today
            var hourlyData: [StepDataPoint] = []
            for hour in 0..<24 {
                if let hourDate = calendar.date(byAdding: .hour, value: hour, to: startDate),
                   hourDate <= endDate {
                    // For demo, generate some sample data
                    let steps = Int.random(in: 0...500)
                    hourlyData.append(StepDataPoint(date: hourDate, steps: steps))
                }
            }

            // Fetch actual data from HealthKit
            HealthKitManager.shared.fetchHourlySteps(from: startDate, to: endDate) { hourlySteps in
                DispatchQueue.main.async {
                    if !hourlySteps.isEmpty {
                        self.stepData = hourlySteps.enumerated().map { index, steps in
                            let date = calendar.date(byAdding: .hour, value: index, to: startDate) ?? startDate
                            return StepDataPoint(date: date, steps: Int(steps))
                        }
                    } else {
                        self.stepData = hourlyData
                    }
                }
            }

        case .week:
            // Daily data for past week
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
            interval = .day

            var dailyData: [StepDataPoint] = []
            for day in 0..<7 {
                if let dayDate = calendar.date(byAdding: .day, value: day, to: startDate) {
                    dailyData.append(StepDataPoint(date: dayDate, steps: 0))
                }
            }

            // Fetch actual data from HealthKit
            for (index, dataPoint) in dailyData.enumerated() {
                let dayStart = dataPoint.date
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

                HealthKitManager.shared.fetchSteps(from: dayStart, to: dayEnd) { steps in
                    DispatchQueue.main.async {
                        if index < self.stepData.count {
                            self.stepData[index].steps = Int(steps)
                        } else {
                            dailyData[index].steps = Int(steps)
                            self.stepData = dailyData
                        }
                    }
                }
            }

        case .month:
            // Weekly data for past month
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
            interval = .weekOfYear

            var weeklyData: [StepDataPoint] = []
            for week in 0..<4 {
                if let weekDate = calendar.date(byAdding: .weekOfYear, value: week, to: startDate) {
                    weeklyData.append(StepDataPoint(date: weekDate, steps: 0))
                }
            }

            self.stepData = weeklyData
        }
    }

    private func formatDateForChart(_ date: Date) -> String {
        let formatter = DateFormatter()

        switch timeRange {
        case .today:
            formatter.dateFormat = "ha" // 12PM, 1PM, etc.
        case .week:
            formatter.dateFormat = "E" // Mon, Tue, etc.
        case .month:
            formatter.dateFormat = "MMM d" // Jan 1, etc.
        }

        return formatter.string(from: date)
    }
}

struct StepDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    var steps: Int
}

