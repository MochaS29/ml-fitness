import SwiftUI

struct SupplementStatsWidget: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileManager: UserProfileManager
    @Binding var showingDetail: Bool

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.startOfDay(for: Date()) as NSDate),
        animation: nil  // Disable animation to prevent UI updates
    ) private var todaysSupplements: FetchedResults<SupplementEntry>
    
    var topNutrients: [(name: String, percentage: Int)] {
        guard let profile = profileManager.currentProfile else { return [] }

        // Limit processing to prevent memory issues
        let supplementsToProcess = Array(todaysSupplements.prefix(5))  // Reduced from 10

        var nutrientTotals: [String: Double] = [:]

        // Aggregate nutrients from supplements (limited)
        for supplement in supplementsToProcess {
            if let nutrients = supplement.nutrients as? [String: Double] {
                for (nutrientId, amount) in nutrients.prefix(3) {  // Reduced from 5
                    nutrientTotals[nutrientId, default: 0] += amount
                }
            }
        }

        // Calculate percentages and get top 3
        var percentages: [(name: String, percentage: Int)] = []

        // Simple nutrient names without database lookup
        let simpleNames = [
            "vitamin_d": "Vitamin D",
            "vitamin_c": "Vitamin C",
            "vitamin_b12": "Vitamin B12",
            "iron": "Iron",
            "calcium": "Calcium",
            "magnesium": "Magnesium"
        ]

        for (nutrientId, amount) in nutrientTotals.prefix(3) {  // Reduced from 6
            let name = simpleNames[nutrientId] ?? nutrientId.capitalized
            let percentage = min(Int(amount), 200)  // Cap at 200% for safety
            percentages.append((name: name, percentage: percentage))
        }

        return Array(percentages.sorted { $0.percentage > $1.percentage }.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Supplements")
                        .font(.headline)
                    Text("\(todaysSupplements.count) taken today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingDetail = true
            }
            
            if !topNutrients.isEmpty {
                VStack(spacing: 6) {
                    ForEach(topNutrients, id: \.name) { nutrient in
                        HStack {
                            Text(nutrient.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(nutrient.percentage)%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(colorForPercentage(nutrient.percentage))
                        }
                    }
                }
            } else if todaysSupplements.isEmpty {
                Text("No supplements tracked today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
    }
    
    func colorForPercentage(_ percentage: Int) -> Color {
        if percentage < 50 {
            return .red
        } else if percentage < 90 {
            return .orange
        } else if percentage <= 110 {
            return .green
        } else {
            return .blue
        }
    }
}

// #Preview {
//     SupplementStatsWidget(showingDetail: .constant(false))
//         .environmentObject(UserProfileManager())
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }