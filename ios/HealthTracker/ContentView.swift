import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showingAddMenu = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ProfessionalDashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(0)
                
                DiaryView()
                    .tabItem {
                        Label("Diary", systemImage: "book.fill")
                    }
                    .tag(1)
                
                Text("")
                    .tabItem {
                        Label("", systemImage: "plus.circle.fill")
                    }
                    .tag(2)
                
                MealPlanningView()
                    .tabItem {
                        Label("Plan", systemImage: "calendar")
                    }
                    .tag(3)
                
                MoreView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                    .tag(4)
            }
            .accentColor(.mochaBrown)
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
                    achievement: achievement,
                    isShowing: $achievementManager.showingCelebration
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .environmentObject(achievementManager)
        .sheet(isPresented: $showingAddMenu) {
            AddMenuView(selectedDate: Date())
        }
    }
}