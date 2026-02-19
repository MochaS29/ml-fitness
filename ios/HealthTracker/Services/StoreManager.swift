import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    nonisolated static let proProductID = "com.mochasmindlab.HealthTracker.pro"

    @Published private(set) var isPro: Bool = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchaseState: PurchaseState = .idle

    enum PurchaseState: Equatable {
        case idle
        case loading
        case purchasing
        case purchased
        case failed(String)
        case restored
    }

    private var transactionListener: Task<Void, Never>?

    init() {
        // Load cached state immediately
        isPro = UserDefaults.standard.bool(forKey: "isProUser")

        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Check entitlements and load products
        Task {
            await checkEntitlement()
            await loadProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            purchaseState = .loading
            products = try await Product.products(for: [Self.proProductID])
            purchaseState = .idle
        } catch {
            print("Failed to load products: \(error)")
            purchaseState = .failed("Failed to load products.")
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product = products.first else {
            purchaseState = .failed("Product not available.")
            return
        }

        do {
            purchaseState = .purchasing
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                setProStatus(true)
                purchaseState = .purchased

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            print("Purchase failed: \(error)")
            purchaseState = .failed("Purchase failed. Please try again.")
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        purchaseState = .loading
        // Sync with App Store to ensure latest transactions are available
        do {
            try await AppStore.sync()
        } catch {
            print("AppStore sync failed: \(error)")
        }
        await checkEntitlement()
        if isPro {
            purchaseState = .restored
        } else {
            purchaseState = .failed("No previous purchase found.")
        }
    }

    // MARK: - Check Entitlement

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.proProductID,
               transaction.revocationDate == nil {
                setProStatus(true)
                return
            }
        }
        // No valid entitlement found
        setProStatus(false)
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == StoreManager.proProductID {
                        if transaction.revocationDate != nil {
                            await self.setProStatus(false)
                        } else {
                            await self.setProStatus(true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func setProStatus(_ value: Bool) {
        isPro = value
        UserDefaults.standard.set(value, forKey: "isProUser")
    }

    /// Reset purchase state back to idle (e.g. after dismissing alert)
    func resetPurchaseState() {
        purchaseState = .idle
    }

    /// Price string for the Pro product, or a fallback
    var proPriceDisplay: String {
        products.first?.displayPrice ?? "$6.99"
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
