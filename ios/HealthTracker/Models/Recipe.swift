import Foundation

struct RecipeModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: RecipeCategory
    var prepTime: Int // minutes
    var cookTime: Int // minutes
    var servings: Int
    var ingredients: [IngredientModel]
    var instructions: [String]
    var nutrition: NutritionInfo?
    var imageURL: String?
    var source: String?
    var tags: [String]
    var isFavorite: Bool = false
    var rating: Int = 0
    
    init(id: UUID = UUID(), name: String, category: RecipeCategory, prepTime: Int, cookTime: Int, servings: Int, ingredients: [IngredientModel], instructions: [String], nutrition: NutritionInfo? = nil, imageURL: String? = nil, source: String? = nil, tags: [String] = [], isFavorite: Bool = false, rating: Int = 0) {
        self.id = id
        self.name = name
        self.category = category
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutrition = nutrition
        self.imageURL = imageURL
        self.source = source
        self.tags = tags
        self.isFavorite = isFavorite
        self.rating = rating
    }
    
    var totalTime: Int {
        prepTime + cookTime
    }
}

struct IngredientModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: IngredientUnit
    var notes: String?
    var category: GroceryCategory
    
    init(id: UUID = UUID(), name: String, amount: Double, unit: IngredientUnit, notes: String? = nil, category: GroceryCategory) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.notes = notes
        self.category = category
    }
    
    var displayAmount: String {
        if amount == Double(Int(amount)) {
            return "\(Int(amount))"
        } else {
            return String(format: "%.2f", amount).trimmingCharacters(in: CharacterSet(charactersIn: "0")).trimmingCharacters(in: CharacterSet(charactersIn: "."))
        }
    }
    
    var fullDescription: String {
        "\(displayAmount) \(unit.displayName(amount: amount)) \(name)"
    }
}

enum RecipeCategory: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case snack = "Snack"
    case appetizer = "Appetizer"
    case beverage = "Beverage"
    case salad = "Salad"
    case soup = "Soup"
    case sideDish = "Side Dish"
}

enum IngredientUnit: String, CaseIterable, Codable {
    case cup = "cup"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case ounce = "oz"
    case pound = "lb"
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "L"
    case piece = "piece"
    case clove = "clove"
    case pinch = "pinch"
    case dash = "dash"
    case can = "can"
    case package = "package"
    case bunch = "bunch"
    
    func displayName(amount: Double) -> String {
        switch self {
        case .cup: return amount == 1 ? "cup" : "cups"
        case .tablespoon: return amount == 1 ? "tbsp" : "tbsp"
        case .teaspoon: return amount == 1 ? "tsp" : "tsp"
        case .ounce: return amount == 1 ? "oz" : "oz"
        case .pound: return amount == 1 ? "lb" : "lbs"
        case .gram: return "g"
        case .kilogram: return "kg"
        case .milliliter: return "ml"
        case .liter: return "L"
        case .piece: return amount == 1 ? "piece" : "pieces"
        case .clove: return amount == 1 ? "clove" : "cloves"
        case .pinch: return amount == 1 ? "pinch" : "pinches"
        case .dash: return amount == 1 ? "dash" : "dashes"
        case .can: return amount == 1 ? "can" : "cans"
        case .package: return amount == 1 ? "package" : "packages"
        case .bunch: return amount == 1 ? "bunch" : "bunches"
        }
    }
}

enum GroceryCategory: String, CaseIterable, Codable {
    case produce = "Produce"
    case meat = "Meat & Seafood"
    case dairy = "Dairy & Eggs"
    case bakery = "Bakery"
    case pantry = "Pantry"
    case frozen = "Frozen"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case condiments = "Condiments & Sauces"
    case spices = "Spices & Seasonings"
    case other = "Other"
}

struct NutritionInfo: Codable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var sugar: Double?
    var sodium: Double?

    // Vitamins
    var vitaminA: Double?
    var vitaminC: Double?
    var vitaminD: Double?
    var vitaminE: Double?
    var vitaminK: Double?
    var thiamin: Double? // B1
    var riboflavin: Double? // B2
    var niacin: Double? // B3
    var vitaminB6: Double?
    var folate: Double?
    var vitaminB12: Double?
    var biotin: Double?
    var pantothenicAcid: Double? // B5
    var choline: Double?

    // Minerals
    var calcium: Double?
    var iron: Double?
    var magnesium: Double?
    var phosphorus: Double?
    var potassium: Double?
    var zinc: Double?
    var copper: Double?
    var manganese: Double?
    var selenium: Double?
    var chromium: Double?
    var molybdenum: Double?
    var iodine: Double?

    // Special nutrients
    var omega3: Double?
    var omega6: Double?
}

// Meal Plan Models - Now using Core Data entities instead
// struct MealPlan and struct PlannedMeal have been replaced with Core Data entities

// Grocery List Models
// GroceryList and GroceryItem structs have been replaced with Core Data entity and custom class