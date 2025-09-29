package com.mochasmindlab.mlhealth.config

/**
 * API Configuration for ML Fitness Android
 * Synced from iOS HealthTracker app
 */
object ApiConfig {
    
    // USDA FoodData Central API
    // 3,600 requests/hour, 10,000 requests/day
    const val USDA_API_KEY = "Prq1Udw3TZOvlFdBdIflKXfphbASsabuyG4zGp4A"
    const val USDA_BASE_URL = "https://api.nal.usda.gov/fdc/v1"
    
    // Spoonacular API (for additional food data and recipes)
    const val SPOONACULAR_API_KEY = "78925a5a97ef4f53a8fc692cad0b1618"
    const val SPOONACULAR_BASE_URL = "https://api.spoonacular.com"
    
    // Open Food Facts API (no key required)
    const val OPEN_FOOD_FACTS_URL = "https://world.openfoodfacts.org/api/v2"
    
    // Nutritionix API (900,000+ products including supplements)
    const val NUTRITIONIX_APP_ID = "aeaa64ca"
    const val NUTRITIONIX_APP_KEY = "454cc82f4000f827b2be248b6da57d69"
    const val NUTRITIONIX_BASE_URL = "https://trackapi.nutritionix.com/v2"
    
    // Rate limiting
    const val USDA_RATE_LIMIT_PER_HOUR = 3600
    const val USDA_RATE_LIMIT_PER_DAY = 10000
    
    // API selection priority for barcode scanning
    enum class ApiPriority {
        OPEN_FOOD_FACTS,  // First - free and no limits
        USDA,            // Second - official US data
        SPOONACULAR,     // Third - good for recipes
        NUTRITIONIX      // Fourth - if available
    }
    
    fun getApiKeyForService(service: String): String? {
        return when (service) {
            "USDA" -> USDA_API_KEY
            "SPOONACULAR" -> SPOONACULAR_API_KEY
            "NUTRITIONIX_ID" -> NUTRITIONIX_APP_ID
            "NUTRITIONIX_KEY" -> NUTRITIONIX_APP_KEY
            else -> null
        }
    }
    
    // Check if API is configured
    fun isApiConfigured(service: String): Boolean {
        return when (service) {
            "USDA" -> USDA_API_KEY.isNotEmpty() && USDA_API_KEY != "DEMO_KEY"
            "SPOONACULAR" -> SPOONACULAR_API_KEY.isNotEmpty()
            "NUTRITIONIX" -> NUTRITIONIX_APP_ID.isNotEmpty() && NUTRITIONIX_APP_KEY.isNotEmpty()
            "OPEN_FOOD_FACTS" -> true // Always available
            else -> false
        }
    }
}