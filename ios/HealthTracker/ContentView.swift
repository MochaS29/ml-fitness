import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showingAddMenu = false
    @State private var notificationAction: NotificationAction?

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
            
            // Celebration overlay
            if achievementManager.showingCelebration,
               let achievement = achievementManager.currentCelebration {
                CelebrationView(
                    achievement: CelebrationAchievement.from(achievement),
                    isPresented: $achievementManager.showingCelebration
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .environmentObject(achievementManager)
        .withCelebrations(context: viewContext)  // Add celebration detection
        .sheet(isPresented: $showingAddMenu) {
            AddMenuView(selectedDate: Date())
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

enum NotificationAction {
    case openMealLogging(MealType)
    case openWaterLogging
    case openExerciseLogging
    case openSupplementLogging
}