import Foundation

struct APIConfiguration {
    // MARK: - Food Recognition API
    struct FoodRecognition {
        static let baseURL = "https://api.foodrecognition.com/v1"
        static let timeout: TimeInterval = 30
        static let maxImageSize = 5 * 1024 * 1024 // 5MB
        static let supportedFormats = ["jpg", "jpeg", "png", "heic"]
        
        // API endpoints
        struct Endpoints {
            static let analyze = "/analyze"
            static let search = "/search"
            static let nutrients = "/nutrients"
            static let barcode = "/barcode"
        }
        
        // Default parameters
        struct DefaultParameters {
            static let confidenceThreshold = 0.7
            static let maxResults = 10
            static let includeNutrition = true
            static let includeBoundingBox = true
        }
    }
    
    // MARK: - Nutrition Database API
    struct NutritionDatabase {
        static let baseURL = "https://api.nutritionix.com/v2"
        static let appId = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_ID"] ?? ""
        static let appKey = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_KEY"] ?? ""
        
        struct Endpoints {
            static let search = "/search/instant"
            static let nutrients = "/natural/nutrients"
            static let branded = "/search/branded"
        }
    }
    
    // MARK: - USDA FoodData Central API
    struct USDA {
        static let baseURL = "https://api.nal.usda.gov/fdc/v1"
        static let apiKey = ProcessInfo.processInfo.environment["USDA_API_KEY"] ?? ""
        
        struct Endpoints {
            static let search = "/foods/search"
            static let food = "/food"
            static let nutrients = "/nutrients"
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