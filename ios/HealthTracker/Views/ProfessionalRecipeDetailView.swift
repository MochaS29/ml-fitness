import SwiftUI
import PhotosUI
import CoreData

struct ProfessionalRecipeDetailView: View {
    let recipe: RecipeModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var scale: Double = 1.0
    @State private var checkedIngredients: Set<UUID> = []
    @State private var showingShareSheet = false
    @State private var showingAddToMealPlan = false
    
    var scaledServings: Int {
        Int(Double(recipe.servings) * scale)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Recipe Header
                VStack(spacing: 16) {
                    // Recipe Image
                    if let imageURL = recipe.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        } placeholder: {
                            RecipeImagePlaceholder()
                        }
                    } else {
                        RecipeImagePlaceholder()
                    }
                    
                    // Recipe Title and Info
                    VStack(spacing: 12) {
                        Text(recipe.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if let source = recipe.source {
                            HStack {
                                Text("from")
                                    .foregroundColor(.secondary)
                                Link(source, destination: URL(string: "https://\(source)")!)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                        
                        // Time and Servings
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text("PREP")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(recipe.prepTime) min")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 4) {
                                Text("COOK")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(recipe.cookTime) min")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 4) {
                                Text("SERVES")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(recipe.servings)")
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Rating
                        HStack {
                            Text("Rating")
                                .font(.subheadline)
                            Spacer()
                            StarRatingView(rating: recipe.rating)
                        }
                        .padding(.horizontal)
                        
                        // Collections
                        HStack {
                            Text("Collections")
                                .font(.subheadline)
                            Spacer()
                            Text("Not set")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // View Full Recipe Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.blue)
                                Text("View Full Recipe")
                                    .foregroundColor(.blue)
                            }
                            .font(.headline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "Ingredients", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Steps", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "Recipe Info", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(UIColor.separator)),
                    alignment: .bottom
                )
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    IngredientsTab(recipe: recipe, scale: $scale, checkedIngredients: $checkedIngredients)
                        .tag(0)

                    StepsTab(recipe: recipe)
                        .tag(1)

                    RecipeInfoTab(recipe: recipe)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom Navigation Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        FavoriteButton(recipe: recipe)
                        
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground).opacity(0.95))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(UIColor.separator)),
                    alignment: .bottom
                ),
                alignment: .top
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [recipe.name])
        }
        .sheet(isPresented: $showingAddToMealPlan) {
            AddToMealPlanView(recipe: recipe, servingsMultiplier: scale)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color.blue : Color.clear)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct IngredientsTab: View {
    let recipe: RecipeModel
    @Binding var scale: Double
    @Binding var checkedIngredients: Set<UUID>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                scaleAndServingsView
                scaleSliderView
                
                // Ingredients List
                VStack(spacing: 0) {
                    ForEach(Array(recipe.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        IngredientRow(
                            ingredient: ingredient,
                            scale: scale,
                            isChecked: checkedIngredients.contains(ingredient.id),
                            onToggle: {
                                if checkedIngredients.contains(ingredient.id) {
                                    checkedIngredients.remove(ingredient.id)
                                } else {
                                    checkedIngredients.insert(ingredient.id)
                                }
                            }
                        )
                        
                        if index < recipe.ingredients.count - 1 {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var scaleAndServingsView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("SCALE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(scale, specifier: "%.1f")x")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("SERVINGS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(Int(Double(recipe.servings) * scale))")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var scaleSliderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { if scale > 0.5 { scale -= 0.5 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Slider(value: $scale, in: 0.5...4.0, step: 0.5)
                
                Button(action: { if scale < 4.0 { scale += 0.5 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct IngredientRow: View {
    let ingredient: IngredientModel
    let scale: Double
    let isChecked: Bool
    let onToggle: () -> Void
    
    var scaledAmount: String {
        let amount = ingredient.amount * scale
        if amount == Double(Int(amount)) {
            return "\(Int(amount))"
        } else {
            return String(format: "%.2f", amount).trimmingCharacters(in: ["0", "."])
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isChecked ? .blue : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(scaledAmount)
                        .fontWeight(.semibold)
                    Text(ingredient.unit.displayName(amount: ingredient.amount * scale))
                    Text(ingredient.name)
                }
                .strikethrough(isChecked)
                .foregroundColor(isChecked ? .secondary : .primary)
                
                if let notes = ingredient.notes {
                    Text("(\(notes))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

struct StepsTab: View {
    let recipe: RecipeModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Prep and Cook Time Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("PREP TIME")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.prepTime) min")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("COOK TIME")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.cookTime) min")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step \(index + 1)")
                                .font(.headline)
                            
                            Text(instruction)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct RecipeInfoTab: View {
    let recipe: RecipeModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Nutrition Information
                if let nutrition = recipe.nutrition {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition Per Serving")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            NutritionInfoItem(label: "Calories", value: Int(nutrition.calories), unit: "")
                            NutritionInfoItem(label: "Protein", value: Int(nutrition.protein), unit: "g")
                            NutritionInfoItem(label: "Carbs", value: Int(nutrition.carbs), unit: "g")
                            NutritionInfoItem(label: "Fat", value: Int(nutrition.fat), unit: "g")
                            if let fiber = nutrition.fiber {
                                NutritionInfoItem(label: "Fiber", value: Int(fiber), unit: "g")
                            }
                            if let sodium = nutrition.sodium {
                                NutritionInfoItem(label: "Sodium", value: Int(sodium), unit: "mg")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Tags
                if !recipe.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                        
                        FlowLayout(items: recipe.tags) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Source
                if let source = recipe.source {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipe Source")
                            .font(.headline)
                        Link(source, destination: URL(string: "https://\(source)")!)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct NutritionInfoItem: View {
    let label: String
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)\(unit)")
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct RecipeImagePlaceholder: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGray5)
            Image(systemName: "photo")
                .font(.system(size: 50))
                .foregroundColor(Color(UIColor.systemGray3))
        }
        .frame(height: 200)
    }
}

struct StarRatingView: View {
    let rating: Int
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(index <= rating ? .yellow : .gray)
            }
        }
    }
}

struct FavoriteButton: View {
    let recipe: RecipeModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite = false
    
    var body: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundColor(isFavorite ? .red : .blue)
        }
        .onAppear {
            checkIfFavorite()
        }
    }
    
    private func checkIfFavorite() {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %@", recipe.id.uuidString)
        request.fetchLimit = 1
        
        do {
            let favorites = try viewContext.fetch(request)
            isFavorite = !favorites.isEmpty
        } catch {
            print("Error checking favorite status: \(error)")
        }
    }
    
    private func toggleFavorite() {
        if isFavorite {
            // Remove from favorites
            let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
            request.predicate = NSPredicate(format: "recipeId == %@", recipe.id.uuidString)
            
            do {
                let favorites = try viewContext.fetch(request)
                favorites.forEach { viewContext.delete($0) }
                try viewContext.save()
                isFavorite = false
            } catch {
                print("Error removing favorite: \(error)")
            }
        } else {
            // Add to favorites
            let favorite = FavoriteRecipe(context: viewContext)
            favorite.id = UUID()
            favorite.recipeId = recipe.id.uuidString
            favorite.recipeName = recipe.name
            favorite.category = recipe.category.rawValue
            favorite.prepTime = Int32(recipe.prepTime)
            favorite.cookTime = Int32(recipe.cookTime)
            favorite.servings = Int32(recipe.servings)
            favorite.rating = Int32(recipe.rating)
            favorite.imageURL = recipe.imageURL
            favorite.source = recipe.source
            favorite.dateAdded = Date()
            
            do {
                try viewContext.save()
                isFavorite = true
            } catch {
                print("Error adding favorite: \(error)")
            }
        }
    }
}