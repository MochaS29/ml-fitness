import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject private var streakManager = LoggingStreakManager.shared
    @State private var selectedTimeRange = TimeRange.week
    @State private var animateCharts = false
    @State private var activeSheet: ActiveSheet?
    @State private var widgetsEnabled = false

    private enum ActiveSheet: Identifiable {
        case aiInsightDetail(AIInsight)
        case calorieDetail
        case weightDetail
        case exerciseDetail
        case waterDetail
        case supplementDetail
        case stepDetail
        case stepGoal
        case exerciseQuickAdd
        case allInsights
        case reminders
        case nutritionDetail
        case quickLog

        var id: String {
            switch self {
            case .aiInsightDetail(let insight): return "aiInsightDetail-\(insight.id)"
            case .calorieDetail: return "calorieDetail"
            case .weightDetail: return "weightDetail"
            case .exerciseDetail: return "exerciseDetail"
            case .waterDetail: return "waterDetail"
            case .supplementDetail: return "supplementDetail"
            case .stepDetail: return "stepDetail"
            case .stepGoal: return "stepGoal"
            case .exerciseQuickAdd: return "exerciseQuickAdd"
            case .allInsights: return "allInsights"
            case .reminders: return "reminders"
            case .nutritionDetail: return "nutritionDetail"
            case .quickLog: return "quickLog"
            }
        }
    }

    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Time Range Selector
                headerSection

                // Delay loading heavy widgets
                if widgetsEnabled {
                    // Key Metrics Cards — 4 blocks
                    metricsOverview

                    // Nutrition Distribution Chart
                    nutritionDistributionCard

                    // Supplement Stats Widget
                    SupplementStatsWidget(showingDetail: Binding(
                        get: { if case .supplementDetail = activeSheet { return true }; return false },
                        set: { if $0 { activeSheet = .supplementDetail } else { activeSheet = nil } }
                    ))

                    // AI Insights Carousel
                    aiInsightsSection

                    // Smart Recommendations
                    aiRecommendationsSection

                    // Quick Reminders Access
                    quickRemindersStrip

                    // Detailed Analytics
                    detailedAnalyticsSection
                } else {
                    // Show loading placeholder
                    VStack(spacing: 20) {
                        ProgressView("Loading Dashboard...")
                            .padding()

                        Text("Please wait while we prepare your health data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .overlay(alignment: .bottomTrailing) {
            Button(action: { activeSheet = .quickLog }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 28)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Enable widgets after a delay to prevent initial freezing
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    widgetsEnabled = true
                }
            }

            // Further delay chart animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    animateCharts = true
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .aiInsightDetail(let insight):
                AIInsightDetailView(insight: insight)
            case .calorieDetail:
                FoodTrackingView()
            case .weightDetail:
                WeightTrackingView()
            case .exerciseDetail:
                ExerciseDetailView()
            case .waterDetail:
                WaterTrackingView()
            case .supplementDetail:
                ProFeatureGate {
                    EnhancedSupplementTrackingView()
                }
            case .stepDetail:
                StepDetailsView()
            case .stepGoal:
                StepGoalView()
            case .exerciseQuickAdd:
                ExerciseQuickAddView()
            case .allInsights:
                AllInsightsView(insights: viewModel.aiInsights)
            case .reminders:
                RemindersView()
            case .nutritionDetail:
                NutritionDetailView()
            case .quickLog:
                AddMenuView(selectedDate: Date())
            }
        }
    }

    // MARK: - Quick Reminders Strip

    private var quickRemindersStrip: some View {
        let settings = SmartReminderSettings.shared
        let activeCount = [settings.waterEnabled, settings.stepsEnabled, settings.mealsEnabled, settings.exerciseEnabled, settings.weightEnabled].filter { $0 }.count

        return Button(action: { activeSheet = .reminders }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.mindfulTeal.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: activeCount > 0 ? "bell.badge.fill" : "bell.fill")
                        .foregroundColor(.mindfulTeal)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Reminders")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(activeCount > 0 ? "\(activeCount) active reminder\(activeCount == 1 ? "" : "s")" : "Tap to set up reminders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        let streak = streakManager.currentStreak
        let emoji: String
        switch streak {
        case 1...2: emoji = "🌱"
        case 3...6: emoji = "🔥"
        case 7...13: emoji = "⚡️"
        case 14...29: emoji = "🏅"
        default: emoji = "🏆"
        }
        return HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 32))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak)-Day Logging Streak!")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(streak == 1 ? "Great start — log again tomorrow to build your streak." : "You've logged food \(streak) days in a row. Keep it up!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Welcome Message with AI Touch
            HStack(spacing: 12) {
                if let avatar = profileManager.avatarImage {
                    Image(uiImage: avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello, \(viewModel.userName)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.deepCharcoal)

                    Text(viewModel.aiGreeting)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Overall Health Score + Streak combined card
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Score Circle
                    ZStack {
                        Circle()
                            .stroke(Color(UIColor.systemFill), lineWidth: 8)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: animateCharts ? viewModel.healthScore / 100 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [.wellnessGreen, .mindfulTeal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text("\(Int(viewModel.healthScore))")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // AI Analysis
                    VStack(alignment: .leading, spacing: 8) {
                        Label(viewModel.healthTrend, systemImage: viewModel.healthTrendIcon)
                            .font(.headline)
                            .foregroundColor(viewModel.healthTrendColor)

                        Text(viewModel.healthSummary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding()

                if streakManager.currentStreak > 0 {
                    Divider().padding(.horizontal)

                    let streak = streakManager.currentStreak
                    let emoji: String = {
                        switch streak {
                        case 1...2: return "🌱"
                        case 3...6: return "🔥"
                        case 7...13: return "⚡️"
                        case 14...29: return "🏅"
                        default: return "🏆"
                        }
                    }()

                    HStack(spacing: 12) {
                        Text(emoji)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(streak)-Day Logging Streak!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(streak == 1 ? "Great start — log again tomorrow to build your streak." : "You've logged food \(streak) days in a row. Keep it up!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - AI Insights Section (from Option 4)
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI Insights", systemImage: "brain")
                    .font(.headline)
                    .foregroundColor(.deepCharcoal)
                
                Spacer()
                
                Button(action: { activeSheet = .allInsights }) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.mindfulTeal)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.aiInsights) { insight in
                        AIInsightCard(insight: insight)
                            .onTapGesture {
                                activeSheet = .aiInsightDetail(insight)
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - Metrics Overview (from Option 3)
    
    private var metricsOverview: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCardWithTrend(
                title: "Steps",
                value: "\(viewModel.todaySteps)",
                subtitle: "of \(viewModel.stepGoal) goal",
                trend: viewModel.stepsTrend,
                trendValue: "+\(viewModel.stepsTrendPercent)%",
                icon: "figure.walk",
                color: .green,
                sparklineData: viewModel.stepsSparkline
            )
            .onTapGesture {
                activeSheet = .stepGoal
            }
            
            MetricCardWithTrend(
                title: "Weight",
                value: String(format: "%.1f lbs", viewModel.currentWeight),
                subtitle: String(format: "%.1f lbs to goal", viewModel.currentWeight - viewModel.targetWeight),
                trend: viewModel.weightTrend,
                trendValue: "\(viewModel.weightTrendPercent)%",
                icon: "scalemass.fill",
                color: .blue,
                sparklineData: viewModel.weightSparkline
            )
            .onTapGesture {
                activeSheet = .weightDetail
            }
            
            MetricCardWithTrend(
                title: "Exercise",
                value: "\(viewModel.todayExercise) min",
                subtitle: "\(viewModel.exerciseSessions) sessions",
                trend: .up,
                trendValue: "+15%",
                icon: "figure.run",
                color: .orange,
                sparklineData: viewModel.exerciseSparkline
            )
            .onTapGesture {
                activeSheet = .exerciseDetail
            }
            
            MetricCardWithTrend(
                title: "Water",
                value: "\(viewModel.todayWater)",
                subtitle: "\(viewModel.waterPercentage)% hydrated",
                trend: viewModel.waterTrend,
                trendValue: "\(viewModel.waterTrendPercent)%",
                icon: "drop.fill",
                color: .cyan,
                sparklineData: viewModel.waterSparkline
            )
            .onTapGesture {
                activeSheet = .waterDetail
            }
        }
    }
    
    // MARK: - Nutrition Distribution Card

    private var nutritionDistributionCard: some View {
        Button(action: { activeSheet = .nutritionDetail }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Nutrition Distribution")
                        .font(.headline)
                        .foregroundColor(.deepCharcoal)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Chart {
                    ForEach(viewModel.nutritionData) { item in
                        SectorMark(
                            angle: .value("Value", item.value),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(4)
                        .opacity(animateCharts ? 1 : 0)
                    }
                }
                .frame(height: 200)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        VStack {
                            Text("\(viewModel.todayCalories)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }

                HStack(spacing: 20) {
                    ForEach(viewModel.nutritionData) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 12, height: 12)
                            Text(item.name)
                                .font(.caption)
                            Text("\(Int(item.percentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal)

                Text("Tap for detailed day / week / month breakdown")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - AI Recommendations (from Option 4)
    
    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Smart Recommendations", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.deepCharcoal)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.mindfulTeal)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.recommendations) { recommendation in
                    HybridRecommendationRow(recommendation: recommendation)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

            Text("Recommendations are based on general guidelines from the USDA Dietary Guidelines for Americans and WHO physical activity recommendations. This app is not a substitute for professional medical advice.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
    
    // MARK: - Detailed Analytics (from Option 3)
    
    private var detailedAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Analytics")
                .font(.headline)
                .foregroundColor(.deepCharcoal)

            if viewModel.nutrientBreakdown.isEmpty {
                // Empty state when no food has been logged
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No nutrition data yet")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("Start logging your meals to see detailed nutrient analytics")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            } else {
                // Nutrient Breakdown Table
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Nutrient")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                        Text("Goal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                        Text("Status")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 80)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.tertiarySystemFill))

                    Divider()

                    // Rows
                    ForEach(viewModel.nutrientBreakdown) { nutrient in
                        HybridNutrientRow(nutrient: nutrient)
                        Divider()
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Supporting Views

struct AIInsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundColor(insight.color)
                
                Spacer()
                
                if insight.isNew {
                    Text("NEW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            Text(insight.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.deepCharcoal)
                .lineLimit(2)
            
            Text(insight.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Label("\(insight.impact)", systemImage: "arrow.up.circle.fill")
                    .font(.caption)
                    .foregroundColor(insight.color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MetricCardWithTrend: View {
    let title: String
    let value: String
    let subtitle: String
    let trend: Trend
    let trendValue: String
    let icon: String
    let color: Color
    let sparklineData: [Double]
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption2)
                    Text(trendValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(trend.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.deepCharcoal)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Mini Sparkline
            GeometryReader { geometry in
                Path { path in
                    guard sparklineData.count > 1 else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let maxValue = sparklineData.max() ?? 1
                    let minValue = sparklineData.min() ?? 0
                    let range = maxValue - minValue
                    
                    for (index, value) in sparklineData.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(sparklineData.count - 1)
                        let y = height - (height * CGFloat(value - minValue) / CGFloat(range))
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color.opacity(0.6), lineWidth: 2)
            }
            .frame(height: 30)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct HybridRecommendationRow: View {
    let recommendation: AIRecommendation
    @State private var isCompleted = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: recommendation.icon)
                .font(.title3)
                .foregroundColor(recommendation.color)
                .frame(width: 40, height: 40)
                .background(recommendation.color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.deepCharcoal)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let actionText = recommendation.actionText {
                    Text(actionText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(recommendation.color)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    isCompleted.toggle()
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 8)
        .opacity(isCompleted ? 0.6 : 1)
    }
}

struct HybridNutrientRow: View {
    let nutrient: NutrientBreakdown
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(nutrient.color)
                    .frame(width: 8, height: 8)
                Text(nutrient.name)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(nutrient.current)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60)
            
            Text(nutrient.goal)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 60)
            
            HStack(spacing: 4) {
                Image(systemName: nutrient.statusIcon)
                    .font(.caption)
                Text(nutrient.statusText)
                    .font(.caption)
            }
            .foregroundColor(nutrient.statusColor)
            .frame(width: 80)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - View Models and Data Models

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let impact: String
    let isNew: Bool
}

struct AIRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actionText: String?
}

struct NutrientBreakdown: Identifiable {
    let id = UUID()
    let name: String
    let current: String
    let goal: String
    let percentage: Double
    let color: Color
    
    var statusIcon: String {
        if percentage >= 90 && percentage <= 110 {
            return "checkmark.circle.fill"
        } else if percentage < 90 {
            return "exclamationmark.circle.fill"
        } else {
            return "arrow.up.circle.fill"
        }
    }
    
    var statusColor: Color {
        if percentage >= 90 && percentage <= 110 {
            return .green
        } else if percentage < 90 {
            return .orange
        } else {
            return .red
        }
    }
    
    var statusText: String {
        return "\(Int(percentage))% RDA"
    }
}

// MARK: - Preview

// #Preview {
//     NavigationView {
//         DashboardView()
//     }
// }