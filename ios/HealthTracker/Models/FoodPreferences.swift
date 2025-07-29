import Foundation

// MARK: - Food Allergies
enum FoodAllergy: String, Codable, CaseIterable {
    // Top 9 Allergens (FDA)
    case milk = "Milk"
    case eggs = "Eggs"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case treeNuts = "Tree Nuts"
    case peanuts = "Peanuts"
    case wheat = "Wheat"
    case soybeans = "Soybeans"
    case sesame = "Sesame"
    
    // Additional Common Allergens
    case gluten = "Gluten"
    case corn = "Corn"
    case sulfites = "Sulfites"
    case mustard = "Mustard"
    case celery = "Celery"
    case lupin = "Lupin"
    
    var icon: String {
        switch self {
        case .milk: return "🥛"
        case .eggs: return "🥚"
        case .fish: return "🐟"
        case .shellfish: return "🦐"
        case .treeNuts: return "🌰"
        case .peanuts: return "🥜"
        case .wheat: return "🌾"
        case .soybeans: return "🫘"
        case .sesame: return "🌿"
        case .gluten: return "🍞"
        case .corn: return "🌽"
        case .sulfites: return "🍷"
        case .mustard: return "🌭"
        case .celery: return "🥬"
        case .lupin: return "🌱"
        }
    }
    
    var severity: AllergySeverity {
        // Default severities - can be customized per user
        switch self {
        case .peanuts, .treeNuts, .shellfish:
            return .severe
        case .milk, .eggs, .fish, .wheat, .soybeans, .sesame:
            return .moderate
        default:
            return .mild
        }
    }
}

enum AllergySeverity: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case lifeThreatening = "Life-Threatening"
    
    var color: String {
        switch self {
        case .mild: return "yellow"
        case .moderate: return "orange"
        case .severe: return "red"
        case .lifeThreatening: return "darkred"
        }
    }
}

// MARK: - Food Intolerances
enum FoodIntolerance: String, Codable, CaseIterable {
    case lactose = "Lactose"
    case fructose = "Fructose"
    case histamine = "Histamine"
    case fodmap = "FODMAP"
    case nightshades = "Nightshades"
    case caffeine = "Caffeine"
    case alcohol = "Alcohol"
    case msg = "MSG"
    
    var icon: String {
        switch self {
        case .lactose: return "🥛"
        case .fructose: return "🍎"
        case .histamine: return "🧪"
        case .fodmap: return "🥦"
        case .nightshades: return "🍅"
        case .caffeine: return "☕"
        case .alcohol: return "🍺"
        case .msg: return "🧂"
        }
    }
}

// MARK: - Dietary Preferences
enum DietaryPreference: String, Codable, CaseIterable {
    // Vegetarian/Vegan
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescatarian = "Pescatarian"
    case flexitarian = "Flexitarian"
    
    // Religious
    case kosher = "Kosher"
    case halal = "Halal"
    case hindu = "Hindu Vegetarian"
    case jain = "Jain"
    
    // Health-Based
    case lowCarb = "Low Carb"
    case keto = "Ketogenic"
    case paleo = "Paleo"
    case whole30 = "Whole30"
    case mediterranean = "Mediterranean"
    case lowFat = "Low Fat"
    case lowSodium = "Low Sodium"
    case diabeticFriendly = "Diabetic Friendly"
    case heartHealthy = "Heart Healthy"
    case antiInflammatory = "Anti-Inflammatory"
    
    // Other
    case organic = "Organic"
    case nonGMO = "Non-GMO"
    case local = "Local/Seasonal"
    case sustainable = "Sustainable"
    
    var icon: String {
        switch self {
        case .vegetarian: return "🥗"
        case .vegan: return "🌱"
        case .pescatarian: return "🐟"
        case .flexitarian: return "🥦"
        case .kosher: return "✡️"
        case .halal: return "☪️"
        case .hindu: return "🕉️"
        case .jain: return "☸️"
        case .lowCarb: return "🥖"
        case .keto: return "🥑"
        case .paleo: return "🍖"
        case .whole30: return "30"
        case .mediterranean: return "🫒"
        case .lowFat: return "🧈"
        case .lowSodium: return "🧂"
        case .diabeticFriendly: return "💉"
        case .heartHealthy: return "❤️"
        case .antiInflammatory: return "🔥"
        case .organic: return "🌿"
        case .nonGMO: return "🧬"
        case .local: return "📍"
        case .sustainable: return "♻️"
        }
    }
}

// MARK: - User Food Preferences Model
struct UserFoodPreferences: Codable {
    var allergies: [AllergyInfo]
    var intolerances: [FoodIntolerance]
    var dietaryPreferences: [DietaryPreference]
    var dislikedFoods: [String]
    var avoidIngredients: [String]
    var cuisinePreferences: [CuisinePreference]
    var mealPreferences: MealPreferences
    
    init() {
        self.allergies = []
        self.intolerances = []
        self.dietaryPreferences = []
        self.dislikedFoods = []
        self.avoidIngredients = []
        self.cuisinePreferences = []
        self.mealPreferences = MealPreferences()
    }
}

struct AllergyInfo: Codable, Identifiable {
    let id: UUID
    let allergy: FoodAllergy
    var severity: AllergySeverity
    var notes: String?
    
    init(id: UUID = UUID(), allergy: FoodAllergy, severity: AllergySeverity, notes: String? = nil) {
        self.id = id
        self.allergy = allergy
        self.severity = severity
        self.notes = notes
    }
}

struct CuisinePreference: Codable {
    let cuisine: String
    let preference: PreferenceLevel
}

enum PreferenceLevel: String, Codable, CaseIterable {
    case love = "Love"
    case like = "Like"
    case neutral = "Neutral"
    case dislike = "Dislike"
    case avoid = "Avoid"
}

struct MealPreferences: Codable {
    var breakfastTime: Date?
    var lunchTime: Date?
    var dinnerTime: Date?
    var snackPreferences: [String]
    var portionSize: PortionPreference
    var spiceLevel: SpiceLevel
    
    init() {
        self.snackPreferences = []
        self.portionSize = .normal
        self.spiceLevel = .medium
    }
}

enum PortionPreference: String, Codable, CaseIterable {
    case small = "Small"
    case normal = "Normal"
    case large = "Large"
}

enum SpiceLevel: String, Codable, CaseIterable {
    case none = "No Spice"
    case mild = "Mild"
    case medium = "Medium"
    case hot = "Hot"
    case veryHot = "Very Hot"
}

// MARK: - Allergen Detection
struct AllergenInfo {
    let allergen: FoodAllergy
    let ingredientSource: String
    let confidence: AllergenConfidence
}

enum AllergenConfidence: String {
    case certain = "Contains"
    case likely = "May Contain"
    case possible = "Possible Traces"
}

// MARK: - Common Allergen Keywords
extension FoodAllergy {
    var keywords: [String] {
        switch self {
        case .milk:
            return ["milk", "dairy", "cheese", "butter", "cream", "yogurt", "whey", "casein", "lactose", "ghee"]
        case .eggs:
            return ["egg", "eggs", "albumin", "mayonnaise", "meringue", "egg white", "egg yolk"]
        case .fish:
            return ["fish", "salmon", "tuna", "cod", "tilapia", "bass", "trout", "halibut", "anchovy"]
        case .shellfish:
            return ["shellfish", "shrimp", "crab", "lobster", "crayfish", "prawn", "scallop", "oyster", "mussel", "clam"]
        case .treeNuts:
            return ["almond", "cashew", "walnut", "pecan", "pistachio", "brazil nut", "hazelnut", "macadamia", "pine nut"]
        case .peanuts:
            return ["peanut", "groundnut", "arachis", "peanut butter", "peanut oil"]
        case .wheat:
            return ["wheat", "flour", "bread", "pasta", "couscous", "spelt", "kamut", "durum", "semolina"]
        case .soybeans:
            return ["soy", "soybean", "tofu", "tempeh", "edamame", "soy sauce", "miso", "soy lecithin"]
        case .sesame:
            return ["sesame", "tahini", "sesame oil", "sesame seed", "benne"]
        case .gluten:
            return ["gluten", "wheat", "barley", "rye", "malt", "brewer's yeast", "triticale"]
        case .corn:
            return ["corn", "maize", "cornmeal", "corn syrup", "cornstarch", "hominy", "polenta"]
        case .sulfites:
            return ["sulfite", "sulfur dioxide", "sodium bisulfite", "potassium bisulfite", "sodium metabisulfite"]
        case .mustard:
            return ["mustard", "mustard seed", "mustard oil", "mustard powder", "dijon"]
        case .celery:
            return ["celery", "celeriac", "celery seed", "celery salt"]
        case .lupin:
            return ["lupin", "lupine", "lupini beans"]
        }
    }
}