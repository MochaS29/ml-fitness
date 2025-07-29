import SwiftUI
import CoreData

struct MyRecipeBookView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var showingImportRecipe = false
    @State private var selectedCategory: RecipeCategory? = nil
    
    // Fetch favorite recipes from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteRecipe.dateAdded, ascending: false)],
        animation: .default
    ) private var favoriteRecipes: FetchedResults<FavoriteRecipe>
    
    // Fetch custom recipes
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomRecipe.createdDate, ascending: false)],
        predicate: NSPredicate(format: "isUserCreated == true"),
        animation: .default
    ) private var customRecipes: FetchedResults<CustomRecipe>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Recipe Type", selection: $selectedTab) {
                    Text("Favorites").tag(0)
                    Text("My Recipes").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search my recipes...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Content based on selected tab
                if selectedTab == 0 {
                    favoritesView
                } else {
                    myRecipesView
                }
            }
            .navigationTitle("My Recipe Book")
            .navigationBarItems(
                trailing: HStack(spacing: 16) {
                    Button(action: { showingImportRecipe = true }) {
                        Image(systemName: "link")
                    }
                    
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            )
            .sheet(isPresented: $showingAddRecipe) {
                AddCustomRecipeView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingImportRecipe) {
                ImportRecipeView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private var favoritesView: some View {
        Group {
            if favoriteRecipes.isEmpty {
                emptyFavoritesView
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredFavorites) { favorite in
                            if let recipe = getRecipeFromFavorite(favorite) {
                                NavigationLink(destination: ProfessionalRecipeDetailView(recipe: recipe)) {
                                    FavoriteRecipeCard(recipe: recipe, favorite: favorite)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var myRecipesView: some View {
        Group {
            if customRecipes.isEmpty {
                emptyMyRecipesView
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredCustomRecipes) { customRecipe in
                            NavigationLink(destination: CustomRecipeDetailView(customRecipe: customRecipe)) {
                                CustomRecipeCard(customRecipe: customRecipe)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(Color(UIColor.systemGray3))
            
            Text("No Favorite Recipes Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Browse the recipe database and tap the heart icon to add recipes here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            NavigationLink(destination: RecipeLibraryView()) {
                Text("Browse Recipes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var emptyMyRecipesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(Color(UIColor.systemGray3))
            
            Text("No Personal Recipes Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create your own recipes to save them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack(spacing: 16) {
                Button(action: { showingImportRecipe = true }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Import")
                    }
                    .font(.headline)
                    .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(red: 127/255, green: 176/255, blue: 105/255), lineWidth: 2)
                    )
                }
                
                Button(action: { showingAddRecipe = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(25)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var filteredFavorites: [FavoriteRecipe] {
        if searchText.isEmpty {
            return Array(favoriteRecipes)
        } else {
            return favoriteRecipes.filter { favorite in
                (favorite.recipeName ?? "").localizedCaseInsensitiveContains(searchText) ||
                (favorite.category ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var filteredCustomRecipes: [CustomRecipe] {
        if searchText.isEmpty {
            return Array(customRecipes)
        } else {
            return customRecipes.filter { recipe in
                (recipe.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (recipe.category ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func getRecipeFromFavorite(_ favorite: FavoriteRecipe) -> Recipe? {
        // In a real app, this would fetch the recipe from the database
        // For now, we'll create a Recipe from the FavoriteRecipe data
        guard let id = favorite.recipeId,
              let name = favorite.recipeName,
              let categoryString = favorite.category,
              let category = RecipeCategory(rawValue: categoryString) else {
            return nil
        }
        
        return Recipe(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            category: category,
            prepTime: Int(favorite.prepTime),
            cookTime: Int(favorite.cookTime),
            servings: Int(favorite.servings),
            ingredients: [], // Would be fetched from database
            instructions: [], // Would be fetched from database
            imageURL: favorite.imageURL,
            source: favorite.source,
            rating: Int(favorite.rating)
        )
    }
}

// Favorite Recipe Card
struct FavoriteRecipeCard: View {
    let recipe: Recipe
    let favorite: FavoriteRecipe
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingUnfavoriteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Image
            ZStack(alignment: .topTrailing) {
                if let imageURL = recipe.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RecipeImagePlaceholder()
                    }
                } else {
                    RecipeImagePlaceholder()
                }
                
                // Heart button
                Button(action: { showingUnfavoriteAlert = true }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8)
            
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
        .alert("Remove from Favorites?", isPresented: $showingUnfavoriteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeFavorite()
            }
        } message: {
            Text("This recipe will be removed from your favorites.")
        }
    }
    
    private func removeFavorite() {
        viewContext.delete(favorite)
        try? viewContext.save()
    }
}

// Custom Recipe Card
struct CustomRecipeCard: View {
    let customRecipe: CustomRecipe
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Image
            ZStack(alignment: .topTrailing) {
                if let imageData = customRecipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    RecipeImagePlaceholder()
                        .frame(height: 120)
                }
                
                // Edit indicator
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .padding(8)
            }
            .cornerRadius(8)
            
            // Recipe Info
            VStack(alignment: .leading, spacing: 4) {
                Text(customRecipe.name ?? "Untitled Recipe")
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\((customRecipe.prepTime + customRecipe.cookTime)) min")
                        .font(.caption)
                    
                    Spacer()
                    
                    if customRecipe.servings > 0 {
                        Text("\(customRecipe.servings) servings")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                
                // Nutrition preview
                HStack(spacing: 8) {
                    NutritionBadge(value: Int(customRecipe.calories), label: "cal")
                    NutritionBadge(value: Int(customRecipe.protein), label: "g P")
                    NutritionBadge(value: Int(customRecipe.carbs), label: "g C")
                    NutritionBadge(value: Int(customRecipe.fat), label: "g F")
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct NutritionBadge: View {
    let value: Int
    let label: String
    
    var body: some View {
        Text("\(value)\(label)")
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(4)
    }
}

// Custom Recipe Detail View
struct CustomRecipeDetailView: View {
    let customRecipe: CustomRecipe
    @State private var showingEditView = false
    
    var body: some View {
        // Convert CustomRecipe to Recipe for display
        if let recipe = convertToRecipe(customRecipe) {
            ProfessionalRecipeDetailView(recipe: recipe)
                .navigationBarItems(
                    trailing: Button("Edit") {
                        showingEditView = true
                    }
                )
                .sheet(isPresented: $showingEditView) {
                    // Edit custom recipe view
                }
        } else {
            Text("Unable to load recipe")
        }
    }
    
    private func convertToRecipe(_ customRecipe: CustomRecipe) -> Recipe? {
        guard let name = customRecipe.name,
              let categoryString = customRecipe.category,
              let category = RecipeCategory(rawValue: categoryString) else {
            return nil
        }
        
        // Convert stored arrays to proper types
        let ingredients: [Ingredient] = [] // Would need to parse from customRecipe.ingredients
        let instructions: [String] = customRecipe.instructions ?? []
        
        return Recipe(
            id: customRecipe.id ?? UUID(),
            name: name,
            category: category,
            prepTime: Int(customRecipe.prepTime),
            cookTime: Int(customRecipe.cookTime),
            servings: Int(customRecipe.servings),
            ingredients: ingredients,
            instructions: instructions,
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
}

#Preview {
    MyRecipeBookView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}