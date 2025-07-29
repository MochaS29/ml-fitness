import SwiftUI
import CoreData

struct ProfessionalDashboardView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedTimeRange = TimeRange.week
    @State private var dashboardData = DashboardData()
    @State private var showingProfileSheet = false
    @State private var showingNotifications = false
    @State private var showingSleepTracking = false
    @State private var showingRecipes = false
    @State private var showingWorkouts = false
    @State private var showingSupplements = false
    @State private var showingFastingTimer = false
    @State private var showingProgressTracker = false
    
    // Fetch requests
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
                VStack(spacing: 0) {
                    // Custom Navigation Header
                    headerView
                    
                    // Main Chart Area
                    mainChartView
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Time Range Selector
                    timeRangeSelectorView
                        .padding(.vertical, 16)
                    
                    // Discover Section
                    discoverSection
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                loadDashboardData()
            }
            .onChange(of: selectedTimeRange) { oldValue, newValue in
                loadDashboardData()
            }
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showingSleepTracking) {
            SleepTrackingView()
        }
    }
    
    private var headerView: some View {
        HStack {
            // Profile Picture
            Button(action: { showingProfileSheet = true }) {
                if let profile = userProfileManager.currentProfile {
                    Circle()
                        .fill(Color(red: 139/255, green: 69/255, blue: 19/255))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(profile.name.prefix(1).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            
            Spacer()
            
            // Notifications
            Button(action: { showingNotifications = true }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private var mainChartView: some View {
        VStack(spacing: 20) {
            // Chart with gradient background
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 127/255, green: 176/255, blue: 105/255).opacity(0.3),
                        Color(red: 127/255, green: 176/255, blue: 105/255).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(20)
                
                VStack(spacing: 16) {
                    // Chart Value
                    Text("\(Int(dashboardData.averageCalories))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Chart
                    ProgressChartView(data: dashboardData.chartData, color: .white)
                        .frame(height: 120)
                        .padding(.horizontal)
                    
                    // Date Range
                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 30)
            }
            .frame(height: 250)
            
            // Quick Stats
            HStack(spacing: 16) {
                QuickStatCard(
                    title: "Average",
                    value: "\(Int(dashboardData.averageCalories))",
                    unit: "cal",
                    color: Color(red: 127/255, green: 176/255, blue: 105/255)
                )
                
                QuickStatCard(
                    title: "Best",
                    value: "\(Int(dashboardData.bestCalories))",
                    unit: "cal",
                    date: dashboardData.bestDate,
                    color: Color(red: 74/255, green: 155/255, blue: 155/255)
                )
                
                QuickStatCard(
                    title: "Total",
                    value: formatLargeNumber(dashboardData.totalCalories),
                    unit: "",
                    color: Color(red: 139/255, green: 69/255, blue: 19/255)
                )
            }
        }
    }
    
    private var timeRangeSelectorView: some View {
        HStack(spacing: 0) {
            ForEach([TimeRange.today, TimeRange.week, TimeRange.month], id: \.self) { range in
                Button(action: { selectedTimeRange = range }) {
                    VStack(spacing: 4) {
                        Image(systemName: iconForTimeRange(range))
                            .font(.title2)
                            .foregroundColor(selectedTimeRange == range ? Color(red: 139/255, green: 69/255, blue: 19/255) : .secondary)
                        
                        Text(titleForTimeRange(range))
                            .font(.caption)
                            .foregroundColor(selectedTimeRange == range ? Color(red: 139/255, green: 69/255, blue: 19/255) : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTimeRange == range ?
                        Color(red: 139/255, green: 69/255, blue: 19/255).opacity(0.1) : Color.clear
                    )
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var discoverSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discover")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DiscoverCard(
                    icon: "moon.fill",
                    title: "Sleep",
                    subtitle: "Eat right, sleep tight",
                    color: .blue
                ) {
                    showingSleepTracking = true
                }
                
                NavigationLink(destination: RecipeLibraryView()) {
                    DiscoverCard(
                        icon: "book.fill",
                        title: "Recipes",
                        subtitle: "Cook, eat, log, repeat",
                        color: Color(red: 127/255, green: 176/255, blue: 105/255)
                    ) {
                        // No action needed, NavigationLink handles it
                    }
                }
                
                NavigationLink(destination: ExerciseTrackingView()) {
                    DiscoverCard(
                        icon: "figure.walk",
                        title: "Workouts",
                        subtitle: "Sweating is self-care",
                        color: Color(red: 74/255, green: 155/255, blue: 155/255)
                    ) {
                        // No action needed, NavigationLink handles it
                    }
                }
                
                NavigationLink(destination: SupplementTrackingView()) {
                    DiscoverCard(
                        icon: "pills.fill",
                        title: "Supplements",
                        subtitle: "Track vitamins & minerals",
                        color: .purple
                    ) {
                        // No action needed, NavigationLink handles it
                    }
                }
                
                NavigationLink(destination: IntermittentFastingView()) {
                    DiscoverCard(
                        icon: "timer",
                        title: "Fasting Timer",
                        subtitle: "Track your fasting windows",
                        color: .orange
                    ) {
                        // No action needed, NavigationLink handles it
                    }
                }
                
                NavigationLink(destination: ProfessionalProgressView()) {
                    DiscoverCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress Tracker",
                        subtitle: "View your achievements",
                        color: .pink
                    ) {
                        // No action needed, NavigationLink handles it
                    }
                }
            }
        }
    }
    
    private func loadDashboardData() {
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
        
        // Filter entries within date range
        let foodInRange = recentFoodEntries.filter {
            $0.timestamp ?? Date() >= startDate && $0.timestamp ?? Date() <= endDate
        }
        
        // Calculate metrics
        var dailyCalories: [Double] = []
        var bestCalories: Double = 0
        var bestDate: Date?
        
        // Group by day
        let grouped = Dictionary(grouping: foodInRange) { entry -> Date in
            calendar.startOfDay(for: entry.timestamp ?? Date())
        }
        
        for (date, entries) in grouped {
            let dayTotal = entries.reduce(0) { $0 + $1.calories }
            dailyCalories.append(dayTotal)
            
            if dayTotal > bestCalories {
                bestCalories = dayTotal
                bestDate = date
            }
        }
        
        // Update dashboard data
        dashboardData.averageCalories = dailyCalories.isEmpty ? 0 : dailyCalories.reduce(0, +) / Double(dailyCalories.count)
        dashboardData.bestCalories = bestCalories
        dashboardData.bestDate = bestDate
        dashboardData.totalCalories = dailyCalories.reduce(0, +)
        dashboardData.chartData = dailyCalories
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let endDate = Date()
        let startDate: Date
        
        let calendar = Calendar.current
        
        switch selectedTimeRange {
        case .today:
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: endDate)
        case .week:
            // Get the start of the current week
            let weekday = calendar.component(.weekday, from: endDate)
            let daysToSubtract = weekday - calendar.firstWeekday
            startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: endDate)) ?? endDate
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        case .month:
            // Get the start of the current month
            let components = calendar.dateComponents([.year, .month], from: endDate)
            startDate = calendar.date(from: components) ?? endDate
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: endDate)
        }
    }
    
    private func iconForTimeRange(_ range: TimeRange) -> String {
        switch range {
        case .today: return "calendar"
        case .week: return "calendar.badge.7"
        case .month: return "calendar.badge.30"
        }
    }
    
    private func titleForTimeRange(_ range: TimeRange) -> String {
        switch range {
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
    
    private func formatLargeNumber(_ number: Double) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", number / 1000000)
        } else if number >= 1000 {
            return String(format: "%.1fK", number / 1000)
        } else {
            return String(format: "%.0f", number)
        }
    }
}

struct DashboardData {
    var averageCalories: Double = 0
    var bestCalories: Double = 0
    var bestDate: Date?
    var totalCalories: Double = 0
    var chartData: [Double] = []
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let unit: String
    var date: Date? = nil
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(color.opacity(0.8))
            }
            
            if let date = date {
                Text("(\(date, style: .date))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct DiscoverCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .onTapGesture {
            action()
        }
    }
}

struct ProgressChartView: View {
    let data: [Double]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(index == data.count - 1 ? 1.0 : 0.6))
                        .frame(width: max(4, (geometry.size.width - CGFloat(data.count - 1) * 4) / CGFloat(data.count)),
                               height: normalizedHeight(for: value, in: geometry.size.height))
                }
            }
        }
    }
    
    private func normalizedHeight(for value: Double, in maxHeight: CGFloat) -> CGFloat {
        guard !data.isEmpty else { return 0 }
        let maxValue = data.max() ?? 1
        let minValue = data.min() ?? 0
        let range = maxValue - minValue
        
        if range == 0 { return maxHeight * 0.5 }
        
        let normalized = (value - minValue) / range
        return max(4, normalized * maxHeight)
    }
}

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Text("No new notifications")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
            .navigationTitle("Notifications")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ProfessionalDashboardView()
        .environmentObject(UserProfileManager())
        .environmentObject(AchievementManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}