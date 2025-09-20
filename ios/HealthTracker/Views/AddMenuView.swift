import SwiftUI
import CoreData

struct AddMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    @State private var selectedMealType: MealType = .breakfast
    @State private var showingFoodSearch = false
    @State private var showingExerciseSearch = false
    @State private var showingBarcodeScanner = false
    @State private var showingSupplementAdd = false
    @State private var showingWeightEntry = false
    @State private var showingWaterEntry = false
    
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
        .sheet(isPresented: $showingFoodSearch) {
            AutocompleteFoodSearchView { foodItem in
                addFoodEntry(foodItem: foodItem)
                dismiss()
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            BarcodeScannerView(selectedDate: selectedDate, mealType: selectedMealType)
        }
        .sheet(isPresented: $showingExerciseSearch) {
            ExerciseSearchView(selectedDate: selectedDate)
        }
        .sheet(isPresented: $showingSupplementAdd) {
            ManualSupplementEntryView()
        }
        .sheet(isPresented: $showingWeightEntry) {
            QuickWeightAddView(selectedDate: selectedDate)
        }
        .sheet(isPresented: $showingWaterEntry) {
            QuickWaterAddView(selectedDate: selectedDate)
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
                Button(action: { showingFoodSearch = true }) {
                    Label("Search Food Database", systemImage: "magnifyingglass")
                        .foregroundColor(.primary)
                }
                
                Button(action: { showingBarcodeScanner = true }) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        .foregroundColor(.primary)
                }
            }
            
            // Exercise Section
            Section("Exercise") {
                Button(action: { showingExerciseSearch = true }) {
                    Label("Add Exercise", systemImage: "figure.run")
                        .foregroundColor(.primary)
                }
            }
            
            // Tracking Section
            Section("Tracking") {
                Button(action: { showingWeightEntry = true }) {
                    Label("Log Weight", systemImage: "scalemass")
                        .foregroundColor(.primary)
                }
                
                Button(action: { showingWaterEntry = true }) {
                    Label("Log Water", systemImage: "drop.fill")
                        .foregroundColor(.primary)
                }
                
                Button(action: { showingSupplementAdd = true }) {
                    Label("Add Supplement", systemImage: "pills.fill")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func addFoodEntry(foodItem: FoodItem) {
        let entry = FoodEntry(context: viewContext)
        entry.id = UUID()
        entry.name = foodItem.name
        entry.brand = foodItem.brand
        entry.calories = foodItem.calories
        entry.protein = foodItem.protein
        entry.carbs = foodItem.carbs
        entry.fat = foodItem.fat
        entry.fiber = foodItem.fiber
        entry.sugar = foodItem.sugar ?? 0
        entry.sodium = foodItem.sodium ?? 0
        entry.servingSize = foodItem.servingSize
        entry.servingUnit = foodItem.servingUnit
        entry.timestamp = selectedDate
        entry.mealType = selectedMealType.rawValue
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving food entry: \(error)")
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
        entry.timestamp = selectedDate
        entry.date = selectedDate
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
    @State private var showingAddForm = false
    
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
                        showingAddForm = true
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
            .sheet(isPresented: $showingAddForm) {
                if let exercise = selectedExercise {
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

#Preview {
    AddMenuView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}