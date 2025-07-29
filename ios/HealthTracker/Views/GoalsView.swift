import SwiftUI

struct GoalsView: View {
    @StateObject private var goalsManager = GoalsManager.shared
    @State private var selectedTab = 0
    @State private var showingAddGoal = false
    @State private var showingGoalDetail: Goal?
    @State private var showingStatistics = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("Completed").tag(1)
                    Text("All").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if goalsManager.goals.isEmpty {
                    EmptyGoalsView(showingAddGoal: $showingAddGoal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredGoals) { goal in
                                GoalCard(goal: goal)
                                    .onTapGesture {
                                        showingGoalDetail = goal
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStatistics = true }) {
                        Image(systemName: "chart.pie")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .sheet(item: $showingGoalDetail) { goal in
                GoalDetailView(goal: goal)
            }
            .sheet(isPresented: $showingStatistics) {
                GoalStatisticsView()
            }
        }
    }
    
    private var filteredGoals: [Goal] {
        switch selectedTab {
        case 0:
            return goalsManager.activeGoals
        case 1:
            return goalsManager.completedGoals
        case 2:
            return goalsManager.goals
        default:
            return goalsManager.goals
        }
    }
}

// MARK: - Empty State
struct EmptyGoalsView: View {
    @Binding var showingAddGoal: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No Goals Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set your first goal and start your journey to a healthier you!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddGoal = true }) {
                Label("Create Your First Goal", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.wellnessGreen)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: Goal
    @StateObject private var goalsManager = GoalsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: goal.category.icon)
                    .font(.title2)
                    .foregroundColor(goal.category.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    
                    HStack {
                        Text(goal.frequency.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(6)
                        
                        if goal.isOverdue {
                            Text("Overdue")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(6)
                        } else if goal.isCompleted {
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                    }
                }
                
                Spacer()
                
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: goal.progress)
                        .stroke(goal.statusColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: goal.progress)
                    
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            // Progress Details
            HStack {
                VStack(alignment: .leading) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatValue(goal.currentValue)) \(goal.targetUnit)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatValue(goal.targetValue)) \(goal.targetUnit)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // Time remaining
            if !goal.isCompleted {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if goal.isOverdue {
                        Text("Ended \(goal.targetDate, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("\(goal.daysRemaining) days remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick update button
                    if goal.isActive && !goal.isCompleted {
                        Button(action: {
                            // Quick update action
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.wellnessGreen)
                        }
                    }
                }
            }
            
            // Milestones
            if !goal.milestones.filter({ $0.isReached }).isEmpty {
                HStack(spacing: 8) {
                    ForEach(goal.milestones) { milestone in
                        Circle()
                            .fill(milestone.isReached ? Color.wellnessGreen : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Goal Statistics View
struct GoalStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalsManager = GoalsManager.shared
    
    var statistics: GoalStatistics {
        goalsManager.getGoalStatistics()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Total Goals",
                            value: "\(statistics.totalGoals)",
                            icon: "target",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Active",
                            value: "\(statistics.activeGoals)",
                            icon: "bolt.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(statistics.completedGoals)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Success Rate",
                            value: "\(Int(statistics.completionRate * 100))%",
                            icon: "percent",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goals by Category")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(statistics.categoryBreakdown.sorted(by: { $0.value > $1.value })), id: \.key) { category, count in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                    .frame(width: 30)
                                
                                Text(category.rawValue)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("\(count)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goal Setting Tips")
                            .font(.headline)
                        
                        TipRow(icon: "lightbulb", text: "Set SMART goals: Specific, Measurable, Achievable, Relevant, Time-bound")
                        TipRow(icon: "chart.line.uptrend", text: "Start small and gradually increase your targets")
                        TipRow(icon: "bell", text: "Use reminders to stay on track")
                        TipRow(icon: "star", text: "Celebrate milestones along the way")
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Goal Statistics")
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

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.wellnessGreen)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    GoalsView()
}