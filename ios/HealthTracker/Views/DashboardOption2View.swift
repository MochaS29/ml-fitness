import SwiftUI
import CoreData

// Option 2: Health Rings Style Dashboard (Apple Health inspired)
struct DashboardOption2View: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    
    // Fetch today's data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysFoodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysExerciseEntries: FetchedResults<ExerciseEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysSupplementEntries: FetchedResults<SupplementEntry>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Date and Profile Header
                    headerSection
                    
                    // Activity Rings
                    activityRingsSection
                    
                    // Daily Progress
                    dailyProgressSection
                    
                    // Insights
                    insightsSection
                    
                    // Quick Log
                    quickLogSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(selectedDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Profile Button
            if let profile = userProfileManager.currentProfile {
                NavigationLink(destination: ProfileView()) {
                    Circle()
                        .fill(Color(red: 139/255, green: 69/255, blue: 19/255))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(profile.name.prefix(1).uppercased())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    private var activityRingsSection: some View {
        VStack(spacing: 24) {
            // Main Rings
            ZStack {
                // Calories Ring (Outer)
                ActivityRing(
                    progress: caloriesProgress,
                    ringWidth: 20,
                    color: Color(red: 255/255, green: 45/255, blue: 85/255)
                )
                .frame(width: 200, height: 200)
                
                // Exercise Ring (Middle)
                ActivityRing(
                    progress: exerciseProgress,
                    ringWidth: 20,
                    color: Color(red: 52/255, green: 199/255, blue: 89/255)
                )
                .frame(width: 160, height: 160)
                
                // Nutrition Ring (Inner)
                ActivityRing(
                    progress: nutritionProgress,
                    ringWidth: 20,
                    color: Color(red: 0/255, green: 122/255, blue: 255/255)
                )
                .frame(width: 120, height: 120)
                
                // Center Stats
                VStack(spacing: 4) {
                    Text("\(Int(totalCalories))")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Ring Labels
            HStack(spacing: 32) {
                RingLabel(
                    title: "Move",
                    value: "\(Int(totalCalories))",
                    goal: "2000",
                    color: Color(red: 255/255, green: 45/255, blue: 85/255)
                )
                
                RingLabel(
                    title: "Exercise",
                    value: "\(totalExerciseMinutes)",
                    goal: "30 min",
                    color: Color(red: 52/255, green: 199/255, blue: 89/255)
                )
                
                RingLabel(
                    title: "Nutrition",
                    value: "\(nutritionScore)%",
                    goal: "100%",
                    color: Color(red: 0/255, green: 122/255, blue: 255/255)
                )
            }
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
    
    private var dailyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Progress")
                .font(.headline)
            
            VStack(spacing: 12) {
                ProgressRow(
                    icon: "drop.fill",
                    title: "Water",
                    current: 5,
                    goal: 8,
                    unit: "cups",
                    color: .blue
                )
                
                ProgressRow(
                    icon: "leaf.fill",
                    title: "Protein",
                    current: Int(todaysFoodEntries.reduce(0) { $0 + $1.protein }),
                    goal: 50,
                    unit: "g",
                    color: .green
                )
                
                ProgressRow(
                    icon: "pills.fill",
                    title: "Supplements",
                    current: todaysSupplementEntries.count,
                    goal: 3,
                    unit: "taken",
                    color: .purple
                )
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Insights")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    InsightCard(
                        icon: "arrow.up.circle.fill",
                        title: "Great Start!",
                        message: "You're 40% toward your calorie goal",
                        color: .orange
                    )
                    
                    InsightCard(
                        icon: "clock.fill",
                        title: "Time to Move",
                        message: "A 15-min walk would complete your exercise ring",
                        color: .green
                    )
                    
                    InsightCard(
                        icon: "star.fill",
                        title: "Streak: 5 days",
                        message: "Keep up the great work!",
                        color: .yellow
                    )
                }
            }
        }
    }
    
    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Log")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickLogButton(
                    icon: "fork.knife",
                    title: "Food",
                    color: Color(red: 255/255, green: 149/255, blue: 0/255)
                )
                
                QuickLogButton(
                    icon: "figure.run",
                    title: "Exercise",
                    color: Color(red: 52/255, green: 199/255, blue: 89/255)
                )
                
                QuickLogButton(
                    icon: "scalemass",
                    title: "Weight",
                    color: Color(red: 88/255, green: 86/255, blue: 214/255)
                )
                
                QuickLogButton(
                    icon: "camera.fill",
                    title: "Scan Dish",
                    color: Color(red: 255/255, green: 45/255, blue: 85/255)
                )
            }
        }
    }
    
    // Computed properties
    private var totalCalories: Double {
        todaysFoodEntries.reduce(0) { $0 + $1.calories }
    }
    
    private var caloriesProgress: Double {
        min(totalCalories / 2000, 1.0)
    }
    
    private var totalExerciseMinutes: Int {
        todaysExerciseEntries.reduce(0) { $0 + Int($1.duration) }
    }
    
    private var exerciseProgress: Double {
        min(Double(totalExerciseMinutes) / 30.0, 1.0)
    }
    
    private var nutritionScore: Int {
        // Simple nutrition score based on variety and balance
        let hasProtein = todaysFoodEntries.contains { $0.protein > 10 }
        let hasVeggies = todaysFoodEntries.contains { $0.fiber > 3 }
        let hasWater = true // Placeholder
        let hasSupplements = !todaysSupplementEntries.isEmpty
        
        var score = 0
        if hasProtein { score += 25 }
        if hasVeggies { score += 25 }
        if hasWater { score += 25 }
        if hasSupplements { score += 25 }
        
        return score
    }
    
    private var nutritionProgress: Double {
        Double(nutritionScore) / 100.0
    }
}

struct ActivityRing: View {
    let progress: Double
    let ringWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: ringWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: ringWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

struct RingLabel: View {
    let title: String
    let value: String
    let goal: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            
            Text(goal)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressRow: View {
    let icon: String
    let title: String
    let current: Int
    let goal: Int
    let unit: String
    let color: Color
    
    private var progress: Double {
        min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(current)/\(goal) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(color.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * progress, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 180)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct QuickLogButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
}

#Preview {
    DashboardOption2View()
        .environmentObject(UserProfileManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}