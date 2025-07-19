import SwiftUI

struct MoreView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
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
                    NavigationLink(destination: FoodTrackingView()) {
                        MoreMenuItem(
                            icon: "fork.knife",
                            title: "Food Diary",
                            color: Color(red: 127/255, green: 176/255, blue: 105/255)
                        )
                    }
                    
                    NavigationLink(destination: ExerciseTrackingView()) {
                        MoreMenuItem(
                            icon: "figure.run",
                            title: "Exercise Log",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(destination: WeightTrackingView()) {
                        MoreMenuItem(
                            icon: "scalemass",
                            title: "Weight Tracker",
                            color: Color(red: 139/255, green: 69/255, blue: 19/255)
                        )
                    }
                    
                    NavigationLink(destination: SupplementTrackingView()) {
                        MoreMenuItem(
                            icon: "pills",
                            title: "Supplements",
                            color: .purple
                        )
                    }
                    
                    NavigationLink(destination: IntermittentFastingView()) {
                        MoreMenuItem(
                            icon: "timer",
                            title: "Fasting Timer",
                            color: Color(red: 74/255, green: 155/255, blue: 155/255)
                        )
                    }
                }
                
                // Progress & Analysis
                Section("Progress & Analysis") {
                    NavigationLink(destination: ProfessionalProgressView()) {
                        MoreMenuItem(
                            icon: "chart.bar.fill",
                            title: "Progress Charts",
                            color: .blue
                        )
                    }
                    
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
                }
                
                // Developer Tools
                Section("Developer Tools") {
                    Button(action: { showingDemoDataAlert = true }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.blue)
                            Text("Generate Demo Data")
                                .foregroundColor(.primary)
                            Spacer()
                            if hasDemoData {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .disabled(hasDemoData)
                }
                
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
                GoalsView()
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
            .alert("Generate Demo Data?", isPresented: $showingDemoDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Generate") {
                    generateDemoData()
                }
            } message: {
                Text("This will create sample food, exercise, weight, and supplement entries for the past 30 days. This helps you see how the app looks with data.")
            }
        }
    }
    
    private func generateDemoData() {
        let context = PersistenceController.shared.container.viewContext
        DemoDataGenerator.generateDemoData(context: context)
        hasDemoData = true
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
                        Text(value)
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
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    CategoryChip(
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
    
    private var filteredRecipes: [Recipe] {
        // Combine built-in recipes with imported recipes
        var recipes = RecipeDatabase.shared.recipes
        
        // Convert imported CustomRecipe entities to Recipe structs
        let convertedImportedRecipes = importedRecipes.compactMap { customRecipe -> Recipe? in
            guard let name = customRecipe.name,
                  let categoryString = customRecipe.category,
                  let category = RecipeCategory(rawValue: categoryString) else {
                return nil
            }
            
            // Parse ingredients from string array
            let ingredients: [Ingredient] = (customRecipe.ingredients ?? []).map { ingredientString in
                // Simple parsing - in real app would be more sophisticated
                Ingredient(name: ingredientString, amount: 1, unit: .piece)
            }
            
            return Recipe(
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

struct RecipeCard: View {
    let recipe: Recipe
    
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
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var isAuthorized = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Connection Status")
                    Spacer()
                    Text(isAuthorized ? "Connected" : "Not Connected")
                        .foregroundColor(isAuthorized ? .green : .red)
                }
                
                if !isAuthorized {
                    Button("Connect to Apple Health") {
                        healthKitManager.requestAuthorization { success in
                            isAuthorized = success
                        }
                    }
                }
            }
            
            if isAuthorized {
                Section("Sync Settings") {
                    Toggle("Sync Weight", isOn: .constant(true))
                    Toggle("Sync Exercise", isOn: .constant(true))
                    Toggle("Sync Steps", isOn: .constant(true))
                }
                
                Section {
                    Button("Sync Now") {
                        // Trigger sync
                    }
                }
            }
        }
        .navigationTitle("Apple Health")
        .onAppear {
            // Check authorization status when view appears
            // This could be implemented to check current authorization
        }
    }
}

// Placeholder views for sheets
struct GoalsView: View {
    var body: some View {
        NavigationView {
            Text("Goals Settings")
                .navigationTitle("Goals")
        }
    }
}

struct RemindersView: View {
    var body: some View {
        NavigationView {
            Text("Reminder Settings")
                .navigationTitle("Reminders")
        }
    }
}

struct ExportDataView: View {
    var body: some View {
        NavigationView {
            Text("Export Data Options")
                .navigationTitle("Export Data")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("App Settings")
                .navigationTitle("Settings")
        }
    }
}

struct HelpView: View {
    var body: some View {
        NavigationView {
            Text("Help & Support")
                .navigationTitle("Help")
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(UserProfileManager())
        .environmentObject(AchievementManager())
}