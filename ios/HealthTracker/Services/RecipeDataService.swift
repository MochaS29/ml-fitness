import Foundation
import CoreData
import Combine

// MARK: - Recipe Data Service
/// Manages recipe data using CustomRecipe Core Data entity
class RecipeDataService: ObservableObject {
    static let shared = RecipeDataService()

    @Published var recipes: [CustomRecipe] = []
    @Published var isLoading = false
    @Published var lastSyncDate: Date?

    private let viewContext = PersistenceController.shared.container.viewContext
    private var cancellables = Set<AnyCancellable>()

    // API configuration (optional - can work fully offline)
    private let apiBaseURL = UserDefaults.standard.string(forKey: "recipe_api_url") ?? "http://localhost:3000/api"
    private let apiEnabled = UserDefaults.standard.bool(forKey: "recipe_api_enabled")

    init() {
        loadLocalRecipes()
        setupInitialDataIfNeeded()
    }

    // MARK: - Core Data Operations

    /// Load recipes from Core Data
    func loadLocalRecipes(
        category: String? = nil,
        searchText: String? = nil,
        dietaryTags: [String] = [],
        mealPlan: String? = nil,
        favoritesOnly: Bool = false
    ) {
        let request = NSFetchRequest<CustomRecipe>(entityName: "CustomRecipe")
        var predicates: [NSPredicate] = []

        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }

        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(
                format: "name CONTAINS[cd] %@ OR tags CONTAINS[cd] %@",
                searchText, searchText
            ))
        }

        if favoritesOnly {
            predicates.append(NSPredicate(format: "isFavorite == YES"))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CustomRecipe.isFavorite, ascending: false),
            NSSortDescriptor(keyPath: \CustomRecipe.name, ascending: true)
        ]

        do {
            recipes = try viewContext.fetch(request)
        } catch {
            print("Error fetching recipes: \(error)")
        }
    }

    /// Save a new recipe or update existing
    func saveRecipe(_ recipe: CustomRecipe) {
        do {
            try viewContext.save()
            loadLocalRecipes()
        } catch {
            print("Error saving recipe: \(error)")
        }
    }

    /// Delete a recipe
    func deleteRecipe(_ recipe: CustomRecipe) {
        viewContext.delete(recipe)
        do {
            try viewContext.save()
            loadLocalRecipes()
        } catch {
            print("Error deleting recipe: \(error)")
        }
    }

    /// Toggle favorite status
    func toggleFavorite(for recipe: CustomRecipe) {
        recipe.isFavorite.toggle()
        saveRecipe(recipe)
    }

    // MARK: - Initial Data Setup

    /// Setup initial recipe data from RecipeDatabase
    private func setupInitialDataIfNeeded() {
        let request = NSFetchRequest<CustomRecipe>(entityName: "CustomRecipe")
        request.fetchLimit = 1

        do {
            let count = try viewContext.count(for: request)
            if count == 0 {
                importInitialRecipes()
            }
        } catch {
            print("Error checking for existing recipes: \(error)")
        }
    }

    /// Import initial recipes from RecipeDatabase
    private func importInitialRecipes() {
        let initialRecipes = RecipeDatabase.shared.recipes

        for recipeModel in initialRecipes {
            let customRecipe = CustomRecipe(context: viewContext)
            customRecipe.id = recipeModel.id
            customRecipe.name = recipeModel.name
            customRecipe.category = recipeModel.category.rawValue
            customRecipe.prepTime = Int32(recipeModel.prepTime)
            customRecipe.cookTime = Int32(recipeModel.cookTime)
            customRecipe.servings = Int32(recipeModel.servings)

            // Convert ingredients to string array
            customRecipe.ingredients = recipeModel.ingredients.map {
                "\($0.amount) \($0.unit.rawValue) \($0.name)"
            }

            // Store instructions
            customRecipe.instructions = recipeModel.instructions

            // Store nutrition
            if let nutrition = recipeModel.nutrition {
                customRecipe.calories = nutrition.calories
                customRecipe.protein = nutrition.protein
                customRecipe.carbs = nutrition.carbs
                customRecipe.fat = nutrition.fat
                customRecipe.fiber = nutrition.fiber ?? 0
                customRecipe.sugar = nutrition.sugar ?? 0
                customRecipe.sodium = nutrition.sodium ?? 0
            }

            // Store metadata
            customRecipe.tags = recipeModel.tags
            customRecipe.source = recipeModel.source
            customRecipe.isFavorite = recipeModel.isFavorite
            customRecipe.createdDate = Date()
            customRecipe.isUserCreated = false
        }

        do {
            try viewContext.save()
            print("Successfully imported \(initialRecipes.count) recipes")
            loadLocalRecipes()
        } catch {
            print("Error importing initial recipes: \(error)")
        }
    }

    // MARK: - Search and Filter

    /// Search recipes by keyword
    func searchRecipes(keyword: String) -> [CustomRecipe] {
        return recipes.filter { recipe in
            guard let name = recipe.name else { return false }
            let nameMatch = name.localizedCaseInsensitiveContains(keyword)
            let tagMatch = recipe.tags?.contains { ($0 as? String)?.localizedCaseInsensitiveContains(keyword) ?? false } ?? false
            return nameMatch || tagMatch
        }
    }

    /// Get recipes by category
    func getRecipesByCategory(_ category: String) -> [CustomRecipe] {
        return recipes.filter { $0.category == category }
    }

    /// Get favorite recipes
    func getFavoriteRecipes() -> [CustomRecipe] {
        return recipes.filter { $0.isFavorite }
    }

    // MARK: - API Operations (Optional)

    /// Sync recipes with API if enabled
    func syncWithAPI() {
        guard apiEnabled else { return }

        isLoading = true

        // Create URL request
        guard let url = URL(string: "\(apiBaseURL)/recipes") else {
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [RecipeData].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("API sync failed: \(error)")
                    }
                },
                receiveValue: { [weak self] apiRecipes in
                    self?.mergeAPIRecipes(apiRecipes)
                    self?.lastSyncDate = Date()
                }
            )
            .store(in: &cancellables)
    }

    /// Merge API recipes with local data
    private func mergeAPIRecipes(_ apiRecipes: [RecipeData]) {
        for apiRecipe in apiRecipes {
            // Check if recipe already exists
            let request = NSFetchRequest<CustomRecipe>(entityName: "CustomRecipe")
            request.predicate = NSPredicate(format: "name == %@", apiRecipe.name)
            request.fetchLimit = 1

            do {
                let existingRecipes = try viewContext.fetch(request)

                let recipe = existingRecipes.first ?? CustomRecipe(context: viewContext)

                // Update recipe data
                recipe.name = apiRecipe.name
                recipe.category = apiRecipe.category
                recipe.prepTime = Int32(apiRecipe.prepTime)
                recipe.cookTime = Int32(apiRecipe.cookTime)
                recipe.servings = Int32(apiRecipe.servings)
                recipe.ingredients = apiRecipe.ingredients.map { $0.name }
                recipe.instructions = apiRecipe.instructions.map { $0.description }
                recipe.calories = Double(apiRecipe.nutrition.calories)
                recipe.protein = apiRecipe.nutrition.protein
                recipe.carbs = apiRecipe.nutrition.carbs
                recipe.fat = apiRecipe.nutrition.fat
                recipe.fiber = apiRecipe.nutrition.fiber
                recipe.tags = apiRecipe.dietaryTags

                if recipe.id == nil {
                    recipe.id = UUID()
                    recipe.createdDate = Date()
                }

            } catch {
                print("Error merging API recipe: \(error)")
            }
        }

        do {
            try viewContext.save()
            loadLocalRecipes()
        } catch {
            print("Error saving merged recipes: \(error)")
        }
    }

    /// Upload a user-created recipe to API
    func uploadRecipe(_ recipe: CustomRecipe) {
        guard apiEnabled else { return }

        // Convert CustomRecipe to API format
        let recipeData = RecipeData(from: recipe)

        guard let url = URL(string: "\(apiBaseURL)/recipes"),
              let jsonData = try? JSONEncoder().encode(recipeData) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading recipe: \(error)")
            } else if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                print("Recipe uploaded successfully")
            }
        }.resume()
    }
}

// MARK: - API Data Models

struct RecipeData: Codable {
    let id: String
    let name: String
    let category: String
    let prepTime: Int
    let cookTime: Int
    let servings: Int

    let nutrition: RecipeNutritionData
    let ingredients: [IngredientData]
    let instructions: [InstructionData]

    let dietaryTags: [String]
    let mealPlans: [String]
    let imageUrl: String?
    let source: String?
    let rating: Double

    init(from customRecipe: CustomRecipe) {
        self.id = customRecipe.id?.uuidString ?? UUID().uuidString
        self.name = customRecipe.name ?? ""
        self.category = customRecipe.category ?? ""
        self.prepTime = Int(customRecipe.prepTime)
        self.cookTime = Int(customRecipe.cookTime)
        self.servings = Int(customRecipe.servings)

        self.nutrition = RecipeNutritionData(
            calories: Int(customRecipe.calories),
            protein: customRecipe.protein,
            carbs: customRecipe.carbs,
            fat: customRecipe.fat,
            fiber: customRecipe.fiber
        )

        // Convert ingredients from string array
        self.ingredients = (customRecipe.ingredients as? [String] ?? []).map {
            IngredientData(name: $0, amount: 1, unit: "", category: nil)
        }

        // Convert instructions
        self.instructions = (customRecipe.instructions as? [String] ?? []).enumerated().map { index, instruction in
            InstructionData(step: index + 1, description: instruction, duration: nil)
        }

        self.dietaryTags = customRecipe.tags as? [String] ?? []
        self.mealPlans = []
        self.imageUrl = nil
        self.source = customRecipe.source
        self.rating = 0
    }
}

struct RecipeNutritionData: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
}

struct IngredientData: Codable {
    let name: String
    let amount: Double
    let unit: String
    let category: String?

    init(from apiIngredient: APIIngredient) {
        self.name = apiIngredient.name
        self.amount = apiIngredient.amount
        self.unit = apiIngredient.unit
        self.category = apiIngredient.category
    }

    init(name: String, amount: Double, unit: String, category: String?) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
    }
}

struct InstructionData: Codable {
    let step: Int
    let description: String
    let duration: Int?
}

// MARK: - Recipe Importer
extension RecipeDataService {
    /// Import recipe from URL or text
    func importRecipe(from source: String, completion: @escaping (Result<CustomRecipe, Error>) -> Void) {
        // This would handle recipe imports from various sources
        // For now, create a placeholder recipe
        let recipe = CustomRecipe(context: viewContext)
        recipe.id = UUID()
        recipe.name = "Imported Recipe"
        recipe.createdDate = Date()
        recipe.isUserCreated = true

        saveRecipe(recipe)
        completion(.success(recipe))
    }
}