import SwiftUI

enum PaywallTrigger {
    case mealScanner   // came from scanner — lead with scanner hero
    case mealPlan      // came from meal plan lock
    case general       // general upgrade tap
}

struct PaywallView: View {
    var trigger: PaywallTrigger = .general
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Hero
                    heroSection

                    // MARK: Social proof strip
                    HStack(spacing: 24) {
                        ProStat(value: "400+", label: "Recipes")
                        Divider().frame(height: 28)
                        ProStat(value: "8", label: "Diet plans")
                        Divider().frame(height: 28)
                        ProStat(value: "AI", label: "Meal scanner")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color(.secondarySystemBackground))

                    // MARK: Feature list
                    VStack(alignment: .leading, spacing: 14) {
                        ProFeatureRow(
                            icon: "camera.fill",
                            title: "AI Meal Scanner — unlimited",
                            description: "Point your camera at any meal. AI identifies every ingredient and logs macros instantly.",
                            highlight: trigger == .mealScanner
                        )
                        ProFeatureRow(
                            icon: "calendar",
                            title: "Full Meal Plan Library",
                            description: "All 8 diets · 4 weeks each · 400 recipes with grocery lists",
                            highlight: trigger == .mealPlan
                        )
                        ProFeatureRow(
                            icon: "barcode.viewfinder",
                            title: "Barcode Scanner",
                            description: "Scan any product barcode for instant nutrition info"
                        )
                        ProFeatureRow(
                            icon: "timer",
                            title: "Intermittent Fasting Timer",
                            description: "16:8, OMAD, 5:2 and custom fasting schedules"
                        )
                        ProFeatureRow(
                            icon: "chart.bar.fill",
                            title: "Advanced Analytics",
                            description: "Week & month nutrition trends, macro breakdowns, progress charts"
                        )
                        ProFeatureRow(
                            icon: "heart.fill",
                            title: "Apple Health Sync",
                            description: "Two-way sync with Apple Health for complete data"
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)

                    // MARK: CTA
                    VStack(spacing: 10) {
                        Button(action: {
                            Task { await storeManager.purchase() }
                        }) {
                            Group {
                                if storeManager.purchaseState == .purchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    VStack(spacing: 2) {
                                        Text("Upgrade to Pro · \(storeManager.proPriceDisplay)")
                                            .fontWeight(.bold)
                                        Text("One-time purchase · no subscription")
                                            .font(.caption)
                                            .opacity(0.85)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
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

    // MARK: - Hero section

    @ViewBuilder
    private var heroSection: some View {
        switch trigger {
        case .mealScanner:
            scannerHero
        case .mealPlan:
            mealPlanHero
        case .general:
            generalHero
        }
    }

    private var scannerHero: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [Color.mindfulTeal.opacity(0.85), Color.wellnessGreen.opacity(0.85)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)

                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                    Text("Point. Shoot. Logged.")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("AI identifies every ingredient in seconds")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Text("You've used your 3 free scans")
                .font(.headline)
            Text("Upgrade once to scan unlimited meals forever.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 8)
    }

    private var mealPlanHero: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 64))
                .foregroundColor(.wellnessGreen)
                .padding(.top, 28)
            Text("400 Recipes. 8 Diets.")
                .font(.title2.bold())
            Text("Unlock the complete 4-week meal plan library.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 8)
    }

    private var generalHero: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.wellnessGreen)
                .padding(.top, 28)
            Text("MindLab Fitness Pro")
                .font(.title2.bold())
            Text("The AI-powered nutrition coach in your pocket.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Alert helpers

    private var showingAlert: Binding<Bool> {
        Binding(
            get: {
                switch storeManager.purchaseState {
                case .purchased, .restored, .failed: return true
                default: return false
                }
            },
            set: { _ in }
        )
    }

    private var alertTitle: String {
        switch storeManager.purchaseState {
        case .purchased: return "Welcome to Pro!"
        case .restored: return "Purchase Restored"
        case .failed: return "Error"
        default: return ""
        }
    }

    private var alertMessage: String {
        switch storeManager.purchaseState {
        case .purchased: return "All Pro features are now unlocked. Enjoy!"
        case .restored: return "Your Pro purchase has been restored."
        case .failed(let message): return message
        default: return ""
        }
    }
}

// MARK: - Supporting views

private struct ProStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.wellnessGreen)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    var highlight: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(highlight ? .white : .wellnessGreen)
                .frame(width: 36, height: 36)
                .background(highlight ? Color.wellnessGreen : Color.wellnessGreen.opacity(0.15))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(highlight ? 10 : 0)
        .background(highlight ? Color.wellnessGreen.opacity(0.08) : Color.clear)
        .cornerRadius(10)
    }
}
