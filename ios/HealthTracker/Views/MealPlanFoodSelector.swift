import SwiftUI

struct MealPlanFoodSelector: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = UnifiedDataManager.shared
    @Binding var selectedFoodItems: [FoodItem]
    let mealType: MealType

    @State private var searchText = ""
    @State private var tempSelectedItems: [FoodItem] = []
    @FocusState private var isSearchFocused: Bool

    var searchResults: [FoodItem] {
        if searchText.isEmpty {
            return []
        }
        return dataManager.searchFoodDatabase(searchText)
    }

    var recentFoods: [FoodItem] {
        return dataManager.getRecentFoods()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search foods...", text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Selected items count
                if !tempSelectedItems.isEmpty {
                    HStack {
                        Text("\(tempSelectedItems.count) items selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Clear All") {
                            tempSelectedItems.removeAll()
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // Results List
                List {
                    // Search Results or Recent Foods
                    if !searchText.isEmpty {
                        Section("Search Results") {
                            ForEach(searchResults.prefix(20), id: \.id) { food in
                                FoodSelectionRow(
                                    food: food,
                                    isSelected: tempSelectedItems.contains(where: { $0.id == food.id }),
                                    onToggle: { toggleFood(food) }
                                )
                            }
                        }
                    } else {
                        Section("Recent Foods") {
                            ForEach(recentFoods, id: \.id) { food in
                                FoodSelectionRow(
                                    food: food,
                                    isSelected: tempSelectedItems.contains(where: { $0.id == food.id }),
                                    onToggle: { toggleFood(food) }
                                )
                            }
                        }

                        Section("Common Foods") {
                            ForEach(commonQuickAddFoods, id: \.id) { food in
                                FoodSelectionRow(
                                    food: food,
                                    isSelected: tempSelectedItems.contains(where: { $0.id == food.id }),
                                    onToggle: { toggleFood(food) }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Foods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedFoodItems = tempSelectedItems
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(tempSelectedItems.isEmpty)
                }
            }
            .onAppear {
                tempSelectedItems = selectedFoodItems
                isSearchFocused = true
            }
        }
    }

    private func toggleFood(_ food: FoodItem) {
        if let index = tempSelectedItems.firstIndex(where: { $0.id == food.id }) {
            tempSelectedItems.remove(at: index)
        } else {
            tempSelectedItems.append(food)
        }
    }

    private var commonQuickAddFoods: [FoodItem] {
        return [
            FoodItem(name: "Apple", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4, sugar: 19, sodium: 2, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
            FoodItem(name: "Banana", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1, sugar: 14, sodium: 1, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
            FoodItem(name: "Chicken Breast", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 140, protein: 26, carbs: 0, fat: 3, fiber: 0, sugar: 0, sodium: 74, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
            FoodItem(name: "Rice", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup", calories: 205, protein: 4.3, carbs: 44.5, fat: 0.4, fiber: 0.6, sugar: 0.1, sodium: 1, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
            FoodItem(name: "Salad", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "bowl", calories: 50, protein: 3, carbs: 10, fat: 0.5, fiber: 4, sugar: 4, sodium: 100, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true)
        ]
    }
}

// Food selection row with checkbox
struct FoodSelectionRow: View {
    let food: FoodItem
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .wellnessGreen : .secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(food.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let brand = food.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 15) {
                        Text("\(Int(food.calories)) cal")
                            .font(.subheadline)
                            .foregroundColor(.orange)

                        HStack(spacing: 8) {
                            MacroLabel(value: food.protein, label: "P", color: .red)
                            MacroLabel(value: food.carbs, label: "C", color: .blue)
                            MacroLabel(value: food.fat, label: "F", color: .green)
                        }

                        Spacer()

                        Text("\(food.servingSize) \(food.servingUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}