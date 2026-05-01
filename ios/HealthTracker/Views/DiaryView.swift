import SwiftUI
import CoreData

struct DiaryView: View {
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @StateObject private var viewModel = DiaryViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var showingAddMenu = false
    @State private var showingFoodSearch = false
    @State private var showingExerciseSearch = false
    @State private var showingWaterEntry = false
    @State private var showingSupplementEntry = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var nutritionExpanded = true
    @State private var showingGoalsSetup = false
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    // Fetch requests for selected date
    @FetchRequest private var foodEntries: FetchedResults<FoodEntry>
    @FetchRequest private var exerciseEntries: FetchedResults<ExerciseEntry>
    @FetchRequest private var weightEntries: FetchedResults<WeightEntry>
    @FetchRequest private var supplementEntries: FetchedResults<SupplementEntry>
    
    init() {
        _foodEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: true)],
            predicate: NSPredicate.forDay()
        )

        _exerciseEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: true)],
            predicate: NSPredicate.forDay()
        )

        _weightEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WeightEntry.timestamp, ascending: true)],
            predicate: NSPredicate.forDay()
        )

        _supplementEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: true)],
            predicate: NSPredicate.forDay()
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Date Selector
                dateSelectorView
                
                // Daily Summary
                dailySummaryView
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // Goal setup prompt (shown when calorie goal is at default 0)
                let calorieGoalSet = UserDefaults.standard.integer(forKey: "dailyCalorieGoal") > 0
                if !calorieGoalSet {
                    Button(action: { showingGoalsSetup = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "target")
                                .foregroundColor(.orange)
                            Text("Set your calorie & nutrition goals for accurate tracking")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.1))
                    }
                    .buttonStyle(.plain)
                }

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

                        // Daily Nutrition Analytics
                        diaryNutritionSection

                        // Data source citation
                        Text("Nutrition data sourced from USDA FoodData Central (fdc.nal.usda.gov). For informational purposes only — not medical advice.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 100)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        shareText = viewModel.generateDiaryShareText(
                            selectedDate: selectedDate,
                            foodEntries: foodEntries,
                            exerciseEntries: exerciseEntries
                        )
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMenu = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMenu) {
                QuickAddMenu(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingFoodSearch) {
                UnifiedFoodSearchSheet(mealType: selectedMealType, targetDate: selectedDate)
            }
            .sheet(isPresented: $showingExerciseSearch) {
                ExerciseEntrySheet()
            }
            .sheet(isPresented: $showingWaterEntry) {
                WaterTrackingView()
            }
            .sheet(isPresented: $showingSupplementEntry) {
                ManualSupplementEntryView(targetDate: selectedDate)
            }
            .sheet(isPresented: $showingGoalsSetup) {
                SimpleGoalsView()
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [shareText])
            }
            .onChange(of: selectedDate) {
                updateFetchRequests()
                updateDailySummary()
            }
            // Recompute summary when entries are added/removed from any source
            // (e.g. QuickAddMenu, Meal Scanner, EditFoodEntrySheet servings change).
            .onChange(of: foodEntries.count) { updateDailySummary() }
            .onChange(of: exerciseEntries.count) { updateDailySummary() }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                updateDailySummary()
            }
            .onAppear {
                updateDailySummary()
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
        let remaining = viewModel.dailySummary.caloriesRemaining
        let remainingColor: Color = remaining < 0 ? .red : Color(red: 127/255, green: 176/255, blue: 105/255)
        return VStack(spacing: 8) {
            HStack(spacing: 20) {
                SummaryMetric(
                    title: "Eaten",
                    value: "\(Int(viewModel.dailySummary.calories))",
                    subtitle: "/ \(Int(viewModel.dailySummary.calorieGoal))",
                    color: Color(red: 127/255, green: 176/255, blue: 105/255)
                )

                SummaryMetric(
                    title: "Burned",
                    value: "\(Int(viewModel.dailySummary.caloriesBurned))",
                    subtitle: "cal",
                    color: .orange
                )

                SummaryMetric(
                    title: "Remaining",
                    value: "\(Int(abs(remaining)))",
                    subtitle: remaining < 0 ? "over" : "left",
                    color: remainingColor
                )

                SummaryMetric(
                    title: "Protein",
                    value: "\(Int(viewModel.dailySummary.protein))",
                    subtitle: "/ \(Int(viewModel.dailySummary.proteinGoal))g",
                    color: Color(red: 74/255, green: 155/255, blue: 155/255)
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func mealSection(for mealType: MealType) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text(viewModel.mealTypeDisplayName(mealType))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(viewModel.mealCalories(for: mealType, in: foodEntries)) cal")
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
                        FoodEntryRow(entry: entry, onDelete: {
                            deleteFoodEntry(entry)
                        })

                        if entry != mealFoods.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
            } else {
                Button(action: {
                    selectedMealType = mealType
                    showingFoodSearch = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                        Text("Add \(viewModel.mealTypeDisplayName(mealType).lowercased())...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .buttonStyle(.plain)
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
                
                Text("\(viewModel.totalExerciseMinutes(from: exerciseEntries)) min")
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
                        ExerciseEntryRow(entry: entry, onDelete: {
                            deleteExerciseEntry(entry)
                        })

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
                
                Button(action: { showingSupplementEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Supplement entries
            if !supplementEntries.isEmpty {
                VStack(spacing: 0) {
                    ForEach(supplementEntries) { entry in
                        SupplementEntryRow(entry: entry, onDelete: {
                            deleteSupplementEntry(entry)
                        })
                            .background(Color(UIColor.secondarySystemGroupedBackground))

                        if entry != supplementEntries.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
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

                Text("\(Int(viewModel.calculateWaterOunces(for: selectedDate))) oz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    // Add 8oz of water
                    dataManager.quickAddWater(8)
                    // Refresh the view
                    updateDailySummary()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))

            // Water tracking UI with proper update
            WaterTrackingRow(
                currentOunces: Int(viewModel.calculateWaterOunces(for: selectedDate)),
                onWaterAdded: { ounces in
                    dataManager.quickAddWater(ounces)
                    updateDailySummary()
                }
            )
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
                
                Button(action: {
                    // For now, just show a note entry alert or do nothing
                    // TODO: Add note entry functionality
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.gray)
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
    
    // MARK: - Diary Nutrition Analytics

    private var diaryNutritionSection: some View {
        let calorieGoal = viewModel.dailySummary.calorieGoal
        let proteinGoal = viewModel.dailySummary.proteinGoal
        let suppNutrients = viewModel.supplementNutrients(from: supplementEntries)
        let foodNutrients = viewModel.foodAdditionalNutrients(from: foodEntries)
        let combinedNutrients = foodNutrients + suppNutrients

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { nutritionExpanded.toggle() } }) {
                HStack {
                    Label("Day's Nutrition", systemImage: "chart.bar.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    if !foodEntries.isEmpty {
                        Text("\(Int(viewModel.totalCalories(from: foodEntries))) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: nutritionExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .buttonStyle(.plain)

            if nutritionExpanded {
                VStack(spacing: 0) {
                    if foodEntries.isEmpty && supplementEntries.isEmpty {
                        Text("No food or supplements logged yet for this day.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                    } else {
                        // Macro progress bars
                        VStack(spacing: 12) {
                            DiaryMacroBar(label: "Calories", value: viewModel.totalCalories(from: foodEntries), goal: calorieGoal, unit: "kcal", color: .orange)
                            DiaryMacroBar(label: "Protein",  value: viewModel.totalProtein(from: foodEntries),  goal: proteinGoal, unit: "g",    color: .blue)
                            DiaryMacroBar(label: "Carbs",    value: viewModel.totalCarbs(from: foodEntries),    goal: 275,          unit: "g",    color: .green)
                            DiaryMacroBar(label: "Fat",      value: viewModel.totalFat(from: foodEntries),      goal: 78,           unit: "g",    color: Color(red: 1, green: 0.8, blue: 0))
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))

                        Divider().padding(.leading)

                        // Additional nutrients from food
                        VStack(spacing: 0) {
                            DiaryNutrientRow(name: "Fiber",  value: viewModel.totalFiber(from: foodEntries),  unit: "g",  goal: 28,   goalPrefix: "", color: .brown)
                            Divider().padding(.leading)
                            DiaryNutrientRow(name: "Sugar",  value: viewModel.totalSugar(from: foodEntries),  unit: "g",  goal: 50,   goalPrefix: "< ", color: .pink)
                            Divider().padding(.leading)
                            DiaryNutrientRow(name: "Sodium", value: viewModel.totalSodium(from: foodEntries), unit: "mg", goal: 2300, goalPrefix: "< ", color: .gray)
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))

                        // Vitamins & minerals — combined food + supplement totals
                        if !combinedNutrients.isEmpty {
                            Divider().padding(.leading)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vitamins & Minerals")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                let vitaminRDAs: [(id: String, name: String, rda: Double, unit: String)] = [
                                    ("vitamin_c", "Vitamin C", 90, "mg"),
                                    ("vitamin_d", "Vitamin D", 600, "IU"),
                                    ("vitamin_b12", "Vitamin B12", 2.4, "mcg"),
                                    ("vitamin_a", "Vitamin A", 900, "mcg"),
                                    ("vitamin_e", "Vitamin E", 15, "mg"),
                                    ("folate", "Folate", 400, "mcg"),
                                    ("calcium", "Calcium", 1000, "mg"),
                                    ("iron", "Iron", 18, "mg"),
                                    ("magnesium", "Magnesium", 400, "mg"),
                                    ("zinc", "Zinc", 11, "mg"),
                                    ("potassium", "Potassium", 2600, "mg"),
                                ]

                                ForEach(vitaminRDAs, id: \.id) { vit in
                                    if let amount = combinedNutrients[vit.id], amount > 0 {
                                        DiaryNutrientRow(
                                            name: vit.name,
                                            value: amount,
                                            unit: vit.unit,
                                            goal: vit.rda,
                                            goalPrefix: "",
                                            color: .purple
                                        )
                                        Divider().padding(.leading)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                        }
                    }
                }
            }
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
        foodEntries.nsPredicate = .forDay(selectedDate)
        exerciseEntries.nsPredicate = .forDay(selectedDate)
        weightEntries.nsPredicate = .forDay(selectedDate)
        supplementEntries.nsPredicate = .forDay(selectedDate)
    }
    
    private func updateDailySummary() {
        viewModel.updateDailySummary(
            foodEntries: foodEntries,
            exerciseEntries: exerciseEntries,
            selectedDate: selectedDate
        )
        viewModel.refreshActiveEnergy(for: selectedDate)
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
            // Send update to Apple Watch
            PhoneConnectivityManager.shared.sendDailyUpdate()
        } catch {
            print("Error saving food entry: \(error)")
        }
    }

    // MARK: - Delete Functions

    private func deleteFoodEntry(_ entry: FoodEntry) {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            updateDailySummary()
            // Send update to Apple Watch
            PhoneConnectivityManager.shared.sendDailyUpdate()
        } catch {
            print("Error deleting food entry: \(error)")
        }
    }

    private func deleteExerciseEntry(_ entry: ExerciseEntry) {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            updateDailySummary()
            // Send update to Apple Watch
            PhoneConnectivityManager.shared.sendDailyUpdate()
        } catch {
            print("Error deleting exercise entry: \(error)")
        }
    }

    private func deleteSupplementEntry(_ entry: SupplementEntry) {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            updateDailySummary()
            // Send update to Apple Watch
            PhoneConnectivityManager.shared.sendDailyUpdate()
        } catch {
            print("Error deleting supplement entry: \(error)")
        }
    }
}

struct DailySummary {
    var calories: Double = 0
    var calorieGoal: Double = Double(AppConstants.Defaults.dailyCalorieGoal)
    var caloriesBurned: Double = 0
    var protein: Double = 0
    var proteinGoal: Double = 50
    var exerciseMinutes: Double = 0
    var waterOunces: Double = 0

    var caloriesRemaining: Double {
        calorieGoal + caloriesBurned - calories
    }
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
    var onDelete: (() -> Void)? = nil
    @State private var selectedRecipe: RecipeModel?
    @State private var showingEdit = false

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
            .padding(.leading)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text("\(entry.servingSize ?? "1") \(entry.servingUnit ?? "serving")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditFoodEntrySheet(
                entry: entry,
                onViewRecipe: {
                    if let name = entry.name, let recipe = findRecipe(named: name) {
                        showingEdit = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            selectedRecipe = recipe
                        }
                    }
                }
            )
        }
        .sheet(item: $selectedRecipe) { recipe in
            ProfessionalRecipeDetailView(recipe: recipe)
        }
    }

    private func findRecipe(named name: String) -> RecipeModel? {
        if let match = RecipeDatabase.shared.recipes.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return match
        }
        for plan in MealPlanData.shared.allMealPlans {
            for week in plan.monthlyPlans {
                for day in week.days {
                    for meal in [day.breakfast, day.lunch, day.dinner] + day.snacks {
                        if meal.name.lowercased() == name.lowercased() {
                            return RecipeModel(
                                id: UUID(),
                                name: meal.name,
                                category: .dinner,
                                prepTime: meal.prepTime,
                                cookTime: meal.cookTime,
                                servings: 2,
                                ingredients: meal.ingredients.map {
                                    IngredientModel(name: $0, amount: 1, unit: .piece, category: .other)
                                },
                                instructions: meal.instructions,
                                nutrition: NutritionInfo(
                                    calories: Double(meal.calories),
                                    protein: meal.protein,
                                    carbs: meal.carbs,
                                    fat: meal.fat,
                                    fiber: meal.fiber,
                                    sugar: nil,
                                    sodium: nil
                                ),
                                tags: meal.tags
                            )
                        }
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - Edit Food Entry Sheet

struct EditFoodEntrySheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: FoodEntry
    var onViewRecipe: (() -> Void)? = nil

    @ObservedObject private var favourites = FavouriteFoodsManager.shared

    @State private var servings: Double = 1.0
    @State private var mealType: MealType = .breakfast
    @State private var originalServings: Double = 1.0

    /// Per-1-serving FoodItem snapshot for favourites (so it round-trips back to search later).
    private var asFoodItem: FoodItem {
        FoodItem(
            name: entry.name ?? "Unknown",
            brand: entry.brand,
            category: .other,
            servingSize: entry.servingSize ?? "1",
            servingUnit: entry.servingUnit ?? "serving",
            calories: basePerServing.calories,
            protein: basePerServing.protein,
            carbs: basePerServing.carbs,
            fat: basePerServing.fat,
            fiber: basePerServing.fiber,
            sugar: basePerServing.sugar,
            sodium: basePerServing.sodium,
            cholesterol: nil, saturatedFat: nil, barcode: entry.barcode, isCommon: false
        )
    }

    /// Per-1-serving macros, captured on appear so re-scaling stays accurate even after multiple edits.
    @State private var basePerServing = (
        calories: 0.0, protein: 0.0, carbs: 0.0, fat: 0.0,
        fiber: 0.0, sugar: 0.0, sodium: 0.0
    )

    var body: some View {
        NavigationView {
            Form {
                Section("Item") {
                    Text(entry.name ?? "Unknown Food")
                        .font(.headline)
                    if let brand = entry.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Servings") {
                    HStack {
                        Text("Servings")
                        Spacer()
                        Stepper(value: $servings, in: 0.25...20, step: 0.25) {
                            Text(servingDisplay)
                                .frame(minWidth: 60, alignment: .trailing)
                        }
                    }
                    if let unit = entry.servingUnit {
                        Text("Per serving: \(entry.servingSize ?? "1") \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Meal") {
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Nutrition (preview)") {
                    macroRow("Calories", value: basePerServing.calories * servings, unit: "cal")
                    macroRow("Protein", value: basePerServing.protein * servings, unit: "g")
                    macroRow("Carbs", value: basePerServing.carbs * servings, unit: "g")
                    macroRow("Fat", value: basePerServing.fat * servings, unit: "g")
                }

                if let extras = scaledExtras(), !extras.isEmpty {
                    Section("Vitamins & Minerals") {
                        ForEach(extras, id: \.label) { row in
                            macroRow(row.label, value: row.value, unit: row.unit)
                        }
                    }
                }

                if onViewRecipe != nil {
                    Section {
                        Button(action: { onViewRecipe?() }) {
                            Label("View Recipe Details", systemImage: "book")
                        }
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { favourites.toggle(asFoodItem) }) {
                            let isFav = favourites.isFavourite(asFoodItem)
                            Image(systemName: isFav ? "star.fill" : "star")
                                .foregroundColor(isFav ? .yellow : .secondary)
                        }
                        .accessibilityLabel("Favourite")
                        Button("Save") { save() }
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear { loadInitialState() }
        }
    }

    private var servingDisplay: String {
        servings == servings.rounded() ? "\(Int(servings))" : String(format: "%.2f", servings)
    }

    private func macroRow(_ label: String, value: Double, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value.rounded())) \(unit)")
                .foregroundColor(.secondary)
        }
    }

    private struct ExtraNutrientRow {
        let label: String
        let value: Double
        let unit: String
    }

    private func scaledExtras() -> [ExtraNutrientRow]? {
        let count = entry.servingCount > 0 ? entry.servingCount : 1.0
        let scale = servings / count
        var rows: [ExtraNutrientRow] = []

        if entry.cholesterol > 0 {
            rows.append(.init(label: "Cholesterol", value: entry.cholesterol * scale, unit: "mg"))
        }
        if entry.saturatedFat > 0 {
            rows.append(.init(label: "Saturated Fat", value: entry.saturatedFat * scale, unit: "g"))
        }

        if let extras = entry.additionalNutrients {
            let order: [(key: String, label: String, unit: String)] = [
                ("vitamin_a", "Vitamin A", "mcg"),
                ("vitamin_c", "Vitamin C", "mg"),
                ("vitamin_d", "Vitamin D", "mcg"),
                ("vitamin_e", "Vitamin E", "mg"),
                ("vitamin_k", "Vitamin K", "mcg"),
                ("thiamin", "Thiamin (B1)", "mg"),
                ("riboflavin", "Riboflavin (B2)", "mg"),
                ("niacin", "Niacin (B3)", "mg"),
                ("vitamin_b6", "Vitamin B6", "mg"),
                ("folate", "Folate", "mcg"),
                ("vitamin_b12", "Vitamin B12", "mcg"),
                ("biotin", "Biotin", "mcg"),
                ("pantothenic_acid", "Pantothenic Acid", "mg"),
                ("calcium", "Calcium", "mg"),
                ("iron", "Iron", "mg"),
                ("magnesium", "Magnesium", "mg"),
                ("phosphorus", "Phosphorus", "mg"),
                ("potassium", "Potassium", "mg"),
                ("zinc", "Zinc", "mg"),
                ("copper", "Copper", "mg"),
                ("manganese", "Manganese", "mg"),
                ("selenium", "Selenium", "mcg"),
            ]
            for item in order {
                if let v = extras[item.key], v > 0 {
                    rows.append(.init(label: item.label, value: v * scale, unit: item.unit))
                }
            }
        }
        return rows
    }

    private func loadInitialState() {
        let count = entry.servingCount > 0 ? entry.servingCount : 1.0
        originalServings = count
        servings = count
        basePerServing = (
            calories: entry.calories / count,
            protein: entry.protein / count,
            carbs: entry.carbs / count,
            fat: entry.fat / count,
            fiber: entry.fiber / count,
            sugar: entry.sugar / count,
            sodium: entry.sodium / count
        )
        mealType = MealType(rawValue: entry.mealType ?? "") ?? .defaultForCurrentTime()
    }

    private func save() {
        entry.servingCount = servings
        entry.calories = basePerServing.calories * servings
        entry.protein = basePerServing.protein * servings
        entry.carbs = basePerServing.carbs * servings
        entry.fat = basePerServing.fat * servings
        entry.fiber = basePerServing.fiber * servings
        entry.sugar = basePerServing.sugar * servings
        entry.sodium = basePerServing.sodium * servings
        entry.mealType = mealType.rawValue

        do {
            try viewContext.save()
            PhoneConnectivityManager.shared.sendDailyUpdate()
            dismiss()
        } catch {
            print("Error saving food entry edit: \(error)")
        }
    }
}

struct ExerciseEntryRow: View {
    let entry: ExerciseEntry
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name ?? "Unknown Exercise")
                    .font(.subheadline)

                Text(entry.category ?? "General")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.duration) min")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text("\(Int(entry.caloriesBurned)) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct SupplementEntryRow: View {
    let entry: SupplementEntry
    var onDelete: (() -> Void)? = nil

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
            .padding(.leading)

            Spacer()

            Text("\(entry.servingSize ?? "1") \(entry.servingUnit ?? "serving")")
                .font(.caption)
                .foregroundColor(.secondary)

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct WaterTrackingRow: View {
    let currentOunces: Int
    var onWaterAdded: ((Double) -> Void)? = nil
    let glassSize: Int = 8
    @ObservedObject private var dataManager = UnifiedDataManager.shared

    var glasses: Int {
        currentOunces / glassSize
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<8, id: \.self) { index in
                Button(action: {
                    // Calculate how much water to add
                    let targetOunces = (index + 1) * glassSize
                    let ouncesToAdd = Double(targetOunces - currentOunces)

                    if ouncesToAdd > 0 {
                        // Use callback if provided, otherwise use dataManager
                        if let onWaterAdded = onWaterAdded {
                            onWaterAdded(ouncesToAdd)
                        } else {
                            dataManager.quickAddWater(ouncesToAdd)
                        }
                    } else if ouncesToAdd < 0 {
                        // If tapping a filled glass, toggle it off
                        if let onWaterAdded = onWaterAdded {
                            onWaterAdded(ouncesToAdd)
                        }
                    }
                }) {
                    Image(systemName: index < glasses ? "drop.fill" : "drop")
                        .font(.title2)
                        .foregroundColor(index < glasses ? .blue : .gray)
                }
                .buttonStyle(.plain)
            }
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

// MARK: - Diary Nutrition Supporting Views

struct DiaryMacroBar: View {
    let label: String
    let value: Double
    let goal: Double
    let unit: String
    let color: Color

    private var progress: Double { min(value / max(goal, 1), 1.0) }
    private var pct: Int { Int((value / max(goal, 1)) * 100) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(unit == "kcal"
                     ? "\(Int(value)) / \(Int(goal)) \(unit)"
                     : String(format: "%.1f / %.0f %@", value, goal, unit))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("(\(pct)%)")
                    .font(.caption2)
                    .foregroundColor(pct > 100 ? .red : .secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(color.opacity(0.15))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(pct > 100 ? Color.red : color)
                        .frame(width: geo.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

struct DiaryNutrientRow: View {
    let name: String
    let value: Double
    let unit: String
    let goal: Double
    let goalPrefix: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 8, height: 8)
            Text(name)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(unit == "mg"
                 ? String(format: "%.0f %@", value, unit)
                 : String(format: "%.1f %@", value, unit))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            Text("/ \(goalPrefix)\(unit == "mg" ? "\(Int(goal))" : String(format: "%.0f", goal)) \(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// #Preview {
//     DiaryView()
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }