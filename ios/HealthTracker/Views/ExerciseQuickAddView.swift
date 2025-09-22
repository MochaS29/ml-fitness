import SwiftUI
import CoreData

struct ExerciseQuickAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedExercise: ExerciseTemplateModel?
    @State private var duration: Double = 30
    @State private var customCalories: String = ""
    @State private var showingCustomExercise = false

    // Pre-populated exercises we've created
    let presetExercises = [
        ExerciseTemplateModel(name: "Walking", type: .cardio, caloriesPerMinute: 5, category: "Outdoor"),
        ExerciseTemplateModel(name: "Running", type: .cardio, caloriesPerMinute: 10, category: "Outdoor"),
        ExerciseTemplateModel(name: "Cycling", type: .cardio, caloriesPerMinute: 8, category: "Outdoor"),
        ExerciseTemplateModel(name: "Swimming", type: .cardio, caloriesPerMinute: 11, category: "Water"),
        ExerciseTemplateModel(name: "Weight Training", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplateModel(name: "Yoga", type: .flexibility, caloriesPerMinute: 3, category: "Mind & Body"),
        ExerciseTemplateModel(name: "HIIT", type: .cardio, caloriesPerMinute: 12, category: "High Intensity"),
        ExerciseTemplateModel(name: "Pilates", type: .flexibility, caloriesPerMinute: 4, category: "Mind & Body"),
        ExerciseTemplateModel(name: "Dancing", type: .cardio, caloriesPerMinute: 7, category: "Fun"),
        ExerciseTemplateModel(name: "Hiking", type: .cardio, caloriesPerMinute: 6, category: "Outdoor"),
        ExerciseTemplateModel(name: "Tennis", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplateModel(name: "Basketball", type: .sports, caloriesPerMinute: 9, category: "Sports")
    ]

    var estimatedCalories: Int {
        if let exercise = selectedExercise {
            return Int(Double(exercise.caloriesPerMinute) * duration)
        }
        return 0
    }

    var estimatedSteps: Int {
        // Estimate steps based on exercise type and duration
        guard let exercise = selectedExercise else { return 0 }

        switch exercise.name {
        case "Walking":
            return Int(duration * 100) // ~100 steps per minute walking
        case "Running":
            return Int(duration * 160) // ~160 steps per minute running
        case "Hiking":
            return Int(duration * 80) // ~80 steps per minute hiking
        case "Dancing":
            return Int(duration * 70) // ~70 steps per minute dancing
        case "Cycling", "Swimming", "Weight Training", "Yoga", "Pilates":
            return 0 // These don't contribute to steps
        default:
            return Int(duration * 50) // Default estimate for other activities
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Exercise Selection Grid
                    exerciseGrid

                    // Duration Selector
                    durationSelector

                    // Estimated Impact
                    if selectedExercise != nil {
                        impactCard
                    }

                    // Quick Duration Buttons
                    quickDurationButtons

                    // Add Button
                    addButton
                }
                .padding()
            }
            .navigationTitle("Quick Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Custom") {
                        showingCustomExercise = true
                    }
                }
            }
            .sheet(isPresented: $showingCustomExercise) {
                // Custom exercise entry view
                CustomExerciseEntryView()
            }
        }
    }

    private var exerciseGrid: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Select Exercise")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presetExercises) { exercise in
                    ExerciseButton(
                        exercise: exercise,
                        isSelected: selectedExercise?.id == exercise.id,
                        action: {
                            selectedExercise = exercise
                        }
                    )
                }
            }
        }
    }

    private var durationSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Duration")
                .font(.headline)

            HStack {
                Text("\(Int(duration)) minutes")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Stepper("", value: $duration, in: 5...180, step: 5)
                    .labelsHidden()
            }

            Slider(value: $duration, in: 5...180, step: 5)
                .accentColor(.blue)

            HStack {
                Text("5 min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("3 hours")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var impactCard: some View {
        VStack(spacing: 15) {
            Text("Estimated Impact")
                .font(.headline)

            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("\(estimatedCalories)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                if estimatedSteps > 0 {
                    Divider()
                        .frame(height: 50)

                    VStack {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("\(estimatedSteps)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    private var quickDurationButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                    Button(action: { duration = Double(minutes) }) {
                        Text("\(minutes) min")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(
                                duration == Double(minutes) ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(
                                duration == Double(minutes) ? .white : .primary
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button(action: addExercise) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add to Today's Activity")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedExercise != nil ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(selectedExercise == nil)
    }

    private func addExercise() {
        guard let exercise = selectedExercise else { return }

        let newEntry = ExerciseEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = exercise.name
        newEntry.type = exercise.type.rawValue
        newEntry.duration = Int32(duration)
        newEntry.caloriesBurned = Double(estimatedCalories)
        newEntry.timestamp = Date()

        // If this exercise contributes to steps, also update step count
        if estimatedSteps > 0 {
            // Here you would update the step count in your step tracking system
            // For now, we'll just save the exercise
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

struct ExerciseButton: View {
    let exercise: ExerciseTemplateModel
    let isSelected: Bool
    let action: () -> Void

    var iconName: String {
        switch exercise.type {
        case .cardio:
            return "heart.fill"
        case .strength:
            return "dumbbell.fill"
        case .flexibility:
            return "figure.yoga"
        case .sports:
            return "sportscourt.fill"
        case .other:
            return "star.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(exercise.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct CustomExerciseEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name = ""
    @State private var duration = ""
    @State private var calories = ""
    @State private var steps = ""
    @State private var selectedType: ExerciseType = .other

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)

                    Picker("Type", selection: $selectedType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Duration & Impact") {
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)

                    TextField("Calories Burned", text: $calories)
                        .keyboardType(.numberPad)

                    TextField("Steps (if applicable)", text: $steps)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Custom Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomExercise()
                    }
                    .disabled(name.isEmpty || duration.isEmpty || calories.isEmpty)
                }
            }
        }
    }

    private func saveCustomExercise() {
        let newEntry = ExerciseEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = name
        newEntry.type = selectedType.rawValue
        newEntry.duration = Int32(duration) ?? 0
        newEntry.caloriesBurned = Double(calories) ?? 0
        newEntry.timestamp = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving custom exercise: \(error)")
        }
    }
}

struct ExerciseQuickAddView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseQuickAddView()
    }
}