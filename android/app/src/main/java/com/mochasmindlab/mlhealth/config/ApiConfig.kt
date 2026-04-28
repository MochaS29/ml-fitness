package com.mochasmindlab.mlhealth.config

import com.mochasmindlab.mlhealth.services.SecretsManager

/**
 * API endpoint URLs and rate-limit constants for MindLab Fitness.
 *
 * **Keys are NOT stored here.** They live in `local.properties` (gitignored)
 * and are baked into BuildConfig at build time, accessed via [SecretsManager].
 * This file historically had hardcoded keys that were committed to git;
 * those have been rotated and moved out.
 */
object ApiConfig {

    // USDA FoodData Central API — 3,600 req/hr, 10,000 req/day
    const val USDA_BASE_URL = "https://api.nal.usda.gov/fdc/v1"

    // Spoonacular API — recipes + supplementary food data
    const val SPOONACULAR_BASE_URL = "https://api.spoonacular.com"

    // Open Food Facts API — barcode lookup, no key required
    const val OPEN_FOOD_FACTS_URL = "https://world.openfoodfacts.org/api/v2"

    // Nutritionix — supplements + branded foods
    const val NUTRITIONIX_BASE_URL = "https://trackapi.nutritionix.com/v2"

    const val USDA_RATE_LIMIT_PER_HOUR = 3600
    const val USDA_RATE_LIMIT_PER_DAY = 10000

    enum class ApiPriority {
        OPEN_FOOD_FACTS,  // free, no limits
        USDA,
        SPOONACULAR,
        NUTRITIONIX
    }

    fun getApiKeyForService(service: String): String? = when (service) {
        "USDA" -> SecretsManager.usdaApiKey
        "SPOONACULAR" -> SecretsManager.spoonacularApiKey
        "NUTRITIONIX_ID" -> SecretsManager.nutritionixAppId
        "NUTRITIONIX_KEY" -> SecretsManager.nutritionixAppKey
        else -> null
    }

    fun isApiConfigured(service: String): Boolean = when (service) {
        "USDA" -> SecretsManager.usdaApiKey != null
        "SPOONACULAR" -> SecretsManager.spoonacularApiKey != null
        "NUTRITIONIX" -> SecretsManager.nutritionixAppId != null && SecretsManager.nutritionixAppKey != null
        "OPEN_FOOD_FACTS" -> true
        else -> false
    }
}
