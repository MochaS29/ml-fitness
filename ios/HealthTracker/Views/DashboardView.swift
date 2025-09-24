import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTimeRange = TimeRange.week
    @State private var showingAIInsightDetail = false
    @State private var selectedInsight: AIInsight?
    @State private var animateCharts = false
    @State private var showingCalorieDetail = false
    @State private var showingWeightDetail = false
    @State private var showingExerciseDetail = false
    @State private var showingWaterDetail = false
    @State private var showingSupplementDetail = false
    @State private var showingStepDetail = false
    @State private var showingStepGoal = false
    @State private var showingExerciseQuickAdd = false
    @State private var showingAllInsights = false
    @State private var widgetsEnabled = false

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
                    // AI Insights Carousel (from Option 4)
                    aiInsightsSection

                    // Key Metrics Cards with Trends (from Option 3)
                    metricsOverview

                    // Supplement Stats Widget
                    SupplementStatsWidget(showingDetail: $showingSupplementDetail)

                    // Interactive Charts Section (from Option 3)
                    chartsSection

                    // AI Recommendations (from Option 4)
                    aiRecommendationsSection

                    // Detailed Analytics (from Option 3)
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
        .sheet(item: $selectedInsight) { insight in
            AIInsightDetailView(insight: insight)
        }
        .sheet(isPresented: $showingCalorieDetail) {
            FoodTrackingView()
        }
        .sheet(isPresented: $showingWeightDetail) {
            WeightTrackingView()
        }
        .sheet(isPresented: $showingExerciseDetail) {
            ExerciseTrackingView()
        }
        .sheet(isPresented: $showingWaterDetail) {
            WaterTrackingView()
        }
        .sheet(isPresented: $showingSupplementDetail) {
            EnhancedSupplementTrackingView()
        }
        .sheet(isPresented: $showingStepDetail) {
            StepDetailsView()
        }
        .sheet(isPresented: $showingStepGoal) {
            StepGoalView()
        }
        .sheet(isPresented: $showingExerciseQuickAdd) {
            ExerciseQuickAddView()
        }
        .sheet(isPresented: $showingAllInsights) {
            AllInsightsView(insights: viewModel.aiInsights)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Welcome Message with AI Touch
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(viewModel.userName)!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.deepCharcoal)

                Text(viewModel.aiGreeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Overall Health Score with AI Analysis
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
                
                Button(action: { showingAllInsights = true }) {
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
                                selectedInsight = insight
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
                showingStepGoal = true  // Show the new StepGoalView
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
                showingWeightDetail = true
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
                showingExerciseQuickAdd = true
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
                showingWaterDetail = true
            }
        }
    }
    
    // MARK: - Charts Section (from Option 3)

    private var chartsSection: some View {
        VStack(spacing: 20) {
            // Steps Chart - Weekly View
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.walk")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("Steps - Weekly")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                    }
                    Spacer()
                }

                Chart(viewModel.getWeeklyStepsData()) { dataPoint in
                    BarMark(
                        x: .value("Time", dataPoint.date),
                        y: .value("Steps", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green.opacity(0.8), .mint.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

            // Weight Chart
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "scalemass")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Weight Trend")
                        .font(.headline)
                        .foregroundColor(.deepCharcoal)
                    Spacer()
                }

                Chart(viewModel.getWeightData(for: selectedTimeRange)) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.value)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.value)
                    )
                    .foregroundStyle(Color.blue)
                    .symbolSize(50)
                }
                .frame(height: 150)
                .chartYScale(domain: viewModel.getWeightRange(for: selectedTimeRange))
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

            // Exercise Minutes Chart
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("Exercise Minutes")
                        .font(.headline)
                        .foregroundColor(.deepCharcoal)
                    Spacer()
                }
                .padding(.bottom, 4)

                Chart(viewModel.getExerciseData(for: selectedTimeRange)) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Minutes", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 150)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

            // Nutrition Distribution Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Nutrition Distribution")
                    .font(.headline)
                    .foregroundColor(.deepCharcoal)
                
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
                
                // Legend
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
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            // Weekly Trend Chart
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Weekly Trends")
                        .font(.headline)
                        .foregroundColor(.deepCharcoal)
                    
                    Spacer()
                    
                    // Metric Selector
                    Menu {
                        Button("Calories") { }
                        Button("Weight") { }
                        Button("Exercise") { }
                        Button("Water") { }
                    } label: {
                        Label("Calories", systemImage: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.mindfulTeal)
                    }
                }
                
                Chart(viewModel.weeklyData) { item in
                    LineMark(
                        x: .value("Day", item.day),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.wellnessGreen, .mindfulTeal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .opacity(animateCharts ? 1 : 0)
                    
                    AreaMark(
                        x: .value("Day", item.day),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.wellnessGreen.opacity(0.3), .mindfulTeal.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(animateCharts ? 1 : 0)
                    
                    PointMark(
                        x: .value("Day", item.day),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(animateCharts ? 60 : 0)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...3000)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
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