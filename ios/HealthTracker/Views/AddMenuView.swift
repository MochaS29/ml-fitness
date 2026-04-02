import SwiftUI
import CoreData

struct AddMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @AppStorage("freeMealScansUsed") private var freeMealScansUsed = 0

    let selectedDate: Date
    @State private var selectedMealType: MealType = .breakfast
    @State private var activeSheet: ActiveSheet?

    private static let freeScansAllowed = 3

    private enum ActiveSheet: Identifiable {
        case foodSearch
        case exerciseSearch
        case barcodeScanner
        case supplementAdd
        case weightEntry
        case waterEntry
        case mealScanner

        var id: Self { self }
    }

    var body: some View {
        NavigationView {
            listContent
                .navigationTitle("Add to Diary")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .foodSearch:
                UnifiedFoodSearchSheet(mealType: selectedMealType, targetDate: selectedDate)
            case .barcodeScanner:
                ProFeatureGate {
                    BarcodeScannerView(selectedDate: selectedDate, mealType: selectedMealType)
                }
            case .exerciseSearch:
                ExerciseSearchView(selectedDate: selectedDate)
            case .supplementAdd:
                ManualSupplementEntryView()
            case .weightEntry:
                QuickWeightAddView(selectedDate: selectedDate)
            case .waterEntry:
                QuickWaterAddView(selectedDate: selectedDate)
            case .mealScanner:
                MealPhotoAnalyzerView()
            }
        }
    }
    
    private var listContent: some View {
        List {
            // Food Section
            Section("Food") {
                // Meal selection
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Text(mealType.rawValue).tag(mealType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                // Add food options
                Button(action: { activeSheet = .foodSearch }) {
                    Label("Search Food Database", systemImage: "magnifyingglass")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .mealScanner }) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Scan Meal with Camera", systemImage: "camera.fill")
                                .foregroundColor(.primary)
                            if !storeManager.isPro && !TrialManager.shared.isTrialActive {
                                let remaining = max(0, Self.freeScansAllowed - freeMealScansUsed)
                                Text(remaining > 0
                                     ? "\(remaining) free scan\(remaining == 1 ? "" : "s") · tap to try"
                                     : "Upgrade to keep scanning")
                                    .font(.caption)
                                    .foregroundColor(remaining > 0 ? .orange : .secondary)
                            }
                        }
                        Spacer()
                        if !storeManager.isPro && !TrialManager.shared.isTrialActive {
                            let remaining = max(0, Self.freeScansAllowed - freeMealScansUsed)
                            if remaining > 0 {
                                Text("FREE")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Button(action: { activeSheet = .barcodeScanner }) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        .foregroundColor(.primary)
                }
            }
            
            // Exercise Section
            Section("Exercise") {
                Button(action: { activeSheet = .exerciseSearch }) {
                    Label("Add Exercise", systemImage: "figure.run")
                        .foregroundColor(.primary)
                }
            }
            
            // Tracking Section
            Section("Tracking") {
                Button(action: { activeSheet = .weightEntry }) {
                    Label("Log Weight", systemImage: "scalemass")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .waterEntry }) {
                    Label("Log Water", systemImage: "drop.fill")
                        .foregroundColor(.primary)
                }

                Button(action: { activeSheet = .supplementAdd }) {
                    Label("Add Supplement", systemImage: "pills.fill")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
}

// Quick water add view
struct QuickWaterAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    @State private var waterAmount: Double = 8
    @State private var unit: String = "oz"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Amount") {
                    HStack {
                        TextField("Amount", value: $waterAmount, format: .number)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            Text("oz").tag("oz")
                            Text("ml").tag("ml")
                            Text("cups").tag("cups")
                            Text("liters").tag("liters")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section {
                    // Quick presets
                    HStack(spacing: 12) {
                        ForEach([8, 16, 20, 32], id: \.self) { amount in
                            Button(action: {
                                waterAmount = Double(amount)
                                unit = "oz"
                            }) {
                                Text("\(amount) oz")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWaterEntry()
                    }
                }
            }
        }
    }
    
    private func saveWaterEntry() {
        let entry = WaterEntry(context: viewContext)
        entry.id = UUID()
        entry.amount = convertToOunces(amount: waterAmount, unit: unit)
        entry.timestamp = selectedDate
        entry.unit = "oz"
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving water entry: \(error)")
        }
    }
    
    private func convertToOunces(amount: Double, unit: String) -> Double {
        switch unit {
        case "ml":
            return amount * 0.033814
        case "cups":
            return amount * 8
        case "liters":
            return amount * 33.814
        default:
            return amount
        }
    }
}

// Quick weight add view
struct QuickWeightAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let selectedDate: Date
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var entryDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                    DatePicker("Date", selection: $entryDate, displayedComponents: .date)
                }

                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes)
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWeightEntry()
                    }
                    .disabled(weight.isEmpty)
                }
            }
        }
    }
    
    private func saveWeightEntry() {
        guard let weightValue = Double(weight) else { return }

        let entry = WeightEntry(context: viewContext)
        entry.id = UUID()
        entry.weight = weightValue
        entry.timestamp = entryDate
        entry.date = entryDate
        entry.notes = notes.isEmpty ? nil : notes
        
        do {
            try viewContext.save()
            
            // Update goals based on the new weight entry
            GoalsManager.shared.updateGoalsFromWeightEntry(entry)
            
            dismiss()
        } catch {
            print("Error saving weight entry: \(error)")
        }
    }
}

// Exercise search view
struct ExerciseSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedExercise: ExerciseTemplateModel?
    @State private var duration: String = "30"

    let selectedDate: Date
    private let exerciseDB = ExerciseDatabase.shared
    
    var searchResults: [ExerciseTemplateModel] {
        if searchText.isEmpty {
            return exerciseDB.exercises
        } else {
            return exerciseDB.searchExercises(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search exercises...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Exercise list
                List(searchResults, id: \.name) { exercise in
                    Button(action: {
                        selectedExercise = exercise
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.headline)
                                Text("\(exercise.category) • \(exercise.type.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("~\(Int(exercise.caloriesPerMinute)) cal/min")
                                .font(.caption)
                                .foregroundColor(.wellnessGreen)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseEntryForm(
                    exercise: exercise,
                    selectedDate: selectedDate,
                    onSave: { duration in
                        saveExercise(exercise, duration: duration)
                    }
                )
            }
        }
    }

    private func saveExercise(_ exercise: ExerciseTemplateModel, duration: Double) {
        let newExercise = ExerciseEntry(context: viewContext)
        newExercise.id = UUID()
        newExercise.name = exercise.name
        newExercise.type = exercise.type.rawValue
        newExercise.duration = Int32(duration)
        newExercise.caloriesBurned = exercise.caloriesPerMinute * duration
        newExercise.date = selectedDate
        newExercise.timestamp = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

struct ExerciseEntryForm: View {
    let exercise: ExerciseTemplateModel
    let selectedDate: Date
    let onSave: (Double) -> Void
    
    @State private var duration = "30"
    @Environment(\.dismiss) private var dismiss
    
    var estimatedCalories: Int {
        let durationValue = Double(duration) ?? 0
        return Int(exercise.caloriesPerMinute * durationValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    HStack {
                        Text("Exercise")
                        Spacer()
                        Text(exercise.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(exercise.type.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Duration")) {
                    HStack {
                        TextField("Duration", text: $duration)
                            .keyboardType(.numberPad)
                        Text("minutes")
                    }
                }
                
                Section(header: Text("Estimated Calories")) {
                    HStack {
                        Text("Calories Burned")
                        Spacer()
                        Text("\(estimatedCalories) cal")
                            .foregroundColor(.wellnessGreen)
                            .bold()
                    }
                }
            }
            .navigationTitle("Add \(exercise.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let durationValue = Double(duration), durationValue > 0 {
                            onSave(durationValue)
                            dismiss()
                        }
                    }
                    .disabled(Double(duration) ?? 0 <= 0)
                }
            }
        }
    }
}

// This placeholder has been replaced - the sheet now calls ManualSupplementEntryView directly

// #Preview {
//     AddMenuView(selectedDate: Date())
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }