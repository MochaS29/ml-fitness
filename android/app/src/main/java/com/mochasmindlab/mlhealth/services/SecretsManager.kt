package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.BuildConfig

/**
 * Centralized read access to BuildConfig-baked secrets.
 * All values come from local.properties at build time and are never committed.
 * Each getter returns null when the key is empty so callers can short-circuit
 * cleanly rather than make API calls with a blank header.
 */
object SecretsManager {
    val anthropicApiKey: String?
        get() = BuildConfig.ANTHROPIC_API_KEY.takeIf { it.isNotBlank() }

    val usdaApiKey: String?
        get() = BuildConfig.USDA_API_KEY.takeIf { it.isNotBlank() }

    val spoonacularApiKey: String?
        get() = BuildConfig.SPOONACULAR_API_KEY.takeIf { it.isNotBlank() }

    val nutritionixAppId: String?
        get() = BuildConfig.NUTRITIONIX_APP_ID.takeIf { it.isNotBlank() }

    val nutritionixAppKey: String?
        get() = BuildConfig.NUTRITIONIX_APP_KEY.takeIf { it.isNotBlank() }
}
