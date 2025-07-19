import SwiftUI

struct DashboardSelectorView: View {
    @AppStorage("selectedDashboard") private var selectedDashboard = 1
    @State private var showingPreview = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                    default:
                        ProfessionalDashboardView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Dashboard selector
                VStack(spacing: 16) {
                    Text("Choose Your Dashboard Style")
                        .font(.headline)
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
                                selectedDashboard = 1
                            }
                            
                            DashboardOption(
                                number: 2,
                                title: "Health Rings",
                                description: "Apple Health inspired activity rings",
                                icon: "circle.circle",
                                color: .green,
                                isSelected: selectedDashboard == 2
                            ) {
                                selectedDashboard = 2
                            }
                            
                            DashboardOption(
                                number: 3,
                                title: "Data Focus",
                                description: "Detailed stats and analytics view",
                                icon: "chart.bar.fill",
                                color: .blue,
                                isSelected: selectedDashboard == 3
                            ) {
                                selectedDashboard = 3
                            }
                            
                            DashboardOption(
                                number: 4,
                                title: "AI Insights",
                                description: "Personalized recommendations and insights",
                                icon: "brain",
                                color: .purple,
                                isSelected: selectedDashboard == 4
                            ) {
                                selectedDashboard = 4
                            }
                            
                            DashboardOption(
                                number: 0,
                                title: "Original",
                                description: "Professional fitness app style",
                                icon: "sparkles",
                                color: Color(red: 139/255, green: 69/255, blue: 19/255),
                                isSelected: selectedDashboard == 0
                            ) {
                                selectedDashboard = 0
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationBarHidden(true)
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

#Preview {
    DashboardSelectorView()
        .environmentObject(UserProfileManager())
        .environmentObject(AchievementManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}