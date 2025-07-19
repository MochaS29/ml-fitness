import SwiftUI

struct MealPlanningView: View {
    @State private var selectedTab = 0
    @State private var currentMealPlan: MealPlan?
    @State private var showingRecipeLibrary = false
    @State private var showingGroceryList = false
    @StateObject private var mealPlanManager = MealPlanManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Weekly Plan").tag(0)
                    Text("Recipes").tag(1)
                    Text("Grocery List").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected tab
                switch selectedTab {
                case 0:
                    WeeklyMealPlanView(
                        mealPlan: $currentMealPlan,
                        showingRecipeLibrary: $showingRecipeLibrary
                    )
                case 1:
                    MealPlanningRecipeLibraryView()
                case 2:
                    GroceryListView(mealPlan: currentMealPlan)
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Meal Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingRecipeLibrary = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingRecipeLibrary) {
                RecipeSelectionView { recipe in
                    // Add recipe to meal plan
                    if currentMealPlan == nil {
                        createNewMealPlan()
                    }
                    addRecipeToMealPlan(recipe)
                }
            }
            .onAppear {
                loadCurrentMealPlan()
            }
        }
    }
    
    func createNewMealPlan() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        currentMealPlan = MealPlan(
            name: "Weekly Plan",
            startDate: startDate,
            endDate: endDate,
            meals: []
        )
    }
    
    func loadCurrentMealPlan() {
        // Load from UserDefaults or Core Data
        currentMealPlan = mealPlanManager.getCurrentMealPlan()
    }
    
    func addRecipeToMealPlan(_ recipe: Recipe) {
        // Implementation to add recipe to current meal plan
    }
}

struct WeeklyMealPlanView: View {
    @Binding var mealPlan: MealPlan?
    @Binding var showingRecipeLibrary: Bool
    @State private var selectedDate = Date()
    
    var weekDays: [Date] {
        guard let firstDay = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return []
        }
        return (0..<7).compactMap { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: firstDay)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Week selector
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(weekDateRange)
                        .font(.headline)
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // Days of the week
                ForEach(weekDays, id: \.self) { date in
                    DayMealPlanCard(
                        date: date,
                        meals: mealsForDate(date),
                        onAddMeal: { mealType in
                            // Add meal for this date and type
                            showingRecipeLibrary = true
                        }
                    )
                    .cardStyle()
                }
            }
            .padding()
        }
    }
    
    var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = weekDays.first ?? Date()
        let end = weekDays.last ?? Date()
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
    
    func mealsForDate(_ date: Date) -> [PlannedMeal] {
        guard let plan = mealPlan else { return [] }
        return plan.meals.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

struct DayMealPlanCard: View {
    let date: Date
    let meals: [PlannedMeal]
    let onAddMeal: (MealType) -> Void
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .foregroundColor(isToday ? .mochaBrown : .primary)
                
                if isToday {
                    Text("Today")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.mochaBrown)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
            
            // Meal slots
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealSlotView(
                    mealType: mealType,
                    plannedMeal: meals.first { $0.mealType == mealType },
                    onAdd: { onAddMeal(mealType) }
                )
            }
        }
        .padding()
    }
}

struct MealSlotView: View {
    let mealType: MealType
    let plannedMeal: PlannedMeal?
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let meal = plannedMeal {
                    Text(meal.recipe.name)
                        .font(.body)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label("\(meal.recipe.totalTime) min", systemImage: "clock")
                        Label("\(Int(meal.recipe.nutrition?.calories ?? 0)) cal", systemImage: "flame")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } else {
                    Button(action: onAdd) {
                        Label("Add meal", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundColor(.mindfulTeal)
                    }
                }
            }
            
            Spacer()
            
            if plannedMeal != nil {
                Menu {
                    Button("Change Recipe", action: onAdd)
                    Button("Remove", role: .destructive) {
                        // Remove meal
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.lightGray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct MealPlanningRecipeLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: RecipeCategory?
    @State private var showingRecipeDetail = false
    @State private var selectedRecipe: Recipe?
    
    private let recipeDatabase = RecipeDatabase.shared
    
    var filteredRecipes: [Recipe] {
        var recipes = recipeDatabase.searchRecipes(searchText)
        if let category = selectedCategory {
            recipes = recipes.filter { $0.category == category }
        }
        return recipes
    }
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search recipes...", text: $searchText)
            }
            .padding(8)
            .background(Color.lightGray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
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
            
            // Recipe list
            List(filteredRecipes) { recipe in
                RecipeRow(recipe: recipe) {
                    selectedRecipe = recipe
                    showingRecipeDetail = true
                }
            }
        }
        .sheet(isPresented: $showingRecipeDetail) {
            if let recipe = selectedRecipe {
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                
                HStack(spacing: 15) {
                    Label("\(recipe.totalTime) min", systemImage: "clock")
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                    if let calories = recipe.nutrition?.calories {
                        Label("\(Int(calories)) cal", systemImage: "flame")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.mindfulTeal.opacity(0.2))
                                .foregroundColor(.mindfulTeal)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct RecipeSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSelect: (Recipe) -> Void
    
    var body: some View {
        NavigationView {
            MealPlanningRecipeLibraryView()
                .navigationTitle("Select Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

// Meal Plan Manager
class MealPlanManager: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    
    func getCurrentMealPlan() -> MealPlan? {
        // Return the current week's meal plan
        let today = Date()
        return mealPlans.first { plan in
            plan.startDate <= today && plan.endDate >= today
        }
    }
    
    func saveMealPlan(_ mealPlan: MealPlan) {
        // Save to UserDefaults or Core Data
    }
}