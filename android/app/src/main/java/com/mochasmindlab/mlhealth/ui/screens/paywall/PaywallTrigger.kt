package com.mochasmindlab.mlhealth.ui.screens.paywall

/**
 * Where the paywall was opened from. Reported as the `context` of the paywall
 * funnel events (paywall_shown, paywall_dismissed, buy_tapped), so every
 * navigation to the paywall should pass the most specific case it can via
 * [paywallRoute]. Mirrors iOS `PaywallTrigger`; keep the cases in step.
 */
enum class PaywallTrigger(val analyticsName: String) {
    MEAL_SCANNER("meal_scanner"),                    // free scans used up in the scanner
    MEAL_SCANNER_LAST_SCAN("meal_scanner_last_scan"), // iOS only today: gate shown after the last free scan result
    MEAL_PLAN("meal_plan"),                          // meal plan lock
    RECIPE_BOOK("recipe_book"),                      // recipe library upsell
    BARCODE_SCANNER("barcode_scanner"),              // Pro gate on the barcode scanner
    SUPPLEMENTS("supplements"),                      // Pro gate on supplement tracking
    FASTING("fasting"),                              // Pro gate on the fasting timer
    SETTINGS("settings"),                            // "Upgrade to Pro" row on the More tab
    GENERAL("general");                              // general upgrade tap

    companion object {
        const val ROUTE = "paywall?trigger={trigger}"
        const val ARG = "trigger"

        /** Parses the route argument; unknown or missing values fall back to [GENERAL]. */
        fun fromAnalyticsName(name: String?): PaywallTrigger =
            values().firstOrNull { it.analyticsName == name } ?: GENERAL
    }
}

/** Route to navigate to the paywall from [trigger]. Matches [PaywallTrigger.ROUTE]. */
fun paywallRoute(trigger: PaywallTrigger): String = "paywall?trigger=${trigger.analyticsName}"
