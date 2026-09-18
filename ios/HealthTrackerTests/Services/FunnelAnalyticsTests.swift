//
//  FunnelAnalyticsTests.swift
//  HealthTrackerTests
//

import XCTest
@testable import HealthTracker

/// Covers the pure parts of FunnelAnalytics: the event and screen names the hub
/// endpoint must accept, the paywall trigger labels, and the screen_view
/// throttle. Nothing here touches the network.
final class FunnelAnalyticsTests: XCTestCase {

    // MARK: - Event names (must match the endpoint's allow-list)

    func testEventNamesMatchEndpointAllowList() {
        XCTAssertEqual(FunnelAnalytics.Event.onboardingComplete.rawValue, "onboarding_complete")
        XCTAssertEqual(FunnelAnalytics.Event.firstScan.rawValue, "first_scan")
        XCTAssertEqual(FunnelAnalytics.Event.paywallShown.rawValue, "paywall_shown")
        XCTAssertEqual(FunnelAnalytics.Event.paywallDismissed.rawValue, "paywall_dismissed")
        XCTAssertEqual(FunnelAnalytics.Event.buyTapped.rawValue, "buy_tapped")
        XCTAssertEqual(FunnelAnalytics.Event.purchaseSuccess.rawValue, "purchase_success")
        XCTAssertEqual(FunnelAnalytics.Event.purchaseFailed.rawValue, "purchase_failed")
        XCTAssertEqual(FunnelAnalytics.Event.screenView.rawValue, "screen_view")
    }

    func testScreenNamesAreSnakeCase() {
        let screens: [FunnelAnalytics.Screen] = [
            .dashboard, .diary, .addToDiary, .mealScanner, .mealPlan, .more, .paywall,
            .onboardingWelcome, .onboardingQuickSetup, .onboardingReminders,
        ]
        for screen in screens {
            XCTAssertTrue(
                screen.rawValue.allSatisfy { $0.isLowercase || $0 == "_" },
                "\(screen) has a non snake_case raw value: \(screen.rawValue)"
            )
        }
        XCTAssertEqual(FunnelAnalytics.Screen.addToDiary.rawValue, "add_to_diary")
        XCTAssertEqual(FunnelAnalytics.Screen.mealScanner.rawValue, "meal_scanner")
        XCTAssertEqual(FunnelAnalytics.Screen.mealPlan.rawValue, "meal_plan")
    }

    // MARK: - Paywall trigger labels

    func testPaywallTriggerAnalyticsNames() {
        XCTAssertEqual(PaywallTrigger.mealScanner.analyticsName, "meal_scanner")
        XCTAssertEqual(PaywallTrigger.mealScannerLastScan.analyticsName, "meal_scanner_last_scan")
        XCTAssertEqual(PaywallTrigger.mealPlan.analyticsName, "meal_plan")
        XCTAssertEqual(PaywallTrigger.recipeBook.analyticsName, "recipe_book")
        XCTAssertEqual(PaywallTrigger.barcodeScanner.analyticsName, "barcode_scanner")
        XCTAssertEqual(PaywallTrigger.supplements.analyticsName, "supplements")
        XCTAssertEqual(PaywallTrigger.fasting.analyticsName, "fasting")
        XCTAssertEqual(PaywallTrigger.settings.analyticsName, "settings")
        XCTAssertEqual(PaywallTrigger.general.analyticsName, "general")
    }

    // MARK: - screen_view throttle

    func testFirstAppearanceIsAdmitted() {
        var throttle = ScreenViewThrottle()
        XCTAssertTrue(throttle.admit("dashboard", now: Date(timeIntervalSince1970: 100)))
    }

    func testSameScreenWithinWindowIsDropped() {
        var throttle = ScreenViewThrottle()
        let t0 = Date(timeIntervalSince1970: 100)
        XCTAssertTrue(throttle.admit("dashboard", now: t0))
        XCTAssertFalse(throttle.admit("dashboard", now: t0.addingTimeInterval(0.5)))
        XCTAssertFalse(throttle.admit("dashboard", now: t0.addingTimeInterval(1.99)))
    }

    func testSameScreenAfterWindowIsAdmitted() {
        var throttle = ScreenViewThrottle()
        let t0 = Date(timeIntervalSince1970: 100)
        XCTAssertTrue(throttle.admit("dashboard", now: t0))
        XCTAssertTrue(throttle.admit("dashboard", now: t0.addingTimeInterval(2.0)))
    }

    func testDifferentScreenIsAlwaysAdmitted() {
        var throttle = ScreenViewThrottle()
        let t0 = Date(timeIntervalSince1970: 100)
        XCTAssertTrue(throttle.admit("dashboard", now: t0))
        XCTAssertTrue(throttle.admit("diary", now: t0.addingTimeInterval(0.1)))
        // Bouncing straight back counts as a new appearance of the first screen.
        XCTAssertTrue(throttle.admit("dashboard", now: t0.addingTimeInterval(0.2)))
    }

    func testDroppedRepeatDoesNotExtendTheWindow() {
        var throttle = ScreenViewThrottle()
        let t0 = Date(timeIntervalSince1970: 100)
        XCTAssertTrue(throttle.admit("dashboard", now: t0))
        XCTAssertFalse(throttle.admit("dashboard", now: t0.addingTimeInterval(1.5)))
        // 2.5 s after the admitted call, even though only 1 s after the dropped one.
        XCTAssertTrue(throttle.admit("dashboard", now: t0.addingTimeInterval(2.5)))
    }

    func testDefaultWindowIsTwoSeconds() {
        XCTAssertEqual(ScreenViewThrottle.defaultWindow, 2)
    }
}
