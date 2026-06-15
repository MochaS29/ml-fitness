package com.mochasmindlab.mlhealth.services

// ---------------------------------------------------------------------------
// Wiring instruction (DO NOT modify MLFitnessApplication.kt directly):
//
//   In MLFitnessApplication.kt add:
//       @Inject lateinit var billing: BillingManager
//   then inside onCreate():
//       billing.connect()
//
// Hilt will handle injection because the class is @Singleton and the
// Application is annotated @HiltAndroidApp.
// ---------------------------------------------------------------------------

import android.app.Activity
import android.content.Context
import android.util.Log
import com.android.billingclient.api.*
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

/** Connection state of the underlying BillingClient. */
enum class ConnectionState { Disconnected, Connecting, Connected, Error }

@Singleton
class BillingManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val prefs: PreferencesManager
) : PurchasesUpdatedListener {

    companion object {
        const val PRO_PRODUCT_ID = "com.mochasmindlab.mlhealth.pro"
        private const val TAG = "BillingManager"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    // ---- Public state flows ------------------------------------------------

    private val _connectionState = MutableStateFlow(ConnectionState.Disconnected)
    val connectionState: StateFlow<ConnectionState> = _connectionState.asStateFlow()

    private val _proProductDetails = MutableStateFlow<ProductDetails?>(null)
    val proProductDetails: StateFlow<ProductDetails?> = _proProductDetails.asStateFlow()

    /**
     * Combined Pro entitlement: true when the DataStore cache says so (instant,
     * no billing round-trip) OR when billing has verified it this session.
     * The DataStore value is updated on every successful purchase/restore, so
     * the two signals converge quickly.
     */
    private val _isProUser = MutableStateFlow(false)
    val isProUser: StateFlow<Boolean> = _isProUser.asStateFlow()

    // ---- BillingClient -----------------------------------------------------

    private val billingClient: BillingClient = BillingClient.newBuilder(context)
        .setListener(this)
        .enablePendingPurchases(
            // Billing 7 removed the no-arg overload; one-time products must be opted in.
            PendingPurchasesParams.newBuilder()
                .enableOneTimeProducts()
                .build()
        )
        .build()

    init {
        // Seed from DataStore immediately so UI shows correct state before
        // the billing client has connected.
        scope.launch {
            _isProUser.value = prefs.isProUser.first()
            // Keep the StateFlow in sync with DataStore if it changes
            // (e.g. another session updated it).
            prefs.isProUser.collect { cached ->
                if (cached && !_isProUser.value) {
                    _isProUser.value = true
                }
            }
        }
    }

    // ---- Connection --------------------------------------------------------

    /**
     * Idempotent. Safe to call multiple times — no-ops if already
     * Connecting or Connected.
     */
    fun connect() {
        if (_connectionState.value == ConnectionState.Connecting ||
            _connectionState.value == ConnectionState.Connected
        ) return

        _connectionState.value = ConnectionState.Connecting

        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    Log.d(TAG, "Billing connected")
                    _connectionState.value = ConnectionState.Connected
                    // Sync entitlements and load product details on connection.
                    scope.launch {
                        syncPurchases()
                        queryProProduct()
                    }
                } else {
                    Log.e(TAG, "Billing setup failed: ${result.debugMessage}")
                    _connectionState.value = ConnectionState.Error
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.w(TAG, "Billing service disconnected")
                _connectionState.value = ConnectionState.Disconnected
            }
        })
    }

    // ---- Product query -----------------------------------------------------

    /** Fetches ProductDetails for the single Pro SKU. */
    suspend fun queryProProduct() {
        if (!billingClient.isReady) {
            Log.w(TAG, "queryProProduct called before billing client is ready")
            return
        }

        val params = QueryProductDetailsParams.newBuilder()
            .setProductList(
                listOf(
                    QueryProductDetailsParams.Product.newBuilder()
                        .setProductId(PRO_PRODUCT_ID)
                        .setProductType(BillingClient.ProductType.INAPP)
                        .build()
                )
            )
            .build()

        val result = billingClient.queryProductDetails(params)
        if (result.billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
            val details = result.productDetailsList?.firstOrNull()
            _proProductDetails.value = details
            Log.d(TAG, "Product details loaded: ${details?.title} @ ${details?.oneTimePurchaseOfferDetails?.formattedPrice}")
        } else {
            Log.e(TAG, "queryProductDetails failed: ${result.billingResult.debugMessage}")
        }
    }

    // ---- Purchase ----------------------------------------------------------

    /**
     * Launches the Play Billing purchase flow.
     * Must be called from UI code — [activity] is the foreground Activity.
     */
    fun launchPurchaseFlow(activity: Activity) {
        val details = _proProductDetails.value
        if (details == null) {
            Log.e(TAG, "launchPurchaseFlow: product details not loaded yet")
            return
        }

        val offerToken = details.oneTimePurchaseOfferDetails?.let {
            // oneTimePurchaseOfferDetails has no offerToken; use productDetails directly.
            null
        }

        val productDetailsParams = BillingFlowParams.ProductDetailsParams.newBuilder()
            .setProductDetails(details)
            .apply { offerToken?.let { setOfferToken(it) } }
            .build()

        val flowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(listOf(productDetailsParams))
            .build()

        val result = billingClient.launchBillingFlow(activity, flowParams)
        if (result.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, "launchBillingFlow failed: ${result.debugMessage}")
        }
    }

    // ---- PurchasesUpdatedListener ------------------------------------------

    override fun onPurchasesUpdated(result: BillingResult, purchases: List<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> {
                purchases?.forEach { purchase ->
                    scope.launch { handlePurchase(purchase) }
                }
            }
            BillingClient.BillingResponseCode.USER_CANCELED -> {
                Log.d(TAG, "Purchase cancelled by user")
            }
            else -> {
                Log.e(TAG, "Purchase error: ${result.debugMessage}")
            }
        }
    }

    // ---- Restore -----------------------------------------------------------

    /** Queries Google Play for existing INAPP purchases and syncs entitlement. */
    suspend fun restorePurchases() {
        if (!billingClient.isReady) {
            connect()
            return
        }
        syncPurchases()
    }

    // ---- Internal helpers --------------------------------------------------

    private suspend fun syncPurchases() {
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.INAPP)
            .build()

        val result = billingClient.queryPurchasesAsync(params)
        if (result.billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
            val proPurchase = result.purchasesList.firstOrNull { purchase ->
                purchase.products.contains(PRO_PRODUCT_ID) &&
                    purchase.purchaseState == Purchase.PurchaseState.PURCHASED
            }
            if (proPurchase != null) {
                handlePurchase(proPurchase)
            } else {
                // No active entitlement on Play — keep DataStore as ground truth
                // (don't revoke here; only Play's own revocation should do that).
                Log.d(TAG, "No active Pro purchase found in Play account")
            }
        } else {
            Log.e(TAG, "queryPurchasesAsync failed: ${result.billingResult.debugMessage}")
        }
    }

    private suspend fun handlePurchase(purchase: Purchase) {
        if (!purchase.products.contains(PRO_PRODUCT_ID)) return
        if (purchase.purchaseState != Purchase.PurchaseState.PURCHASED) return

        // Acknowledge if needed (non-consumable INAPP must be acknowledged within 3 days).
        if (!purchase.isAcknowledged) {
            acknowledgePurchase(purchase)
        }

        // Grant entitlement locally.
        prefs.setProUser(true)
        _isProUser.value = true
        Log.d(TAG, "Pro entitlement granted and cached")
    }

    /** Acknowledges a verified purchase. */
    suspend fun acknowledgePurchase(purchase: Purchase) {
        val params = AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(purchase.purchaseToken)
            .build()
        val result = billingClient.acknowledgePurchase(params)
        if (result.responseCode == BillingClient.BillingResponseCode.OK) {
            Log.d(TAG, "Purchase acknowledged: ${purchase.orderId}")
        } else {
            Log.e(TAG, "Acknowledge failed: ${result.debugMessage}")
        }
    }
}
