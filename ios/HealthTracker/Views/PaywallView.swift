import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.wellnessGreen)

                        Text("ML Fitness Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Unlock the full power of your health journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Feature list
                    VStack(alignment: .leading, spacing: 16) {
                        ProFeatureRow(icon: "camera.fill", title: "AI Food Scanner", description: "Snap a photo to identify meals instantly")
                        ProFeatureRow(icon: "barcode.viewfinder", title: "Barcode Scanner", description: "Scan product barcodes for nutrition info")
                        ProFeatureRow(icon: "calendar", title: "Full Meal Plan Library", description: "All 8 diets with complete weekly plans")
                        ProFeatureRow(icon: "timer", title: "Fasting Timer", description: "Intermittent fasting tracking & insights")
                        ProFeatureRow(icon: "pills.fill", title: "Supplement Tracking", description: "Track vitamins, minerals & supplements")
                        ProFeatureRow(icon: "cart.fill", title: "Grocery List Generator", description: "Auto-generate lists from your meal plans")
                        ProFeatureRow(icon: "heart.fill", title: "HealthKit Sync", description: "Sync with Apple Health for complete data")
                        ProFeatureRow(icon: "chart.bar.fill", title: "Advanced Analytics", description: "Deep insights into your nutrition trends")
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)

                    // Price and purchase
                    VStack(spacing: 12) {
                        Text("One-time purchase")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: {
                            Task { await storeManager.purchase() }
                        }) {
                            Group {
                                if storeManager.purchaseState == .purchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Upgrade for \(storeManager.proPriceDisplay)")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(storeManager.purchaseState == .purchasing)

                        Button("Restore Purchases") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.subheadline)
                        .foregroundColor(.mindfulTeal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert(alertTitle, isPresented: showingAlert) {
                Button("OK") {
                    if storeManager.purchaseState == .purchased || storeManager.purchaseState == .restored {
                        dismiss()
                    }
                    storeManager.resetPurchaseState()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var showingAlert: Binding<Bool> {
        Binding(
            get: {
                switch storeManager.purchaseState {
                case .purchased, .restored, .failed:
                    return true
                default:
                    return false
                }
            },
            set: { _ in }
        )
    }

    private var alertTitle: String {
        switch storeManager.purchaseState {
        case .purchased:
            return "Welcome to Pro!"
        case .restored:
            return "Purchase Restored"
        case .failed:
            return "Error"
        default:
            return ""
        }
    }

    private var alertMessage: String {
        switch storeManager.purchaseState {
        case .purchased:
            return "All Pro features are now unlocked. Enjoy!"
        case .restored:
            return "Your Pro purchase has been restored."
        case .failed(let message):
            return message
        default:
            return ""
        }
    }
}

// MARK: - Feature Row
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.wellnessGreen)
                .frame(width: 36, height: 36)
                .background(Color.wellnessGreen.opacity(0.15))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.wellnessGreen)
        }
    }
}
