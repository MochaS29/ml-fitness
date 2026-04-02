import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showingAddMenu = false
    @State private var notificationAction: NotificationAction?
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingPaywall = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView()
                }
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

                NavigationStack {
                    DiaryView()
                }
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
                .tag(1)

                Text("")
                    .tabItem {
                        Label("", systemImage: "plus.circle.fill")
                    }
                    .tag(2)

                NavigationStack {
                    EnhancedMealPlanningView()
                        .overlay(alignment: .top) {
                            if !storeManager.isPro {
                                ProUpgradeBanner(showingPaywall: $showingPaywall)
                            }
                        }
                }
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
                .tag(3)

                NavigationStack {
                    MoreView()
                }
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(4)
            }
            .accentColor(.mochaBrown)
            // Force tab bar to be visible on iPad
            .tabViewStyle(.automatic)
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 2 {
                    // Reset to previous tab and show add menu
                    selectedTab = 0
                    showingAddMenu = true
                }
            }
            
        }
        .environmentObject(achievementManager)
        .withCelebrations(context: viewContext)  // Add celebration detection
        .sheet(isPresented: $showingAddMenu) {
            AddMenuView(selectedDate: Date())
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
        .onAppear {
            setupNotificationObservers()
        }
    }
    
    private func setupNotificationObservers() {
        // Handle meal logging notification
        NotificationCenter.default.addObserver(
            forName: .openMealLogging,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1 // Go to Diary tab
            showingAddMenu = true
        }
        
        // Handle water logging notification
        NotificationCenter.default.addObserver(
            forName: .openWaterLogging,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1 // Go to Diary tab
        }
        
        // Handle exercise logging notification
        NotificationCenter.default.addObserver(
            forName: .openExerciseLogging,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1 // Go to Diary tab
        }
    }
}

// MARK: - Pro Upgrade Banner
struct ProUpgradeBanner: View {
    @Binding var showingPaywall: Bool

    var body: some View {
        Button(action: { showingPaywall = true }) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.caption)
                Text("Free Preview")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("Upgrade for full access")
                    .font(.caption)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.wellnessGreen.opacity(0.9))
        }
    }
}

enum NotificationAction {
    case openMealLogging(MealType)
    case openWaterLogging
    case openExerciseLogging
    case openSupplementLogging
}