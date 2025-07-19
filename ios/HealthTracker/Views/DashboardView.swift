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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var totalCalories: Double = 0
    @State private var totalSteps: Int = 0
    
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
            
            HStack(spacing: 20) {
                DashboardSummaryMetric(
                    icon: "flame",
                    value: "\(Int(totalCalories))",
                    label: "Calories",
                    color: .orange
                )
                
                DashboardSummaryMetric(
                    icon: "timer",
                    value: fastingStatus,
                    label: "Fasting",
                    color: fastingColor
                )
                
                DashboardSummaryMetric(
                    icon: "figure.walk",
                    value: "\(totalSteps.formatted())",
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
        let calendar = Calendar.current
        let endDate = Date()
        let startDate: Date
        
        switch timeRange {
        case .today:
            startDate = calendar.startOfDay(for: endDate)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        }
        
        // Fetch food entries
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as CVarArg, endDate as CVarArg)
        
        do {
            let foodEntries = try viewContext.fetch(foodRequest)
            totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
            
            // For now, using sample step data
            // In a real app, this would come from HealthKit or exercise entries
            switch timeRange {
            case .today:
                totalSteps = Int.random(in: 5000...10000)
            case .week:
                totalSteps = Int.random(in: 35000...70000)
            case .month:
                totalSteps = Int.random(in: 150000...300000)
            }
        } catch {
            print("Error fetching food entries: \(error)")
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

