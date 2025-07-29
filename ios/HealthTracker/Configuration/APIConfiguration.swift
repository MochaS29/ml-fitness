import Foundation

struct APIConfiguration {
    // MARK: - Food Recognition APIs (Image Analysis)
    
    // Nutritionix - Best for image recognition + database
    struct Nutritionix {
        static let baseURL = "https://trackapi.nutritionix.com/v2"
        static let appId = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_ID"] ?? ""
        static let appKey = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_KEY"] ?? ""
        
        struct Endpoints {
            static let instantSearch = "/search/instant"
            static let naturalNutrients = "/natural/nutrients" // Supports image upload
            static let brandedSearch = "/search/branded"
            static let barcode = "/search/item"
        }
        
        static var isConfigured: Bool {
            !appId.isEmpty && !appKey.isEmpty
        }
    }
    
    // Spoonacular - Good for recipes and meal planning
    struct Spoonacular {
        static let baseURL = "https://api.spoonacular.com"
        static let apiKey = ProcessInfo.processInfo.environment["SPOONACULAR_API_KEY"] ?? ""
        
        struct Endpoints {
            static let imageAnalysis = "/food/images/analyze"
            static let searchGroceryProducts = "/food/products/search"
            static let searchRecipes = "/recipes/complexSearch"
            static let nutritionByID = "/recipes/{id}/nutritionWidget.json"
        }
        
        static var isConfigured: Bool {
            !apiKey.isEmpty
        }
    }
    
    // MARK: - Nutrition Database APIs (Largest Datasets)
    
    // USDA FoodData Central - Largest free database (1.9M+ foods)
    struct USDA {
        static let baseURL = "https://api.nal.usda.gov/fdc/v1"
        static let apiKey = ProcessInfo.processInfo.environment["USDA_API_KEY"] ?? "DEMO_KEY" // Works with demo key
        
        struct Endpoints {
            static let search = "/foods/search"
            static let food = "/food"
            static let foods = "/foods" // Bulk lookup
            static let nutrients = "/nutrients"
        }
        
        static var isConfigured: Bool {
            true // Always available with DEMO_KEY
        }
        
        // Database types
        enum DataType: String {
            case branded = "Branded"           // 1.1M+ branded foods
            case survey = "Survey (FNDDS)"     // NHANES survey foods
            case foundation = "Foundation"      // Detailed nutrient data
            case legacy = "SR Legacy"          // Legacy database
            case all = ""                      // All types
        }
    }
    
    // Open Food Facts - Open source (2.9M+ products)
    struct OpenFoodFacts {
        static let baseURL = "https://world.openfoodfacts.org/api/v2"
        
        struct Endpoints {
            static let search = "/search"
            static let product = "/product" // Barcode lookup
        }
        
        static var isConfigured: Bool {
            true // No API key required
        }
    }
    
    // Edamam - Good for recipes and diet analysis
    struct Edamam {
        static let baseURL = "https://api.edamam.com/api"
        static let appId = ProcessInfo.processInfo.environment["EDAMAM_APP_ID"] ?? ""
        static let appKey = ProcessInfo.processInfo.environment["EDAMAM_APP_KEY"] ?? ""
        
        struct Endpoints {
            static let foodDatabase = "/food-database/v2/parser"
            static let nutrients = "/food-database/v2/nutrients"
            static let recipeSearch = "/recipes/v2"
        }
        
        static var isConfigured: Bool {
            !appId.isEmpty && !appKey.isEmpty
        }
    }
    
    // FatSecret - Free API with 500k+ foods
    struct FatSecret {
        static let baseURL = "https://platform.fatsecret.com/rest/server.api"
        static let clientId = ProcessInfo.processInfo.environment["FATSECRET_CLIENT_ID"] ?? ""
        static let clientSecret = ProcessInfo.processInfo.environment["FATSECRET_CLIENT_SECRET"] ?? ""
        
        static var isConfigured: Bool {
            !clientId.isEmpty && !clientSecret.isEmpty
        }
    }
    
    // MARK: - General Configuration
    static let isDebugMode = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static let useMockData = ProcessInfo.processInfo.environment["USE_MOCK_DATA"] == "true"
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let networkError = "Unable to connect to the server. Please check your internet connection."
        static let invalidImage = "The image format is not supported. Please use JPG or PNG."
        static let apiKeyMissing = "API configuration is missing. Please contact support."
        static let recognitionFailed = "Could not identify foods in the image. Please try again with a clearer photo."
    }
}