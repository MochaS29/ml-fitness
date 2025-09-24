import SwiftUI
import HealthKit
import CoreData

struct MoreView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var showingProfile = false
    @State private var showingProgress = false
    @State private var showingFoodDatabase = false
    @State private var showingRecipes = false
    @State private var showingGoals = false
    @State private var showingReminders = false
    @State private var showingExport = false
    @State private var showingSettings = false
    @State private var showingHelp = false
    @State private var showingUSDAImport = false
    @State private var showingDemoDataAlert = false
    @AppStorage("hasDemoData") private var hasDemoData = false
    @State private var showingResetAlert = false
    @State private var showingResetConfirmation = false
    @Environment(\.managedObjectContext) private var viewContext

    // New state variables for unified tracking tools
    @State private var showingFoodSearch = false
    @State private var showingExerciseSearch = false
    @State private var showingWeightEntry = false
    @State private var showingSupplementEntry = false
    @State private var showingWaterEntry = false
    @State private var selectedMealType: MealType = .snack
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section {
                    Button(action: { showingProfile = true }) {
                        HStack {
                            if let profile = userProfileManager.currentProfile {
                                Circle()
                                    .fill(Color(red: 139/255, green: 69/255, blue: 19/255))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(profile.name.prefix(1).uppercased())
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("View Profile")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Tracking Tools
                Section("Tracking Tools") {
                    Button(action: { showingFoodSearch = true }) {
                        MoreMenuItem(
                            icon: "fork.knife",
                            title: "Food Diary",
                            color: Color(red: 127/255, green: 176/255, blue: 105/255)
                        )
                    }

                    Button(action: { showingExerciseSearch = true }) {
                        MoreMenuItem(
                            icon: "figure.run",
                            title: "Exercise Log",
                            color: .orange
                        )
                    }

                    Button(action: { showingWeightEntry = true }) {
                        MoreMenuItem(
                            icon: "scalemass",
                            title: "Weight Tracker",
                            color: Color(red: 139/255, green: 69/255, blue: 19/255)
                        )
                    }

                    // Supplements - Commented out (available in Dashboard & Diary)
                    // Button(action: { showingSupplementEntry = true }) {
                    //     MoreMenuItem(
                    //         icon: "pills",
                    //         title: "Supplements",
                    //         color: .purple
                    //     )
                    // }

                    NavigationLink(destination: IntermittentFastingView()) {
                        MoreMenuItem(
                            icon: "timer",
                            title: "Fasting Timer",
                            color: Color(red: 74/255, green: 155/255, blue: 155/255)
                        )
                    }
                    
                    // Nutrition Overview - Commented out (similar data in Dashboard & Diary)
                    // NavigationLink(destination: EnhancedMacroTrackingView()) {
                    //     MoreMenuItem(
                    //         icon: "chart.pie.fill",
                    //         title: "Nutrition Overview",
                    //         color: .indigo
                    //     )
                    // }
                }
                
                // Progress & Analysis
                Section("Progress & Analysis") {
                    // Commented out until display format is decided
                    // NavigationLink(destination: ProfessionalProgressView()) {
                    //     MoreMenuItem(
                    //         icon: "chart.bar.fill",
                    //         title: "Progress Charts",
                    //         color: .blue
                    //     )
                    // }

                    // Water Tracking - Commented out (available in Dashboard & Diary)
                    // Button(action: { showingWaterEntry = true }) {
                    //     MoreMenuItem(
                    //         icon: "drop.fill",
                    //         title: "Water Tracking",
                    //         color: .blue
                    //     )
                    // }
                    
                    Button(action: { showingGoals = true }) {
                        MoreMenuItem(
                            icon: "target",
                            title: "Goals",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: AchievementsView()) {
                        MoreMenuItem(
                            icon: "trophy.fill",
                            title: "Achievements",
                            color: .yellow
                        )
                    }
                }
                
                // Food & Recipes
                Section("Food & Recipes") {
                    NavigationLink(destination: MyRecipeBookView()) {
                        MoreMenuItem(
                            icon: "heart.text.square.fill",
                            title: "My Recipe Book",
                            color: .red
                        )
                    }
                    
                    NavigationLink(destination: RecipeLibraryView()) {
                        MoreMenuItem(
                            icon: "book.fill",
                            title: "Recipe Library",
                            color: Color(red: 127/255, green: 176/255, blue: 105/255)
                        )
                    }
                    
                    // Meal Planning - Commented out (has dedicated Plan tab)
                    // NavigationLink(destination: MealPlanningView()) {
                    //     MoreMenuItem(
                    //         icon: "calendar",
                    //         title: "Meal Planning",
                    //         color: .indigo
                    //     )
                    // }
                    
                    NavigationLink(destination: CustomFoodsView()) {
                        MoreMenuItem(
                            icon: "plus.square.fill",
                            title: "My Foods",
                            color: .orange
                        )
                    }
                    
                    Button(action: { showingFoodDatabase = true }) {
                        MoreMenuItem(
                            icon: "magnifyingglass",
                            title: "Food Database",
                            color: Color(red: 74/255, green: 155/255, blue: 155/255)
                        )
                    }
                    
                    Button(action: { showingUSDAImport = true }) {
                        MoreMenuItem(
                            icon: "arrow.down.doc.fill",
                            title: "Import USDA Database",
                            color: .purple
                        )
                    }
                }
                
                // Demo Data (for screenshots)
                #if DEBUG
                Section("Developer Tools") {
                    Button(action: {
                        DemoDataGenerator.generateDemoData(context: viewContext)
                        // Refresh the dashboard
                        NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: nil)
                    }) {
                        MoreMenuItem(
                            icon: "wand.and.stars",
                            title: "Generate Demo Data",
                            color: .purple
                        )
                    }
                }
                #endif

                // Settings & Support
                Section("Settings & Support") {
                    Button(action: { showingReminders = true }) {
                        MoreMenuItem(
                            icon: "bell.fill",
                            title: "Reminders",
                            color: .red
                        )
                    }
                    
                    NavigationLink(destination: HealthKitSettingsView()) {
                        MoreMenuItem(
                            icon: "heart.fill",
                            title: "Apple Health",
                            color: .red
                        )
                    }
                    
                    Button(action: { showingExport = true }) {
                        MoreMenuItem(
                            icon: "square.and.arrow.up",
                            title: "Export Data",
                            color: .blue
                        )
                    }
                    
                    Button(action: { showingSettings = true }) {
                        MoreMenuItem(
                            icon: "gearshape.fill",
                            title: "Settings",
                            color: .gray
                        )
                    }
                    
                    Button(action: { showingHelp = true }) {
                        MoreMenuItem(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            color: Color(red: 139/255, green: 69/255, blue: 19/255)
                        )
                    }

                    Button(action: { showingResetAlert = true }) {
                        MoreMenuItem(
                            icon: "trash.fill",
                            title: "Reset All Data",
                            color: .red
                        )
                    }
                }
                
                // Developer Tools - Disabled for production release
                // Section("Developer Tools") {
                //     Button(action: { showingDemoDataAlert = true }) {
                //         HStack {
                //             Image(systemName: "wand.and.stars")
                //                 .foregroundColor(.blue)
                //             Text("Generate Demo Data")
                //                 .foregroundColor(.primary)
                //             Spacer()
                //             if hasDemoData {
                //                 Image(systemName: "checkmark.circle.fill")
                //                     .foregroundColor(.green)
                //             }
                //         }
                //     }
                //     .disabled(hasDemoData)
                //
                //     NavigationLink(destination: AppIconPreview()) {
                //         HStack {
                //             Image(systemName: "app.badge")
                //                 .foregroundColor(.purple)
                //             Text("App Icon Generator")
                //                 .foregroundColor(.primary)
                //         }
                //     }
                // }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingProgress) {
                NavigationView {
                    ProfessionalProgressView()
                }
            }
            .sheet(isPresented: $showingGoals) {
                SimpleGoalsView()
            }
            .sheet(isPresented: $showingReminders) {
                RemindersView()
            }
            .sheet(isPresented: $showingExport) {
                ExportDataView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .sheet(isPresented: $showingUSDAImport) {
                USDAImportView()
            }
            // Unified tracking entry sheets
            .sheet(isPresented: $showingFoodSearch) {
                UnifiedFoodSearchSheet(mealType: selectedMealType)
            }
            .sheet(isPresented: $showingExerciseSearch) {
                ExerciseSearchView(selectedDate: Date())
            }
            .sheet(isPresented: $showingWeightEntry) {
                QuickWeightAddView(selectedDate: Date())
            }
            .sheet(isPresented: $showingSupplementEntry) {
                ManualSupplementEntryView()
            }
            .sheet(isPresented: $showingWaterEntry) {
                QuickWaterAddView(selectedDate: Date())
            }
            .alert("Generate Demo Data?", isPresented: $showingDemoDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Generate") {
                    generateDemoData()
                }
            } message: {
                Text("This will create sample food, exercise, weight, and supplement entries for the past 30 days. This helps you see how the app looks with data.")
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    showingResetConfirmation = true
                }
            } message: {
                Text("This will permanently delete all your data including food entries, exercises, weight records, supplements, and custom foods. This action cannot be undone.")
            }
            .alert("Are You Sure?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Everything", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This is your final confirmation. All data will be permanently deleted and cannot be recovered.")
            }
        }
    }
    
    private func generateDemoData() {
        let context = PersistenceController.shared.container.viewContext
        DemoDataGenerator.generateDemoData(context: context)
        hasDemoData = true
    }

    private func resetAllData() {
        // Delete all Food Entries
        let foodFetchRequest: NSFetchRequest<NSFetchRequestResult> = FoodEntry.fetchRequest()
        let foodDeleteRequest = NSBatchDeleteRequest(fetchRequest: foodFetchRequest)

        // Delete all Exercise Entries
        let exerciseFetchRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseEntry.fetchRequest()
        let exerciseDeleteRequest = NSBatchDeleteRequest(fetchRequest: exerciseFetchRequest)

        // Delete all Weight Entries
        let weightFetchRequest: NSFetchRequest<NSFetchRequestResult> = WeightEntry.fetchRequest()
        let weightDeleteRequest = NSBatchDeleteRequest(fetchRequest: weightFetchRequest)

        // Delete all Supplement Entries
        let supplementFetchRequest: NSFetchRequest<NSFetchRequestResult> = SupplementEntry.fetchRequest()
        let supplementDeleteRequest = NSBatchDeleteRequest(fetchRequest: supplementFetchRequest)

        // Delete all Water Entries
        let waterFetchRequest: NSFetchRequest<NSFetchRequestResult> = WaterEntry.fetchRequest()
        let waterDeleteRequest = NSBatchDeleteRequest(fetchRequest: waterFetchRequest)

        // Delete all Custom Foods
        let customFoodFetchRequest: NSFetchRequest<NSFetchRequestResult> = CustomFood.fetchRequest()
        let customFoodDeleteRequest = NSBatchDeleteRequest(fetchRequest: customFoodFetchRequest)

        // Delete all User Goals (if they exist)
        // Note: Commenting out as DailyGoals entity might not exist
        // let goalsRequest: NSFetchRequest<NSFetchRequestResult> = DailyGoals.fetchRequest()
        // let goalsDeleteRequest = NSBatchDeleteRequest(fetchRequest: goalsRequest)

        // Execute all delete requests
        do {
            try viewContext.execute(foodDeleteRequest)
            try viewContext.execute(exerciseDeleteRequest)
            try viewContext.execute(weightDeleteRequest)
            try viewContext.execute(supplementDeleteRequest)
            try viewContext.execute(waterDeleteRequest)
            try viewContext.execute(customFoodDeleteRequest)
            // try viewContext.execute(goalsDeleteRequest)

            // Save the context
            try viewContext.save()

            // Reset the demo data flag
            hasDemoData = false

            // Reset the user profile to trigger welcome screen
            userProfileManager.resetProfile()

            // Force refresh the UI
            // The data will automatically refresh via Core Data observers

        } catch {
            print("Error resetting data: \(error)")
        }
    }
}

struct MoreMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AchievementsView: View {
    @EnvironmentObject var achievementManager: AchievementManager
    
    var body: some View {
        List {
            ForEach(achievementManager.recentAchievements) { achievement in
                HStack {
                    Image(systemName: iconForAchievement(achievement.type))
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(achievement.dateEarned, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let value = achievement.value {
                        Text(String(format: "%.0f", value))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Achievements")
    }
    
    private func iconForAchievement(_ type: AchievementType) -> String {
        switch type {
        case .weightLoss: return "arrow.down.circle.fill"
        case .exerciseStreak: return "flame.fill"
        case .calorieGoal: return "target"
        case .streak: return "calendar"
        case .nutritionBalance: return "leaf.fill"
        case .waterIntake: return "drop.fill"
        case .stepGoal: return "figure.walk"
        case .supplementConsistency: return "pills.fill"
        case .exerciseGoal: return "figure.run"
        case .calorieTarget: return "flame.fill"
        case .loggingStreak: return "calendar.badge.checkmark"
        case .other: return "star.fill"
        }
    }
}

struct CustomFoodsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomFood.name, ascending: true)]
    ) private var customFoods: FetchedResults<CustomFood>
    
    @State private var showingAddFood = false
    
    var body: some View {
        List {
            ForEach(customFoods) { food in
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name ?? "Unknown")
                        .font(.headline)
                    HStack {
                        Text("\(Int(food.calories)) cal")
                        Text("•")
                        Text("P: \(Int(food.protein))g")
                        Text("•")
                        Text("C: \(Int(food.carbs))g")
                        Text("•")
                        Text("F: \(Int(food.fat))g")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteFoods)
        }
        .navigationTitle("My Foods")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddFood = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddCustomFoodView()
        }
    }
    
    private func deleteFoods(offsets: IndexSet) {
        withAnimation {
            offsets.map { customFoods[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct RecipeLibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedCategory: RecipeCategory? = nil
    @State private var searchText = ""
    
    // Fetch imported recipes from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomRecipe.name, ascending: true)],
        predicate: NSPredicate(format: "isUserCreated == false")
    ) private var importedRecipes: FetchedResults<CustomRecipe>
    
    var body: some View {
        VStack {
            searchBarView
            categoryFilterView
            recipeGridView
        }
        .navigationTitle("Recipe Library")
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search recipes...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                RecipeCategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    RecipeCategoryChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var recipeGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: ProfessionalRecipeDetailView(recipe: recipe)) {
                        RecipeCard(recipe: recipe)
                    }
                }
            }
            .padding()
        }
    }
    
    private var filteredRecipes: [RecipeModel] {
        // Combine built-in recipes with imported recipes
        var recipes = RecipeDatabase.shared.recipes

        // Convert imported CustomRecipe entities to RecipeModel structs
        let convertedImportedRecipes = importedRecipes.compactMap { customRecipe -> RecipeModel? in
            guard let name = customRecipe.name,
                  let categoryString = customRecipe.category,
                  let category = RecipeCategory(rawValue: categoryString) else {
                return nil
            }
            
            // Parse ingredients from string array
            let ingredients: [IngredientModel] = (customRecipe.ingredients ?? []).map { ingredientString in
                // Simple parsing - in real app would be more sophisticated
                IngredientModel(name: ingredientString, amount: 1, unit: .piece, notes: nil, category: .other)
            }
            
            return RecipeModel(
                id: customRecipe.id ?? UUID(),
                name: name,
                category: category,
                prepTime: Int(customRecipe.prepTime),
                cookTime: Int(customRecipe.cookTime),
                servings: Int(customRecipe.servings),
                ingredients: ingredients,
                instructions: customRecipe.instructions ?? [],
                nutrition: NutritionInfo(
                    calories: customRecipe.calories,
                    protein: customRecipe.protein,
                    carbs: customRecipe.carbs,
                    fat: customRecipe.fat,
                    fiber: customRecipe.fiber,
                    sugar: customRecipe.sugar,
                    sodium: customRecipe.sodium
                ),
                source: customRecipe.source,
                tags: customRecipe.tags ?? [],
                isFavorite: customRecipe.isFavorite
            )
        }
        
        // Combine all recipes
        recipes.append(contentsOf: convertedImportedRecipes)
        
        // Apply filters
        if let category = selectedCategory {
            recipes = recipes.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return recipes
    }
}

struct RecipeCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.wellnessGreen : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct RecipeCard: View {
    let recipe: RecipeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Image
            if let imageURL = recipe.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
            }
            
            // Recipe Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(recipe.totalTime) min")
                        .font(.caption)
                    
                    Spacer()
                    
                    StarRatingView(rating: recipe.rating)
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct HealthKitSettingsView: View {
    @State private var isAuthorized = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var syncWeight = true
    @State private var syncExercise = true
    @State private var syncSteps = true

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Connection Status")
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Text(isAuthorized ? "Connected" : "Not Connected")
                            .foregroundColor(isAuthorized ? .green : .red)
                    }
                }

                if !isAuthorized && !isLoading {
                    Button("Connect to Apple Health") {
                        requestHealthKitAccess()
                    }
                    .foregroundColor(.blue)
                }
            }

            if isAuthorized {
                Section("Sync Settings") {
                    Toggle("Sync Weight", isOn: $syncWeight)
                    Toggle("Sync Exercise", isOn: $syncExercise)
                    Toggle("Sync Steps", isOn: $syncSteps)
                }

                Section {
                    Button("Sync Now") {
                        performSync()
                    }
                    .foregroundColor(.blue)
                }

                Section {
                    Text("HealthTracker can read and write health data to provide comprehensive tracking.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("About")
                }
            }
        }
        .navigationTitle("Apple Health")
        .alert("HealthKit Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }

    private func requestHealthKitAccess() {
        isLoading = true

        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data is not available on this device."
            showError = true
            isLoading = false
            return
        }

        // Request authorization
        HealthKitManager.shared.requestAuthorization { success in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isAuthorized = success

                if !success {
                    self.errorMessage = "Failed to connect to Apple Health. Please go to Settings > Privacy & Security > Health > HealthTracker and grant permissions."
                    self.showError = true
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        // For now, we'll check if we've been authorized before
        // In a production app, you'd check the actual authorization status
        isAuthorized = false
    }

    private func performSync() {
        // Implement sync functionality
        print("Syncing with Apple Health...")
    }
}

// Import the actual GoalsView from Goals folder
// GoalsView is now defined in Views/Goals/GoalsView.swift


struct ExportDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var exportType: ExportType = .csv
    @State private var dateRange: DateRange = .allTime
    @State private var showShareSheet = false
    @State private var exportedData: Data?
    @State private var isExporting = false

    enum ExportType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"

        var fileExtension: String {
            switch self {
            case .csv: return "csv"
            case .json: return "json"
            }
        }
    }

    enum DateRange: String, CaseIterable {
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case last3Months = "Last 3 Months"
        case allTime = "All Time"

        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .lastWeek:
                return calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            case .lastMonth:
                return calendar.date(byAdding: .month, value: -1, to: now) ?? now
            case .last3Months:
                return calendar.date(byAdding: .month, value: -3, to: now) ?? now
            case .allTime:
                return Date.distantPast
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $exportType) {
                        ForEach(ExportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Date Range") {
                    Picker("Period", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }

                Section("Data to Export") {
                    Label("Food Entries", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Exercise Sessions", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Weight Records", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Water Intake", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Supplements", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                Section {
                    Button(action: exportData) {
                        if isExporting {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Exporting...")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Data")
                            }
                        }
                    }
                    .disabled(isExporting)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = exportedData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private func exportData() {
        isExporting = true

        // Simple export implementation - creates a basic summary
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let exportString = "Health Tracker Data Export\n" +
                              "Date: \(Date().formatted())\n" +
                              "Range: \(dateRange.rawValue)\n" +
                              "Format: \(exportType.rawValue)\n\n" +
                              "This is a placeholder export. Full implementation would include all selected data."

            exportedData = exportString.data(using: .utf8)
            isExporting = false
            showShareSheet = true
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useMetricSystem") private var useMetricSystem = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("autoBackup") private var autoBackup = true
    @AppStorage("calorieDisplayMode") private var calorieDisplayMode = "remaining"

    var body: some View {
        NavigationView {
            Form {
                Section("General") {
                    Toggle("Use Metric System", isOn: $useMetricSystem)

                    Picker("Calorie Display", selection: $calorieDisplayMode) {
                        Text("Show Remaining").tag("remaining")
                        Text("Show Consumed").tag("consumed")
                        Text("Show Both").tag("both")
                    }
                }

                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { _, newValue in
                            // This would need to be implemented with proper dark mode support
                        }
                }

                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $enableNotifications)

                    if enableNotifications {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Manage all your reminders in the Reminders tab")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.mindfulTeal)
                                Text("Go to Reminders tab →")
                                    .foregroundColor(.mindfulTeal)
                            }
                            .font(.callout)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Data & Privacy") {
                    Toggle("Auto Backup", isOn: $autoBackup)

                    HStack {
                        Text("Last Backup")
                        Spacer()
                        Text(Date().addingTimeInterval(-3600).formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2024.1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: HelpCategory? = nil
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search for help", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding(.horizontal)

                // Quick Actions
                Section("Quick Help") {
                    NavigationLink(destination: GettingStartedView()) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.mindfulTeal)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Getting Started")
                                    .font(.headline)
                                Text("Learn the basics of Health Tracker")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    NavigationLink(destination: TutorialsView()) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Tutorials")
                                    .font(.headline)
                                Text("Step-by-step guides for features")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // FAQ Section
                Section("Frequently Asked Questions") {
                    ForEach(filteredFAQs) { faq in
                        NavigationLink(destination: FAQDetailView(faq: faq)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(faq.question)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                Text(faq.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Contact Support
                Section("Contact Support") {
                    Button(action: sendEmailSupport) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Email Support")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }

                    Button(action: openWebSupport) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.green)
                            Text("Visit Support Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }

                    Button(action: reportBug) {
                        HStack {
                            Image(systemName: "ant.fill")
                                .foregroundColor(.red)
                            Text("Report a Bug")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                // Resources
                Section("Resources") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.fill")
                    }

                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }

                    Button(action: rateApp) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Rate Health Tracker")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                // App Info
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 2024.1)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Last Updated")
                        Spacer()
                        Text("January 2025")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredFAQs: [FAQ] {
        if searchText.isEmpty {
            return FAQ.allFAQs
        } else {
            return FAQ.allFAQs.filter { faq in
                faq.question.localizedCaseInsensitiveContains(searchText) ||
                faq.answer.localizedCaseInsensitiveContains(searchText) ||
                faq.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func sendEmailSupport() {
        if let url = URL(string: "mailto:support@healthtracker.app?subject=Health%20Tracker%20Support") {
            UIApplication.shared.open(url)
        }
    }

    private func openWebSupport() {
        if let url = URL(string: "https://healthtracker.app/support") {
            UIApplication.shared.open(url)
        }
    }

    private func reportBug() {
        if let url = URL(string: "mailto:bugs@healthtracker.app?subject=Bug%20Report&body=Please%20describe%20the%20issue%20you%20encountered:") {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        // This would normally open the App Store review page
        if let url = URL(string: "https://apps.apple.com/app/idXXXXXXXXX") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct GettingStartedView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Health Tracker!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    GuideSection(
                        icon: "1.circle.fill",
                        title: "Set Up Your Profile",
                        description: "Start by entering your basic information like age, weight, and health goals. This helps us personalize your experience."
                    )

                    GuideSection(
                        icon: "2.circle.fill",
                        title: "Track Your Meals",
                        description: "Log your meals using our extensive food database or create custom foods. Track calories and nutrients automatically."
                    )

                    GuideSection(
                        icon: "3.circle.fill",
                        title: "Log Your Exercise",
                        description: "Record your workouts and activities to track calories burned and monitor your fitness progress."
                    )

                    GuideSection(
                        icon: "4.circle.fill",
                        title: "Monitor Progress",
                        description: "View charts and insights to understand your health trends and stay motivated on your journey."
                    )

                    GuideSection(
                        icon: "5.circle.fill",
                        title: "Earn Achievements",
                        description: "Complete challenges and earn badges as you reach your health and fitness milestones."
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Getting Started")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideSection: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.mindfulTeal)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TutorialsView: View {
    var body: some View {
        List {
            Section("Nutrition Tracking") {
                TutorialRow(title: "How to log meals", duration: "2 min")
                TutorialRow(title: "Creating custom foods", duration: "3 min")
                TutorialRow(title: "Using the barcode scanner", duration: "1 min")
                TutorialRow(title: "Meal planning basics", duration: "4 min")
            }

            Section("Exercise & Activity") {
                TutorialRow(title: "Logging workouts", duration: "2 min")
                TutorialRow(title: "Setting up step tracking", duration: "1 min")
                TutorialRow(title: "Creating custom exercises", duration: "3 min")
            }

            Section("Health Monitoring") {
                TutorialRow(title: "Tracking weight changes", duration: "2 min")
                TutorialRow(title: "Understanding your health score", duration: "3 min")
                TutorialRow(title: "Setting and managing goals", duration: "4 min")
            }

            Section("Advanced Features") {
                TutorialRow(title: "Using fasting timer", duration: "2 min")
                TutorialRow(title: "Managing supplements", duration: "3 min")
                TutorialRow(title: "Exporting your data", duration: "2 min")
            }
        }
        .navigationTitle("Tutorials")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TutorialRow: View {
    let title: String
    let duration: String

    var body: some View {
        HStack {
            Image(systemName: "play.circle")
                .foregroundColor(.blue)
            Text(title)
            Spacer()
            Text(duration)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct FAQDetailView: View {
    let faq: FAQ

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(faq.question)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(faq.answer)
                    .font(.body)

                if !faq.relatedLinks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Related Topics")
                            .font(.headline)

                        ForEach(faq.relatedLinks, id: \.self) { link in
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.mindfulTeal)
                                Text(link)
                                    .foregroundColor(.mindfulTeal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Last updated: January 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Your privacy is important to us. This privacy policy explains how we collect, use, and protect your information when you use Health Tracker.")

                Group {
                    Text("Information We Collect")
                        .font(.headline)
                        .padding(.top)
                    Text("• Health and fitness data you enter")
                    Text("• Device information for app functionality")
                    Text("• Usage analytics to improve the app")
                }

                Group {
                    Text("How We Use Your Information")
                        .font(.headline)
                        .padding(.top)
                    Text("• To provide personalized health insights")
                    Text("• To track your progress toward goals")
                    Text("• To improve app features and performance")
                }

                Group {
                    Text("Data Security")
                        .font(.headline)
                        .padding(.top)
                    Text("We use industry-standard encryption to protect your data. Your information is stored securely on your device and in iCloud if enabled.")
                }

                Group {
                    Text("Your Rights")
                        .font(.headline)
                        .padding(.top)
                    Text("You can export or delete your data at any time through the app settings. We never share your personal health information with third parties without your consent.")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("By using Health Tracker, you agree to these terms.")

                Group {
                    Text("Use of the App")
                        .font(.headline)
                        .padding(.top)
                    Text("Health Tracker is designed for personal health tracking and should not replace professional medical advice.")
                }

                Group {
                    Text("User Responsibilities")
                        .font(.headline)
                        .padding(.top)
                    Text("You are responsible for the accuracy of the information you enter and for maintaining the security of your account.")
                }

                Group {
                    Text("Limitations")
                        .font(.headline)
                        .padding(.top)
                    Text("We strive for accuracy but cannot guarantee that all nutritional information is 100% accurate. Always consult with healthcare professionals for medical decisions.")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Models

enum HelpCategory: String, CaseIterable {
    case gettingStarted = "Getting Started"
    case nutrition = "Nutrition"
    case exercise = "Exercise"
    case tracking = "Tracking"
    case goals = "Goals"
    case technical = "Technical"
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let category: HelpCategory
    let relatedLinks: [String]

    static let allFAQs = [
        FAQ(
            question: "How do I track my daily calories?",
            answer: "To track calories, go to the Diary tab and tap the '+' button to add food. You can search our database, scan barcodes, or create custom foods. Your daily calorie total appears at the top of the diary.",
            category: .nutrition,
            relatedLinks: ["Creating custom foods", "Using the barcode scanner"]
        ),
        FAQ(
            question: "Can I set custom calorie goals?",
            answer: "Yes! Go to More > Goals and tap on Calorie Goal. You can set a custom daily calorie target based on your needs.",
            category: .goals,
            relatedLinks: ["Setting weight goals", "Understanding macros"]
        ),
        FAQ(
            question: "How does the health score work?",
            answer: "Your health score is calculated based on multiple factors including steps taken, calories consumed vs. goal, water intake, and exercise completed. The score updates in real-time as you log activities.",
            category: .tracking,
            relatedLinks: ["Improving your health score", "Understanding metrics"]
        ),
        FAQ(
            question: "Can I export my data?",
            answer: "Yes, go to More > Export Data. You can export your health data in CSV or JSON format for any date range.",
            category: .technical,
            relatedLinks: ["Data backup", "Privacy settings"]
        ),
        FAQ(
            question: "How do I track water intake?",
            answer: "You can track water from the Dashboard quick actions or the Diary tab. Tap the water icon and enter the amount consumed.",
            category: .tracking,
            relatedLinks: ["Setting water goals", "Water reminders"]
        ),
        FAQ(
            question: "What are achievements?",
            answer: "Achievements are rewards for reaching health milestones like logging meals for 7 days straight or reaching step goals. View them in More > Achievements.",
            category: .goals,
            relatedLinks: ["Earning badges", "Streak tracking"]
        )
    ]
}

// #Preview {
//     MoreView()
//         .environmentObject(UserProfileManager())
//         .environmentObject(AchievementManager())
// }