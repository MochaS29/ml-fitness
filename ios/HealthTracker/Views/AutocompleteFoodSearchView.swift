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
    @State private var usdaResults: [USDAFoodItem] = []
    @State private var isLoadingUSDA = false
    @FocusState private var isSearchFieldFocused: Bool

    private let usdaService = USDAFoodService.shared

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
                    fiber: entry.fiber,
                    sugar: entry.sugar,
                    sodium: entry.sodium,
                    cholesterol: 0,
                    saturatedFat: 0,
                    barcode: entry.barcode,
                    isCommon: false
                ))

                if uniqueFoods.count >= 15 { break }  // Limit recent foods to 15
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

        // Then check the local SQLite food database (FTS5 search)
        let databaseMatches = LocalFoodDatabase.shared.searchFoods(searchText, limit: 20)
            .filter { food in
                // Don't include if already in recent matches
                !recentMatches.contains { $0.name == food.name && $0.brand == food.brand }
            }
            .prefix(20)  // Limit database results

        // Add USDA results converted to FoodItem
        let usdaFoodItems = usdaResults.map { $0.toFoodItem() }
            .filter { food in
                // Don't include if already in recent or database matches
                !recentMatches.contains { $0.name == food.name && $0.brand == food.brand } &&
                !databaseMatches.contains { $0.name == food.name && $0.brand == food.brand }
            }
            .prefix(20)

        let combined = recentMatches + Array(databaseMatches) + Array(usdaFoodItems)
        return sortByRelevance(combined, query: searchText)
    }

    /// Rank results so closest matches to the query appear first.
    private func sortByRelevance(_ foods: [FoodItem], query: String) -> [FoodItem] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return foods }

        return foods.sorted { a, b in
            let tierA = relevanceScore(a.name, query: q)
            let tierB = relevanceScore(b.name, query: q)
            if tierA != tierB { return tierA < tierB }
            // Within same tier, prefer items with calorie data over 0-cal (bad data)
            if (a.calories > 0) != (b.calories > 0) { return a.calories > 0 }
            // Then prefer shorter names
            return a.name.count < b.name.count
        }
    }

    /// Lower score = better match.
    /// Distinguishes whole-word matches from prefix-of-word matches:
    /// "Egg whites" (query "egg" is a whole word) ranks above "Eggnog" (prefix of another word).
    private func relevanceScore(_ name: String, query: String) -> Int {
        let lower = name.lowercased()
        let words = lower.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }

        // Tier 0: Exact match
        if lower == query { return 0 }

        // Check if query appears as a whole word at the start of the name
        // (not as a prefix of a longer word like "egg" in "eggnog")
        let queryIsWordAtStart: Bool = {
            guard lower.hasPrefix(query) else { return false }
            if lower.count == query.count { return true }
            let nextIdx = lower.index(lower.startIndex, offsetBy: query.count)
            let nextChar = lower[nextIdx]
            if !nextChar.isLetter { return true } // "Egg whites" — space after "egg"
            // Allow simple plural: "eggs" for "egg"
            if nextChar == "s" {
                let afterS = lower.index(after: nextIdx)
                return afterS >= lower.endIndex || !lower[afterS].isLetter
            }
            return false
        }()

        // Tier 1: Query is a whole word at start of a short name ("Egg whites", "Eggs, whole")
        if queryIsWordAtStart && words.count <= 3 { return 1 }
        // Tier 2: Query is an exact word in a short name ("Coffee, Latte" for "latte")
        if words.contains(query) && words.count <= 3 { return 2 }
        // Tier 3: Query is a whole word at start of a longer name ("Latte Blended Greek Yogurt")
        if queryIsWordAtStart { return 3 }
        // Tier 4: Query is an exact word in a longer name
        if words.contains(query) { return 4 }
        // Tier 5: Name starts with query as prefix of a word ("Eggnog" for "egg")
        if lower.hasPrefix(query) { return 5 }
        // Tier 6: A word starts with query
        if words.contains(where: { $0.hasPrefix(query) }) { return 6 }
        // Tier 7: Substring match
        if lower.contains(query) { return 7 }
        return 8
    }

    // Suggested foods based on time of day
    private var suggestedFoods: [FoodItem] {
        _ = Calendar.current.component(.hour, from: Date())

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
                            .onChange(of: searchText) {
                                isSearching = !searchText.isEmpty
                                if !searchText.isEmpty {
                                    searchUSDA(searchText)
                                } else {
                                    usdaResults = []
                                }
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

                                // Loading indicator for USDA search
                                if isLoadingUSDA {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Searching USDA database...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding()

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
                        .frame(maxHeight: 500)
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
        showingManualEntry = true
        // The manual entry form will use the search text as the initial name
    }

    private func searchUSDA(_ query: String) {
        // Debounce the search
        Task {
            // Wait a bit to avoid too many API calls while typing
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

            // Check if search text hasn't changed
            guard query == searchText else { return }

            isLoadingUSDA = true
            do {
                let results = try await usdaService.searchFoods(query)
                await MainActor.run {
                    self.usdaResults = results
                    self.isLoadingUSDA = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingUSDA = false
                    print("USDA search error: \(error)")
                }
            }
        }
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