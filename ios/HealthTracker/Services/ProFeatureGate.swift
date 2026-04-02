import SwiftUI

/// Wraps premium content behind a Pro check.
/// If the user is Pro, shows the content. Otherwise shows a locked overlay.
struct ProFeatureGate<Content: View>: View {
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingPaywall = false
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    private var isUnlocked: Bool { storeManager.isPro || TrialManager.shared.isTrialActive }

    var body: some View {
        if isUnlocked {
            content()
        } else {
            LockedFeatureView(showingPaywall: $showingPaywall)
                .sheet(isPresented: $showingPaywall) {
                    PaywallView()
                        .environmentObject(storeManager)
                }
        }
    }
}

/// A placeholder view shown when a feature is locked.
struct LockedFeatureView: View {
    @Binding var showingPaywall: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("Pro Feature")
                .font(.title2)
                .fontWeight(.bold)

            Text("Upgrade to MindLab Fitness Pro to access this feature.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { showingPaywall = true }) {
                Text("Upgrade to Pro")
                    .fontWeight(.semibold)
                    .frame(width: 200)
                    .padding()
                    .background(Color.wellnessGreen)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }

            Spacer()
        }
    }
}

/// View modifier for inline pro gating — hides/replaces a single element.
struct ProGateModifier: ViewModifier {
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingPaywall = false

    private var isUnlocked: Bool { storeManager.isPro || TrialManager.shared.isTrialActive }

    func body(content: Content) -> some View {
        if isUnlocked {
            content
        } else {
            Button(action: { showingPaywall = true }) {
                content
                    .overlay(
                        ZStack {
                            Color(UIColor.systemBackground).opacity(0.7)
                            VStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.title3)
                                Text("Pro")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.secondary)
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
        }
    }
}

extension View {
    /// Apply an inline pro lock overlay to any view.
    func requiresPro() -> some View {
        modifier(ProGateModifier())
    }
}
