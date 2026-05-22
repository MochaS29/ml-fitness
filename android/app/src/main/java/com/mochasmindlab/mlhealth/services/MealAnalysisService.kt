package com.mochasmindlab.mlhealth.services

import android.graphics.Bitmap
import android.util.Base64
import com.mochasmindlab.mlhealth.data.database.FoodDao
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.MealAnalysis
import com.mochasmindlab.mlhealth.utils.PreferencesManager
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
    object ApiKeyMissing : AnalysisError("App is misconfigured. Please update.")
    object NetworkError : AnalysisError("Network connection error")
    object RateLimited : AnalysisError("Too many scans this hour. Try again later.")
}

@Singleton
class MealAnalysisService @Inject constructor(
    private val preferencesManager: PreferencesManager
) {

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
            // Auth: shared secret identifies us as the genuine app to the proxy.
            // Without it the proxy returns 401. (We don't carry an Anthropic key.)
            val sharedSecret = SecretsManager.appSharedSecret
                ?: return@withContext Result.failure(AnalysisError.ApiKeyMissing)

            val installId = preferencesManager.getOrCreateInstallId()

            val base64Image = try {
                encodeImage(bitmap)
            } catch (e: Exception) {
                return@withContext Result.failure(AnalysisError.ImageProcessingFailed)
            }

            try {
                val rawJson = callMealScanProxy(base64Image, sharedSecret, installId)
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

    private fun callMealScanProxy(
        base64Image: String,
        sharedSecret: String,
        installId: String
    ): String {
        // Body matches the proxy contract — see Web-Projects/mochamindlabs-website/api/v1/meal-scan.js.
        // The proxy builds the actual Anthropic request server-side so we never
        // ship the Anthropic API key. Prompt + model selection are server-owned too.
        val requestBody = JsonObject(mapOf("image" to JsonPrimitive(base64Image))).toString()
        val request = Request.Builder()
            .url(SecretsManager.mealScanEndpoint)
            .addHeader("X-App-Secret", sharedSecret)
            .addHeader("X-Install-Id", installId)
            // Platform header — proxy uses this to pick the right Anthropic key
            // (when ANTHROPIC_API_KEY_ANDROID is set) and for per-platform logs.
            .addHeader("X-Platform", "android")
            .post(requestBody.toRequestBody("application/json".toMediaType()))
            .build()

        val response = client.newCall(request).execute()
        val body = response.body?.string() ?: throw AnalysisError.NoData
        when (response.code) {
            in 200..299 -> return body
            401 -> throw AnalysisError.ApiKeyMissing
            429 -> throw AnalysisError.RateLimited
            else -> throw AnalysisError.InvalidResponse
        }
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
