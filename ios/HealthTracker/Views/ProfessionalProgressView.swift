import SwiftUI
import CoreData

struct ProfessionalProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedMetric = ProgressMetric.steps
    @State private var selectedTimeRange = ProgressTimeRange.sixMonths
    @State private var progressData = ProgressData()
    
    // Fetch requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)]
    ) private var exerciseEntries: FetchedResults<ExerciseEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)]
    ) private var foodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: false)]
    ) private var weightEntries: FetchedResults<WeightEntry>
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Metric Selector
            metricSelectorView
                .padding(.vertical, 16)
            
            // Stats Summary
            statsSummaryView
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            // Bar Chart
            barChartView
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            // Entries List
            entriesListView
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            loadProgressData()
        }
        .onChange(of: selectedMetric) {
            loadProgressData()
        }
        .onChange(of: selectedTimeRange) {
            loadProgressData()
        }
    }
    
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { /* Navigate back */ }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: { /* Share */ }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            Text("Progress")
                .font(.headline)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var metricSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(ProgressMetric.allCases, id: \.self) { metric in
                Button(action: { selectedMetric = metric }) {
                    VStack(spacing: 8) {
                        Image(systemName: metric.icon)
                            .font(.title2)
                        Text(metric.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedMetric == metric ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedMetric == metric ?
                        Color(red: 139/255, green: 69/255, blue: 19/255) : Color.clear
                    )
                }
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var statsSummaryView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(progressData.average))")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("AVERAGE")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 4) {
                Text("\(Int(progressData.best))")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("BEST (\(progressData.bestDateFormatted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatTotal(progressData.total))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("TOTAL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
    
    private var barChartView: some View {
        VStack(spacing: 16) {
            // Time Range Selector
            HStack {
                Spacer()
                Menu {
                    ForEach(ProgressTimeRange.allCases, id: \.self) { range in
                        Button(action: { selectedTimeRange = range }) {
                            Label(range.title, systemImage: "calendar")
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedTimeRange.title)
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
            
            // Bar Chart
            BarChartView(
                data: progressData.chartData,
                labels: progressData.chartLabels,
                color: colorForMetric(selectedMetric),
                maxValue: progressData.chartMax
            )
            .frame(height: 200)
        }
    }
    
    private var entriesListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Entries")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(progressData.recentEntries) { entry in
                        ProgressEntryRow(entry: entry)
                        
                        if entry.id != progressData.recentEntries.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private func loadProgressData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Determine date range
        let monthsBack: Int
        switch selectedTimeRange {
        case .threeMonths: monthsBack = 3
        case .sixMonths: monthsBack = 6
        case .oneYear: monthsBack = 12
        }
        
        let startDate = calendar.date(byAdding: .month, value: -monthsBack, to: now) ?? now
        
        // Load data based on selected metric
        switch selectedMetric {
        case .steps:
            loadStepsData(from: startDate, to: now)
        case .calories:
            loadCaloriesData(from: startDate, to: now)
        case .weight:
            loadWeightData(from: startDate, to: now)
        case .exercise:
            loadExerciseData(from: startDate, to: now)
        }
    }
    
    private func loadStepsData(from startDate: Date, to endDate: Date) {
        // For demo purposes, generate sample step data
        let calendar = Calendar.current
        var data: [(date: Date, value: Double)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let steps = Double.random(in: 3000...8000)
            data.append((date: currentDate, value: steps))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        updateProgressData(from: data, unit: "steps")
    }
    
    private func loadCaloriesData(from startDate: Date, to endDate: Date) {
        let entries = foodEntries.filter {
            guard let date = $0.timestamp else { return false }
            return date >= startDate && date <= endDate
        }
        
        let grouped = Dictionary(grouping: entries) { entry -> Date in
            Calendar.current.startOfDay(for: entry.timestamp ?? Date())
        }
        
        let data = grouped.map { (date, entries) -> (date: Date, value: Double) in
            let totalCalories = entries.reduce(0) { $0 + $1.calories }
            return (date: date, value: totalCalories)
        }.sorted { $0.date < $1.date }
        
        updateProgressData(from: data, unit: "cal")
    }
    
    private func loadWeightData(from startDate: Date, to endDate: Date) {
        let entries = weightEntries.filter {
            guard let date = $0.timestamp else { return false }
            return date >= startDate && date <= endDate
        }
        
        let data = entries.map { entry -> (date: Date, value: Double) in
            (date: entry.timestamp ?? Date(), value: entry.weight)
        }.sorted { $0.date < $1.date }
        
        updateProgressData(from: data, unit: "lbs")
    }
    
    private func loadExerciseData(from startDate: Date, to endDate: Date) {
        let entries = exerciseEntries.filter {
            guard let date = $0.timestamp else { return false }
            return date >= startDate && date <= endDate
        }
        
        let grouped = Dictionary(grouping: entries) { entry -> Date in
            Calendar.current.startOfDay(for: entry.timestamp ?? Date())
        }
        
        let data = grouped.map { (date, entries) -> (date: Date, value: Double) in
            let totalMinutes = entries.reduce(0) { $0 + Double($1.duration) }
            return (date: date, value: totalMinutes)
        }.sorted { $0.date < $1.date }
        
        updateProgressData(from: data, unit: "min")
    }
    
    private func updateProgressData(from data: [(date: Date, value: Double)], unit: String) {
        guard !data.isEmpty else { return }
        
        let values = data.map { $0.value }
        progressData.average = values.reduce(0, +) / Double(values.count)
        
        if let maxEntry = data.max(by: { $0.value < $1.value }) {
            progressData.best = maxEntry.value
            progressData.bestDate = maxEntry.date
        }
        
        progressData.total = values.reduce(0, +)
        
        // Group by month for chart
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data) { entry -> Date in
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            return calendar.date(from: components) ?? entry.date
        }
        
        let chartEntries = grouped.map { (month, entries) -> (date: Date, value: Double) in
            let monthAverage = entries.map { $0.value }.reduce(0, +) / Double(entries.count)
            return (date: month, value: monthAverage)
        }.sorted { $0.date < $1.date }
        
        progressData.chartData = chartEntries.map { $0.value }
        progressData.chartLabels = chartEntries.map { formatMonthLabel($0.date) }
        progressData.chartMax = (progressData.chartData.max() ?? 0) * 1.2
        
        // Recent entries
        let recentData = data.suffix(7).reversed()
        progressData.recentEntries = recentData.map { entry in
            ProgressRecentEntry(
                id: UUID(),
                date: entry.date,
                value: Int(entry.value.rounded()),
                unit: unit,
                dayOfWeek: formatDayOfWeek(entry.date)
            )
        }
    }
    
    private func formatMonthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func formatTotal(_ value: Double) -> String {
        if value >= 1000000 {
            return String(format: "%.1fM", value / 1000000)
        } else if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    private func colorForMetric(_ metric: ProgressMetric) -> Color {
        switch metric {
        case .steps: return Color(red: 74/255, green: 155/255, blue: 155/255)
        case .calories: return Color(red: 127/255, green: 176/255, blue: 105/255)
        case .weight: return Color(red: 139/255, green: 69/255, blue: 19/255)
        case .exercise: return .orange
        }
    }
}

enum ProgressMetric: CaseIterable {
    case steps, calories, weight, exercise
    
    var title: String {
        switch self {
        case .steps: return "Steps"
        case .calories: return "Calories"
        case .weight: return "Weight"
        case .exercise: return "Exercise"
        }
    }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .calories: return "flame.fill"
        case .weight: return "scalemass.fill"
        case .exercise: return "figure.run"
        }
    }
}

enum ProgressTimeRange: CaseIterable {
    case threeMonths, sixMonths, oneYear
    
    var title: String {
        switch self {
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        }
    }
}

struct ProgressData {
    var average: Double = 0
    var best: Double = 0
    var bestDate: Date = Date()
    var total: Double = 0
    var chartData: [Double] = []
    var chartLabels: [String] = []
    var chartMax: Double = 0
    var recentEntries: [ProgressRecentEntry] = []
    
    var bestDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: bestDate)
    }
}

struct ProgressRecentEntry: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let value: Int
    let unit: String
    let dayOfWeek: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct ProgressEntryRow: View {
    let entry: ProgressRecentEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.formattedDate)
                    .font(.subheadline)
                Text(entry.dayOfWeek)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(entry.value)")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
    }
}

struct BarChartView: View {
    let data: [Double]
    let labels: [String]
    let color: Color
    let maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: barWidth(for: geometry.size.width),
                                   height: barHeight(for: value, maxHeight: geometry.size.height - 20))
                        
                        if index < labels.count {
                            Text(labels[index])
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func barWidth(for totalWidth: CGFloat) -> CGFloat {
        let spacing = CGFloat(data.count - 1) * 8
        let availableWidth = totalWidth - spacing
        return max(20, availableWidth / CGFloat(data.count))
    }
    
    private func barHeight(for value: Double, maxHeight: CGFloat) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        return max(4, (value / maxValue) * maxHeight)
    }
}

#Preview {
    NavigationView {
        ProfessionalProgressView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}