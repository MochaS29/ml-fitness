import SwiftUI
import WatchKit

struct QuickLogView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var selectedCategory = 0
    @State private var showingSuccess = false
    @State private var lastAddedItem = ""

    let categories = ["Meals", "Snacks", "Drinks"]

    let quickFoods = [
        "Meals": [
            ("Breakfast", 350),
            ("Lunch", 550),
            ("Dinner", 650),
            ("Small Meal", 400)
        ],
        "Snacks": [
            ("Apple", 95),
            ("Banana", 105),
            ("Protein Bar", 200),
            ("Nuts", 170)
        ],
        "Drinks": [
            ("Coffee", 5),
            ("Protein Shake", 150),
            ("Juice", 110),
            ("Smoothie", 250)
        ]
    ]

    var body: some View {
        VStack(spacing: 10) {
            Text("Quick Log")
                .font(.title3)
                .bold()

            Picker("Category", selection: $selectedCategory) {
                ForEach(0..<categories.count, id: \.self) { index in
                    Text(categories[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(quickFoods[categories[selectedCategory]] ?? [], id: \.0) { item in
                        Button(action: {
                            logFood(name: item.0, calories: item.1)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.0)
                                        .font(.footnote)
                                        .bold()
                                    Text("\(item.1) cal")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.body)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .overlay(
            Group {
                if showingSuccess {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("Added!")
                            .font(.caption)
                            .bold()
                        Text(lastAddedItem)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }

    private func logFood(name: String, calories: Int) {
        connectivity.sendQuickFoodEntry(name: name, calories: calories)
        connectivity.currentCalories += Double(calories)
        lastAddedItem = "\(name) - \(calories) cal"

        withAnimation {
            showingSuccess = true
        }

        WKInterfaceDevice.current().play(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSuccess = false
            }
        }
    }
}

import WatchKit

#Preview {
    QuickLogView()
        .environmentObject(WatchConnectivityManager())
}