import Foundation

struct Recipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: RecipeCategory
    var prepTime: Int // minutes
    var cookTime: Int // minutes
    var servings: Int
    var ingredients: [Ingredient]
    var instructions: [String]
    var nutrition: NutritionInfo?
    var imageURL: String?
    var source: String?
    var tags: [String]
    var isFavorite: Bool = false
    var rating: Int = 0
    
    init(id: UUID = UUID(), name: String, category: RecipeCategory, prepTime: Int, cookTime: Int, servings: Int, ingredients: [Ingredient], instructions: [String], nutrition: NutritionInfo? = nil, imageURL: String? = nil, source: String? = nil, tags: [String] = [], isFavorite: Bool = false, rating: Int = 0) {
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

struct Ingredient: Identifiable, Codable {
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
}

// Meal Plan Models
struct MealPlan: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var meals: [PlannedMeal]
    
    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date, meals: [PlannedMeal] = []) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.meals = meals
    }
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct PlannedMeal: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mealType: MealType
    var recipe: Recipe
    var servingsMultiplier: Double = 1.0
    
    init(id: UUID = UUID(), date: Date, mealType: MealType, recipe: Recipe, servingsMultiplier: Double = 1.0) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipe = recipe
        self.servingsMultiplier = servingsMultiplier
    }
}

// Grocery List Models
struct GroceryList: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: [GroceryItem]
    var createdDate: Date
    var isCompleted: Bool = false
    
    init(id: UUID = UUID(), name: String, items: [GroceryItem] = [], createdDate: Date = Date(), isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.items = items
        self.createdDate = createdDate
        self.isCompleted = isCompleted
    }
}

struct GroceryItem: Identifiable, Codable {
    let id: UUID
    var ingredient: Ingredient
    var isChecked: Bool = false
    var quantity: Double
    var notes: String?
    
    init(id: UUID = UUID(), ingredient: Ingredient, isChecked: Bool = false, quantity: Double, notes: String? = nil) {
        self.id = id
        self.ingredient = ingredient
        self.isChecked = isChecked
        self.quantity = quantity
        self.notes = notes
    }
    
    var displayText: String {
        "\(ingredient.displayAmount) \(ingredient.unit.displayName(amount: ingredient.amount)) \(ingredient.name)"
    }
}