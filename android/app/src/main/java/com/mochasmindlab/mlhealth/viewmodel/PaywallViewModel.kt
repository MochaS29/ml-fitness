package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.services.BillingManager
import com.mochasmindlab.mlhealth.services.FunnelAnalytics
import com.mochasmindlab.mlhealth.ui.screens.paywall.PaywallTrigger
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for [com.mochasmindlab.mlhealth.ui.screens.paywall.PaywallScreen].
 *
 * On init it ensures the billing client is connected and the Pro product
 * details are loaded so the paywall can show the correct formatted price.
 *
 * All reactive state (connection, product details, isPro) is exposed directly
 * from [BillingManager]; the ViewModel acts as a thin coordinator so the
 * Composable only depends on this ViewModel rather than the service directly.
 *
 * Funnel events live here rather than in the Composable because this
 * ViewModel is scoped to the paywall's back-stack entry: it is created once
 * when the paywall opens and cleared once when it is popped, so paywall_shown
 * and paywall_dismissed fire exactly once per visit even across a
 * configuration change. Mirrors the iOS PaywallView onAppear / onDisappear
 * pair.
 */
@HiltViewModel
class PaywallViewModel @Inject constructor(
    val billing: BillingManager,
    private val funnel: FunnelAnalytics,
    savedStateHandle: SavedStateHandle,
) : ViewModel() {

    /** Where this paywall was opened from; the `context` on its funnel events. */
    val trigger: PaywallTrigger =
        PaywallTrigger.fromAnalyticsName(savedStateHandle.get<String>(PaywallTrigger.ARG))

    // Set once a purchase or restore lands while this paywall is open, so the
    // close can be reported as a dismissal only when nothing was bought.
    private var didPurchase = false

    fun logBuyTapped() = funnel.log(FunnelAnalytics.Event.BUY_TAPPED, trigger.analyticsName)

    init {
        funnel.log(FunnelAnalytics.Event.PAYWALL_SHOWN, trigger.analyticsName)

        // Ensure we are connected (idempotent; no-ops if already connected).
        billing.connect()

        // Eagerly load product details so price is ready when the screen opens.
        viewModelScope.launch {
            billing.queryProProduct()
        }

        // A false -> true flip while the paywall is open is a purchase or a
        // successful restore. Someone who was already Pro when it opened and
        // just closes it counts as a dismissal, same as iOS.
        val wasProAtOpen = billing.isProUser.value
        if (!wasProAtOpen) {
            viewModelScope.launch {
                billing.isProUser.collect { isPro ->
                    if (isPro) didPurchase = true
                }
            }
        }
    }

    /** Delegates restore to BillingManager (syncs Play purchase history). */
    fun restorePurchases() {
        viewModelScope.launch {
            billing.restorePurchases()
        }
    }

    override fun onCleared() {
        if (!didPurchase) {
            funnel.log(FunnelAnalytics.Event.PAYWALL_DISMISSED, trigger.analyticsName)
        }
        super.onCleared()
    }
}
