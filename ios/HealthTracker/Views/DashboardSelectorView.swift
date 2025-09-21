import SwiftUI

struct DashboardSelectorView: View {
    @AppStorage("selectedDashboard") private var selectedDashboard = 1
    @AppStorage("hasSelectedDashboard") private var hasSelectedDashboard = false
    @State private var showingSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Preview of selected dashboard
                Group {
                    switch selectedDashboard {
                    case 1:
                        DashboardOption1View()
                    case 2:
                        DashboardOption2View()
                    case 3:
                        DashboardOption3View()
                    case 4:
                        DashboardOption4View()
                    case 5:
                        HybridDashboardView()
                    default:
                        DashboardOption1View()
                    }
                }
                
                // Floating button to show selector
                if hasSelectedDashboard && !showingSelector {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring()) {
                                    showingSelector = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.grid.2x2")
                                    Text("Change Style")
                                }
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            .padding()
                        }
                    }
                }
                
                // Dashboard selector overlay
                if !hasSelectedDashboard || showingSelector {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Choose Your Dashboard Style")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if showingSelector && hasSelectedDashboard {
                                    Button("Done") {
                                        withAnimation(.spring()) {
                                            showingSelector = false
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    DashboardOption(
                                        number: 1,
                                        title: "Minimalist",
                                        description: "Clean card-based design with quick actions",
                                        icon: "square.grid.2x2",
                                        color: .orange,
                                        isSelected: selectedDashboard == 1
                                    ) {
                                        selectDashboard(1)
                                    }
                                    
                                    DashboardOption(
                                        number: 2,
                                        title: "Health Rings",
                                        description: "Apple Health inspired activity rings",
                                        icon: "circle.circle",
                                        color: .green,
                                        isSelected: selectedDashboard == 2
                                    ) {
                                        selectDashboard(2)
                                    }
                                    
                                    DashboardOption(
                                        number: 3,
                                        title: "Data Focus",
                                        description: "Detailed stats and analytics view",
                                        icon: "chart.bar.fill",
                                        color: .blue,
                                        isSelected: selectedDashboard == 3
                                    ) {
                                        selectDashboard(3)
                                    }
                                    
                                    DashboardOption(
                                        number: 4,
                                        title: "AI Insights",
                                        description: "Personalized recommendations and insights",
                                        icon: "brain",
                                        color: .purple,
                                        isSelected: selectedDashboard == 4
                                    ) {
                                        selectDashboard(4)
                                    }
                                    
                                    DashboardOption(
                                        number: 5,
                                        title: "Hybrid Pro",
                                        description: "Best of data analytics + AI insights",
                                        icon: "sparkles.rectangle.stack",
                                        color: .indigo,
                                        isSelected: selectedDashboard == 5
                                    ) {
                                        selectDashboard(5)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                        .transition(.move(edge: .bottom))
                    }
                    .animation(.spring(), value: showingSelector)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func selectDashboard(_ number: Int) {
        selectedDashboard = number
        if !hasSelectedDashboard {
            hasSelectedDashboard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    showingSelector = false
                }
            }
        }
    }
}

struct DashboardOption: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? color : Color(UIColor.secondarySystemGroupedBackground))
                        .frame(width: 140, height: 100)
                    
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(isSelected ? .white : color)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? color : .primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(width: 140)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 3)
            )
        }
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// #Preview {
//     DashboardSelectorView()
//         .environmentObject(UserProfileManager())
//         .environmentObject(AchievementManager())
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }