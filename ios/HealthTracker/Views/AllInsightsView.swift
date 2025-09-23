import SwiftUI

struct AllInsightsView: View {
    @Environment(\.dismiss) private var dismiss
    let insights: [AIInsight]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(insights) { insight in
                        InsightDetailCard(insight: insight)
                    }

                    if insights.isEmpty {
                        ContentUnavailableView(
                            "No Insights Available",
                            systemImage: "lightbulb.slash",
                            description: Text("Start tracking your activities to receive personalized insights")
                        )
                        .frame(minHeight: 400)
                    }
                }
                .padding()
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct InsightDetailCard: View {
    let insight: AIInsight

    var iconColor: Color {
        switch insight.icon {
        case "flame.fill":
            return .orange
        case "figure.walk":
            return .green
        case "drop.fill":
            return .blue
        case "scalemass.fill":
            return .purple
        case "sparkles":
            return .yellow
        case "moon.fill":
            return .indigo
        case "heart.fill":
            return .red
        default:
            return .mindfulTeal
        }
    }

    var categoryName: String {
        switch insight.icon {
        case "flame.fill":
            return "Nutrition"
        case "figure.walk":
            return "Activity"
        case "drop.fill":
            return "Hydration"
        case "scalemass.fill":
            return "Weight"
        case "sparkles":
            return "Achievement"
        case "moon.fill":
            return "Recovery"
        case "heart.fill":
            return "Exercise"
        default:
            return "Health"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(categoryName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Spacer()
            }

            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !insight.impact.isEmpty {
                Divider()

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)

                    Text(insight.impact)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }

            if insight.isNew {
                HStack {
                    Image(systemName: "sparkle")
                        .font(.caption)
                    Text("New Insight")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.mindfulTeal.opacity(0.2))
                .foregroundColor(.mindfulTeal)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AllInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        AllInsightsView(insights: [
            AIInsight(
                title: "Calorie Goal",
                description: "You're at 1500/2000 calories today",
                icon: "flame.fill",
                color: .orange,
                impact: "You have 500 calories remaining for dinner",
                isNew: true
            ),
            AIInsight(
                title: "Step Progress",
                description: "Great job! You've reached 75% of your step goal",
                icon: "figure.walk",
                color: .green,
                impact: "A 15-minute walk will help you reach your goal",
                isNew: false
            )
        ])
    }
}