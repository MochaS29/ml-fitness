import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    // User Info
    @Published var userName = "Mocha"
    @Published var healthScore: Double = 85
    
    // AI Greetings and Analysis
    var aiGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Great morning! You're 15% more active than usual this week 🌟"
        case 12..<17:
            return "Keep it up! You're on track to meet 4 of 5 goals today 💪"
        case 17..<22:
            return "Strong finish! Just 200 calories to reach your protein goal 🎯"
        default:
            return "Rest well! Your body burns 1,800 calories even at rest 😴"
        }
    }
    
    var healthTrend: String {
        return healthScore > 80 ? "Excellent Progress" : "Room for Improvement"
    }
    
    var healthTrendIcon: String {
        return healthScore > 80 ? "arrow.up.right.circle.fill" : "arrow.right.circle.fill"
    }
    
    var healthTrendColor: Color {
        return healthScore > 80 ? .green : .orange
    }
    
    var healthSummary: String {
        return "You've lost 1.7 lbs this week! Your consistent exercise routine is paying off."
    }
    
    // Today's Metrics
    @Published var todayCalories = 1650
    @Published var calorieGoal = 2200
    @Published var currentWeight = 165.5
    @Published var targetWeight = 160.0
    @Published var todayExercise = 45
    @Published var exerciseSessions = 2
    @Published var todayWater = 6
    @Published var waterGoal = 8
    
    // Calculated Properties
    var weightProgress: Double {
        let totalToLose = 170.0 - targetWeight // Assuming starting weight was 170
        let currentLost = 170.0 - currentWeight
        return (currentLost / totalToLose) * 100
    }
    
    var waterPercentage: Int {
        Int((Double(todayWater) / Double(waterGoal)) * 100)
    }
    
    // Trends
    var calorieTrend: MetricCardWithTrend.Trend = .up
    var calorieTrendPercent = 8
    var weightTrend: MetricCardWithTrend.Trend = .down
    var weightTrendPercent = -2  // Lost 2% this week
    var waterTrend: MetricCardWithTrend.Trend = .neutral
    var waterTrendPercent = 0
    
    // Sparkline Data (last 7 days)
    var calorieSparkline: [Double] = [1850, 2100, 1950, 2200, 1900, 2050, 1650]
    var weightSparkline: [Double] = [167.2, 167.0, 166.8, 166.5, 166.2, 165.8, 165.5]
    var exerciseSparkline: [Double] = [30, 0, 45, 60, 0, 30, 45]
    var waterSparkline: [Double] = [7, 8, 6, 8, 7, 5, 6]
    
    // Nutrition Distribution
    var nutritionData: [HybridNutritionItem] {
        [
            HybridNutritionItem(name: "Carbs", value: 45, percentage: 45, color: .orange),
            HybridNutritionItem(name: "Protein", value: 30, percentage: 30, color: .blue),
            HybridNutritionItem(name: "Fat", value: 25, percentage: 25, color: .purple)
        ]
    }
    
    // Weekly Data for Chart
    var weeklyData: [WeeklyDataPoint] {
        [
            WeeklyDataPoint(day: "Mon", value: 1850),
            WeeklyDataPoint(day: "Tue", value: 2100),
            WeeklyDataPoint(day: "Wed", value: 1950),
            WeeklyDataPoint(day: "Thu", value: 2200),
            WeeklyDataPoint(day: "Fri", value: 1900),
            WeeklyDataPoint(day: "Sat", value: 2050),
            WeeklyDataPoint(day: "Sun", value: 1650)
        ]
    }
    
    // AI Insights
    var aiInsights: [AIInsight] {
        [
            AIInsight(
                title: "Protein Timing Discovery",
                description: "You absorb 23% more protein when consumed within 30 minutes after exercise",
                icon: "clock.fill",
                color: .blue,
                impact: "High Impact",
                isNew: true
            ),
            AIInsight(
                title: "Hydration Pattern",
                description: "Your energy dips correlate with low water intake. Try drinking water every 2 hours",
                icon: "drop.fill",
                color: .cyan,
                impact: "Medium Impact",
                isNew: false
            ),
            AIInsight(
                title: "Sleep & Cravings",
                description: "You consume 340 extra calories on days with less than 7 hours sleep",
                icon: "moon.fill",
                color: .indigo,
                impact: "High Impact",
                isNew: true
            ),
            AIInsight(
                title: "Meal Timing Win",
                description: "Your 3pm snack prevents evening overeating - keep it up!",
                icon: "star.fill",
                color: .yellow,
                impact: "Positive",
                isNew: false
            )
        ]
    }
    
    // AI Recommendations
    var recommendations: [AIRecommendation] {
        [
            AIRecommendation(
                title: "Add 20g protein to breakfast",
                description: "Based on your morning workouts, this will boost recovery by 40%",
                icon: "sunrise.fill",
                color: .orange,
                actionText: "See protein-rich breakfast ideas"
            ),
            AIRecommendation(
                title: "Hydrate before your 2pm meeting",
                description: "Your focus scores drop 15% when dehydrated",
                icon: "drop.circle.fill",
                color: .blue,
                actionText: "Set reminder"
            ),
            AIRecommendation(
                title: "Try intermittent fasting",
                description: "Your metabolism shows signs it would respond well to 16:8 fasting",
                icon: "clock.arrow.circlepath",
                color: .green,
                actionText: "Learn more"
            ),
            AIRecommendation(
                title: "Swap evening carbs for veggies",
                description: "This could improve your sleep quality by 25%",
                icon: "moon.stars.fill",
                color: .purple,
                actionText: "See dinner alternatives"
            )
        ]
    }
    
    // Nutrient Breakdown
    var nutrientBreakdown: [NutrientBreakdown] {
        [
            NutrientBreakdown(name: "Calories", current: "1,650", goal: "2,200", percentage: 75, color: .orange),
            NutrientBreakdown(name: "Protein", current: "85g", goal: "120g", percentage: 71, color: .blue),
            NutrientBreakdown(name: "Carbs", current: "186g", goal: "275g", percentage: 68, color: .brown),
            NutrientBreakdown(name: "Fat", current: "46g", goal: "73g", percentage: 63, color: .purple),
            NutrientBreakdown(name: "Fiber", current: "22g", goal: "30g", percentage: 73, color: .green),
            NutrientBreakdown(name: "Sugar", current: "45g", goal: "50g", percentage: 90, color: .pink),
            NutrientBreakdown(name: "Sodium", current: "2,800mg", goal: "2,300mg", percentage: 122, color: .red),
            NutrientBreakdown(name: "Iron", current: "14mg", goal: "18mg", percentage: 78, color: .gray),
            NutrientBreakdown(name: "Calcium", current: "950mg", goal: "1,000mg", percentage: 95, color: .mint),
            NutrientBreakdown(name: "Vitamin D", current: "12μg", goal: "15μg", percentage: 80, color: .yellow)
        ]
    }

    func updateTimeRange(_ range: HybridDashboardView.TimeRange) {
        // Update data based on selected time range
        switch range {
        case .day:
            // Load today's data
            print("Loading day data")
        case .week:
            // Load week's data
            print("Loading week data")
        case .month:
            // Load month's data
            print("Loading month data")
        }
        // Trigger UI update
        objectWillChange.send()
    }

    // MARK: - Chart Data Methods

    func getCaloriesData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        switch range {
        case .day:
            // Hour-by-hour for today
            let hours = stride(from: 0, to: 24, by: 4).map { hour in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .hour, value: hour, to: Calendar.current.startOfDay(for: Date()))!,
                    value: Double.random(in: 200...400)
                )
            }
            return hours
        case .week:
            // Daily for past 7 days
            return (0..<7).map { dayOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!,
                    value: Double([1850, 2100, 1950, 2200, 1900, 2050, 1650][dayOffset % 7])
                )
            }.reversed()
        case .month:
            // Weekly averages for past month
            return (0..<4).map { weekOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!,
                    value: Double.random(in: 1800...2200)
                )
            }.reversed()
        }
    }

    func getWeightData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        switch range {
        case .day:
            // Single point for today
            return [ChartDataPoint(date: Date(), value: currentWeight)]
        case .week:
            // Daily weights for past week
            return (0..<7).map { dayOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!,
                    value: currentWeight + Double.random(in: -1...1)
                )
            }.reversed()
        case .month:
            // Weekly weights for past month
            return (0..<4).map { weekOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!,
                    value: currentWeight + Double(4 - weekOffset) * 0.5
                )
            }.reversed()
        }
    }

    func getExerciseData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        switch range {
        case .day:
            // Sessions for today
            return [
                ChartDataPoint(date: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, value: 30),
                ChartDataPoint(date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, value: 15)
            ]
        case .week:
            // Daily totals for past week
            return (0..<7).map { dayOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!,
                    value: Double([30, 0, 45, 60, 0, 30, 45][dayOffset % 7])
                )
            }.reversed()
        case .month:
            // Weekly totals for past month
            return (0..<4).map { weekOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!,
                    value: Double.random(in: 150...300)
                )
            }.reversed()
        }
    }

    func getWeightRange(for range: HybridDashboardView.TimeRange) -> ClosedRange<Double> {
        switch range {
        case .day:
            return (currentWeight - 2)...(currentWeight + 2)
        case .week:
            return (currentWeight - 3)...(currentWeight + 3)
        case .month:
            return (currentWeight - 5)...(currentWeight + 5)
        }
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct HybridNutritionItem: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let percentage: Double
    let color: Color
}

struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// MARK: - AI Insight Detail View

struct AIInsightDetailView: View {
    let insight: AIInsight
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 60))
                            .foregroundColor(insight.color)
                        
                        Text(insight.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Label(insight.impact, systemImage: "sparkles")
                            .font(.subheadline)
                            .foregroundColor(insight.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(insight.color.opacity(0.1))
                            .cornerRadius(20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What we discovered")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        Text(insight.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    // Evidence
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Supporting Data")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        VStack(spacing: 12) {
                            DataPointRow(label: "Confidence Level", value: "0%", icon: "checkmark.shield.fill")
                            DataPointRow(label: "Data Points Analyzed", value: "0", icon: "chart.line.uptrend.xyaxis")
                            DataPointRow(label: "Pattern Detected", value: "None", icon: "calendar")
                            DataPointRow(label: "Similar Users", value: "0", icon: "person.3.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Steps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended Actions")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        VStack(spacing: 12) {
                            ActionStepRow(number: 1, text: "Track this metric for the next 7 days")
                            ActionStepRow(number: 2, text: "Adjust your routine based on the insight")
                            ActionStepRow(number: 3, text: "Monitor changes in your energy levels")
                        }
                    }
                    .padding(.horizontal)
                    
                    // CTA Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Apply This Insight")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(insight.color)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DataPointRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.mindfulTeal)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.deepCharcoal)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ActionStepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.mindfulTeal)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.deepCharcoal)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}