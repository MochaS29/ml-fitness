package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.config.ApiConfig
import com.mochasmindlab.mlhealth.data.models.FoodItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.Date
import java.util.concurrent.TimeUnit

/**
 * Service for looking up restaurant and fast food menu items
 * Uses Nutritionix API which has 800+ restaurant chains
 */
class RestaurantFoodService {
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    /**
     * Popular fast food chains supported by Nutritionix
     */
    enum class Restaurant(val displayName: String, val searchName: String) {
        MCDONALDS("McDonald's", "mcdonalds"),
        BURGER_KING("Burger King", "burger king"),
        WENDYS("Wendy's", "wendys"),
        SUBWAY("Subway", "subway"),
        CHIPOTLE("Chipotle", "chipotle"),
        STARBUCKS("Starbucks", "starbucks"),
        DUNKIN("Dunkin'", "dunkin"),
        TACO_BELL("Taco Bell", "taco bell"),
        KFC("KFC", "kfc"),
        PIZZA_HUT("Pizza Hut", "pizza hut"),
        DOMINOS("Domino's", "dominos"),
        PAPA_JOHNS("Papa John's", "papa johns"),
        CHICKFILA("Chick-fil-A", "chick fil a"),
        PANERA("Panera Bread", "panera"),
        FIVE_GUYS("Five Guys", "five guys"),
        IN_N_OUT("In-N-Out", "in n out"),
        ARBYS("Arby's", "arbys"),
        POPEYES("Popeyes", "popeyes"),
        SONIC("Sonic", "sonic"),
        CARLS_JR("Carl's Jr", "carls jr"),
        WHATABURGER("Whataburger", "whataburger"),
        SHAKE_SHACK("Shake Shack", "shake shack"),
        PANDA_EXPRESS("Panda Express", "panda express"),
        JIMMY_JOHNS("Jimmy John's", "jimmy johns"),
        QDOBA("Qdoba", "qdoba")
    }

    /**
     * Search for restaurant food items using natural language
     * Examples: "Big Mac from McDonald's", "Venti Latte Starbucks", "Footlong Italian BMT Subway"
     */
    suspend fun searchRestaurantFood(query: String): List<FoodItem> = withContext(Dispatchers.IO) {
        if (!ApiConfig.isApiConfigured("NUTRITIONIX")) {
            // Fallback to mock data if API not configured
            return@withContext getMockRestaurantFoods(query)
        }

        try {
            val url = "${ApiConfig.NUTRITIONIX_BASE_URL}/natural/nutrients"

            val requestBody = buildJsonObject {
                put("query", query)
            }.toString()

            val request = Request.Builder()
                .url(url)
                .header("x-app-id", ApiConfig.NUTRITIONIX_APP_ID)
                .header("x-app-key", ApiConfig.NUTRITIONIX_APP_KEY)
                .header("Content-Type", "application/json")
                .post(requestBody.toRequestBody("application/json".toMediaType()))
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) {
                return@withContext emptyList()
            }

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            val foods = jsonResponse["foods"]?.jsonArray ?: return@withContext emptyList()

            foods.mapNotNull { foodElement ->
                parseNutritionixFood(foodElement.jsonObject)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            getMockRestaurantFoods(query)
        }
    }

    /**
     * Search specific restaurant menu
     */
    suspend fun searchRestaurantMenu(
        restaurant: Restaurant,
        itemName: String
    ): List<FoodItem> {
        val query = "$itemName from ${restaurant.searchName}"
        return searchRestaurantFood(query)
    }

    /**
     * Get common menu items for a restaurant
     */
    suspend fun getPopularItems(restaurant: Restaurant): List<FoodItem> {
        return when (restaurant) {
            Restaurant.MCDONALDS -> searchRestaurantFood("big mac, quarter pounder, mcnuggets 10 piece, medium fries from mcdonalds")
            Restaurant.STARBUCKS -> searchRestaurantFood("grande latte, venti frappuccino, cake pop from starbucks")
            Restaurant.SUBWAY -> searchRestaurantFood("footlong italian bmt, 6 inch turkey breast from subway")
            Restaurant.CHIPOTLE -> searchRestaurantFood("chicken burrito bowl, chips and guacamole from chipotle")
            else -> emptyList()
        }
    }

    private fun parseNutritionixFood(food: JsonObject): FoodItem? {
        return try {
            val name = food["food_name"]?.jsonPrimitive?.content ?: return null
            val brand = food["brand_name"]?.jsonPrimitive?.content ?: "Restaurant"

            // Nutritional information
            val calories = food["nf_calories"]?.jsonPrimitive?.floatOrNull?.toInt() ?: 0
            val protein = food["nf_protein"]?.jsonPrimitive?.floatOrNull ?: 0f
            val carbs = food["nf_total_carbohydrate"]?.jsonPrimitive?.floatOrNull ?: 0f
            val fat = food["nf_total_fat"]?.jsonPrimitive?.floatOrNull ?: 0f
            val fiber = food["nf_dietary_fiber"]?.jsonPrimitive?.floatOrNull ?: 0f
            val sugar = food["nf_sugars"]?.jsonPrimitive?.floatOrNull ?: 0f
            val sodium = food["nf_sodium"]?.jsonPrimitive?.floatOrNull ?: 0f
            val saturatedFat = food["nf_saturated_fat"]?.jsonPrimitive?.floatOrNull ?: 0f
            val cholesterol = food["nf_cholesterol"]?.jsonPrimitive?.floatOrNull ?: 0f

            val servingQty = food["serving_qty"]?.jsonPrimitive?.floatOrNull ?: 1f
            val servingUnit = food["serving_unit"]?.jsonPrimitive?.content ?: "serving"
            val servingWeight = food["serving_weight_grams"]?.jsonPrimitive?.floatOrNull

            FoodItem(
                name = name,
                brand = brand,
                barcode = null,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fat = fat,
                fiber = fiber,
                sugar = sugar,
                sodium = sodium,
                saturatedFat = saturatedFat,
                cholesterol = cholesterol,
                servingSize = servingQty.toString(),
                servingUnit = servingUnit,
                servingWeightGrams = servingWeight,
                isCustom = false,
                isFavorite = false,
                isRestaurantFood = true,
                lastLogged = null,
                logCount = 0,
                createdAt = Date()
            )
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    /**
     * Mock data for testing and offline use
     */
    private fun getMockRestaurantFoods(query: String): List<FoodItem> {
        val mockItems = listOf(
            // McDonald's
            FoodItem(
                name = "Big Mac",
                brand = "McDonald's",
                calories = 563,
                protein = 26f,
                carbs = 45f,
                fat = 33f,
                fiber = 3f,
                sugar = 9f,
                sodium = 1010f,
                saturatedFat = 11f,
                servingSize = "1",
                servingUnit = "burger",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "Quarter Pounder with Cheese",
                brand = "McDonald's",
                calories = 520,
                protein = 30f,
                carbs = 42f,
                fat = 26f,
                fiber = 2f,
                sugar = 10f,
                sodium = 1140f,
                saturatedFat = 12f,
                servingSize = "1",
                servingUnit = "burger",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "Medium French Fries",
                brand = "McDonald's",
                calories = 320,
                protein = 4f,
                carbs = 43f,
                fat = 15f,
                fiber = 4f,
                sugar = 0f,
                sodium = 260f,
                saturatedFat = 2f,
                servingSize = "1",
                servingUnit = "medium",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "10 Piece Chicken McNuggets",
                brand = "McDonald's",
                calories = 420,
                protein = 23f,
                carbs = 26f,
                fat = 25f,
                fiber = 1f,
                sugar = 0f,
                sodium = 840f,
                saturatedFat = 4f,
                servingSize = "10",
                servingUnit = "pieces",
                isRestaurantFood = true
            ),

            // Starbucks
            FoodItem(
                name = "Grande Caffe Latte",
                brand = "Starbucks",
                calories = 190,
                protein = 13f,
                carbs = 19f,
                fat = 7f,
                fiber = 0f,
                sugar = 17f,
                sodium = 170f,
                saturatedFat = 4.5f,
                servingSize = "16",
                servingUnit = "fl oz",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "Venti Caramel Frappuccino",
                brand = "Starbucks",
                calories = 470,
                protein = 5f,
                carbs = 72f,
                fat = 17f,
                fiber = 0f,
                sugar = 68f,
                sodium = 320f,
                saturatedFat = 11f,
                servingSize = "24",
                servingUnit = "fl oz",
                isRestaurantFood = true
            ),

            // Subway
            FoodItem(
                name = "6\" Italian BMT",
                brand = "Subway",
                calories = 390,
                protein = 19f,
                carbs = 40f,
                fat = 17f,
                fiber = 3f,
                sugar = 5f,
                sodium = 1260f,
                saturatedFat = 6f,
                servingSize = "1",
                servingUnit = "6 inch sub",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "Footlong Turkey Breast",
                brand = "Subway",
                calories = 560,
                protein = 36f,
                carbs = 92f,
                fat = 8f,
                fiber = 10f,
                sugar = 14f,
                sodium = 1460f,
                saturatedFat = 2f,
                servingSize = "1",
                servingUnit = "footlong",
                isRestaurantFood = true
            ),

            // Chipotle
            FoodItem(
                name = "Chicken Burrito Bowl",
                brand = "Chipotle",
                calories = 625,
                protein = 41f,
                carbs = 58f,
                fat = 23f,
                fiber = 11f,
                sugar = 6f,
                sodium = 1435f,
                saturatedFat = 8f,
                servingSize = "1",
                servingUnit = "bowl",
                isRestaurantFood = true
            ),
            FoodItem(
                name = "Chips and Guacamole",
                brand = "Chipotle",
                calories = 770,
                protein = 9f,
                carbs = 82f,
                fat = 47f,
                fiber = 12f,
                sugar = 4f,
                sodium = 850f,
                saturatedFat = 7f,
                servingSize = "1",
                servingUnit = "serving",
                isRestaurantFood = true
            )
        )

        // Filter based on query
        val searchTerm = query.lowercase()
        return mockItems.filter { item ->
            item.name.lowercase().contains(searchTerm) ||
            item.brand?.lowercase()?.contains(searchTerm) == true ||
            searchTerm.contains(item.name.lowercase())
        }
    }
}

// Extension to FoodItem for restaurant foods
fun FoodItem.isHealthyOption(): Boolean {
    return calories < 500 &&
           saturatedFat < 10 &&
           sodium < 1000 &&
           fiber > 3
}

fun FoodItem.getMealType(): String {
    return when {
        name.contains("breakfast", ignoreCase = true) -> "Breakfast"
        name.contains("lunch", ignoreCase = true) -> "Lunch"
        name.contains("dinner", ignoreCase = true) -> "Dinner"
        name.contains("coffee", ignoreCase = true) ||
        name.contains("latte", ignoreCase = true) ||
        name.contains("frappuccino", ignoreCase = true) -> "Beverage"
        name.contains("fries", ignoreCase = true) ||
        name.contains("chips", ignoreCase = true) -> "Side"
        else -> "Main"
    }
}