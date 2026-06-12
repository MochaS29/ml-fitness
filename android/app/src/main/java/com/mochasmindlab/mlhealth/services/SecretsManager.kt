package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.BuildConfig

/**
 * Centralized read access to BuildConfig-baked secrets.
 * All values come from local.properties at build time and are never committed.
 * Each getter returns null when the key is empty so callers can short-circuit
 * cleanly rather than make API calls with a blank header.
 */
object SecretsManager {
    // Anthropic access goes through the proxy at MEAL_SCAN_ENDPOINT — no key
    // is bundled in the APK any more. Apps authenticate to the proxy with
    // APP_SHARED_SECRET + a per-install UUID generated client-side.
    val appSharedSecret: String?
        get() = BuildConfig.APP_SHARED_SECRET.takeIf { it.isNotBlank() }

    val mealScanEndpoint: String
        get() = BuildConfig.MEAL_SCAN_ENDPOINT

    val usdaApiKey: String?
        get() = BuildConfig.USDA_API_KEY.takeIf { it.isNotBlank() }

    val spoonacularApiKey: String?
        get() = BuildConfig.SPOONACULAR_API_KEY.takeIf { it.isNotBlank() }

    val nutritionixAppId: String?
        get() = BuildConfig.NUTRITIONIX_APP_ID.takeIf { it.isNotBlank() }

    val nutritionixAppKey: String?
        get() = BuildConfig.NUTRITIONIX_APP_KEY.takeIf { it.isNotBlank() }
}
