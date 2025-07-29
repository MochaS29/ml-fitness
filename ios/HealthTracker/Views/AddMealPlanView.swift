import SwiftUI
import CoreData

struct AddMealPlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedRecipe: Recipe?
    @State private var selectedCustomRecipe: CustomRecipe?
    @State private var servings: Int = 1
    @State private var notes: String = ""
    @State private var showingRecipeSelector = false
    @State private var recipeSource: RecipeSource = .library
    
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
                    
                    // Recipe selector
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
                    
                    // Servings
                    Stepper("Servings: \(servings)", value: $servings, in: 1...10)
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Nutrition preview
                if selectedRecipe != nil || selectedCustomRecipe != nil {
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
                    .disabled(selectedRecipe == nil && selectedCustomRecipe == nil)
                }
            }
            .sheet(isPresented: $showingRecipeSelector) {
                RecipeSelectorView(
                    selectedRecipe: $selectedRecipe,
                    selectedCustomRecipe: $selectedCustomRecipe,
                    recipeSource: $recipeSource
                )
            }
        }
    }
    
    private var totalCalories: Double {
        if let recipe = selectedRecipe {
            return (recipe.nutrition?.calories ?? 0) * Double(servings)
        } else if let customRecipe = selectedCustomRecipe {
            return customRecipe.calories * Double(servings) / Double(customRecipe.servings)
        }
        return 0
    }
    
    private var totalProtein: Double {
        if let recipe = selectedRecipe {
            return (recipe.nutrition?.protein ?? 0) * Double(servings)
        } else if let customRecipe = selectedCustomRecipe {
            return customRecipe.protein * Double(servings) / Double(customRecipe.servings)
        }
        return 0
    }
    
    private var totalCarbs: Double {
        if let recipe = selectedRecipe {
            return (recipe.nutrition?.carbs ?? 0) * Double(servings)
        } else if let customRecipe = selectedCustomRecipe {
            return customRecipe.carbs * Double(servings) / Double(customRecipe.servings)
        }
        return 0
    }
    
    private var totalFat: Double {
        if let recipe = selectedRecipe {
            return (recipe.nutrition?.fat ?? 0) * Double(servings)
        } else if let customRecipe = selectedCustomRecipe {
            return customRecipe.fat * Double(servings) / Double(customRecipe.servings)
        }
        return 0
    }
    
    private func saveMealPlan() {
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

// Recipe selector view
struct RecipeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selectedRecipe: Recipe?
    @Binding var selectedCustomRecipe: CustomRecipe?
    @Binding var recipeSource: AddMealPlanView.RecipeSource
    
    @State private var searchText = ""
    @State private var selectedCategory: RecipeCategory?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomRecipe.name, ascending: true)],
        animation: .default
    ) private var customRecipes: FetchedResults<CustomRecipe>
    
    var filteredLibraryRecipes: [Recipe] {
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

#Preview {
    AddMealPlanView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}