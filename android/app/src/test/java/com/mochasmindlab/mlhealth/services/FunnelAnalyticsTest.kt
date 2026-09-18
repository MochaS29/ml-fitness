package com.mochasmindlab.mlhealth.services

import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.ui.screens.paywall.PaywallTrigger
import com.mochasmindlab.mlhealth.ui.screens.paywall.paywallRoute
import org.junit.Test

/**
 * Covers the pure parts of the funnel: the event and screen names the hub
 * endpoint must accept, the paywall trigger labels and route, and the
 * screen_view throttle. Nothing here touches the network.
 */
class FunnelAnalyticsTest {

    // ---- Event names (must match the endpoint's allow-list and iOS) --------

    @Test
    fun `event names match the endpoint allow-list`() {
        assertThat(FunnelAnalytics.Event.ONBOARDING_COMPLETE.value).isEqualTo("onboarding_complete")
        assertThat(FunnelAnalytics.Event.FIRST_SCAN.value).isEqualTo("first_scan")
        assertThat(FunnelAnalytics.Event.PAYWALL_SHOWN.value).isEqualTo("paywall_shown")
        assertThat(FunnelAnalytics.Event.PAYWALL_DISMISSED.value).isEqualTo("paywall_dismissed")
        assertThat(FunnelAnalytics.Event.BUY_TAPPED.value).isEqualTo("buy_tapped")
        assertThat(FunnelAnalytics.Event.PURCHASE_SUCCESS.value).isEqualTo("purchase_success")
        assertThat(FunnelAnalytics.Event.PURCHASE_FAILED.value).isEqualTo("purchase_failed")
        assertThat(FunnelAnalytics.Event.SCREEN_VIEW.value).isEqualTo("screen_view")
    }

    @Test
    fun `screen names are snake_case and match iOS`() {
        FunnelAnalytics.Screen.values().forEach { screen ->
            assertThat(screen.value).matches("[a-z_]+")
        }
        assertThat(FunnelAnalytics.Screen.ADD_TO_DIARY.value).isEqualTo("add_to_diary")
        assertThat(FunnelAnalytics.Screen.MEAL_SCANNER.value).isEqualTo("meal_scanner")
        assertThat(FunnelAnalytics.Screen.MEAL_PLAN.value).isEqualTo("meal_plan")
        assertThat(FunnelAnalytics.Screen.PAYWALL.value).isEqualTo("paywall")
    }

    // ---- Paywall trigger labels and route ----------------------------------

    @Test
    fun `paywall trigger analytics names match iOS`() {
        assertThat(PaywallTrigger.MEAL_SCANNER.analyticsName).isEqualTo("meal_scanner")
        assertThat(PaywallTrigger.MEAL_SCANNER_LAST_SCAN.analyticsName).isEqualTo("meal_scanner_last_scan")
        assertThat(PaywallTrigger.MEAL_PLAN.analyticsName).isEqualTo("meal_plan")
        assertThat(PaywallTrigger.RECIPE_BOOK.analyticsName).isEqualTo("recipe_book")
        assertThat(PaywallTrigger.BARCODE_SCANNER.analyticsName).isEqualTo("barcode_scanner")
        assertThat(PaywallTrigger.SUPPLEMENTS.analyticsName).isEqualTo("supplements")
        assertThat(PaywallTrigger.FASTING.analyticsName).isEqualTo("fasting")
        assertThat(PaywallTrigger.SETTINGS.analyticsName).isEqualTo("settings")
        assertThat(PaywallTrigger.GENERAL.analyticsName).isEqualTo("general")
    }

    @Test
    fun `paywall route carries the trigger and parses back`() {
        assertThat(paywallRoute(PaywallTrigger.SETTINGS)).isEqualTo("paywall?trigger=settings")
        assertThat(PaywallTrigger.ROUTE).isEqualTo("paywall?trigger={trigger}")
        PaywallTrigger.values().forEach { trigger ->
            assertThat(PaywallTrigger.fromAnalyticsName(trigger.analyticsName)).isEqualTo(trigger)
        }
    }

    @Test
    fun `unknown or missing trigger falls back to general`() {
        assertThat(PaywallTrigger.fromAnalyticsName(null)).isEqualTo(PaywallTrigger.GENERAL)
        assertThat(PaywallTrigger.fromAnalyticsName("not_a_trigger")).isEqualTo(PaywallTrigger.GENERAL)
    }

    // ---- screen_view throttle ----------------------------------------------

    private class FakeClock(var now: Long) {
        fun read(): Long = now
    }

    @Test
    fun `first appearance is admitted`() {
        val clock = FakeClock(100_000L)
        val throttle = ScreenViewThrottle(clock = clock::read)
        assertThat(throttle.admit("dashboard")).isTrue()
    }

    @Test
    fun `same screen within the window is dropped`() {
        val clock = FakeClock(100_000L)
        val throttle = ScreenViewThrottle(clock = clock::read)
        assertThat(throttle.admit("dashboard")).isTrue()
        clock.now += 500
        assertThat(throttle.admit("dashboard")).isFalse()
        clock.now += 1_499
        assertThat(throttle.admit("dashboard")).isFalse()
    }

    @Test
    fun `same screen after the window is admitted`() {
        val clock = FakeClock(100_000L)
        val throttle = ScreenViewThrottle(clock = clock::read)
        assertThat(throttle.admit("dashboard")).isTrue()
        clock.now += 2_000
        assertThat(throttle.admit("dashboard")).isTrue()
    }

    @Test
    fun `a different screen is always admitted`() {
        val clock = FakeClock(100_000L)
        val throttle = ScreenViewThrottle(clock = clock::read)
        assertThat(throttle.admit("dashboard")).isTrue()
        clock.now += 100
        assertThat(throttle.admit("diary")).isTrue()
        clock.now += 100
        // Bouncing straight back counts as a new appearance of the first screen.
        assertThat(throttle.admit("dashboard")).isTrue()
    }

    @Test
    fun `a dropped repeat does not extend the window`() {
        val clock = FakeClock(100_000L)
        val throttle = ScreenViewThrottle(clock = clock::read)
        assertThat(throttle.admit("dashboard")).isTrue()
        clock.now += 1_500
        assertThat(throttle.admit("dashboard")).isFalse()
        clock.now += 1_000 // 2.5 s after the admitted call, 1 s after the dropped one
        assertThat(throttle.admit("dashboard")).isTrue()
    }

    @Test
    fun `default window is two seconds`() {
        assertThat(ScreenViewThrottle.DEFAULT_WINDOW_MILLIS).isEqualTo(2_000L)
    }
}
