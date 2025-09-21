import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalsManager = GoalsManager.shared
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    // Goal properties
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: GoalCategory = .nutrition
    @State private var targetType: GoalTargetType = .reachTarget
    @State private var targetValue: Double = 0
    @State private var targetUnit = ""
    @State private var frequency: GoalFrequency = .daily
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    
    // UI State
    @State private var showingTemplates = true
    @State private var selectedTemplate: GoalTemplate?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if showingTemplates {
                        // Template Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose a Template")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Start with a popular goal template or create your own")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(suggestedTemplates, id: \.title) { template in
                                    TemplateCard(template: template) {
                                        applyTemplate(template)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                showingTemplates = false
                            }) {
                                Label("Create Custom Goal", systemImage: "plus.circle")
                                    .font(.headline)
                                    .foregroundColor(.wellnessGreen)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.wellnessGreen.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Custom Goal Form
                        VStack(spacing: 20) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Goal Details")
                                    .font(.headline)
                                
                                TextField("Goal Title", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Description (Optional)", text: $description, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(2...4)
                            }
                            
                            // Category
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(GoalCategory.allCases, id: \.self) { category in
                                            CategoryChip(
                                                category: category,
                                                isSelected: selectedCategory == category
                                            ) {
                                                selectedCategory = category
                                                updateDefaultUnit()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Target Type
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Target Type")
                                    .font(.headline)
                                
                                Picker("Target Type", selection: $targetType) {
                                    ForEach(GoalTargetType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Text(targetType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Target Value
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Target")
                                    .font(.headline)
                                
                                HStack {
                                    TextField("0", value: $targetValue, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.decimalPad)
                                    
                                    TextField("Unit", text: $targetUnit)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 100)
                                }
                                
                                // Frequency
                                Picker("Frequency", selection: $frequency) {
                                    ForEach(GoalFrequency.allCases, id: \.self) { freq in
                                        Text("\(freq.rawValue) Goal").tag(freq)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            // Timeline
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Timeline")
                                    .font(.headline)
                                
                                DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                
                                Text("You have \(daysUntilTarget) days to reach your goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Reminder
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle("Daily Reminder", isOn: $reminderEnabled)
                                    .font(.headline)
                                
                                if reminderEnabled {
                                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                }
                            }
                            
                            // Notes
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notes (Optional)")
                                    .font(.headline)
                                
                                TextField("Add any additional notes...", text: $notes, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...5)
                            }
                            
                            Button(action: {
                                showingTemplates = true
                            }) {
                                Text("Back to Templates")
                                    .font(.caption)
                                    .foregroundColor(.wellnessGreen)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var suggestedTemplates: [GoalTemplate] {
        Goal.generateSuggestions(
            for: userProfileManager.currentProfile,
            recentData: nil // TODO: Pass actual recent data
        )
    }
    
    private var daysUntilTarget: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    private var isValid: Bool {
        !title.isEmpty && targetValue > 0 && !targetUnit.isEmpty
    }
    
    private func applyTemplate(_ template: GoalTemplate) {
        title = template.title
        description = template.description
        selectedCategory = template.category
        targetType = template.targetType
        targetValue = template.suggestedTarget
        targetUnit = template.unit
        frequency = template.frequency
        targetDate = Date().addingTimeInterval(TimeInterval(template.duration * 24 * 60 * 60))
        showingTemplates = false
    }
    
    private func updateDefaultUnit() {
        switch selectedCategory {
        case .weightLoss, .weightGain:
            targetUnit = "lbs"
        case .nutrition:
            targetUnit = "calories"
        case .exercise:
            targetUnit = "minutes"
        case .hydration:
            targetUnit = "oz"
        case .sleep:
            targetUnit = "hours"
        case .mindfulness:
            targetUnit = "minutes"
        case .custom:
            targetUnit = ""
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description.isEmpty ? "" : description,
            category: selectedCategory,
            targetType: targetType,
            targetValue: targetValue,
            targetUnit: targetUnit,
            targetDate: targetDate,
            frequency: frequency
        )
        
        var updatedGoal = goal
        updatedGoal.reminderEnabled = reminderEnabled
        updatedGoal.reminderTime = reminderEnabled ? reminderTime : nil
        updatedGoal.notes = notes.isEmpty ? nil : notes
        
        goalsManager.addGoal(updatedGoal)
        dismiss()
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: GoalTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: template.category.icon)
                    .font(.title2)
                    .foregroundColor(template.category.color)
                
                Text(template.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text("\(Int(template.suggestedTarget)) \(template.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(template.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: GoalCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// #Preview {
//     AddGoalView()
//         .environmentObject(UserProfileManager())
// }