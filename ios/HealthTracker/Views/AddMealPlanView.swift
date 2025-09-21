import SwiftUI
import CoreData

struct AddMealPlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedRecipe: RecipeModel?
    @State private var selectedCustomRecipe: CustomRecipe?
    @State private var selectedFoodItems: [FoodItem] = []
    @State private var servings: Int = 1
    @State private var notes: String = ""
    @State private var showingRecipeSelector = false
    @State private var showingFoodSearch = false
    @State private var mealSource: MealSource = .recipe
    @State private var recipeSource: RecipeSource = .library

    enum MealSource {
        case recipe
        case foods
    }

    enum RecipeSource {
        case library
        case custom
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meal Details") {
                    // Date display
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
                            .foregroundColor(.secondary)
                    }

                    // Meal type picker
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }

                    // Meal source picker
                    Picker("Add From", selection: $mealSource) {
                        Text("Recipe").tag(MealSource.recipe)
                        Text("Food Items").tag(MealSource.foods)
                    }
                    .pickerStyle(.segmented)

                    // Recipe or Foods selector
                    if mealSource == .recipe {
                        HStack {
                            Text("Recipe")
                            Spacer()
                            if let recipe = selectedRecipe {
                                Text(recipe.name)
                                    .foregroundColor(.secondary)
                            } else if let customRecipe = selectedCustomRecipe {
                                Text(customRecipe.name ?? "Unknown")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Select Recipe")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingRecipeSelector = true
                        }
                    } else {
                        HStack {
                            Text("Foods")
                            Spacer()
                            if selectedFoodItems.isEmpty {
                                Text("Add Foods")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(selectedFoodItems.count) items")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingFoodSearch = true
                        }
                    }
                    
                    // Servings (only for recipes)
                    if mealSource == .recipe {
                        Stepper("Servings: \(servings)", value: $servings, in: 1...10)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Selected Foods List (when adding foods)
                if mealSource == .foods && !selectedFoodItems.isEmpty {
                    Section("Selected Foods") {
                        ForEach(selectedFoodItems, id: \.id) { food in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    Text("\(Int(food.calories)) cal")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    selectedFoodItems.removeAll { $0.id == food.id }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }
                    }
                }

                // Nutrition preview
                if selectedRecipe != nil || selectedCustomRecipe != nil || !selectedFoodItems.isEmpty {
                    Section("Nutrition (Total)") {
                        HStack {
                            NutritionLabel(
                                value: Int(totalCalories),
                                label: "Calories"
                            )
                            NutritionLabel(
                                value: Int(totalProtein),
                                label: "Protein",
                                unit: "g"
                            )
                            NutritionLabel(
                                value: Int(totalCarbs),
                                label: "Carbs",
                                unit: "g"
                            )
                            NutritionLabel(
                                value: Int(totalFat),
                                label: "Fat",
                                unit: "g"
                            )
                        }
                    }
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMealPlan()
                    }
                    .disabled(selectedRecipe == nil && selectedCustomRecipe == nil && selectedFoodItems.isEmpty)
                }
            }
            .sheet(isPresented: $showingRecipeSelector) {
                RecipeSelectorView(
                    selectedRecipe: $selectedRecipe,
                    selectedCustomRecipe: $selectedCustomRecipe,
                    recipeSource: $recipeSource
                )
            }
            .sheet(isPresented: $showingFoodSearch) {
                MealPlanFoodSelector(
                    selectedFoodItems: $selectedFoodItems,
                    mealType: selectedMealType
                )
            }
        }
    }
    
    private var totalCalories: Double {
        if mealSource == .recipe {
            if let recipe = selectedRecipe {
                return (recipe.nutrition?.calories ?? 0) * Double(servings)
            } else if let customRecipe = selectedCustomRecipe {
                return customRecipe.calories * Double(servings) / Double(customRecipe.servings)
            }
        } else {
            return selectedFoodItems.reduce(0) { $0 + $1.calories }
        }
        return 0
    }
    
    private var totalProtein: Double {
        if mealSource == .recipe {
            if let recipe = selectedRecipe {
                return (recipe.nutrition?.protein ?? 0) * Double(servings)
            } else if let customRecipe = selectedCustomRecipe {
                return customRecipe.protein * Double(servings) / Double(customRecipe.servings)
            }
        } else {
            return selectedFoodItems.reduce(0) { $0 + $1.protein }
        }
        return 0
    }
    
    private var totalCarbs: Double {
        if mealSource == .recipe {
            if let recipe = selectedRecipe {
                return (recipe.nutrition?.carbs ?? 0) * Double(servings)
            } else if let customRecipe = selectedCustomRecipe {
                return customRecipe.carbs * Double(servings) / Double(customRecipe.servings)
            }
        } else {
            return selectedFoodItems.reduce(0) { $0 + $1.carbs }
        }
        return 0
    }
    
    private var totalFat: Double {
        if mealSource == .recipe {
            if let recipe = selectedRecipe {
                return (recipe.nutrition?.fat ?? 0) * Double(servings)
            } else if let customRecipe = selectedCustomRecipe {
                return customRecipe.fat * Double(servings) / Double(customRecipe.servings)
            }
        } else {
            return selectedFoodItems.reduce(0) { $0 + $1.fat }
        }
        return 0
    }
    
    private func saveMealPlan() {
        if mealSource == .foods {
            // When adding foods, save them directly as food entries
            let dataManager = UnifiedDataManager.shared
            for food in selectedFoodItems {
                dataManager.addFoodFromDatabase(food, mealType: selectedMealType)
            }
            dismiss()
        } else {
            // Save as meal plan with recipe
            let mealPlan = MealPlan(context: viewContext)
            mealPlan.id = UUID()
            mealPlan.date = selectedDate
            mealPlan.mealType = selectedMealType.rawValue
            mealPlan.servings = Int32(servings)
            mealPlan.notes = notes.isEmpty ? nil : notes

            if let recipe = selectedRecipe {
                mealPlan.recipeName = recipe.name
                mealPlan.recipeId = recipe.id
            } else if let customRecipe = selectedCustomRecipe {
                mealPlan.recipeName = customRecipe.name
                mealPlan.recipeId = customRecipe.id
            }

            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Error saving meal plan: \(error)")
            }
        }
    }
}

// Recipe selector view
struct RecipeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selectedRecipe: RecipeModel?
    @Binding var selectedCustomRecipe: CustomRecipe?
    @Binding var recipeSource: AddMealPlanView.RecipeSource
    
    @State private var searchText = ""
    @State private var selectedCategory: RecipeCategory?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomRecipe.name, ascending: true)],
        animation: .default
    ) private var customRecipes: FetchedResults<CustomRecipe>
    
    var filteredLibraryRecipes: [RecipeModel] {
        var recipes = RecipeDatabase.shared.recipes
        
        if !searchText.isEmpty {
            recipes = recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            recipes = recipes.filter { $0.category == category }
        }
        
        return recipes
    }
    
    var filteredCustomRecipes: [CustomRecipe] {
        if searchText.isEmpty {
            return Array(customRecipes)
        }
        
        return customRecipes.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Source selector
                Picker("Source", selection: $recipeSource) {
                    Text("Library").tag(AddMealPlanView.RecipeSource.library)
                    Text("My Recipes").tag(AddMealPlanView.RecipeSource.custom)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search recipes...", text: $searchText)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                if recipeSource == .library {
                    // Category filter for library recipes
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            MealCategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(RecipeCategory.allCases, id: \.self) { category in
                                MealCategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                // Recipe list
                List {
                    if recipeSource == .library {
                        ForEach(filteredLibraryRecipes) { recipe in
                            RecipeSelectionRow(
                                name: recipe.name,
                                category: recipe.category.rawValue,
                                prepTime: recipe.totalTime,
                                servings: recipe.servings,
                                isSelected: selectedRecipe?.id == recipe.id
                            ) {
                                selectedRecipe = recipe
                                selectedCustomRecipe = nil
                                dismiss()
                            }
                        }
                    } else {
                        ForEach(filteredCustomRecipes) { recipe in
                            RecipeSelectionRow(
                                name: recipe.name ?? "Unknown",
                                category: recipe.category ?? "Other",
                                prepTime: Int(recipe.prepTime + recipe.cookTime),
                                servings: Int(recipe.servings),
                                isSelected: selectedCustomRecipe?.id == recipe.id
                            ) {
                                selectedCustomRecipe = recipe
                                selectedRecipe = nil
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Recipe selection row
struct RecipeSelectionRow: View {
    let name: String
    let category: String
    let prepTime: Int
    let servings: Int
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(prepTime) min", systemImage: "clock")
                        Label("\(servings) servings", systemImage: "person.2")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.wellnessGreen)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct MealCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.wellnessGreen : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// #Preview {
//     AddMealPlanView(selectedDate: Date())
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }