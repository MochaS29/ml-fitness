import SwiftUI

struct ExerciseTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExercise = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        animation: .default)
    private var exercises: FetchedResults<ExerciseEntry>

    var body: some View {
        NavigationStack {
            VStack {
                if exercises.isEmpty {
                    EmptyExerciseView(showingAddExercise: $showingAddExercise)
                } else {
                    List {
                        Section {
                            ExerciseSummaryCard(exercises: Array(exercises))
                        }
                        
                        Section("Today's Activities") {
                            ForEach(todaysExercises) { exercise in
                                ExerciseRow(exercise: exercise)
                            }
                            .onDelete(perform: deleteExercises)
                        }
                        
                        if !olderExercises.isEmpty {
                            Section("Previous Days") {
                                ForEach(olderExercises) { exercise in
                                    ExerciseRow(exercise: exercise)
                                }
                                .onDelete(perform: deleteExercises)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }
    
    var todaysExercises: [ExerciseEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return exercises.filter { exercise in
            guard let timestamp = exercise.timestamp else { return false }
            return calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    var olderExercises: [ExerciseEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return exercises.filter { exercise in
            guard let timestamp = exercise.timestamp else { return false }
            return !calendar.isDate(timestamp, inSameDayAs: today)
        }
    }
    
    func deleteExercises(offsets: IndexSet) {
        withAnimation {
            offsets.map { exercises[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting exercise: \(error)")
            }
        }
    }
}

struct EmptyExerciseView: View {
    @Binding var showingAddExercise: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Exercise Tracked")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your workouts to monitor calories burned and stay active")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddExercise = true }) {
                Label("Add Exercise", systemImage: "plus.circle")
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct ExerciseSummaryCard: View {
    let exercises: [ExerciseEntry]
    
    var totalCalories: Double {
        exercises.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var totalDuration: Int {
        exercises.reduce(0) { $0 + Int($1.duration) }
    }
    
    var totalActivities: Int {
        exercises.count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Today's Summary")
                .font(.headline)
            
            HStack {
                ExerciseSummaryMetric(
                    value: "0",
                    label: "Calories Burned",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ExerciseSummaryMetric(
                    value: "0",
                    label: "Minutes",
                    icon: "clock.fill",
                    color: .blue
                )
                
                ExerciseSummaryMetric(
                    value: "0",
                    label: "Activities",
                    icon: "figure.run",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ExerciseSummaryMetric: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseRow: View {
    let exercise: ExerciseEntry
    
    var body: some View {
        HStack {
            Image(systemName: exerciseIcon(for: exercise.type ?? ""))
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name ?? "Unknown Exercise")
                    .font(.headline)
                
                HStack {
                    Text("\(exercise.duration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(exercise.caloriesBurned)) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let timestamp = exercise.timestamp {
                Text(timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    func exerciseIcon(for type: String) -> String {
        switch type.lowercased() {
        case "running", "run":
            return "figure.run"
        case "cycling", "bike":
            return "bicycle"
        case "swimming", "swim":
            return "figure.pool.swim"
        case "weight training", "weights":
            return "dumbbell.fill"
        case "yoga":
            return "figure.mind.and.body"
        case "walking", "walk":
            return "figure.walk"
        default:
            return "figure.run"
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var exerciseName = ""
    @State private var exerciseType = ExerciseType.cardio
    @State private var duration: Int = 30
    @State private var caloriesBurned: Double = 0
    @State private var notes = ""
    @State private var showingSuggestions = false
    @State private var suggestions: [ExerciseTemplateModel] = []
    @State private var smartSuggestions: [ExerciseAutofillService.ExerciseSuggestion] = []
    @State private var selectedDate = Date()
    
    private let exerciseDatabase = ExerciseDatabase.shared
    private let autofillService = ExerciseAutofillService.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Details") {
                    VStack(alignment: .leading) {
                        TextField("Exercise Name", text: $exerciseName)
                            .onChange(of: exerciseName) { _, newValue in
                                // Get both smart suggestions and regular search
                                smartSuggestions = autofillService.getSuggestions(
                                    for: newValue,
                                    at: selectedDate,
                                    context: viewContext
                                )
                                suggestions = exerciseDatabase.searchExercises(newValue)
                                showingSuggestions = !smartSuggestions.isEmpty || (!suggestions.isEmpty && !newValue.isEmpty)
                            }
                        
                        if showingSuggestions {
                            VStack(alignment: .leading, spacing: 8) {
                                // Smart suggestions section
                                if !smartSuggestions.isEmpty {
                                    Text("Suggested for you")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(smartSuggestions.prefix(3), id: \.exercise.name) { suggestion in
                                        SmartSuggestionRow(
                                            suggestion: suggestion,
                                            onSelect: { selectSmartSuggestion(suggestion) }
                                        )
                                        
                                        if suggestion.exercise.name != smartSuggestions.prefix(3).last?.exercise.name {
                                            Divider()
                                        }
                                    }
                                }
                                
                                // Regular search results
                                if !suggestions.isEmpty && !exerciseName.isEmpty {
                                    if !smartSuggestions.isEmpty {
                                        Divider()
                                        Text("All exercises")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 4)
                                            .padding(.top, 4)
                                    }
                                    
                                    ForEach(suggestions.prefix(5), id: \.name) { suggestion in
                                        Button(action: {
                                            selectExercise(suggestion)
                                        }) {
                                            HStack {
                                                Text(suggestion.name)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(suggestion.type.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 4)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if suggestion.name != suggestions.prefix(5).last?.name {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        }
                    }
                    
                    Picker("Type", selection: $exerciseType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 1...300, step: 5)
                }
                
                Section("Calories Burned") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $caloriesBurned, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.numberPad)
                    }
                    
                    Text("Estimate: \(estimatedCalories()) calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
            .onAppear {
                caloriesBurned = Double(estimatedCalories())
                // Load initial smart suggestions
                smartSuggestions = autofillService.getSuggestions(
                    for: "",
                    at: selectedDate,
                    context: viewContext
                )
                showingSuggestions = !smartSuggestions.isEmpty
            }
            .onChange(of: duration) { _, _ in
                caloriesBurned = Double(estimatedCalories())
            }
            .onChange(of: exerciseType) { _, _ in
                caloriesBurned = Double(estimatedCalories())
            }
            .onChange(of: exerciseName) { _, _ in
                caloriesBurned = Double(estimatedCalories())
            }
        }
    }
    
    func selectExercise(_ template: ExerciseTemplateModel) {
        exerciseName = template.name
        exerciseType = template.type
        showingSuggestions = false
        
        // Update calories based on selected exercise
        caloriesBurned = template.caloriesPerMinute * Double(duration)
    }
    
    func selectSmartSuggestion(_ suggestion: ExerciseAutofillService.ExerciseSuggestion) {
        exerciseName = suggestion.exercise.name
        exerciseType = ExerciseType(rawValue: suggestion.exercise.type.rawValue) ?? .other
        
        // Use typical duration if available
        if let typicalDuration = suggestion.typicalDuration {
            duration = typicalDuration
        }
        
        // Use typical calories if available
        if let typicalCalories = suggestion.typicalCalories {
            caloriesBurned = Double(typicalCalories)
        } else {
            caloriesBurned = suggestion.exercise.caloriesPerMinute * Double(duration)
        }
        
        showingSuggestions = false
    }
    
    func estimatedCalories() -> Int {
        // Check if we have a specific exercise selected
        if let template = exerciseDatabase.getExercise(named: exerciseName) {
            return Int(template.caloriesPerMinute * Double(duration))
        }
        
        // Otherwise use generic estimation
        let caloriesPerMinute: Double = {
            switch exerciseType {
            case .cardio: return 10
            case .strength: return 6
            case .flexibility: return 3
            case .sports: return 8
            case .other: return 5
            }
        }()
        
        return Int(caloriesPerMinute * Double(duration))
    }
    
    func saveExercise() {
        let newExercise = ExerciseEntry(context: viewContext)
        newExercise.id = UUID()
        newExercise.name = exerciseName
        newExercise.type = exerciseType.rawValue
        newExercise.duration = Int32(duration)
        newExercise.caloriesBurned = caloriesBurned
        newExercise.notes = notes.isEmpty ? nil : notes
        newExercise.timestamp = Date()
        
        do {
            try viewContext.save()
            
            // Update goals based on the new exercise entry
            GoalsManager.shared.updateGoalsFromExerciseEntry(newExercise)
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

enum ExerciseType: String, CaseIterable {
    case cardio = "Cardio"
    case strength = "Strength Training"
    case flexibility = "Flexibility"
    case sports = "Sports"
    case other = "Other"
}

struct SmartSuggestionRow: View {
    let suggestion: ExerciseAutofillService.ExerciseSuggestion
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(suggestion.exercise.name)
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Reason indicator
                    Image(systemName: reasonIcon)
                        .font(.caption)
                        .foregroundColor(reasonColor)
                }
                
                HStack {
                    // Confidence indicator
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(
                                    Double(index) / 5.0 <= suggestion.confidence
                                    ? Color(red: 127/255, green: 176/255, blue: 105/255)
                                    : Color(UIColor.systemGray4)
                                )
                        }
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    // Additional info
                    if let duration = suggestion.typicalDuration {
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastPerformed = suggestion.lastPerformed {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(relativeTimeString(from: lastPerformed))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var reasonIcon: String {
        switch suggestion.reason {
        case .frequentlyUsed:
            return "star.fill"
        case .timeOfDay:
            return "clock.fill"
        case .dayOfWeek:
            return "calendar"
        case .recentlyUsed:
            return "arrow.clockwise"
        case .similarToInput:
            return "magnifyingglass"
        case .followsPattern:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    private var reasonColor: Color {
        switch suggestion.reason {
        case .frequentlyUsed:
            return .yellow
        case .timeOfDay:
            return .blue
        case .dayOfWeek:
            return .purple
        case .recentlyUsed:
            return .orange
        case .similarToInput:
            return .green
        case .followsPattern:
            return Color(red: 74/255, green: 155/255, blue: 155/255)
        }
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}