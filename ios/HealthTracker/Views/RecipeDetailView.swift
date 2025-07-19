import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    @State private var servingsMultiplier: Double = 1.0
    @State private var showingAddToMealPlan = false
    
    var adjustedIngredients: [Ingredient] {
        recipe.ingredients.map { ingredient in
            var adjusted = ingredient
            adjusted.amount = ingredient.amount * servingsMultiplier
            return adjusted
        }
    }
    
    var adjustedNutrition: NutritionInfo? {
        guard let nutrition = recipe.nutrition else { return nil }
        return NutritionInfo(
            calories: nutrition.calories * servingsMultiplier,
            protein: nutrition.protein * servingsMultiplier,
            carbs: nutrition.carbs * servingsMultiplier,
            fat: nutrition.fat * servingsMultiplier,
            fiber: (nutrition.fiber ?? 0) * servingsMultiplier,
            sugar: (nutrition.sugar ?? 0) * servingsMultiplier,
            sodium: (nutrition.sodium ?? 0) * servingsMultiplier
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recipe Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(recipe.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: { /* Toggle favorite */ }) {
                                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(recipe.isFavorite ? .red : .gray)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Label("\(recipe.totalTime) min", systemImage: "clock")
                            Label("\(recipe.servings) servings", systemImage: "person.2")
                            if let calories = recipe.nutrition?.calories {
                                Label("\(Int(calories)) cal", systemImage: "flame")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        // Tags
                        if !recipe.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recipe.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(Color.mindfulTeal.opacity(0.2))
                                            .foregroundColor(.mindfulTeal)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Servings Adjuster
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Adjust Servings")
                            .font(.headline)
                        
                        HStack {
                            Button(action: { if servingsMultiplier > 0.5 { servingsMultiplier -= 0.5 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.mochaBrown)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(servingsMultiplier, specifier: "%.1f")x")
                                    .font(.title3.bold())
                                Text("\(Int(Double(recipe.servings) * servingsMultiplier)) servings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { servingsMultiplier += 0.5 }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.mochaBrown)
                            }
                        }
                        .padding()
                        .background(Color.lightGray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Nutrition Info
                    if let nutrition = adjustedNutrition {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nutrition Information")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                NutritionItem(label: "Calories", value: "\(Int(nutrition.calories))", unit: "")
                                NutritionItem(label: "Protein", value: "\(Int(nutrition.protein))", unit: "g")
                                NutritionItem(label: "Carbs", value: "\(Int(nutrition.carbs))", unit: "g")
                                NutritionItem(label: "Fat", value: "\(Int(nutrition.fat))", unit: "g")
                                if let fiber = nutrition.fiber {
                                    NutritionItem(label: "Fiber", value: "\(Int(fiber))", unit: "g")
                                }
                                if let sodium = nutrition.sodium {
                                    NutritionItem(label: "Sodium", value: "\(Int(sodium))", unit: "mg")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.headline)
                        
                        ForEach(adjustedIngredients) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.mochaBrown)
                                    .padding(.top, 6)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ingredient.fullDescription)
                                        .font(.body)
                                    if let notes = ingredient.notes {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.mochaBrown))
                                
                                Text(instruction)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Source
                    if let source = recipe.source {
                        HStack {
                            Text("Source: ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(source)
                                .font(.caption)
                                .foregroundColor(.mindfulTeal)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showingAddToMealPlan = true }) {
                            Label("Add to Meal Plan", systemImage: "calendar.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButton()
                        
                        Button(action: shareRecipe) {
                            Label("Share Recipe", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryButton()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddToMealPlan) {
            AddToMealPlanView(recipe: recipe, servingsMultiplier: servingsMultiplier)
        }
    }
    
    func shareRecipe() {
        // Implementation for sharing recipe
    }
}

struct NutritionItem: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value + unit)
                .font(.headline)
                .foregroundColor(.mochaBrown)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.lightGray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AddToMealPlanView: View {
    let recipe: Recipe
    let servingsMultiplier: Double
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var selectedMealType = MealType.dinner
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meal Details") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                    
                    HStack {
                        Text("Servings")
                        Spacer()
                        Text("\(Int(Double(recipe.servings) * servingsMultiplier))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Recipe") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text("\(recipe.totalTime) min • \(recipe.category.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Add to Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Add to meal plan logic
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}