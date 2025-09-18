import SwiftUI

struct SupplementStatsWidget: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileManager: UserProfileManager
    @Binding var showingDetail: Bool
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SupplementEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.startOfDay(for: Date()) as NSDate)
    ) private var todaysSupplements: FetchedResults<SupplementEntry>
    
    var topNutrients: [(name: String, percentage: Int)] {
        guard let profile = profileManager.currentProfile else { return [] }
        
        var nutrientTotals: [String: Double] = [:]
        
        // Aggregate nutrients from all supplements
        for supplement in todaysSupplements {
            if let nutrients = supplement.nutrients {
                for (nutrientId, amount) in nutrients {
                    nutrientTotals[nutrientId, default: 0] += amount
                }
            }
        }
        
        // Calculate percentages and get top 3
        var percentages: [(name: String, percentage: Int)] = []
        
        for (nutrientId, amount) in nutrientTotals {
            if let rda = RDADatabase.shared.getRDA(for: nutrientId, profile: profile) {
                let percentage = Int((amount / rda.amount) * 100)
                if let nutrient = RDADatabase.shared.getAllNutrients().first(where: { $0.nutrientId == nutrientId }) {
                    percentages.append((name: nutrient.name, percentage: percentage))
                }
            }
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

#Preview {
    SupplementStatsWidget(showingDetail: .constant(false))
        .environmentObject(UserProfileManager())
}