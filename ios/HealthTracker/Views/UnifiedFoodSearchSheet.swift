import SwiftUI
import CoreData

// MARK: - Unified Food Search Sheet
// Single food search interface used by all views in the app

struct UnifiedFoodSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = UnifiedDataManager.shared
    @State private var searchText = ""
    @State private var selectedMealType: MealType
    @State private var showingManualEntry = false
    @State private var showingBarcode = false
    @FocusState private var isSearchFocused: Bool

    init(mealType: MealType = .snack) {
        self._selectedMealType = State(initialValue: mealType)
    }

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

                    // Barcode scanner temporarily disabled - will be available in next release
                    // Button(action: { showingBarcode = true }) {
                    //     Image(systemName: "barcode.viewfinder")
                    //         .foregroundColor(.blue)
                    // }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Meal Type Selector
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom)

                // Results List
                List {
                    // Create Custom Food Option
                    if !searchText.isEmpty {
                        Button(action: { showingManualEntry = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading) {
                                    Text("Create \"\(searchText)\"")
                                        .foregroundColor(.primary)
                                    Text("Add custom food")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    // Search Results or Recent Foods
                    if !searchText.isEmpty {
                        Section("Search Results") {
                            ForEach(searchResults.prefix(20), id: \.id) { food in
                                FoodRowView(food: food) {
                                    addFood(food)
                                }
                            }
                        }
                    } else {
                        Section("Recent Foods") {
                            ForEach(recentFoods, id: \.id) { food in
                                FoodRowView(food: food) {
                                    addFood(food)
                                }
                            }
                        }

                        Section("Common Foods") {
                            ForEach(commonQuickAddFoods, id: \.id) { food in
                                FoodRowView(food: food) {
                                    addFood(food)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .onAppear {
                isSearchFocused = true
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualFoodEntrySheet(
                foodName: searchText,
                mealType: selectedMealType,
                onSave: { name, calories, protein, carbs, fat in
                    dataManager.addFoodEntry(
                        name: name,
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                        mealType: selectedMealType
                    )
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingBarcode) {
            BarcodeScannerView(
                selectedDate: Date(),
                mealType: selectedMealType
            )
            .onDisappear {
                showingBarcode = false
            }
        }
    }

    private func addFood(_ food: FoodItem) {
        dataManager.addFoodFromDatabase(food, mealType: selectedMealType)
        dismiss()
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

// MARK: - Food Row View

struct FoodRowView: View {
    let food: FoodItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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

                    Spacer()

                    Text("\(Int(food.calories)) cal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }

                HStack(spacing: 15) {
                    MacroLabel(value: food.protein, label: "P", color: .red)
                    MacroLabel(value: food.carbs, label: "C", color: .blue)
                    MacroLabel(value: food.fat, label: "F", color: .green)

                    Spacer()

                    Text("\(food.servingSize) \(food.servingUnit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Manual Entry Sheet

struct ManualFoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let foodName: String
    let mealType: MealType
    let onSave: (String, Double, Double, Double, Double) -> Void

    @State private var name: String
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var servingSize = "1"
    @State private var servingUnit = "serving"

    init(foodName: String, mealType: MealType, onSave: @escaping (String, Double, Double, Double, Double) -> Void) {
        self.foodName = foodName
        self.mealType = mealType
        self.onSave = onSave
        self._name = State(initialValue: foodName)
    }

    var isValid: Bool {
        !name.isEmpty && Double(calories) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    TextField("Food Name", text: $name)

                    HStack {
                        TextField("Serving Size", text: $servingSize)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)

                        TextField("Unit", text: $servingUnit)
                    }
                }

                Section("Nutrition") {
                    HStack {
                        Label("Calories", systemImage: "flame")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("cal")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Protein", systemImage: "p.square")
                            .foregroundColor(.red)
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Carbs", systemImage: "c.square")
                            .foregroundColor(.blue)
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Fat", systemImage: "f.square")
                            .foregroundColor(.green)
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let caloriesValue = Double(calories) ?? 0
                        let proteinValue = Double(protein) ?? 0
                        let carbsValue = Double(carbs) ?? 0
                        let fatValue = Double(fat) ?? 0

                        onSave(name, caloriesValue, proteinValue, carbsValue, fatValue)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}