import SwiftUI
import CoreData

// Option 3: Data-Focused Tile Dashboard
struct DashboardOption3View: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTimeRange = "Today"
    @State private var showingDetailedStats = false
    
    let timeRanges = ["Today", "Week", "Month"]
    
    // Fetch data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -30, to: Date())! as NSDate)
    ) private var recentFoodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -30, to: Date())! as NSDate)
    ) private var recentExerciseEntries: FetchedResults<ExerciseEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -30, to: Date())! as NSDate)
    ) private var recentWeightEntries: FetchedResults<WeightEntry>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with time selector
                    headerSection
                    
                    // Main stats grid
                    statsGrid
                    
                    // Trends section
                    trendsSection
                    
                    // Macros breakdown
                    macrosSection
                    
                    // Activity heat map
                    activityHeatMap
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingDetailedStats.toggle() }) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Time range selector
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(timeRanges, id: \.self) { range in
                    Text(range).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatTile(
                title: "Calories",
                value: averageCalories,
                unit: "avg/day",
                trend: .up,
                trendValue: "+5%",
                icon: "flame.fill",
                color: .orange
            )
            
            StatTile(
                title: "Weight",
                value: currentWeight,
                unit: "lbs",
                trend: .down,
                trendValue: "-2.5",
                icon: "scalemass",
                color: .blue
            )
            
            StatTile(
                title: "Exercise",
                value: totalExerciseHours,
                unit: "hours",
                trend: .up,
                trendValue: "+30%",
                icon: "figure.run",
                color: .green
            )
            
            StatTile(
                title: "Nutrition Score",
                value: nutritionScore,
                unit: "/100",
                trend: .neutral,
                trendValue: "Same",
                icon: "leaf.fill",
                color: .purple
            )
        }
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.headline)
            
            VStack(spacing: 0) {
                // Mini charts for each metric
                TrendChart(
                    title: "Calorie Intake",
                    data: calorieData,
                    color: .orange,
                    showAverage: true
                )
                
                Divider()
                
                TrendChart(
                    title: "Weight Progress",
                    data: weightData,
                    color: .blue,
                    showAverage: false
                )
                
                Divider()
                
                TrendChart(
                    title: "Exercise Minutes",
                    data: exerciseData,
                    color: .green,
                    showAverage: true
                )
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private var macrosSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macros Breakdown")
                    .font(.headline)
                
                Spacer()
                
                Text(selectedTimeRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                MacroCircle(
                    macro: "Protein",
                    value: averageProtein,
                    goal: 50,
                    color: Color(red: 255/255, green: 59/255, blue: 48/255)
                )
                
                MacroCircle(
                    macro: "Carbs",
                    value: averageCarbs,
                    goal: 225,
                    color: Color(red: 255/255, green: 149/255, blue: 0/255)
                )
                
                MacroCircle(
                    macro: "Fat",
                    value: averageFat,
                    goal: 65,
                    color: Color(red: 52/255, green: 199/255, blue: 89/255)
                )
                
                MacroCircle(
                    macro: "Fiber",
                    value: averageFiber,
                    goal: 25,
                    color: Color(red: 88/255, green: 86/255, blue: 214/255)
                )
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private var activityHeatMap: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Heat Map")
                .font(.headline)
            
            Text("Last 30 days")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Activity grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<30, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(activityColor(for: day))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 12, height: 12)
                    Text("Less")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach([0.3, 0.5, 0.7, 1.0], id: \.self) { opacity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green.opacity(opacity))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("More")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                }
            }
        }
    }
    
    // Computed properties
    private var averageCalories: String {
        let filtered = filterEntriesByTimeRange(recentFoodEntries)
        let total = filtered.reduce(0) { $0 + $1.calories }
        let days = max(1, numberOfDaysInRange())
        return "\(Int(total / Double(days)))"
    }
    
    private var currentWeight: String {
        if let latest = recentWeightEntries.first {
            return String(format: "%.1f", latest.weight)
        }
        return "---"
    }
    
    private var totalExerciseHours: String {
        let filtered = filterEntriesByTimeRange(recentExerciseEntries)
        let totalMinutes = filtered.reduce(0) { $0 + Double($1.duration) }
        return String(format: "%.1f", totalMinutes / 60)
    }
    
    private var nutritionScore: String {
        // Calculate based on variety, balance, etc.
        return "85"
    }
    
    private var averageProtein: Int {
        let filtered = filterEntriesByTimeRange(recentFoodEntries)
        let total = filtered.reduce(0) { $0 + $1.protein }
        let days = max(1, numberOfDaysInRange())
        return Int(total / Double(days))
    }
    
    private var averageCarbs: Int {
        let filtered = filterEntriesByTimeRange(recentFoodEntries)
        let total = filtered.reduce(0) { $0 + $1.carbs }
        let days = max(1, numberOfDaysInRange())
        return Int(total / Double(days))
    }
    
    private var averageFat: Int {
        let filtered = filterEntriesByTimeRange(recentFoodEntries)
        let total = filtered.reduce(0) { $0 + $1.fat }
        let days = max(1, numberOfDaysInRange())
        return Int(total / Double(days))
    }
    
    private var averageFiber: Int {
        let filtered = filterEntriesByTimeRange(recentFoodEntries)
        let total = filtered.reduce(0) { $0 + $1.fiber }
        let days = max(1, numberOfDaysInRange())
        return Int(total / Double(days))
    }
    
    private var calorieData: [Double] {
        // Generate sample data for the selected range
        Array(repeating: 0, count: 7).map { _ in Double.random(in: 1800...2200) }
    }
    
    private var weightData: [Double] {
        // Generate sample weight trend
        Array(0..<7).map { i in 180 - Double(i) * 0.3 }
    }
    
    private var exerciseData: [Double] {
        // Generate sample exercise data
        Array(repeating: 0, count: 7).map { _ in Double.random(in: 20...60) }
    }
    
    private func filterEntriesByTimeRange<T: NSManagedObject>(_ entries: FetchedResults<T>) -> [T] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case "Today":
            startDate = calendar.startOfDay(for: now)
        case "Week":
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case "Month":
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        default:
            startDate = calendar.startOfDay(for: now)
        }
        
        return entries.filter { entry in
            if let timestamp = entry.value(forKey: "timestamp") as? Date {
                return timestamp >= startDate
            }
            return false
        }
    }
    
    private func numberOfDaysInRange() -> Int {
        switch selectedTimeRange {
        case "Today": return 1
        case "Week": return 7
        case "Month": return 30
        default: return 1
        }
    }
    
    private func activityColor(for day: Int) -> Color {
        let random = Double.random(in: 0...1)
        if random < 0.2 {
            return Color.gray.opacity(0.2)
        } else if random < 0.5 {
            return Color.green.opacity(0.3)
        } else if random < 0.8 {
            return Color.green.opacity(0.7)
        } else {
            return Color.green
        }
    }
}

struct StatTile: View {
    enum Trend {
        case up, down, neutral
    }
    
    let title: String
    let value: String
    let unit: String
    let trend: Trend
    let trendValue: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trendIcon)
                        .font(.caption)
                        .foregroundColor(trendColor)
                    
                    Text(trendValue)
                        .font(.caption)
                        .foregroundColor(trendColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(unit) • \(title)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
}

struct TrendChart: View {
    let title: String
    let data: [Double]
    let color: Color
    let showAverage: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                if showAverage {
                    Text("Avg: \(Int(data.reduce(0, +) / Double(data.count)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Mini line chart
            GeometryReader { geometry in
                Path { path in
                    guard let max = data.max(), let min = data.min(), max > min else { return }
                    
                    let xStep = geometry.size.width / CGFloat(data.count - 1)
                    let yRange = max - min
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = geometry.size.height - ((value - min) / yRange * geometry.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, lineWidth: 2)
            }
            .frame(height: 40)
        }
        .padding()
    }
}

struct MacroCircle: View {
    let macro: String
    let value: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        min(Double(value) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(value)")
                    .font(.headline)
            }
            
            Text(macro)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(goal)g")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DashboardOption3View()
        .environmentObject(UserProfileManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}