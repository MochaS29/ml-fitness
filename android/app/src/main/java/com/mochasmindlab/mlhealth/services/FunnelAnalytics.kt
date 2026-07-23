package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.utils.PreferencesManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Minimal, privacy-respecting funnel analytics (mirrors iOS FunnelAnalytics).
 *
 * Fire-and-forget anonymous events so we can see WHERE users drop in the paywall
 * / purchase funnel. No PII: reuses the meal-scan APP_SHARED_SECRET + the
 * anonymous per-install UUID, plus event name, optional context, platform, ts.
 * Never blocks the UI and silently ignores failures. Events land at
 * mochasmindlab.com/api/v1/event.
 */
@Singleton
class FunnelAnalytics @Inject constructor(
    private val prefs: PreferencesManager,
) {
    enum class Event(val value: String) {
        ONBOARDING_COMPLETE("onboarding_complete"),
        FIRST_SCAN("first_scan"),
        PAYWALL_SHOWN("paywall_shown"),
        BUY_TAPPED("buy_tapped"),
        PURCHASE_SUCCESS("purchase_success"),
        PURCHASE_FAILED("purchase_failed"),
    }

    private val client = OkHttpClient()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val jsonMedia = "application/json".toMediaType()

    fun log(event: Event, context: String? = null) {
        scope.launch {
            try {
                val secret = SecretsManager.appSharedSecret ?: return@launch
                val installId = prefs.getOrCreateInstallId()
                val payload = JSONObject().apply {
                    put("event", event.value)
                    put("ts", System.currentTimeMillis() / 1000)
                    if (context != null) put("context", context)
                }.toString()
                val req = Request.Builder()
                    .url("https://mochasmindlab.com/api/v1/event")
                    .addHeader("X-App-Secret", secret)
                    .addHeader("X-Install-Id", installId)
                    .addHeader("X-Platform", "android")
                    .post(payload.toRequestBody(jsonMedia))
                    .build()
                client.newCall(req).execute().use { /* fire-and-forget */ }
            } catch (_: Exception) {
                // Analytics must never block, retry, or crash the app.
            }
        }
    }
}
