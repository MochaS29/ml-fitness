package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.services.BillingManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for [PaywallScreen].
 *
 * On init it ensures the billing client is connected and the Pro product
 * details are loaded so the paywall can show the correct formatted price.
 *
 * All reactive state (connection, product details, isPro) is exposed directly
 * from [BillingManager] — the ViewModel acts as a thin coordinator so the
 * Composable only depends on this ViewModel rather than the service directly.
 *
 * TODO: Wire "paywall" route in MLFitnessNavigation.kt / MLHealthNavHost.kt:
 *   composable("paywall") { PaywallScreen(navController) }
 */
@HiltViewModel
class PaywallViewModel @Inject constructor(
    val billing: BillingManager
) : ViewModel() {

    init {
        // Ensure we are connected (idempotent — no-ops if already connected).
        billing.connect()

        // Eagerly load product details so price is ready when the screen opens.
        viewModelScope.launch {
            billing.queryProProduct()
        }
    }

    /** Delegates restore to BillingManager (syncs Play purchase history). */
    fun restorePurchases() {
        viewModelScope.launch {
            billing.restorePurchases()
        }
    }
}
