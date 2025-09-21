import SwiftUI
import CoreData

// MARK: - Autocomplete Food Search View
struct AutocompleteFoodSearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedFoodItem: FoodItem?
    @State private var showingManualEntry = false
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool

    // Recently used foods
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        animation: .default
    ) private var recentFoodEntries: FetchedResults<FoodEntry>

    let onSelect: (FoodItem) -> Void

    // Get unique recent foods
    private var recentFoods: [FoodItem] {
        var seenNames = Set<String>()
        var uniqueFoods: [FoodItem] = []

        for entry in recentFoodEntries.prefix(50) {  // Limit to last 50 entries
            guard let name = entry.name else { continue }
            if !seenNames.contains(name) {
                seenNames.insert(name)
                uniqueFoods.append(FoodItem(
                    name: name,
                    brand: entry.brand,
                    category: .other,
                    servingSize: entry.servingSize ?? "1 serving",
                    servingUnit: entry.servingUnit ?? "serving",
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber ?? 0,
                    sugar: entry.sugar ?? 0,
                    sodium: entry.sodium ?? 0,
                    cholesterol: 0,
                    saturatedFat: 0,
                    barcode: entry.barcode,
                    isCommon: false
                ))

                if uniqueFoods.count >= 10 { break }  // Limit recent foods to 10
            }
        }

        return uniqueFoods
    }

    // Filtered search results
    private var searchResults: [FoodItem] {
        if searchText.isEmpty {
            return []
        }

        // First, check recent foods
        let recentMatches = recentFoods.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
        }

        // Then check the food database
        let databaseMatches = FoodDatabase.shared.searchFoods(searchText)
            .filter { food in
                // Don't include if already in recent matches
                !recentMatches.contains { $0.name == food.name && $0.brand == food.brand }
            }
            .prefix(10)  // Limit database results

        return recentMatches + Array(databaseMatches)
    }

    // Suggested foods based on time of day
    private var suggestedFoods: [FoodItem] {
        let hour = Calendar.current.component(.hour, from: Date())

        // Return empty results for now - can be enhanced later
        return []
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Field with Dropdown
                VStack(alignment: .leading, spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search or type food name...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($isSearchFieldFocused)
                            .onChange(of: searchText) { _, newValue in
                                isSearching = !newValue.isEmpty
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                isSearchFieldFocused = true
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    // Autocomplete Dropdown
                    if isSearchFieldFocused && !searchText.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // Create new food option
                                if !searchText.isEmpty {
                                    Button(action: {
                                        createNewFood()
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.blue)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Create \"\(searchText)\"")
                                                    .foregroundColor(.primary)
                                                Text("Add as custom food")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }

                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                    }

                                    Divider()
                                }

                                // Search Results
                                ForEach(searchResults) { food in
                                    FoodSuggestionRow(food: food) {
                                        selectFood(food)
                                    }
                                    Divider()
                                        .padding(.leading)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }

                // Main Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Quick Add Section
                        if searchText.isEmpty && !isSearchFieldFocused {
                            // Recent Foods
                            if !recentFoods.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Foods")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(recentFoods.prefix(5)) { food in
                                                QuickFoodCard(food: food) {
                                                    selectFood(food)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // Suggested Foods
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Suggested for You")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(suggestedFoods) { food in
                                    FoodSuggestionRow(food: food) {
                                        selectFood(food)
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Browse Categories
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Browse Categories")
                                    .font(.headline)
                                    .padding(.horizontal)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    CategoryButton(icon: "🍎", title: "Fruits", color: .red) {
                                        searchText = "fruit"
                                        isSearchFieldFocused = true
                                    }
                                    CategoryButton(icon: "🥬", title: "Vegetables", color: .green) {
                                        searchText = "vegetable"
                                        isSearchFieldFocused = true
                                    }
                                    CategoryButton(icon: "🍖", title: "Proteins", color: .orange) {
                                        searchText = "protein"
                                        isSearchFieldFocused = true
                                    }
                                    CategoryButton(icon: "🌾", title: "Grains", color: .brown) {
                                        searchText = "grain"
                                        isSearchFieldFocused = true
                                    }
                                    CategoryButton(icon: "🥛", title: "Dairy", color: .blue) {
                                        searchText = "dairy"
                                        isSearchFieldFocused = true
                                    }
                                    CategoryButton(icon: "🍰", title: "Snacks", color: .purple) {
                                        searchText = "snack"
                                        isSearchFieldFocused = true
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingManualEntry = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                // Auto-focus search field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSearchFieldFocused = true
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualFoodEntryView { foodItem in
                onSelect(foodItem)
                dismiss()
            }
        }
    }

    private func selectFood(_ food: FoodItem) {
        onSelect(food)
        dismiss()
    }

    private func createNewFood() {
        // Create a basic food item with the search text as the name
        let newFood = FoodItem(
            name: searchText,
            brand: nil,
            category: .other,
            servingSize: "1",
            servingUnit: "serving",
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            cholesterol: 0,
            saturatedFat: 0,
            barcode: nil,
            isCommon: false
        )

        showingManualEntry = true
        // Pass the name to manual entry
    }
}

// MARK: - Supporting Views

struct FoodSuggestionRow: View {
    let food: FoodItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let brand = food.brand, !brand.isEmpty {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text("\(Int(food.calories)) cal • \(food.servingSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickFoodCard: View {
    let food: FoodItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("\(Int(food.calories)) cal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 60)
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}

struct CategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title2)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Manual Food Entry View
struct ManualFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var servingSize = "1"
    @State private var servingUnit = "serving"
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0
    @State private var fiber: Double = 0
    @State private var sugar: Double = 0
    @State private var sodium: Double = 0

    let onSave: (FoodItem) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Food Name", text: $name)
                    TextField("Brand (Optional)", text: $brand)

                    HStack {
                        TextField("Serving Size", text: $servingSize)
                            .keyboardType(.decimalPad)

                        TextField("Unit", text: $servingUnit)
                    }
                }

                Section("Nutrition Facts") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Additional Nutrients (Optional)") {
                    HStack {
                        Text("Fiber (g)")
                        Spacer()
                        TextField("0", value: $fiber, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Sugar (g)")
                        Spacer()
                        TextField("0", value: $sugar, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Sodium (mg)")
                        Spacer()
                        TextField("0", value: $sodium, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
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
                        saveFood()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveFood() {
        let food = FoodItem(
            name: name,
            brand: brand.isEmpty ? nil : brand,
            category: .other,
            servingSize: servingSize,
            servingUnit: servingUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            cholesterol: 0,
            saturatedFat: 0,
            barcode: nil,
            isCommon: false
        )

        onSave(food)
        dismiss()
    }
}