import SwiftUI
import CoreData

// Option 1: Minimalist Card-Based Dashboard
struct DashboardOption1View: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var greeting = ""
    @State private var selectedPeriod = "Today"
    @State private var showingAddMenu = false
    @State private var showingDishScanner = false
    @State private var showingFastingTimer = false
    @State private var showingSupplements = false
    @State private var showingBarcodeScanner = false
    
    // Fetch today's data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysFoodEntries: FetchedResults<FoodEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysExerciseEntries: FetchedResults<ExerciseEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate)
    ) private var todaysWaterEntries: FetchedResults<WaterEntry>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Greeting Header
                    headerSection
                    
                    // Main Metrics Cards
                    metricsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                updateGreeting()
            }
        }
        .sheet(isPresented: $showingAddMenu) {
            AddMenuView(selectedDate: Date())
        }
        .sheet(isPresented: $showingDishScanner) {
            NavigationView {
                DishScannerView()
            }
        }
        .sheet(isPresented: $showingFastingTimer) {
            NavigationView {
                IntermittentFastingView()
            }
        }
        .sheet(isPresented: $showingSupplements) {
            NavigationView {
                SupplementTrackingView()
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            BarcodeScannerView(selectedDate: Date(), mealType: .snack)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Let's make today count!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var metricsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MetricCard(
                    title: "Calories",
                    value: "0",
                    goal: "2000",
                    icon: "flame.fill",
                    color: Color(red: 255/255, green: 149/255, blue: 0/255)
                )
                
                MetricCard(
                    title: "Exercise",
                    value: "0",
                    goal: "30 min",
                    icon: "figure.run",
                    color: Color(red: 52/255, green: 199/255, blue: 89/255)
                )
            }
            
            HStack(spacing: 16) {
                MetricCard(
                    title: "Protein",
                    value: "0",
                    goal: "50g",
                    icon: "leaf.fill",
                    color: Color(red: 0/255, green: 122/255, blue: 255/255)
                )
                
                NavigationLink(destination: WaterTrackingView()) {
                    MetricCard(
                        title: "Water",
                        value: "0",
                        goal: "8 cups",
                        icon: "drop.fill",
                        color: .blue
                    )
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "plus.circle.fill",
                        title: "Log Food",
                        color: Color(red: 255/255, green: 149/255, blue: 0/255)
                    ) {
                        showingAddMenu = true
                    }
                    
                    QuickActionButton(
                        icon: "barcode.viewfinder",
                        title: "Scan Barcode",
                        color: Color(red: 147/255, green: 112/255, blue: 219/255)
                    ) {
                        showingBarcodeScanner = true
                    }
                    
                    QuickActionButton(
                        icon: "camera.fill",
                        title: "Scan Dish",
                        color: Color(red: 52/255, green: 199/255, blue: 89/255)
                    ) {
                        showingDishScanner = true
                    }
                    
                    QuickActionButton(
                        icon: "timer",
                        title: "Fasting",
                        color: Color(red: 0/255, green: 122/255, blue: 255/255)
                    ) {
                        showingFastingTimer = true
                    }
                    
                    QuickActionButton(
                        icon: "pills.fill",
                        title: "Supplements",
                        color: Color(red: 88/255, green: 86/255, blue: 214/255)
                    ) {
                        showingSupplements = true
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: DiaryView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 12) {
                if todaysFoodEntries.isEmpty && todaysExerciseEntries.isEmpty {
                    EmptyActivityCard()
                } else {
                    ForEach(todaysFoodEntries.prefix(3)) { entry in
                        RecentActivityRow(
                            icon: "fork.knife",
                            title: entry.name ?? "Food",
                            subtitle: "\(Int(entry.calories)) cal",
                            time: entry.timestamp ?? Date(),
                            color: Color(red: 255/255, green: 149/255, blue: 0/255)
                        )
                    }
                    
                    ForEach(todaysExerciseEntries.prefix(2)) { entry in
                        RecentActivityRow(
                            icon: "figure.run",
                            title: entry.name ?? "Exercise",
                            subtitle: "\(entry.duration) min",
                            time: entry.timestamp ?? Date(),
                            color: Color(red: 52/255, green: 199/255, blue: 89/255)
                        )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userProfileManager.currentProfile?.name.components(separatedBy: " ").first ?? "there"
        
        switch hour {
        case 0..<12:
            greeting = "Good morning, \(name)!"
        case 12..<17:
            greeting = "Good afternoon, \(name)!"
        default:
            greeting = "Good evening, \(name)!"
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let goal: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Goal: \(goal)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 90, height: 90)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

struct RecentActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: Date
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyActivityCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No activity yet today")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Start by logging your breakfast!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// #Preview {
//     DashboardOption1View()
//         .environmentObject(UserProfileManager())
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }