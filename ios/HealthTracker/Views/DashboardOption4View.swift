import SwiftUI
import CoreData

// Option 4: Personalized Insights Dashboard
struct DashboardOption4View: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedCard: String? = nil
    @State private var timeOfDay = ""
    
    // Fetch recent data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate)
    ) private var weeklyFoodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate)
    ) private var weeklyExerciseEntries: FetchedResults<ExerciseEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -30, to: Date())! as NSDate)
    ) private var monthlyWeightEntries: FetchedResults<WeightEntry>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Personalized header
                    personalizedHeader
                    
                    // AI-style insights
                    insightsSection
                    
                    // Today's focus
                    todaysFocusSection
                    
                    // Smart recommendations
                    recommendationsSection
                    
                    // Progress celebration
                    if hasAchievements {
                        celebrationSection
                    }
                    
                    // Quick actions based on time
                    contextualActionsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 248/255, green: 248/255, blue: 252/255),
                        Color(red: 241/255, green: 241/255, blue: 248/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
            .onAppear {
                updateTimeOfDay()
            }
        }
    }
    
    private var personalizedHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(personalizedGreeting)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(motivationalMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Wellness score
                WellnessScoreView(score: wellnessScore)
            }
            
            // Today's summary card
            HStack(spacing: 20) {
                MiniMetric(
                    icon: "flame.fill",
                    value: "\(todaysCalories)",
                    label: "calories",
                    color: .orange
                )
                
                MiniMetric(
                    icon: "figure.walk",
                    value: "\(todaysSteps)",
                    label: "steps",
                    color: .blue
                )
                
                MiniMetric(
                    icon: "drop.fill",
                    value: "\(todaysWater)",
                    label: "cups",
                    color: .cyan
                )
                
                MiniMetric(
                    icon: "bed.double.fill",
                    value: "7.5",
                    label: "hrs sleep",
                    color: .purple
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InsightCard(
                    type: .positive,
                    title: "Great protein intake!",
                    message: "You've hit your protein goal 6 out of 7 days this week. Keep it up!",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    action: "View Protein Stats"
                )
                
                InsightCard(
                    type: .suggestion,
                    title: "Hydration reminder",
                    message: "You're 3 cups away from your daily water goal. Try having a glass with each meal.",
                    icon: "lightbulb.fill",
                    color: .blue,
                    action: "Set Reminder"
                )
                
                if hasWeightLoss {
                    InsightCard(
                        type: .achievement,
                        title: "Weight milestone!",
                        message: "You've lost 3 lbs this month. That's steady, healthy progress!",
                        icon: "star.fill",
                        color: .yellow,
                        action: "View Progress"
                    )
                }
            }
        }
    }
    
    private var todaysFocusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Focus")
                .font(.title2)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    FocusCard(
                        title: "Morning Workout",
                        subtitle: "30 min cardio planned",
                        icon: "sunrise.fill",
                        color: .orange,
                        progress: 0.0,
                        isCompleted: false
                    )
                    
                    FocusCard(
                        title: "Veggie Goal",
                        subtitle: "3 of 5 servings",
                        icon: "leaf.fill",
                        color: .green,
                        progress: 0.6,
                        isCompleted: false
                    )
                    
                    FocusCard(
                        title: "Mindful Eating",
                        subtitle: "Take time with lunch",
                        icon: "brain.head.profile",
                        color: .purple,
                        progress: 0.0,
                        isCompleted: false
                    )
                }
            }
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to recommendations
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                RecommendationRow(
                    icon: "fork.knife",
                    title: "Try this recipe",
                    subtitle: "Grilled Salmon Bowl - High protein, omega-3 rich",
                    accentColor: .orange
                )
                
                RecommendationRow(
                    icon: "figure.yoga",
                    title: "Evening stretch",
                    subtitle: "10-minute yoga flow to improve sleep quality",
                    accentColor: .purple
                )
                
                RecommendationRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Weekly challenge",
                    subtitle: "Walk 10,000 steps daily for 7 days",
                    accentColor: .green
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    private var celebrationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "party.popper.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading) {
                    Text("Amazing Week!")
                        .font(.headline)
                    Text("You've logged food for 7 days straight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(0.1),
                        Color.orange.opacity(0.1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    private var contextualActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(contextualActionTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(contextualActions, id: \.title) { action in
                    ContextualActionButton(
                        icon: action.icon,
                        title: action.title,
                        color: action.color
                    )
                }
            }
        }
    }
    
    // Computed properties
    private var personalizedGreeting: String {
        let name = userProfileManager.currentProfile?.name.components(separatedBy: " ").first ?? "there"
        return "\(timeOfDay), \(name)"
    }
    
    private var motivationalMessage: String {
        let messages = [
            "You're doing great! Keep up the momentum.",
            "Every healthy choice counts. You've got this!",
            "Your consistency is paying off!",
            "Small steps lead to big changes.",
            "You're building healthier habits every day!"
        ]
        return messages.randomElement() ?? ""
    }
    
    private var wellnessScore: Int {
        // Calculate based on recent activity
        var score = 50
        if !weeklyFoodEntries.isEmpty { score += 20 }
        if !weeklyExerciseEntries.isEmpty { score += 20 }
        if hasWeightLoss { score += 10 }
        return min(score, 100)
    }
    
    private var todaysCalories: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return Int(weeklyFoodEntries
            .filter { Calendar.current.isDate($0.timestamp ?? Date(), inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories })
    }
    
    private var todaysSteps: String {
        // Placeholder - would integrate with HealthKit
        return "8,432"
    }
    
    private var todaysWater: Int {
        // Placeholder
        return 5
    }
    
    private var hasAchievements: Bool {
        // Check for recent achievements
        return !weeklyFoodEntries.isEmpty && weeklyFoodEntries.count >= 7
    }
    
    private var hasWeightLoss: Bool {
        guard monthlyWeightEntries.count >= 2 else { return false }
        if let recent = monthlyWeightEntries.first,
           let older = monthlyWeightEntries.last {
            return recent.weight < older.weight
        }
        return false
    }
    
    private var contextualActionTitle: String {
        switch timeOfDay {
        case "Good morning": return "Start Your Day"
        case "Good afternoon": return "Afternoon Actions"
        case "Good evening": return "Evening Routine"
        default: return "Quick Actions"
        }
    }
    
    private var contextualActions: [(icon: String, title: String, color: Color)] {
        switch timeOfDay {
        case "Good morning":
            return [
                ("cup.and.saucer.fill", "Log Breakfast", .orange),
                ("figure.walk", "Morning Walk", .green),
                ("drop.fill", "Hydrate", .blue),
                ("pills.fill", "Vitamins", .purple)
            ]
        case "Good afternoon":
            return [
                ("fork.knife", "Log Lunch", .orange),
                ("figure.run", "Workout", .green),
                ("brain.head.profile", "Mindful Break", .purple),
                ("camera.fill", "Scan Meal", .blue)
            ]
        case "Good evening":
            return [
                ("moon.fill", "Log Dinner", .orange),
                ("figure.yoga", "Evening Stretch", .purple),
                ("book.fill", "Review Day", .blue),
                ("bed.double.fill", "Sleep Mode", .indigo)
            ]
        default:
            return [
                ("plus.circle.fill", "Quick Add", .orange),
                ("camera.fill", "Scan Food", .green),
                ("timer", "Start Fast", .blue),
                ("chart.bar.fill", "View Stats", .purple)
            ]
        }
    }
    
    private func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            timeOfDay = "Good morning"
        case 12..<17:
            timeOfDay = "Good afternoon"
        default:
            timeOfDay = "Good evening"
        }
    }
}

struct WellnessScoreView: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Wellness")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MiniMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct InsightCard: View {
    enum InsightType {
        case positive, suggestion, achievement
    }
    
    let type: InsightType
    let title: String
    let message: String
    let icon: String
    let color: Color
    let action: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Button(action: {}) {
                    Text(action)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
            }
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct FocusCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if progress > 0 && !isCompleted {
                ProgressView(value: progress)
                    .tint(color)
            }
        }
        .frame(width: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(accentColor.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ContextualActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    DashboardOption4View()
        .environmentObject(UserProfileManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}