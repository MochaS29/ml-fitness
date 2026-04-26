package com.mochasmindlab.mlhealth.services

import android.graphics.Bitmap
import android.util.Base64
import com.mochasmindlab.mlhealth.data.database.FoodDao
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.MealAnalysis
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.ByteArrayOutputStream
import java.util.*
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

sealed class AnalysisError(message: String) : Exception(message) {
    object ImageProcessingFailed : AnalysisError("Failed to process image")
    object NoData : AnalysisError("No data received from server")
    object InvalidResponse : AnalysisError("Invalid response format")
    object ApiKeyMissing : AnalysisError("API key not configured")
    object NetworkError : AnalysisError("Network connection error")
}

@Singleton
class MealAnalysisService @Inject constructor() {

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()

    suspend fun analyzeMealPhoto(bitmap: Bitmap): Result<MealAnalysis> =
        withContext(Dispatchers.IO) {
            val apiKey = SecretsManager.anthropicApiKey
                ?: return@withContext Result.failure(AnalysisError.ApiKeyMissing)

            val base64Image = try {
                encodeImage(bitmap)
            } catch (e: Exception) {
                return@withContext Result.failure(AnalysisError.ImageProcessingFailed)
            }

            try {
                val rawJson = callClaudeApi(base64Image, apiKey)
                val analysis = parseResponse(rawJson)
                Result.success(analysis)
            } catch (e: AnalysisError) {
                Result.failure(e)
            } catch (e: Exception) {
                Result.failure(AnalysisError.NetworkError)
            }
        }

    suspend fun saveAnalysisToDiary(
        analysis: MealAnalysis,
        mealType: String,
        foodDao: FoodDao
    ): Int = withContext(Dispatchers.IO) {
        val today = Date()
        var saved = 0
        for (item in analysis.items) {
            val entry = FoodEntry(
                id = UUID.randomUUID(),
                name = item.name,
                date = today,
                timestamp = today,
                mealType = mealType.lowercase(),
                servingSize = item.quantity,
                servingUnit = "serving",
                servingCount = 1.0,
                calories = item.calories,
                protein = item.protein,
                carbs = item.carbs,
                fat = item.fat,
                fiber = item.fiber
            )
            foodDao.insert(entry)
            saved++
        }
        saved
    }

    private fun encodeImage(bitmap: Bitmap): String {
        val scaled = resizeBitmap(bitmap, 1024)
        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.JPEG, 80, stream)
        val bytes = stream.toByteArray()
        if (bytes.isEmpty()) throw AnalysisError.ImageProcessingFailed
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }

    private fun resizeBitmap(src: Bitmap, maxDimension: Int): Bitmap {
        val w = src.width
        val h = src.height
        if (w <= maxDimension && h <= maxDimension) return src
        val scale = maxDimension.toFloat() / maxOf(w, h)
        return Bitmap.createScaledBitmap(src, (w * scale).toInt(), (h * scale).toInt(), true)
    }

    private fun callClaudeApi(base64Image: String, apiKey: String): String {
        val requestBody = buildRequestBody(base64Image)
        val request = Request.Builder()
            .url("https://api.anthropic.com/v1/messages")
            .addHeader("x-api-key", apiKey)
            .addHeader("anthropic-version", "2023-06-01")
            .post(requestBody.toRequestBody("application/json".toMediaType()))
            .build()

        val response = client.newCall(request).execute()
        val body = response.body?.string() ?: throw AnalysisError.NoData
        return body
    }

    private fun buildRequestBody(base64Image: String): String {
        val prompt = """
            Analyze this food image and identify all food items. For each item provide:
            1. Food name
            2. Estimated quantity/portion size
            3. Estimated calories
            4. Estimated macros (protein, carbs, fat in grams)
            5. Confidence level (0-1)

            Return ONLY valid JSON with no other text, in this exact format:
            {
                "items": [
                    {
                        "name": "food name",
                        "quantity": "portion description",
                        "calories": 0,
                        "protein": 0,
                        "carbs": 0,
                        "fat": 0,
                        "fiber": 0,
                        "confidence": 0.0
                    }
                ],
                "totalCalories": 0,
                "confidence": 0.0
            }
        """.trimIndent()

        // Build the Anthropic request JSON. The base64 image string is injected directly;
        // the prompt is escaped so it is safe inside a JSON string literal.
        val escapedPrompt = prompt
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")

        return """
            {
              "model": "claude-sonnet-4-6",
              "max_tokens": 1024,
              "messages": [
                {
                  "role": "user",
                  "content": [
                    {
                      "type": "image",
                      "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": "$base64Image"
                      }
                    },
                    {
                      "type": "text",
                      "text": "$escapedPrompt"
                    }
                  ]
                }
              ]
            }
        """.trimIndent()
    }

    private fun parseResponse(rawJson: String): MealAnalysis {
        val root = try {
            json.parseToJsonElement(rawJson) as? JsonObject
                ?: throw AnalysisError.InvalidResponse
        } catch (e: AnalysisError) {
            throw e
        } catch (e: Exception) {
            throw AnalysisError.InvalidResponse
        }

        if (root.containsKey("error")) throw AnalysisError.InvalidResponse

        val text = root["content"]
            ?.jsonArray
            ?.firstOrNull()
            ?.jsonObject
            ?.get("text")
            ?.jsonPrimitive
            ?.content
            ?: throw AnalysisError.InvalidResponse

        val extracted = extractJson(text)
        return try {
            json.decodeFromString(MealAnalysis.serializer(), extracted)
        } catch (e: Exception) {
            throw AnalysisError.InvalidResponse
        }
    }

    private fun extractJson(text: String): String {
        val start = text.indexOf('{')
        val end = text.lastIndexOf('}')
        if (start == -1 || end == -1 || end < start) return text
        return text.substring(start, end + 1)
    }
}
