import CoreData
import Foundation

// MARK: - Recipe Core Data Management
// This file provides Core Data operations for recipes using CustomRecipe entity

// MARK: - Helper Models for Core Data
struct Ingredient: Codable {
    let name: String
    let amount: Double
    let unit: String
    let category: String?
    let notes: String?
    let isOptional: Bool
}

struct Instruction: Codable {
    let stepNumber: Int
    let instruction: String
    let duration: Int? // minutes
    let imageUrl: String?
    let tips: [String]?
}

// MARK: - CustomRecipe Extensions
extension CustomRecipe {
    var ingredientsList: [Ingredient] {
        get {
            // For now, return empty array since ingredients is stored as [String]
            return []
        }
        set {
            // Convert to string array for storage
            ingredients = newValue.map { "\($0.amount) \($0.unit) \($0.name)" }
        }
    }

    var instructionsList: [Instruction] {
        get {
            // Convert string array to Instruction objects
            guard let instructions = instructions as? [String] else { return [] }
            return instructions.enumerated().map { index, instruction in
                Instruction(stepNumber: index + 1, instruction: instruction, duration: nil, imageUrl: nil, tips: nil)
            }
        }
        set {
            // Convert to string array for storage
            instructions = newValue.map { $0.instruction }
        }
    }
}

// MARK: - Core Data Manager
class RecipeCoreDataManager {
    static let shared = RecipeCoreDataManager()

    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext

    init() {
        container = NSPersistentContainer(name: "HealthTracker")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Fetching
    func fetchRecipes(
        category: String? = nil,
        searchText: String? = nil,
        favoritesOnly: Bool = false
    ) -> [CustomRecipe] {
        let request = NSFetchRequest<CustomRecipe>(entityName: "CustomRecipe")
        var predicates: [NSPredicate] = []

        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }

        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(
                format: "name CONTAINS[cd] %@",
                searchText
            ))
        }

        if favoritesOnly {
            predicates.append(NSPredicate(format: "isFavorite == YES"))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }

    func fetchRecipe(byId id: UUID) -> CustomRecipe? {
        let request = NSFetchRequest<CustomRecipe>(entityName: "CustomRecipe")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Error fetching recipe: \(error)")
            return nil
        }
    }

    // MARK: - Saving
    func saveRecipe(_ recipe: CustomRecipe) {
        do {
            try container.viewContext.save()
        } catch {
            print("Error saving recipe: \(error)")
        }
    }

    // MARK: - Favorites
    func toggleFavorite(for recipe: CustomRecipe) {
        recipe.isFavorite.toggle()

        do {
            try container.viewContext.save()
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }

    // MARK: - Deletion
    func deleteRecipe(_ recipe: CustomRecipe) {
        container.viewContext.delete(recipe)

        do {
            try container.viewContext.save()
        } catch {
            print("Error deleting recipe: \(error)")
        }
    }
}

// MARK: - API Models (for future backend integration)
struct APIRecipe: Codable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let category: String
    let cuisine: String?
    let difficulty: String
    let costEstimate: String
    let prepTime: Int
    let cookTime: Int
    let totalTime: Int
    let servings: Int
    let nutrition: APIRecipeNutrition
    let ingredients: [APIIngredient]
    let instructions: [APIInstruction]
    let equipment: [String]
    let dietaryTags: [String]
    let mealPlans: [String]
    let tags: [String]
    let tips: [String]
    let rating: APIRating
    let isPublished: Bool
    let isFeatured: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct APIRecipeNutrition: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double?
    let sodium: Double?
}

struct APIIngredient: Codable {
    let name: String
    let amount: Double
    let unit: String
    let category: String?
    let notes: String?
    let isOptional: Bool
}

struct APIInstruction: Codable {
    let stepNumber: Int
    let instruction: String
    let duration: Int?
    let imageUrl: String?
    let tips: [String]?
}

struct APIRating: Codable {
    let average: Double
    let count: Int
}

struct UserRecipeData: Codable {
    let recipeId: String
    let isFavorite: Bool
    let userRating: Int
    let notes: String?
    let cookedCount: Int
    let lastCookedDate: Date?
}

// MARK: - Recipe API Service (placeholder for future implementation)
class RecipeAPIService {
    static let shared = RecipeAPIService()

    func fetchAllRecipes(completion: @escaping (Result<[APIRecipe], Error>) -> Void) {
        // Placeholder for API implementation
        completion(.success([]))
    }

    func syncUserData(_ data: UserRecipeData, completion: @escaping (Result<Void, Error>) -> Void) {
        // Placeholder for API implementation
        completion(.success(()))
    }

    func rateRecipe(recipeId: String, rating: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        // Placeholder for API implementation
        completion(.success(()))
    }
}