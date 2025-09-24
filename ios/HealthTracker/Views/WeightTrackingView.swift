import SwiftUI

struct WeightTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileManager: UserProfileManager
    @StateObject private var healthKitManager = HealthKitManager.shared

    @State private var currentWeight: Double = 0
    @State private var showingAddWeight = false
    @State private var selectedTimeRange = TimeRange.week
    @State private var weightHistory: [WeightDataPoint] = []
    @State private var isHealthKitAuthorized = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: false)],
        animation: .default)
    private var weights: FetchedResults<WeightEntry>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Weight Card
                    CurrentWeightCard(
                        currentWeight: latestWeight,
                        showingAddWeight: $showingAddWeight
                    )
                    .cardStyle()
                    
                    // Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Weight Chart
                    if !filteredWeights.isEmpty {
                        WeightChartView(
                            weights: filteredWeights,
                            timeRange: selectedTimeRange
                        )
                        .cardStyle()
                        .frame(height: 300)
                    }
                    
                    // Statistics
                    WeightStatisticsCard(
                        weights: filteredWeights,
                        timeRange: selectedTimeRange
                    )
                    .cardStyle()
                    
                    // Weight History
                    WeightHistoryCard(weights: Array(weights.prefix(10)))
                        .cardStyle()
                    
                    // HealthKit Integration
                    HealthKitCard(
                        isAuthorized: $isHealthKitAuthorized,
                        onConnect: connectHealthKit
                    )
                    .cardStyle()
                }
                .padding()
            }
            .navigationTitle("Weight Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWeight = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWeight) {
                AddWeightView()
            }
            .onAppear {
                // Delay heavy operations to prevent UI blocking
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    loadWeightHistory()
                }
            }
        }
    }
    
    var latestWeight: Double? {
        weights.first?.weight
    }
    
    var filteredWeights: [WeightDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .today:
            startDate = calendar.startOfDay(for: endDate)
        case .week:
            // Get the start of the current week
            let weekday = calendar.component(.weekday, from: endDate)
            let daysToSubtract = weekday - calendar.firstWeekday
            startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: endDate)) ?? endDate
        case .month:
            // Get the start of the current month
            let components = calendar.dateComponents([.year, .month], from: endDate)
            startDate = calendar.date(from: components) ?? endDate
        }
        
        return weights.compactMap { entry in
            guard let timestamp = entry.timestamp,
                  timestamp >= startDate else { return nil }
            return WeightDataPoint(date: timestamp, weight: entry.weight)
        }
    }
    
    func loadWeightHistory() {
        healthKitManager.fetchWeightHistory { entries in
            // Merge with Core Data entries
            // Implementation depends on your sync strategy
        }
    }
    
    func connectHealthKit() {
        healthKitManager.requestAuthorization { authorized in
            isHealthKitAuthorized = authorized
            if authorized {
                loadWeightHistory()
            }
        }
    }
}

struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct CurrentWeightCard: View {
    let currentWeight: Double?
    @Binding var showingAddWeight: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Current Weight")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let weight = currentWeight {
                Text("\(String(format: "%.1f", weight)) lbs")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.mochaBrown)
                
                Text("Last updated \(Date(), style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No weight recorded")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: { showingAddWeight = true }) {
                Label("Update Weight", systemImage: "plus.circle.fill")
            }
            .secondaryButton()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct WeightChartView: View {
    let weights: [WeightDataPoint]
    let timeRange: TimeRange
    
    var minWeight: Double {
        weights.map { $0.weight }.min() ?? 0
    }
    
    var maxWeight: Double {
        weights.map { $0.weight }.max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weight Trend")
                .font(.headline)
                .padding(.horizontal)
            
            if weights.count > 1 {
                // Simple line chart
                GeometryReader { geometry in
                    ZStack {
                        // Grid lines
                        Path { path in
                            let horizontalLines = 5
                            for i in 0...horizontalLines {
                                let y = geometry.size.height * CGFloat(i) / CGFloat(horizontalLines)
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                            }
                        }
                        .stroke(Color.lightGray.opacity(0.3), lineWidth: 1)
                        
                        // Line chart
                        Path { path in
                            let sortedWeights = weights.sorted { $0.date < $1.date }
                            let xStep = geometry.size.width / CGFloat(sortedWeights.count - 1)
                            let yRange = maxWeight - minWeight
                            let yScale = yRange > 0 ? geometry.size.height / yRange : 1
                            
                            for (index, weight) in sortedWeights.enumerated() {
                                let x = CGFloat(index) * xStep
                                let y = geometry.size.height - ((weight.weight - minWeight) * yScale)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.mindfulTeal, lineWidth: 3)
                        
                        // Data points
                        ForEach(Array(weights.sorted { $0.date < $1.date }.enumerated()), id: \.element.id) { index, weight in
                            let xStep = geometry.size.width / CGFloat(weights.count - 1)
                            let yRange = maxWeight - minWeight
                            let yScale = yRange > 0 ? geometry.size.height / yRange : 1
                            let x = CGFloat(index) * xStep
                            let y = geometry.size.height - ((weight.weight - minWeight) * yScale)
                            
                            Circle()
                                .fill(Color.mochaBrown)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 200)
                .padding()
                
                // Weight range labels
                HStack {
                    Text("\(Int(minWeight)) lbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(maxWeight)) lbs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            } else {
                Text("Not enough data for chart")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct WeightStatisticsCard: View {
    let weights: [WeightDataPoint]
    let timeRange: TimeRange
    
    var averageWeight: Double {
        guard !weights.isEmpty else { return 0 }
        return weights.map { $0.weight }.reduce(0, +) / Double(weights.count)
    }
    
    var weightChange: Double {
        guard weights.count >= 2,
              let first = weights.last,
              let last = weights.first else { return 0 }
        return last.weight - first.weight
    }
    
    var minWeight: Double {
        weights.map { $0.weight }.min() ?? 0
    }
    
    var maxWeight: Double {
        weights.map { $0.weight }.max() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(timeRange.rawValue) Statistics")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(
                    title: "Average",
                    value: String(format: "%.1f lbs", averageWeight),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .mindfulTeal
                )
                
                StatItem(
                    title: "Change",
                    value: String(format: "%+.1f lbs", weightChange),
                    icon: weightChange >= 0 ? "arrow.up.circle" : "arrow.down.circle",
                    color: weightChange >= 0 ? .wellnessGreen : .mindfulTeal
                )
                
                StatItem(
                    title: "Lowest",
                    value: String(format: "%.1f lbs", minWeight),
                    icon: "arrow.down.to.line",
                    color: .mindfulTeal
                )
                
                StatItem(
                    title: "Highest",
                    value: String(format: "%.1f lbs", maxWeight),
                    icon: "arrow.up.to.line",
                    color: .mochaBrown
                )
            }
        }
        .padding()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.lightGray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct WeightHistoryCard: View {
    let weights: [WeightEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Entries")
                .font(.headline)
            
            if weights.isEmpty {
                Text("No weight entries yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(weights) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(String(format: "%.1f", entry.weight)) lbs")
                                .font(.headline)
                            
                            if let timestamp = entry.timestamp {
                                Text(timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let timestamp = entry.timestamp {
                            Text(timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if entry != weights.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
    }
}

struct HealthKitCard: View {
    @Binding var isAuthorized: Bool
    let onConnect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Apple Health")
                    .font(.headline)
                
                Spacer()
                
                if isAuthorized {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.wellnessGreen)
                }
            }
            
            Text(isAuthorized ? "Connected to Apple Health" : "Connect to sync weight data with Apple Health")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !isAuthorized {
                Button("Connect to Apple Health", action: onConnect)
                    .primaryButton()
            }
        }
        .padding()
    }
}

struct AddWeightView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    @State private var weight: Double = 150
    @State private var notes = ""
    @State private var selectedDate = Date()
    @State private var syncWithHealthKit = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Weight Entry") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("0", value: $weight, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                    }
                    
                    DatePicker("Date & Time", selection: $selectedDate)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Toggle("Sync with Apple Health", isOn: $syncWithHealthKit)
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWeight()
                    }
                }
            }
        }
    }
    
    func saveWeight() {
        let newWeight = WeightEntry(context: viewContext)
        newWeight.id = UUID()
        newWeight.weight = weight
        newWeight.notes = notes.isEmpty ? nil : notes
        newWeight.timestamp = selectedDate

        do {
            try viewContext.save()

            // Update goals based on the new weight entry
            GoalsManager.shared.updateGoalsFromWeightEntry(newWeight)

            // Refresh UnifiedDataManager to update dashboard
            UnifiedDataManager.shared.refreshAllData()

            if syncWithHealthKit {
                healthKitManager.saveWeight(weight, date: selectedDate) { _ in
                    // Handle success/failure if needed
                }
            }

            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving weight: \(error)")
        }
    }
}

extension TimeRange {
    var strideComponent: Calendar.Component {
        switch self {
        case .today: return .hour
        case .week: return .day
        case .month: return .weekOfMonth
        }
    }
    
    var dateFormat: Date.FormatStyle {
        switch self {
        case .today: return .dateTime.hour()
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day()
        }
    }
}