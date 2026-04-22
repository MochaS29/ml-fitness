import SwiftUI
import CoreData

// MARK: - Quick Add (preset grid)

struct ExerciseQuickAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedExercise: ExerciseTemplateModel?
    @State private var duration: Double = 30
    @State private var showingActivityDatabase = false

    let presetExercises = [
        ExerciseDatabase.shared.getExercise(named: "Walking (brisk)") ??
            ExerciseTemplateModel(name: "Walking", type: .cardio, met: 4.3, category: "Walking & Hiking", sfSymbol: "figure.walk"),
        ExerciseDatabase.shared.getExercise(named: "Running (5 mph)") ??
            ExerciseTemplateModel(name: "Running", type: .cardio, met: 8.3, category: "Running", sfSymbol: "figure.run"),
        ExerciseDatabase.shared.getExercise(named: "Cycling (moderate)") ??
            ExerciseTemplateModel(name: "Cycling", type: .cardio, met: 8.0, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseDatabase.shared.getExercise(named: "Swimming (moderate)") ??
            ExerciseTemplateModel(name: "Swimming", type: .cardio, met: 5.8, category: "Water", sfSymbol: "figure.pool.swim"),
        ExerciseDatabase.shared.getExercise(named: "Weight Training") ??
            ExerciseTemplateModel(name: "Weight Training", type: .strength, met: 3.5, category: "Strength", sfSymbol: "dumbbell"),
        ExerciseDatabase.shared.getExercise(named: "Yoga (gentle)") ??
            ExerciseTemplateModel(name: "Yoga", type: .flexibility, met: 2.5, category: "Mind & Body", sfSymbol: "figure.yoga"),
        ExerciseDatabase.shared.getExercise(named: "HIIT") ??
            ExerciseTemplateModel(name: "HIIT", type: .cardio, met: 8.0, category: "Gym & Cardio", sfSymbol: "bolt.heart"),
        ExerciseDatabase.shared.getExercise(named: "Pilates") ??
            ExerciseTemplateModel(name: "Pilates", type: .flexibility, met: 3.0, category: "Mind & Body", sfSymbol: "figure.pilates"),
        ExerciseDatabase.shared.getExercise(named: "Dancing (general)") ??
            ExerciseTemplateModel(name: "Dancing", type: .cardio, met: 4.5, category: "Dance & Performance", sfSymbol: "music.note"),
        ExerciseDatabase.shared.getExercise(named: "Hiking") ??
            ExerciseTemplateModel(name: "Hiking", type: .cardio, met: 5.3, category: "Walking & Hiking", sfSymbol: "mountain.2"),
        ExerciseDatabase.shared.getExercise(named: "Tennis (singles)") ??
            ExerciseTemplateModel(name: "Tennis", type: .sports, met: 7.3, category: "Racquet Sports", sfSymbol: "tennisball"),
        ExerciseDatabase.shared.getExercise(named: "Basketball") ??
            ExerciseTemplateModel(name: "Basketball", type: .sports, met: 6.5, category: "Team Sports", sfSymbol: "basketball"),
    ]

    // User body weight for MET-based calorie calculation (lbs → kg, fallback 70 kg)
    private var userWeightKg: Double {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data),
           let lbs = profile.startingWeight, lbs > 0 {
            return lbs * 0.453592
        }
        return 70.0
    }

    var estimatedCalories: Int {
        guard let exercise = selectedExercise else { return 0 }
        return exercise.calories(forDuration: duration, weightKg: userWeightKg)
    }

    var estimatedSteps: Int {
        guard let exercise = selectedExercise else { return 0 }
        switch exercise.category {
        case "Walking & Hiking":
            return Int(duration * (exercise.name.contains("brisk") ? 120 : 90))
        case "Running":
            return Int(duration * (exercise.name.contains("7.5") ? 185 : exercise.name.contains("6") ? 170 : 155))
        default:
            return 0
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Button(action: addExercise) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add to Today's Activity")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedExercise != nil ? Color.orange : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedExercise == nil)

                    if let exercise = selectedExercise, !presetExercises.contains(where: { $0.id == exercise.id }) {
                        selectedActivityBanner(exercise: exercise)
                    }

                    exerciseGrid
                    durationSelector

                    if selectedExercise != nil { impactCard }

                    quickDurationButtons
                }
                .padding()
            }
            .navigationTitle("Quick Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Browse All") { showingActivityDatabase = true }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingActivityDatabase) {
                ActivityDatabaseView { exercise in
                    selectedExercise = exercise
                    showingActivityDatabase = false
                }
            }
        }
    }

    private func selectedActivityBanner(exercise: ExerciseTemplateModel) -> some View {
        HStack(spacing: 14) {
            Image(systemName: exercise.sfSymbol)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                Text(exercise.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { selectedExercise = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }

    private var exerciseGrid: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Quick Pick")
                    .font(.headline)
                Spacer()
                Button("Browse all activities") { showingActivityDatabase = true }
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presetExercises) { exercise in
                    ExerciseButton(
                        exercise: exercise,
                        isSelected: selectedExercise?.id == exercise.id,
                        action: { selectedExercise = exercise }
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
                Text("5 min").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("3 hours").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var impactCard: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Estimated Impact")
                    .font(.headline)
                Spacer()
                if let ex = selectedExercise {
                    Text("MET \(ex.met, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

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
                    Divider().frame(height: 50)
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
                            .background(duration == Double(minutes) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(duration == Double(minutes) ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
        }
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

        do {
            try viewContext.save()
            ReviewRequestManager.shared.recordFoodLogged()
            dismiss()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

// MARK: - Exercise Button

struct ExerciseButton: View {
    let exercise: ExerciseTemplateModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: exercise.sfSymbol)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(exercise.name
                    .replacingOccurrences(of: " \\(.*\\)", with: "", options: .regularExpression)
                )
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

// MARK: - Activity Database View

struct ActivityDatabaseView: View {
    let onSelect: (ExerciseTemplateModel) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private let db = ExerciseDatabase.shared

    private var filteredExercises: [ExerciseTemplateModel] {
        if !searchText.isEmpty {
            return db.search(searchText)
        }
        return db.exercises(inCategory: selectedCategory)
    }

    private var groupedExercises: [(category: String, exercises: [ExerciseTemplateModel])] {
        if !searchText.isEmpty || selectedCategory != "All" {
            return [(category: selectedCategory == "All" ? "Results" : selectedCategory, exercises: filteredExercises)]
        }
        return ExerciseDatabase.allCategories.dropFirst().compactMap { cat in
            let items = db.exercises(inCategory: cat)
            return items.isEmpty ? nil : (category: cat, exercises: items)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search activities…", text: $searchText)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Category chips
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExerciseDatabase.allCategories, id: \.self) { cat in
                                Button(action: { selectedCategory = cat }) {
                                    Text(cat)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedCategory == cat ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }

                Divider()

                // Exercise list
                List {
                    ForEach(groupedExercises, id: \.category) { group in
                        Section(group.category) {
                            ForEach(group.exercises) { exercise in
                                ActivityRow(exercise: exercise, onSelect: {
                                    onSelect(exercise)
                                })
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Activity Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Activity Row

private struct ActivityRow: View {
    let exercise: ExerciseTemplateModel
    let onSelect: () -> Void

    // Estimate calories for 30 min at 70 kg for the preview
    private var cal30: Int { exercise.calories(forDuration: 30, weightKg: 70) }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(typeColor(exercise.type).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: exercise.sfSymbol)
                        .foregroundColor(typeColor(exercise.type))
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("~\(cal30) cal / 30 min  ·  MET \(exercise.met, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func typeColor(_ type: ExerciseType) -> Color {
        switch type {
        case .cardio:     return .orange
        case .strength:   return .blue
        case .flexibility: return .purple
        case .sports:     return .green
        case .other:      return .teal
        }
    }
}

struct ExerciseQuickAddView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseQuickAddView()
    }
}
