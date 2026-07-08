package com.mochasmindlab.mlhealth.services

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Manages Play in-app review prompts for both free and Pro users.
 * Mirrors iOS ReviewRequestManager. Rules:
 *  - Free: request at food-log milestones (3, 10, 50, 150, 300, 500)
 *  - Pro: request after upgrading + after first AI meal scan
 *  - Minimum 30 days between any two requests
 *
 * ViewModels/services call the record* methods; MainActivity collects
 * [launchReview] and runs the Play review flow (which needs an Activity).
 * Play itself rate-limits how often the dialog actually appears, same as
 * Apple does on iOS, so a request is a suggestion, not a guarantee.
 */
@Singleton
class ReviewRequestManager @Inject constructor(
    @ApplicationContext context: Context
) {
    companion object {
        private const val PREFS_NAME = "review_request"
        private const val FOOD_LOG_COUNT_KEY = "rrm_foodLogCount"
        private const val LAST_REQUEST_DATE_KEY = "rrm_lastRequestDate"
        private const val PRO_UPGRADE_REVIEWED_KEY = "rrm_proUpgradeReviewed"
        private const val MEAL_SCAN_REVIEWED_KEY = "rrm_mealScanReviewed"
        private val MILESTONES = setOf(3, 10, 50, 150, 300, 500)
        private const val MIN_DAYS_BETWEEN_REQUESTS = 30L
    }

    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private val _launchReview = MutableStateFlow(false)
    /** MainActivity collects this and launches the Play review flow when true. */
    val launchReview: StateFlow<Boolean> = _launchReview.asStateFlow()

    // ---- Trigger points ----------------------------------------------------

    /** Call after every food entry is saved. */
    fun recordFoodLogged() {
        val count = prefs.getInt(FOOD_LOG_COUNT_KEY, 0) + 1
        prefs.edit().putInt(FOOD_LOG_COUNT_KEY, count).apply()
        if (count in MILESTONES) {
            requestReviewIfEligible()
        }
    }

    /** Call immediately after a successful Pro upgrade. */
    fun recordProUpgrade() {
        if (prefs.getBoolean(PRO_UPGRADE_REVIEWED_KEY, false)) return
        prefs.edit().putBoolean(PRO_UPGRADE_REVIEWED_KEY, true).apply()
        requestReviewIfEligible()
    }

    /** Call after the first successful AI meal scan. */
    fun recordMealScanned() {
        if (prefs.getBoolean(MEAL_SCAN_REVIEWED_KEY, false)) return
        prefs.edit().putBoolean(MEAL_SCAN_REVIEWED_KEY, true).apply()
        requestReviewIfEligible()
    }

    /** MainActivity calls this once it has handed the request to the Play API. */
    fun onReviewFlowLaunched() {
        prefs.edit().putLong(LAST_REQUEST_DATE_KEY, System.currentTimeMillis()).apply()
        _launchReview.value = false
    }

    // ---- Private -----------------------------------------------------------

    private fun requestReviewIfEligible() {
        val last = prefs.getLong(LAST_REQUEST_DATE_KEY, -1L)
        val isFirstEver = last < 0
        val daysSince = if (isFirstEver) Long.MAX_VALUE
            else TimeUnit.MILLISECONDS.toDays(System.currentTimeMillis() - last)
        if (isFirstEver || daysSince >= MIN_DAYS_BETWEEN_REQUESTS) {
            _launchReview.value = true
        }
    }
}
