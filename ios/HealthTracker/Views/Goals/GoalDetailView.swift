import SwiftUI
import Charts

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalsManager = GoalsManager.shared
    
    let goal: Goal
    @State private var showingEditGoal = false
    @State private var showingDeleteAlert = false
    @State private var showingUpdateProgress = false
    @State private var newProgressValue: Double = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Card
                    progressCard
                    
                    // Stats
                    statsSection
                    
                    // Progress Chart
                    if !progressHistory.isEmpty {
                        progressChart
                    }
                    
                    // Milestones
                    milestonesSection
                    
                    // Actions
                    actionsSection
                    
                    // Notes
                    if let notes = goal.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                .padding()
            }
            .navigationTitle(goal.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditGoal = true }) {
                            Label("Edit Goal", systemImage: "pencil")
                        }
                        
                        Button(action: { toggleActive() }) {
                            Label(
                                goal.isActive ? "Pause Goal" : "Resume Goal",
                                systemImage: goal.isActive ? "pause.circle" : "play.circle"
                            )
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditGoal) {
                EditGoalView(goal: goal)
            }
            .sheet(isPresented: $showingUpdateProgress) {
                UpdateProgressView(
                    goal: goal,
                    currentValue: goal.currentValue,
                    onUpdate: { newValue in
                        goalsManager.updateProgress(for: goal.id, newValue: newValue)
                        dismiss()
                    }
                )
            }
            .alert("Delete Goal", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    goalsManager.deleteGoal(goal)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this goal? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Components
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(
                        goal.statusColor,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: goal.progress)
                
                VStack {
                    Text("\(goal.progressPercentage)%")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text(goal.isCompleted ? "Completed!" : "Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Current vs Target
            HStack(spacing: 40) {
                VStack {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatValue(goal.currentValue)) \(goal.targetUnit)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                VStack {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatValue(goal.targetValue)) \(goal.targetUnit)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatBox(
                title: "Days Remaining",
                value: goal.isCompleted ? "Done" : "\(goal.daysRemaining)",
                icon: "calendar",
                color: goal.isOverdue ? .red : .blue
            )
            
            StatBox(
                title: "Frequency",
                value: goal.frequency.rawValue,
                icon: "repeat",
                color: .green
            )
            
            StatBox(
                title: "Target Type",
                value: goal.targetType.rawValue,
                icon: "target",
                color: .orange
            )
            
            StatBox(
                title: "Category",
                value: goal.category.rawValue,
                icon: goal.category.icon,
                color: goal.category.color
            )
        }
    }
    
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress History")
                .font(.headline)
            
            Chart(progressHistory) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Progress", entry.value)
                )
                .foregroundStyle(goal.category.color)
                
                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Progress", entry.value)
                )
                .foregroundStyle(goal.category.color.opacity(0.2))
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
            
            ForEach(goal.milestones) { milestone in
                HStack {
                    Image(systemName: milestone.isReached ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(milestone.isReached ? .wellnessGreen : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(milestone.percentage)% - \(milestone.reward ?? "Milestone")")
                            .font(.subheadline)
                            .foregroundColor(milestone.isReached ? .primary : .secondary)
                        
                        if let date = milestone.reachedDate {
                            Text("Reached on \(date, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if goal.isActive && !goal.isCompleted {
                Button(action: { showingUpdateProgress = true }) {
                    Label("Update Progress", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.wellnessGreen)
                        .cornerRadius(10)
                }
                
                if goal.progress >= 1.0 {
                    Button(action: markAsCompleted) {
                        Label("Mark as Completed", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Actions
    
    private func toggleActive() {
        goalsManager.toggleGoalActive(goal)
        dismiss()
    }
    
    private func markAsCompleted() {
        goalsManager.completeGoal(goal)
        dismiss()
    }
    
    // MARK: - Helpers
    
    private func formatValue(_ value: Double) -> String {
        if value == Double(Int(value)) {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    // Mock progress history - in real app, this would come from stored data
    private var progressHistory: [ProgressEntry] {
        let days = min(30, Calendar.current.dateComponents([.day], from: goal.startDate, to: Date()).day ?? 0)
        return (0..<days).map { day in
            ProgressEntry(
                date: goal.startDate.addingTimeInterval(Double(day) * 24 * 60 * 60),
                value: Double(day) / Double(days) * goal.currentValue
            )
        }
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
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

struct UpdateProgressView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @State private var currentValue: Double
    let onUpdate: (Double) -> Void
    
    init(goal: Goal, currentValue: Double, onUpdate: @escaping (Double) -> Void) {
        self.goal = goal
        self._currentValue = State(initialValue: currentValue)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Progress")) {
                    HStack {
                        Text("Value")
                        Spacer()
                        TextField("0", value: $currentValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                        Text(goal.targetUnit)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick increment buttons
                    if goal.frequency == .daily {
                        HStack {
                            ForEach([1, 5, 10, 25], id: \.self) { increment in
                                Button("+\(increment)") {
                                    currentValue += Double(increment)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Section {
                    Text("Progress: \(Int((currentValue / goal.targetValue) * 100))%")
                        .font(.headline)
                        .foregroundColor(.wellnessGreen)
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onUpdate(currentValue)
                    }
                }
            }
        }
    }
}

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalsManager = GoalsManager.shared
    
    let goal: Goal
    
    // Goal properties
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: GoalCategory
    @State private var targetType: GoalTargetType
    @State private var targetValue: Double
    @State private var targetUnit: String
    @State private var frequency: GoalFrequency
    @State private var targetDate: Date
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var notes: String
    @State private var isActive: Bool
    
    init(goal: Goal) {
        self.goal = goal
        self._title = State(initialValue: goal.title)
        self._description = State(initialValue: goal.description)
        self._selectedCategory = State(initialValue: goal.category)
        self._targetType = State(initialValue: goal.targetType)
        self._targetValue = State(initialValue: goal.targetValue)
        self._targetUnit = State(initialValue: goal.targetUnit)
        self._frequency = State(initialValue: goal.frequency)
        self._targetDate = State(initialValue: goal.targetDate)
        self._reminderEnabled = State(initialValue: goal.reminderEnabled)
        self._reminderTime = State(initialValue: goal.reminderTime ?? Date())
        self._notes = State(initialValue: goal.notes ?? "")
        self._isActive = State(initialValue: goal.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Category & Type")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    Picker("Target Type", selection: $targetType) {
                        ForEach(GoalTargetType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Target")) {
                    HStack {
                        TextField("Target Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Unit", text: $targetUnit)
                            .frame(width: 100)
                    }
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(GoalFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
                
                Section(header: Text("Reminder")) {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Additional")) {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                    
                    Toggle("Active", isOn: $isActive)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && targetValue > 0 && !targetUnit.isEmpty
    }
    
    private func saveChanges() {
        var updatedGoal = goal
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.category = selectedCategory
        updatedGoal.targetType = targetType
        updatedGoal.targetValue = targetValue
        updatedGoal.targetUnit = targetUnit
        updatedGoal.frequency = frequency
        updatedGoal.targetDate = targetDate
        updatedGoal.reminderEnabled = reminderEnabled
        updatedGoal.reminderTime = reminderEnabled ? reminderTime : nil
        updatedGoal.notes = notes.isEmpty ? nil : notes
        updatedGoal.isActive = isActive
        
        goalsManager.updateGoal(updatedGoal)
        dismiss()
    }
}

// MARK: - Progress Entry

struct ProgressEntry: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// #Preview {
//     GoalDetailView(goal: Goal(
//         title: "Lose 10 Pounds",
//         description: "Achieve a healthy weight loss",
//         category: .weightLoss,
//         targetType: .reachTarget,
//         targetValue: 10,
//         targetUnit: "lbs",
//         targetDate: Date().addingTimeInterval(60 * 24 * 60 * 60),
//         frequency: .total
//     ))
// }