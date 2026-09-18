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
        PAYWALL_DISMISSED("paywall_dismissed"),
        BUY_TAPPED("buy_tapped"),
        PURCHASE_SUCCESS("purchase_success"),
        PURCHASE_FAILED("purchase_failed"),
        SCREEN_VIEW("screen_view"),
    }

    /**
     * Screens reported through [logScreen]. [value] is the `context` sent with
     * the event. Mirrors iOS `FunnelAnalytics.Screen`; keep the shared names
     * identical on both platforms. Onboarding steps are per platform because
     * the two onboarding flows differ (iOS: welcome, quick setup, reminders).
     */
    enum class Screen(val value: String) {
        DASHBOARD("dashboard"),
        DIARY("diary"),
        ADD_TO_DIARY("add_to_diary"),
        MEAL_SCANNER("meal_scanner"),
        MEAL_PLAN("meal_plan"),
        MORE("more"),
        PAYWALL("paywall"),
        ONBOARDING_WELCOME("onboarding_welcome"),
        ONBOARDING_BASIC_INFO("onboarding_basic_info"),
        ONBOARDING_BODY_METRICS("onboarding_body_metrics"),
        ONBOARDING_ACTIVITY_LEVEL("onboarding_activity_level"),
        ONBOARDING_GOALS("onboarding_goals"),
    }

    private val client = OkHttpClient()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val jsonMedia = "application/json".toMediaType()
    private val screenThrottle = ScreenViewThrottle()

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

    /**
     * Sends [event] at most once per install.
     *
     * The top-of-funnel milestones are "first time" events: ONBOARDING_COMPLETE
     * marks an activated install and FIRST_SCAN marks the first meal actually
     * scanned, so both are denominators: one per install or they count nothing.
     * The scanner runs many times, so the guard lives here rather than at the
     * call site. The flag is a DataStore bool, wiped by an uninstall or Settings
     * -> Clear Data, exactly like the anonymous install ID it is reported
     * against. Mirrors iOS `FunnelAnalytics.logOnce`.
     */
    fun logOnce(event: Event, context: String? = null) {
        scope.launch {
            try {
                if (prefs.markFunnelEventLogged(event.value)) {
                    log(event, context)
                }
            } catch (_: Exception) {
                // Same contract as log(): never block, retry, or crash.
            }
        }
    }

    /**
     * Records one SCREEN_VIEW per appearance of [screen].
     *
     * Compose can re-enter a screen for a single visible appearance (a
     * configuration change recreates the composition, a bottom sheet closing
     * over a tab), so repeats of the same screen inside a two second window are
     * dropped. A different screen always logs. Mirrors iOS
     * `FunnelAnalytics.logScreen`.
     */
    fun logScreen(screen: Screen) {
        if (!screenThrottle.admit(screen.value)) return
        log(Event.SCREEN_VIEW, screen.value)
    }
}
