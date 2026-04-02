import SwiftUI
import CoreData

// MARK: - Water Entry Sheet
struct WaterEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @State private var waterAmount = "8"
    @State private var selectedUnit = "oz"

    var body: some View {
        NavigationView {
            Form {
                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $waterAmount)
                            .keyboardType(.decimalPad)

                        Picker("Unit", selection: $selectedUnit) {
                            Text("oz").tag("oz")
                            Text("ml").tag("ml")
                            Text("cups").tag("cups")
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("Quick Add") {
                    HStack(spacing: 15) {
                        ForEach([8, 16, 24, 32], id: \.self) { ounces in
                            Button(action: {
                                dataManager.quickAddWater(Double(ounces))
                                dismiss()
                            }) {
                                Text("\(ounces) oz")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Double(waterAmount) {
                            var amountInOz = amount

                            // Convert to oz if needed
                            switch selectedUnit {
                            case "ml":
                                amountInOz = amount / 29.5735
                            case "cups":
                                amountInOz = amount * 8
                            default:
                                break
                            }

                            dataManager.quickAddWater(amountInOz)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Entry Sheet
struct ExerciseEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @State private var exerciseName = ""
    @State private var duration = "30"
    @State private var calories = ""
    @State private var selectedCategory = "Cardio"
    @State private var notes = ""
    @State private var caloriesManuallyEdited = false

    let categories = ["Cardio", "Strength", "Flexibility", "Sports", "Other"]

    // MET-based calorie estimate (70 kg default weight)
    private var estimatedCalories: Int {
        let mins = Double(duration) ?? 30
        let met: Double
        switch selectedCategory {
        case "Cardio":    met = 7.5
        case "Strength":  met = 5.0
        case "Flexibility": met = 3.0
        case "Sports":    met = 7.0
        default:          met = 5.0
        }
        return Int((met * 70.0 * mins) / 60.0)
    }

    private var recentExercises: [(name: String, category: String, duration: Int, calories: Double)] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 50
        guard let entries = try? context.fetch(request) else { return [] }
        var seen = Set<String>()
        var results: [(name: String, category: String, duration: Int, calories: Double)] = []
        for e in entries {
            guard let name = e.name, !seen.contains(name) else { continue }
            seen.insert(name)
            results.append((name: name, category: e.category ?? "Other", duration: Int(e.duration), calories: e.caloriesBurned))
            if results.count == 5 { break }
        }
        return results
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $exerciseName)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .onChange(of: selectedCategory) {
                        if !caloriesManuallyEdited {
                            calories = "\(estimatedCalories)"
                        }
                    }

                    HStack {
                        TextField("Duration", text: $duration)
                            .keyboardType(.numberPad)
                        Text("minutes")
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: duration) {
                        if !caloriesManuallyEdited {
                            calories = "\(estimatedCalories)"
                        }
                    }

                    HStack {
                        TextField("Calories burned (est. \(estimatedCalories))", text: $calories)
                            .keyboardType(.numberPad)
                            .onChange(of: calories) {
                                caloriesManuallyEdited = true
                            }
                        Text("cal")
                            .foregroundColor(.secondary)
                    }
                }

                // Recent exercises
                let recents = recentExercises
                if !recents.isEmpty {
                    Section("Recent Exercises") {
                        ForEach(recents, id: \.name) { recent in
                            Button(action: {
                                exerciseName = recent.name
                                selectedCategory = recent.category
                                duration = "\(recent.duration)"
                                calories = "\(Int(recent.calories))"
                                caloriesManuallyEdited = true
                            }) {
                                HStack {
                                    Image(systemName: recent.category == "Cardio" ? "figure.run" : "dumbbell")
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(recent.name)
                                            .foregroundColor(.primary)
                                            .font(.subheadline)
                                        Text("\(recent.duration) min · \(Int(recent.calories)) cal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Quick Add") {
                    VStack(spacing: 10) {
                        quickAddButton("Walking - 30 min", minutes: 30, calories: 100, category: "Cardio")
                        quickAddButton("Running - 20 min", minutes: 20, calories: 200, category: "Cardio")
                        quickAddButton("Cycling - 30 min", minutes: 30, calories: 250, category: "Cardio")
                        quickAddButton("Strength Training - 30 min", minutes: 30, calories: 150, category: "Strength")
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                calories = "\(estimatedCalories)"
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !exerciseName.isEmpty {
                            let durationInt = Int(duration) ?? 30
                            let caloriesDouble = Double(calories) ?? Double(estimatedCalories)
                            let name = exerciseName
                            let category = selectedCategory
                            let noteText = notes.isEmpty ? nil : notes
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                dataManager.addExerciseEntry(
                                    name: name,
                                    category: category,
                                    duration: durationInt,
                                    caloriesBurned: caloriesDouble,
                                    notes: noteText
                                )
                            }
                        }
                    }
                    .disabled(exerciseName.isEmpty)
                }
            }
        }
    }

    private func quickAddButton(_ name: String, minutes: Int, calories: Double, category: String) -> some View {
        Button(action: {
            let exerciseName = name.components(separatedBy: " - ").first ?? name
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                dataManager.quickAddExercise(
                    name: exerciseName,
                    minutes: minutes,
                    calories: calories
                )
            }
        }) {
            HStack {
                Image(systemName: category == "Cardio" ? "figure.run" : "dumbbell")
                    .foregroundColor(.green)
                Text(name)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(calories)) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supplement Entry Sheet
struct SupplementEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @State private var supplementName = ""
    @State private var brand = ""
    @State private var servingSize = "1"
    @State private var servingUnit = "tablet"
    @State private var selectedVitamins: Set<String> = []

    let commonSupplements: [(name: String, brand: String)] = [
        ("Multivitamin", "Nature Made"),
        ("Vitamin D3", "NOW Foods"),
        ("Vitamin C", "Garden of Life"),
        ("Omega-3", "Nordic Naturals"),
        ("Calcium", "Citracal"),
        ("Iron", "Nature's Bounty"),
        ("Magnesium", "Doctor's Best"),
        ("Zinc", "Thorne"),
        ("B Complex", "Jarrow Formulas"),
        ("Probiotics", "Culturelle")
    ]

    let servingUnits = ["tablet", "capsule", "softgel", "gummy", "ml", "tsp", "scoop"]

    var body: some View {
        NavigationView {
            Form {
                Section("Supplement Details") {
                    TextField("Supplement Name", text: $supplementName)
                    TextField("Brand (Optional)", text: $brand)

                    HStack {
                        TextField("Serving Size", text: $servingSize)
                            .keyboardType(.decimalPad)

                        Picker("Unit", selection: $servingUnit) {
                            ForEach(servingUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("Quick Add Common Supplements") {
                    ForEach(commonSupplements, id: \.name) { supplement in
                        Button(action: {
                            dataManager.addSupplementEntry(
                                name: supplement.name,
                                brand: supplement.brand,
                                servingSize: "1",
                                servingUnit: "tablet",
                                nutrients: [:]
                            )
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "pills")
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(supplement.name)
                                        .foregroundColor(.primary)
                                        .font(.subheadline)
                                    Text(supplement.brand)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.purple.opacity(0.6))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Supplement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !supplementName.isEmpty {
                            dataManager.addSupplementEntry(
                                name: supplementName,
                                brand: brand.isEmpty ? nil : brand,
                                servingSize: servingSize,
                                servingUnit: servingUnit,
                                nutrients: [:]
                            )
                            dismiss()
                        }
                    }
                    .disabled(supplementName.isEmpty)
                }
            }
        }
    }
}