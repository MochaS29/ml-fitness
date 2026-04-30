import SwiftUI
import CoreData
import PhotosUI

struct MyRecipeBookView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var storeManager: StoreManager

    var initialTab: Int = 1

    @State private var selectedTab: Int
    @State private var selectedCategory: RecipeCategory? = nil
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var showingImportRecipe = false

    init(initialTab: Int = 1) {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteRecipe.dateAdded, ascending: false)],
        animation: .default
    ) private var favoriteRecipes: FetchedResults<FavoriteRecipe>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomRecipe.createdDate, ascending: false)],
        animation: .default
    ) private var customRecipes: FetchedResults<CustomRecipe>

    var body: some View {
        VStack(spacing: 0) {
            tabToggle
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            searchBar
                .padding(.horizontal)
                .padding(.bottom, 4)

            categoryFilter

            if selectedTab == 0 {
                libraryGridView
            } else {
                myRecipesGridView
            }
        }
        .navigationTitle(selectedTab == 0 ? "Recipe Library" : "My Recipe Book")
        .navigationBarItems(trailing: trailingButtons)
        .sheet(isPresented: $showingAddRecipe) {
            AddCustomRecipeView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingImportRecipe) {
            ImportRecipeView()
                .environment(\.managedObjectContext, viewContext)
        }
    }

    // MARK: - Tab Toggle

    private var tabToggle: some View {
        HStack(spacing: 0) {
            tabButton(title: "Library", index: 0)
            tabButton(title: "My Recipes", index: 1)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 127/255, green: 176/255, blue: 105/255).opacity(0.4), lineWidth: 1)
        )
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(selectedTab == index ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedTab == index
                        ? Color(red: 127/255, green: 176/255, blue: 105/255)
                        : Color.clear
                )
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search recipes...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
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
        .padding(.bottom, 8)
    }

    // MARK: - Trailing Buttons

    @ViewBuilder
    private var trailingButtons: some View {
        HStack(spacing: 16) {
            Button(action: { showingImportRecipe = true }) {
                Image(systemName: "link")
            }
            Button(action: { showingAddRecipe = true }) {
                Image(systemName: "plus")
            }
        }
    }

    // MARK: - Library List

    private var libraryGridView: some View {
        let groups = groupedLibraryRecipes
        return Group {
            if groups.isEmpty {
                emptyStateView(icon: "books.vertical", title: "No Recipes Found", subtitle: "Try a different search or category")
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if !isPro {
                            proUpgradeBanner
                                .padding(.horizontal)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                        }

                        ForEach(groups, id: \.category) { group in
                            // Section header
                            HStack {
                                Text(group.category.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text("\(group.recipes.count) recipes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                            // Recipes card
                            VStack(spacing: 0) {
                                ForEach(Array(group.recipes.enumerated()), id: \.element.id) { index, recipe in
                                    NavigationLink(destination: ProfessionalRecipeDetailView(recipe: recipe)) {
                                        recipeListRow(
                                            name: recipe.name,
                                            category: recipe.category,
                                            subtitle: recipeSubtitle(recipe)
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    if index < group.recipes.count - 1 {
                                        Divider().padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 24)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
        }
    }

    private var proUpgradeBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .frame(width: 36, height: 36)
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock 400+ Recipes")
                    .font(.subheadline.weight(.semibold))
                Text("Pro · 8 meal plans · all diets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            NavigationLink(destination: PaywallView().environmentObject(storeManager)) {
                Text("Upgrade")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(20)
            }
        }
        .padding(12)
        .background(Color(red: 127/255, green: 176/255, blue: 105/255).opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - My Recipes List

    private var myRecipesGridView: some View {
        let items = filteredMyRecipes
        return Group {
            if items.isEmpty {
                emptyMyRecipesView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            switch item {
                            case .favorite(let fav, let model):
                                NavigationLink(destination: ProfessionalRecipeDetailView(recipe: model)) {
                                    recipeListRow(
                                        name: model.name,
                                        category: model.category,
                                        subtitle: recipeSubtitle(model),
                                        isFavorited: true,
                                        onUnfavorite: {
                                            viewContext.delete(fav)
                                            try? viewContext.save()
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            case .custom(let custom):
                                NavigationLink(destination: CustomRecipeDetailView(customRecipe: custom)) {
                                    let cat = RecipeCategory(rawValue: custom.category ?? "") ?? .dinner
                                    recipeListRow(
                                        name: custom.name ?? "Recipe",
                                        category: cat,
                                        subtitle: "\(Int(custom.prepTime + custom.cookTime)) min"
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            if index < items.count - 1 {
                                Divider().padding(.leading, 68)
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
    }

    // MARK: - Shared Row View

    private func recipeListRow(
        name: String,
        category: RecipeCategory,
        subtitle: String,
        isFavorited: Bool = false,
        onUnfavorite: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(category.headerColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: category.placeholderIcon)
                    .font(.system(size: 20))
                    .foregroundColor(category.headerColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isFavorited {
                Button(action: { onUnfavorite?() }) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func recipeSubtitle(_ recipe: RecipeModel) -> String {
        var parts: [String] = ["\(recipe.totalTime) min"]
        if let kcal = recipe.nutrition {
            parts.append("\(Int(kcal.calories)) cal")
            parts.append("\(Int(kcal.protein))g protein")
        }
        return parts.joined(separator: " · ")
    }

    // MARK: - Grouped Data

    private var groupedLibraryRecipes: [(category: RecipeCategory, recipes: [RecipeModel])] {
        let all = filteredLibraryRecipes
        return RecipeCategory.allCases.compactMap { cat in
            let catRecipes = all.filter { $0.category == cat }
            return catRecipes.isEmpty ? nil : (category: cat, recipes: catRecipes)
        }
    }

    // MARK: - Empty States

    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color(UIColor.systemGray3))
            Text(title).font(.headline).foregroundColor(.secondary)
            Text(subtitle)
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 40)
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
                .font(.headline).foregroundColor(.secondary)
            Text("Favorite a recipe from the Library, import one from a URL, or create your own.")
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            HStack(spacing: 16) {
                Button(action: { showingImportRecipe = true }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Import")
                    }
                    .font(.headline)
                    .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .padding(.horizontal, 20).padding(.vertical, 12)
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
                    .font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(25)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - Data: Library

    private var isPro: Bool {
        storeManager.isPro || TrialManager.shared.isTrialActive
    }

    private var filteredLibraryRecipes: [RecipeModel] {
        var recipes: [RecipeModel] = RecipeDatabase.shared.recipes
        var seenNames = Set(recipes.map { $0.name.lowercased() })

        // Add meal plan recipes (free = Mediterranean Week 1 only, Pro = all plans all weeks)
        for plan in MealPlanData.shared.allMealPlans {
            let isFree = plan.id == "mediterranean"
            guard isPro || isFree else { continue }

            let weeksToShow = isPro ? plan.monthlyPlans : Array(plan.monthlyPlans.prefix(1))
            for week in weeksToShow {
                for day in week.days {
                    // Use day position for reliable category — not tags/name keywords
                    let positionedMeals: [(Meal, RecipeCategory)] =
                        [(day.breakfast, .breakfast), (day.lunch, .lunch), (day.dinner, .dinner)]
                        + day.snacks.map { ($0, .snack) }

                    for (meal, category) in positionedMeals {
                        let key = meal.name.lowercased()
                        guard !seenNames.contains(key) else { continue }
                        seenNames.insert(key)

                        recipes.append(RecipeModel(
                            id: UUID(uuidString: meal.id) ?? UUID(),
                            name: meal.name,
                            category: category,
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
                        ))
                    }
                }
            }
        }

        // Add imported / user-created custom recipes
        for customRecipe in customRecipes {
            guard let name = customRecipe.name,
                  let categoryString = customRecipe.category,
                  let category = RecipeCategory(rawValue: categoryString) else { continue }
            let key = name.lowercased()
            guard !seenNames.contains(key) else { continue }
            seenNames.insert(key)

            recipes.append(RecipeModel(
                id: customRecipe.id ?? UUID(),
                name: name,
                category: category,
                prepTime: Int(customRecipe.prepTime),
                cookTime: Int(customRecipe.cookTime),
                servings: Int(customRecipe.servings),
                ingredients: (customRecipe.ingredients ?? []).map {
                    IngredientModel(name: $0, amount: 1, unit: .piece, category: .other)
                },
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
            ))
        }

        return applyFilters(to: recipes)
    }

    // MARK: - Data: My Recipes

    enum MyRecipeItem {
        case favorite(FavoriteRecipe, RecipeModel)
        case custom(CustomRecipe)

        var id: String {
            switch self {
            case .favorite(let fav, _): return "fav-\(fav.recipeId ?? UUID().uuidString)"
            case .custom(let c): return "custom-\(c.id?.uuidString ?? UUID().uuidString)"
            }
        }

        var name: String {
            switch self {
            case .favorite(_, let model): return model.name
            case .custom(let c): return c.name ?? ""
            }
        }

        var categoryString: String? {
            switch self {
            case .favorite(_, let model): return model.category.rawValue
            case .custom(let c): return c.category
            }
        }
    }

    private var filteredMyRecipes: [MyRecipeItem] {
        var items: [MyRecipeItem] = []
        var seenNames = Set<String>()

        for fav in favoriteRecipes {
            guard let name = fav.recipeName else { continue }
            let key = name.lowercased()
            guard !seenNames.contains(key) else { continue }
            seenNames.insert(key)
            if let model = getRecipeFromFavorite(fav) {
                items.append(.favorite(fav, model))
            }
        }

        for custom in customRecipes {
            guard let name = custom.name else { continue }
            let key = name.lowercased()
            guard !seenNames.contains(key) else { continue }
            seenNames.insert(key)
            items.append(.custom(custom))
        }

        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        if let cat = selectedCategory {
            items = items.filter {
                $0.categoryString?.caseInsensitiveCompare(cat.rawValue) == .orderedSame
            }
        }

        return items
    }

    // MARK: - Helpers

    private func applyFilters(to recipes: [RecipeModel]) -> [RecipeModel] {
        var result = recipes
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result
    }

    private func categoryFromMeal(_ meal: Meal) -> RecipeCategory {
        let tags = meal.tags.map { $0.lowercased() }
        let name = meal.name.lowercased()
        if tags.contains("breakfast") || name.contains("breakfast") ||
           name.contains("oatmeal") || name.contains("pancake") ||
           name.contains("granola") || name.contains("yogurt") ||
           name.contains("smoothie bowl") {
            return .breakfast
        }
        if tags.contains("snack") || tags.contains("snacks") { return .snack }
        if tags.contains("dessert") { return .dessert }
        if tags.contains("lunch") || name.contains("salad") ||
           name.contains("sandwich") || name.contains("wrap") {
            return .lunch
        }
        return .dinner
    }

    private func getRecipeFromFavorite(_ favorite: FavoriteRecipe) -> RecipeModel? {
        guard let id = favorite.recipeId, let name = favorite.recipeName else { return nil }

        if let match = RecipeDatabase.shared.recipes.first(where: {
            $0.name.lowercased() == name.lowercased()
        }) {
            return match
        }

        for plan in MealPlanData.shared.allMealPlans {
            for week in plan.monthlyPlans {
                for day in week.days {
                    let positionedMeals: [(Meal, RecipeCategory)] =
                        [(day.breakfast, .breakfast), (day.lunch, .lunch), (day.dinner, .dinner)]
                        + day.snacks.map { ($0, .snack) }
                    for (meal, mealCategory) in positionedMeals {
                        if meal.name.lowercased() == name.lowercased() {
                            return RecipeModel(
                                id: UUID(uuidString: id) ?? UUID(),
                                name: meal.name,
                                category: mealCategory,
                                prepTime: meal.prepTime,
                                cookTime: meal.cookTime,
                                servings: Int(favorite.servings) > 0 ? Int(favorite.servings) : 2,
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
                                imageURL: favorite.imageURL,
                                source: favorite.source,
                                tags: meal.tags
                            )
                        }
                    }
                }
            }
        }

        let category = RecipeCategory(rawValue: favorite.category ?? "") ?? .dinner

        return RecipeModel(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            category: category,
            prepTime: Int(favorite.prepTime),
            cookTime: Int(favorite.cookTime),
            servings: Int(favorite.servings),
            ingredients: [],
            instructions: [],
            imageURL: favorite.imageURL,
            source: favorite.source,
            rating: Int(favorite.rating)
        )
    }
}

// MARK: - Favorite Recipe Card

struct FavoriteRecipeCard: View {
    let recipe: RecipeModel
    let favorite: FavoriteRecipe
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingUnfavoriteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let imageURL = recipe.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                            .frame(height: 120).clipped()
                    } placeholder: {
                        RecipeImagePlaceholder(category: recipe.category, height: 120)
                    }
                } else {
                    RecipeImagePlaceholder(category: recipe.category, height: 120)
                }

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
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                HStack {
                    Image(systemName: "clock").font(.caption)
                    Text("\(recipe.totalTime) min").font(.caption)
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
            Button("Remove", role: .destructive) { removeFavorite() }
        } message: {
            Text("This recipe will be removed from your favorites.")
        }
    }

    private func removeFavorite() {
        viewContext.delete(favorite)
        try? viewContext.save()
    }
}

// MARK: - Custom Recipe Card

struct CustomRecipeCard: View {
    let customRecipe: CustomRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let imageData = customRecipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    RecipeImagePlaceholder().frame(height: 120)
                }

                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .padding(8)
            }
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(customRecipe.name ?? "Untitled Recipe")
                    .font(.headline).lineLimit(2).foregroundColor(.primary)

                HStack {
                    Image(systemName: "clock").font(.caption)
                    Text("\(customRecipe.prepTime + customRecipe.cookTime) min").font(.caption)
                    Spacer()
                    if customRecipe.servings > 0 {
                        Text("\(customRecipe.servings) servings").font(.caption)
                    }
                }
                .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    NutritionBadge(value: Int(customRecipe.calories), unit: "cal", color: .orange)
                    NutritionBadge(value: Int(customRecipe.protein), unit: "g P", color: .red)
                    NutritionBadge(value: Int(customRecipe.carbs), unit: "g C", color: .blue)
                    NutritionBadge(value: Int(customRecipe.fat), unit: "g F", color: .green)
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

// MARK: - Custom Recipe Detail View

struct CustomRecipeDetailView: View {
    let customRecipe: CustomRecipe
    @State private var showingEditView = false

    var body: some View {
        if let recipe = convertToRecipe(customRecipe) {
            ProfessionalRecipeDetailView(recipe: recipe)
                .navigationBarItems(trailing: Button("Edit") { showingEditView = true })
                .sheet(isPresented: $showingEditView) {
                    EditRecipeView(customRecipe: customRecipe)
                }
        } else {
            Text("Unable to load recipe")
        }
    }

    private func convertToRecipe(_ customRecipe: CustomRecipe) -> RecipeModel? {
        guard let name = customRecipe.name,
              let categoryString = customRecipe.category,
              let category = RecipeCategory(rawValue: categoryString) else { return nil }

        return RecipeModel(
            id: customRecipe.id ?? UUID(),
            name: name,
            category: category,
            prepTime: Int(customRecipe.prepTime),
            cookTime: Int(customRecipe.cookTime),
            servings: Int(customRecipe.servings),
            ingredients: (customRecipe.ingredients ?? []).map {
                IngredientModel(name: $0, amount: 1, unit: .piece, category: .other)
            },
            instructions: customRecipe.instructions ?? [],
            nutrition: NutritionInfo.fromCustomRecipe(customRecipe),
            source: customRecipe.source,
            tags: customRecipe.tags ?? [],
            isFavorite: customRecipe.isFavorite
        )
    }
}

// MARK: - Edit Recipe View

struct EditRecipeView: View {
    let customRecipe: CustomRecipe
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var category: RecipeCategory
    @State private var prepTime: Int
    @State private var cookTime: Int
    @State private var servings: Int
    @State private var ingredients: [String]
    @State private var instructions: [String]
    @State private var tags: [String]
    @State private var currentTag = ""
    @State private var recipeImage: UIImage?
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingCamera = false

    init(customRecipe: CustomRecipe) {
        self.customRecipe = customRecipe
        _name         = State(initialValue: customRecipe.name ?? "")
        _category     = State(initialValue: RecipeCategory(rawValue: customRecipe.category ?? "") ?? .dinner)
        _prepTime     = State(initialValue: Int(customRecipe.prepTime))
        _cookTime     = State(initialValue: Int(customRecipe.cookTime))
        _servings     = State(initialValue: Int(customRecipe.servings))
        _ingredients  = State(initialValue: customRecipe.ingredients ?? [])
        _instructions = State(initialValue: (customRecipe.instructions ?? []).filter { !$0.isEmpty })
        _tags         = State(initialValue: customRecipe.tags ?? [])
        if let data = customRecipe.imageData, let img = UIImage(data: data) {
            _recipeImage = State(initialValue: img)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Recipe Information") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(RecipeCategory.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    Stepper("Prep: \(prepTime) min", value: $prepTime, in: 0...300, step: 5)
                    Stepper("Cook: \(cookTime) min", value: $cookTime, in: 0...300, step: 5)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                }

                Section("Photo") {
                    if let img = recipeImage {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(height: 160).clipped().cornerRadius(8)
                        Button(role: .destructive, action: { recipeImage = nil }) {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                    HStack {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("Choose Photo", systemImage: "photo")
                        }
                        .onChange(of: selectedImage) { _, _ in
                            Task {
                                if let data = try? await selectedImage?.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) { recipeImage = img }
                            }
                        }
                        Spacer()
                        Button(action: { showingCamera = true }) {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                }

                Section("Ingredients") {
                    ForEach(ingredients.indices, id: \.self) { i in
                        TextField("e.g. 1 cup flour", text: $ingredients[i])
                    }
                    .onDelete { ingredients.remove(atOffsets: $0) }
                    Button(action: { ingredients.append("") }) {
                        Label("Add Ingredient", systemImage: "plus.circle")
                    }
                }

                Section("Instructions") {
                    ForEach(instructions.indices, id: \.self) { i in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(i + 1).").foregroundColor(.secondary).padding(.top, 8)
                            TextEditor(text: $instructions[i]).frame(minHeight: 56)
                        }
                    }
                    .onDelete { instructions.remove(atOffsets: $0) }
                    Button(action: { instructions.append("") }) {
                        Label("Add Step", systemImage: "plus.circle")
                    }
                }

                Section("Tags") {
                    ForEach(tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                            Spacer()
                            Button(action: { tags.removeAll { $0 == tag } }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    HStack {
                        TextField("Add tag", text: $currentTag)
                        Button("Add") {
                            let trimmed = currentTag.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty { tags.append(trimmed); currentTag = "" }
                        }.disabled(currentTag.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraImagePicker(selectedImage: $recipeImage, sourceType: .camera)
        }
    }

    private func saveChanges() {
        customRecipe.name         = name
        customRecipe.category     = category.rawValue
        customRecipe.prepTime     = Int32(prepTime)
        customRecipe.cookTime     = Int32(cookTime)
        customRecipe.servings     = Int32(servings)
        customRecipe.ingredients  = ingredients.filter { !$0.isEmpty }
        customRecipe.instructions = instructions.filter { !$0.isEmpty }
        customRecipe.tags         = tags
        if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let recipeID = customRecipe.id {
            let folder = docsURL.appendingPathComponent("recipe_photos", isDirectory: true)
            let fileURL = folder.appendingPathComponent("\(recipeID.uuidString).jpg")
            if let img = recipeImage {
                // Save to CoreData and file system
                let jpegData = img.jpegData(compressionQuality: 0.8)
                customRecipe.imageData = jpegData
                if let data = jpegData {
                    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                    try? data.write(to: fileURL)
                }
            } else {
                // Photo was removed — clear both CoreData and file system
                customRecipe.imageData = nil
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Preview

struct MyRecipeBookView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyRecipeBookView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(StoreManager())
        }
    }
}
