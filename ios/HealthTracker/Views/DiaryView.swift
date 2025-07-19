import SwiftUI
import CoreData

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var showingAddMenu = false
    @State private var showingFoodSearch = false
    @State private var showingExerciseSearch = false
    @State private var dailySummary = DailySummary()
    @State private var selectedMealType: MealType = .breakfast
    
    // Fetch requests for selected date
    @FetchRequest private var foodEntries: FetchedResults<FoodEntry>
    @FetchRequest private var exerciseEntries: FetchedResults<ExerciseEntry>
    @FetchRequest private var weightEntries: FetchedResults<WeightEntry>
    @FetchRequest private var supplementEntries: FetchedResults<SupplementEntry>
    
    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        _foodEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
        
        _exerciseEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
        
        _weightEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
        
        _supplementEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Selector
                dateSelectorView
                
                // Daily Summary
                dailySummaryView
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // Entry List
                ScrollView {
                    VStack(spacing: 16) {
                        // Meals Section
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            mealSection(for: mealType)
                        }
                        
                        // Exercise Section
                        exerciseSection
                        
                        // Supplements Section
                        supplementsSection
                        
                        // Water Section
                        waterSection
                        
                        // Notes Section
                        notesSection
                    }
                    .padding(.bottom, 100)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMenu = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMenu) {
                AddMenuView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingFoodSearch) {
                EnhancedFoodSearchView { foodItem in
                    // Add food to the selected meal
                    addFoodEntry(foodItem: foodItem, mealType: selectedMealType)
                }
            }
            .sheet(isPresented: $showingExerciseSearch) {
                // Exercise search functionality
                Text("Exercise Search Coming Soon")
            }
            .onChange(of: selectedDate) {
                updateFetchRequests()
                updateDailySummary()
            }
            .onAppear {
                updateDailySummary()
            }
        }
    }
    
    private var dateSelectorView: some View {
        HStack {
            Button(action: { adjustDate(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: { /* Show date picker */ }) {
                VStack(spacing: 4) {
                    Text(selectedDate, style: .date)
                        .font(.headline)
                    if Calendar.current.isDateInToday(selectedDate) {
                        Text("Today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: { adjustDate(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private var dailySummaryView: some View {
        HStack(spacing: 20) {
            SummaryMetric(
                title: "Calories",
                value: "\(Int(dailySummary.calories))",
                subtitle: "/ \(Int(dailySummary.calorieGoal))",
                color: Color(red: 127/255, green: 176/255, blue: 105/255)
            )
            
            SummaryMetric(
                title: "Protein",
                value: "\(Int(dailySummary.protein))g",
                subtitle: "/ \(Int(dailySummary.proteinGoal))g",
                color: Color(red: 74/255, green: 155/255, blue: 155/255)
            )
            
            SummaryMetric(
                title: "Exercise",
                value: "\(Int(dailySummary.exerciseMinutes))",
                subtitle: "min",
                color: .orange
            )
            
            SummaryMetric(
                title: "Water",
                value: "\(Int(dailySummary.waterOunces))",
                subtitle: "oz",
                color: .blue
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func mealSection(for mealType: MealType) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text(mealTypeDisplayName(mealType))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(mealCalories(for: mealType)) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: { 
                    // Add food to this meal
                    selectedMealType = mealType
                    showingFoodSearch = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Food entries for this meal
            let mealFoods = foodEntries.filter { $0.mealType == mealType.rawValue }
            
            if !mealFoods.isEmpty {
                VStack(spacing: 0) {
                    ForEach(mealFoods) { entry in
                        FoodEntryRow(entry: entry)
                        
                        if entry != mealFoods.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var exerciseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Exercise")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(totalExerciseMinutes()) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: { showingExerciseSearch = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Exercise entries
            if !exerciseEntries.isEmpty {
                VStack(spacing: 0) {
                    ForEach(exerciseEntries) { entry in
                        ExerciseEntryRow(entry: entry)
                        
                        if entry != exerciseEntries.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var supplementsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Supplements")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { /* Add supplement */ }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Supplement entries
            if !supplementEntries.isEmpty {
                VStack(spacing: 0) {
                    ForEach(supplementEntries) { entry in
                        SupplementEntryRow(entry: entry)
                        
                        if entry != supplementEntries.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Water")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(dailySummary.waterOunces)) oz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: { /* Add water */ }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Water tracking UI
            WaterTrackingRow(currentOunces: Int(dailySummary.waterOunces))
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Notes")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { /* Add note */ }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 139/255, green: 69/255, blue: 19/255))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Notes content
            Text("Tap to add notes about your day...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func adjustDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func updateFetchRequests() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        foodEntries.nsPredicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        exerciseEntries.nsPredicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        weightEntries.nsPredicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        supplementEntries.nsPredicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
    }
    
    private func updateDailySummary() {
        dailySummary.calories = foodEntries.reduce(0) { $0 + $1.calories }
        dailySummary.protein = foodEntries.reduce(0) { $0 + $1.protein }
        dailySummary.exerciseMinutes = Double(exerciseEntries.reduce(0) { $0 + Int($1.duration) })
        // Set default goals
        dailySummary.calorieGoal = 2000
        dailySummary.proteinGoal = 50
        dailySummary.waterOunces = 0 // Would need water tracking entity
    }
    
    private func mealCalories(for mealType: MealType) -> Int {
        let mealFoods = foodEntries.filter { $0.mealType == mealType.rawValue }
        return Int(mealFoods.reduce(0) { $0 + $1.calories })
    }
    
    private func totalExerciseMinutes() -> Int {
        exerciseEntries.reduce(0) { $0 + Int($1.duration) }
    }
    
    private func mealTypeDisplayName(_ mealType: MealType) -> String {
        switch mealType {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    
    private func addFoodEntry(foodItem: FoodItem, mealType: MealType) {
        let newEntry = FoodEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = foodItem.name
        newEntry.brand = foodItem.brand
        newEntry.calories = foodItem.calories
        newEntry.protein = foodItem.protein
        newEntry.carbs = foodItem.carbs
        newEntry.fat = foodItem.fat
        newEntry.fiber = foodItem.fiber
        newEntry.servingSize = foodItem.servingSize
        newEntry.servingUnit = foodItem.servingUnit
        newEntry.mealType = mealType.rawValue
        newEntry.timestamp = selectedDate
        newEntry.date = selectedDate
        
        do {
            try viewContext.save()
            updateDailySummary()
        } catch {
            print("Error saving food entry: \(error)")
        }
    }
}

struct DailySummary {
    var calories: Double = 0
    var calorieGoal: Double = 2000
    var protein: Double = 0
    var proteinGoal: Double = 50
    var exerciseMinutes: Double = 0
    var waterOunces: Double = 0
}

struct SummaryMetric: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name ?? "Unknown Food")
                    .font(.subheadline)
                
                if let brand = entry.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("\(entry.servingSize ?? "1") \(entry.servingUnit ?? "serving")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct ExerciseEntryRow: View {
    let entry: ExerciseEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name ?? "Unknown Exercise")
                    .font(.subheadline)
                
                Text(entry.category ?? "General")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.duration) min")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("\(Int(entry.caloriesBurned)) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct SupplementEntryRow: View {
    let entry: SupplementEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name ?? "Unknown Supplement")
                    .font(.subheadline)
                
                if let brand = entry.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(entry.servingSize ?? "1") \(entry.servingUnit ?? "serving")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct WaterTrackingRow: View {
    let currentOunces: Int
    let glassSize: Int = 8
    
    var glasses: Int {
        currentOunces / glassSize
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: index < glasses ? "drop.fill" : "drop")
                    .font(.title2)
                    .foregroundColor(index < glasses ? .blue : .gray)
            }
        }
    }
}

struct AddMenuView: View {
    let selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: EnhancedFoodSearchView { foodItem in
                        // Handle food selection
                    }) {
                        Label("Add Food", systemImage: "fork.knife")
                    }
                    
                    NavigationLink(destination: DishScannerView()) {
                        Label("Scan Dish", systemImage: "camera.fill")
                    }
                    
                    NavigationLink(destination: Text("Exercise Search")) {
                        Label("Add Exercise", systemImage: "figure.run")
                    }
                    
                    NavigationLink(destination: WeightEntryView(date: selectedDate)) {
                        Label("Add Weight", systemImage: "scalemass")
                    }
                    
                    NavigationLink(destination: SupplementTrackingView()) {
                        Label("Add Supplement", systemImage: "pills")
                    }
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct WeightEntryView: View {
    let date: Date
    @State private var weight: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                    Text("lbs")
                }
            }
        }
        .navigationTitle("Add Weight")
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                // Save weight entry
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

#Preview {
    DiaryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}