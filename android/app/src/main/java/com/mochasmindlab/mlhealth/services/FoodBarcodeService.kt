package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.config.ApiConfig
import com.mochasmindlab.mlhealth.data.models.FoodItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.*
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.Date
import java.util.concurrent.TimeUnit

class FoodBarcodeService {
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()
    
    private val json = Json { 
        ignoreUnknownKeys = true
        isLenient = true
    }

    suspend fun lookupBarcode(barcode: String): FoodItem? = withContext(Dispatchers.IO) {
        try {
            // Try Open Food Facts API first
            val openFoodFactsResult = fetchFromOpenFoodFacts(barcode)
            if (openFoodFactsResult != null) {
                return@withContext openFoodFactsResult
            }

            // Try USDA FoodData Central as fallback
            val usdaResult = fetchFromUSDA(barcode)
            if (usdaResult != null) {
                return@withContext usdaResult
            }

            // Try Spoonacular API
            val spoonacularResult = fetchFromSpoonacular(barcode)
            if (spoonacularResult != null) {
                return@withContext spoonacularResult
            }

            // Try Nutritionix API if you have API key
            // val nutritionixResult = fetchFromNutritionix(barcode)
            
            null
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private suspend fun fetchFromOpenFoodFacts(barcode: String): FoodItem? {
        try {
            val url = "https://world.openfoodfacts.org/api/v2/product/$barcode.json"
            val request = Request.Builder()
                .url(url)
                .header("User-Agent", "ML Fitness Android App - Version 1.0")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) {
                return null
            }

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
            
            val status = jsonResponse["status"]?.jsonPrimitive?.intOrNull ?: 0
            if (status != 1) {
                return null
            }

            val product = jsonResponse["product"]?.jsonObject ?: return null
            
            return parseOpenFoodFactsProduct(product, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseOpenFoodFactsProduct(product: JsonObject, barcode: String): FoodItem? {
        try {
            val name = product["product_name"]?.jsonPrimitive?.contentOrNull 
                ?: product["product_name_en"]?.jsonPrimitive?.contentOrNull
                ?: return null

            val brand = product["brands"]?.jsonPrimitive?.contentOrNull
            
            // Get nutriments per 100g
            val nutriments = product["nutriments"]?.jsonObject ?: return null
            
            // Get serving size if available
            val servingSize = product["serving_size"]?.jsonPrimitive?.contentOrNull ?: "100g"
            val servingQuantity = product["serving_quantity"]?.jsonPrimitive?.floatOrNull ?: 100f
            
            // Calculate nutrition per serving
            val multiplier = servingQuantity / 100f
            
            val calories = (nutriments["energy-kcal_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val protein = (nutriments["proteins_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val carbs = (nutriments["carbohydrates_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val fat = (nutriments["fat_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val fiber = (nutriments["fiber_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val sugar = (nutriments["sugars_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier
            val sodium = (nutriments["sodium_100g"]?.jsonPrimitive?.floatOrNull ?: 0f) * multiplier * 1000 // Convert to mg

            return FoodItem(
                name = name,
                brand = brand,
                barcode = barcode,
                calories = calories.toInt(),
                protein = protein,
                carbs = carbs,
                fat = fat,
                fiber = fiber,
                sugar = sugar,
                sodium = sodium,
                servingSize = servingSize,
                servingUnit = "serving",
                isCustom = false,
                isFavorite = false,
                lastLogged = null,
                logCount = 0,
                createdAt = Date()
            )
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private suspend fun fetchFromUSDA(barcode: String): FoodItem? {
        // USDA FoodData Central API
        val apiKey = ApiConfig.USDA_API_KEY

        if (!ApiConfig.isApiConfigured("USDA")) {
            return null // Skip if no real API key
        }

        try {
            val url = "https://api.nal.usda.gov/fdc/v1/foods/search?query=$barcode&api_key=$apiKey"
            val request = Request.Builder()
                .url(url)
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) {
                return null
            }

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject
            
            val foods = jsonResponse["foods"]?.jsonArray
            if (foods.isNullOrEmpty()) {
                return null
            }

            val food = foods[0].jsonObject
            return parseUSDAFood(food, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseUSDAFood(food: JsonObject, barcode: String): FoodItem? {
        try {
            val description = food["description"]?.jsonPrimitive?.contentOrNull ?: return null
            val brandOwner = food["brandOwner"]?.jsonPrimitive?.contentOrNull
            
            val foodNutrients = food["foodNutrients"]?.jsonArray ?: return null
            
            var calories = 0
            var protein = 0f
            var carbs = 0f
            var fat = 0f
            var fiber = 0f
            var sugar = 0f
            var sodium = 0f

            for (nutrientElement in foodNutrients) {
                val nutrient = nutrientElement.jsonObject
                val nutrientName = nutrient["nutrientName"]?.jsonPrimitive?.contentOrNull ?: continue
                val value = nutrient["value"]?.jsonPrimitive?.floatOrNull ?: 0f

                when {
                    nutrientName.contains("Energy", ignoreCase = true) -> calories = value.toInt()
                    nutrientName.contains("Protein", ignoreCase = true) -> protein = value
                    nutrientName.contains("Carbohydrate", ignoreCase = true) -> carbs = value
                    nutrientName.contains("Total lipid", ignoreCase = true) -> fat = value
                    nutrientName.contains("Fiber", ignoreCase = true) -> fiber = value
                    nutrientName.contains("Sugars", ignoreCase = true) -> sugar = value
                    nutrientName.contains("Sodium", ignoreCase = true) -> sodium = value
                }
            }

            return FoodItem(
                name = description,
                brand = brandOwner,
                barcode = barcode,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fat = fat,
                fiber = fiber,
                sugar = sugar,
                sodium = sodium,
                servingSize = "100",
                servingUnit = "g",
                isCustom = false,
                isFavorite = false,
                lastLogged = null,
                logCount = 0,
                createdAt = Date()
            )
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private suspend fun fetchFromSpoonacular(barcode: String): FoodItem? {
        if (!ApiConfig.isApiConfigured("SPOONACULAR")) {
            return null
        }

        try {
            val url = "${ApiConfig.SPOONACULAR_BASE_URL}/food/products/upc/$barcode?apiKey=${ApiConfig.SPOONACULAR_API_KEY}"
            val request = Request.Builder()
                .url(url)
                .header("Accept", "application/json")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) {
                return null
            }

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            return parseSpoonacularProduct(jsonResponse, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseSpoonacularProduct(product: JsonObject, barcode: String): FoodItem? {
        try {
            val title = product["title"]?.jsonPrimitive?.contentOrNull ?: return null
            val brand = product["brand"]?.jsonPrimitive?.contentOrNull

            // Nutrition information
            val nutrition = product["nutrition"]?.jsonObject
            val nutrients = nutrition?.get("nutrients")?.jsonArray ?: return null

            var calories = 0
            var protein = 0f
            var carbs = 0f
            var fat = 0f
            var fiber = 0f
            var sugar = 0f
            var sodium = 0f

            for (nutrientElement in nutrients) {
                val nutrient = nutrientElement.jsonObject
                val name = nutrient["name"]?.jsonPrimitive?.contentOrNull ?: continue
                val amount = nutrient["amount"]?.jsonPrimitive?.floatOrNull ?: 0f

                when (name) {
                    "Calories" -> calories = amount.toInt()
                    "Protein" -> protein = amount
                    "Carbohydrates" -> carbs = amount
                    "Fat" -> fat = amount
                    "Fiber" -> fiber = amount
                    "Sugar" -> sugar = amount
                    "Sodium" -> sodium = amount
                }
            }

            val servingSize = product["serving_size"]?.jsonPrimitive?.contentOrNull ?: "1"
            val servingUnit = product["serving_unit"]?.jsonPrimitive?.contentOrNull ?: "serving"

            return FoodItem(
                name = title,
                brand = brand,
                barcode = barcode,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fat = fat,
                fiber = fiber,
                sugar = sugar,
                sodium = sodium,
                servingSize = servingSize,
                servingUnit = servingUnit,
                isCustom = false,
                isFavorite = false,
                lastLogged = null,
                logCount = 0,
                createdAt = Date()
            )
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    // Mock data for testing without API
    fun getMockFoodItem(barcode: String): FoodItem {
        val mockFoods = mapOf(
            "012345678901" to FoodItem(
                name = "Organic Granola Bar",
                brand = "Nature Valley",
                barcode = "012345678901",
                calories = 140,
                protein = 3f,
                carbs = 19f,
                fat = 6f,
                fiber = 2f,
                sugar = 7f,
                sodium = 95f,
                servingSize = "1",
                servingUnit = "bar (35g)"
            ),
            "038000358210" to FoodItem(
                name = "Special K Cereal",
                brand = "Kellogg's",
                barcode = "038000358210",
                calories = 120,
                protein = 6f,
                carbs = 22f,
                fat = 0.5f,
                fiber = 3f,
                sugar = 4f,
                sodium = 220f,
                servingSize = "1",
                servingUnit = "cup (31g)"
            ),
            "034000052011" to FoodItem(
                name = "Kit Kat",
                brand = "Nestle",
                barcode = "034000052011",
                calories = 210,
                protein = 3f,
                carbs = 27f,
                fat = 11f,
                fiber = 1f,
                sugar = 21f,
                sodium = 30f,
                servingSize = "1",
                servingUnit = "package (42g)"
            )
        )

        return mockFoods[barcode] ?: FoodItem(
            name = "Unknown Product",
            brand = "Generic",
            barcode = barcode,
            calories = 100,
            protein = 2f,
            carbs = 20f,
            fat = 2f,
            fiber = 1f,
            sugar = 5f,
            sodium = 50f,
            servingSize = "1",
            servingUnit = "serving"
        )
    }
}

// Extension to get barcode types we support
fun getBarcodeFormats(): IntArray {
    return intArrayOf(
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_A,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_UPC_E,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_13,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_EAN_8,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_128,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_CODE_39,
        com.google.mlkit.vision.barcode.common.Barcode.FORMAT_ITF
    )
}