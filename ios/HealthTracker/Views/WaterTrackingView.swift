import SwiftUI
import CoreData

struct WaterTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                             Calendar.current.startOfDay(for: Date()) as NSDate,
                             Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate),
        animation: .default)
    private var todayWaterEntries: FetchedResults<WaterEntry>
    
    @State private var waterGoal: Int = 8 // 8 glasses of 8oz each
    @State private var showingAddCustom = false
    @State private var customAmount: String = ""
    
    var totalOuncesToday: Double {
        todayWaterEntries.reduce(0) { $0 + $1.amount }
    }
    
    var glassesConsumed: Int {
        Int(totalOuncesToday / 8)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Water Intake")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    
                    Text("Stay hydrated throughout the day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.lightGray.opacity(0.3), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: min(totalOuncesToday / (Double(waterGoal) * 8), 1.0))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: totalOuncesToday)
                    
                    VStack(spacing: 8) {
                        Text("\(Int(totalOuncesToday))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("oz")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("\(glassesConsumed) / \(waterGoal) glasses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 20)
                
                // Quick Add Droplets
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Add")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Water droplet grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                        ForEach(0..<waterGoal, id: \.self) { index in
                            WaterDroplet(
                                isFilled: index < glassesConsumed,
                                onTap: {
                                    if index < glassesConsumed {
                                        // Remove the last entry if tapping a filled glass
                                        removeLastWaterEntry()
                                    } else if index == glassesConsumed {
                                        // Add new water entry
                                        addWaterEntry(amount: 8)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Custom amounts
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach([8, 12, 16, 20, 24, 32], id: \.self) { amount in
                                Button(action: {
                                    addWaterEntry(amount: Double(amount))
                                }) {
                                    Text("\(amount) oz")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }

                            Button(action: { showingAddCustom = true }) {
                                Label("Custom", systemImage: "plus.circle")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Today's Log
                if !todayWaterEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Log")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(todayWaterEntries) { entry in
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(.blue)
                                    
                                    Text("\(Int(entry.amount)) oz")
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    if let timestamp = entry.timestamp {
                                        Text(timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Button(action: {
                                        deleteWaterEntry(entry)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                        .background(Color.lightGray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hydration Tips")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HydrationTip(icon: "sunrise.fill", text: "Start your day with a glass of water")
                        HydrationTip(icon: "fork.knife", text: "Drink water before each meal")
                        HydrationTip(icon: "figure.walk", text: "Hydrate before, during, and after exercise")
                        HydrationTip(icon: "moon.fill", text: "Keep water by your bedside")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Hydration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Add Custom Amount", isPresented: $showingAddCustom) {
            TextField("Amount (oz)", text: $customAmount)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) {
                customAmount = ""
            }
            Button("Add") {
                if let amount = Double(customAmount), amount > 0 {
                    addWaterEntry(amount: amount)
                    customAmount = ""
                }
            }
        } message: {
            Text("Enter the amount of water in ounces")
        }
        }
    }
    
    private func addWaterEntry(amount: Double) {
        let entry = WaterEntry(context: viewContext)
        entry.id = UUID()
        entry.amount = amount
        entry.timestamp = Date()
        entry.unit = "oz"
        
        do {
            try viewContext.save()
            
            // Update goals based on the new water entry
            GoalsManager.shared.updateGoalsFromWaterEntry(entry)
        } catch {
            print("Error saving water entry: \(error)")
        }
    }
    
    private func removeLastWaterEntry() {
        guard let lastEntry = todayWaterEntries.first else { return }
        deleteWaterEntry(lastEntry)
    }
    
    private func deleteWaterEntry(_ entry: WaterEntry) {
        viewContext.delete(entry)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting water entry: \(error)")
        }
    }
}

struct WaterDroplet: View {
    let isFilled: Bool
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            onTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }) {
            ZStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isFilled ? .blue : Color.lightGray.opacity(0.3))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                
                if isFilled {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HydrationTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// #Preview {
//     WaterTrackingView()
//         .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
// }