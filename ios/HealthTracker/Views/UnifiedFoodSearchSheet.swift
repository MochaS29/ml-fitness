import SwiftUI
import CoreData

// MARK: - Unified Food Search Sheet
// Single food search interface used by all views in the app

struct UnifiedFoodSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = UnifiedDataManager.shared
    @StateObject private var favourites = FavouriteFoodsManager.shared
    @State private var searchText = ""
    @State private var selectedMealType: MealType
    @State private var showingManualEntry = false
    @State private var showingBarcode = false
    @State private var showingCopyFromPreviousDay = false
    @State private var pendingFood: FoodItem?
    @State private var servingMultiplier: Double = 1.0
    @FocusState private var isSearchFocused: Bool

    // USDA API state
    @State private var usdaResults: [USDAFoodItem] = []
    @State private var isLoadingUSDA = false
    @State private var searchTask: Task<Void, Never>?

    private let usdaService = USDAFoodService.shared
    private let targetDate: Date

    init(mealType: MealType = .snack, targetDate: Date = Date()) {
        self._selectedMealType = State(initialValue: mealType)
        self.targetDate = targetDate
    }

    // Phase 1: Instant local results (SQLite + hardcoded DB, deduped)
    var localResults: [FoodItem] {
        if searchText.isEmpty {
            return []
        }
        let sqliteResults = dataManager.searchFoodDatabase(searchText)
        let staticMatches = FoodDatabase.shared.searchFoods(searchText)
        let existingNames = Set(sqliteResults.map { $0.name.lowercased() })
        let uniqueStatic = staticMatches.filter { !existingNames.contains($0.name.lowercased()) }
        return sortByRelevance(sqliteResults + uniqueStatic, query: searchText)
    }

    // Phase 2: USDA API results, deduplicated against local
    var onlineResults: [FoodItem] {
        let localNames = Set(localResults.map { $0.name.lowercased() })
        let filtered = usdaResults
            .map { $0.toFoodItem() }
            .filter { !localNames.contains($0.name.lowercased()) }
        return sortByRelevance(filtered, query: searchText)
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

    var recentFoods: [FoodItem] {
        return dataManager.getRecentFoods()
    }

    // Recent foods filtered to current meal type (last 10 entries for this meal type)
    var mealTypeRecentFoods: [FoodItem] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "mealType == %@", selectedMealType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 50
        guard let entries = try? context.fetch(request) else { return [] }
        var seen = Set<String>()
        var results: [FoodItem] = []
        for entry in entries {
            let key = "\(entry.name ?? "")-\(entry.brand ?? "")"
            guard !seen.contains(key), let name = entry.name else { continue }
            seen.insert(key)
            results.append(FoodItem(
                name: name, brand: entry.brand,
                category: .other,
                servingSize: entry.servingSize ?? "1",
                servingUnit: entry.servingUnit ?? "serving",
                calories: entry.calories, protein: entry.protein,
                carbs: entry.carbs, fat: entry.fat, fiber: entry.fiber,
                sugar: entry.sugar, sodium: entry.sodium,
                cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: false
            ))
            if results.count == 10 { break }
        }
        return results
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
                        Button(action: {
                            searchText = ""
                            usdaResults = []
                            searchTask?.cancel()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: { showingBarcode = true }) {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.blue)
                    }
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
                .padding(.bottom, 8)

                // Copy from Previous Day
                Button(action: { showingCopyFromPreviousDay = true }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                            .font(.subheadline)
                        Text("Copy from Previous Day")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

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

                    // Search Results or Recent/Common Foods
                    if !searchText.isEmpty {
                        // Local results (instant)
                        if !localResults.isEmpty {
                            Section("Local Results") {
                                ForEach(localResults.prefix(50), id: \.id) { food in
                                    FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                        selectFood(food)
                                    }
                                }
                            }
                        }

                        // Online results (async USDA API)
                        if isLoadingUSDA {
                            Section("Online Results") {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Searching online...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else if !onlineResults.isEmpty {
                            Section("Online Results") {
                                ForEach(onlineResults.prefix(30), id: \.id) { food in
                                    FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                        selectFood(food, fromUSDA: true)
                                    }
                                }
                            }
                        }
                    } else {
                        // Favourites section
                        if !favourites.favourites.isEmpty {
                            Section("Favourites") {
                                ForEach(favourites.favourites) { fav in
                                    let food = fav.toFoodItem()
                                    FoodRowView(food: food, isFavourite: true, onStar: { favourites.toggle(food) }) {
                                        selectFood(food)
                                    }
                                }
                            }
                        }

                        // Recent for this meal type
                        let mealRecents = mealTypeRecentFoods
                        if !mealRecents.isEmpty {
                            Section("Recent for \(selectedMealType.rawValue)") {
                                ForEach(mealRecents, id: \.id) { food in
                                    FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                        selectFood(food)
                                    }
                                }
                            }
                        } else {
                            Section("Recent Foods") {
                                if recentFoods.isEmpty {
                                    Text("No recent foods yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(recentFoods.prefix(10), id: \.id) { food in
                                        FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                            selectFood(food)
                                        }
                                    }
                                }
                            }
                        }

                        Section("Common Foods") {
                            ForEach(commonQuickAddFoods, id: \.id) { food in
                                FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                    selectFood(food)
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
            .onChange(of: searchText) {
                onSearchTextChanged(searchText)
            }
        }
        .sheet(item: $pendingFood) { food in
            ServingSizeSheet(
                food: food,
                multiplier: $servingMultiplier,
                onAdd: { addFood(food, multiplier: servingMultiplier) },
                onCancel: { pendingFood = nil }
            )
            .presentationDetents([.medium])
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
        .sheet(isPresented: $showingCopyFromPreviousDay) {
            CopyFromPreviousDayView(targetDate: targetDate)
        }
        .sheet(isPresented: $showingBarcode) {
            ProFeatureGate {
                BarcodeScannerView(
                    selectedDate: Date(),
                    mealType: selectedMealType
                )
            }
            .onDisappear {
                showingBarcode = false
            }
        }
    }

    // MARK: - Actions

    private func selectFood(_ food: FoodItem, fromUSDA: Bool = false) {
        servingMultiplier = 1.0
        if fromUSDA { dataManager.cacheFoodItem(food) }
        pendingFood = food
    }

    private func addFood(_ food: FoodItem, multiplier: Double = 1.0) {
        if multiplier == 1.0 {
            dataManager.addFoodFromDatabase(food, mealType: selectedMealType)
        } else {
            dataManager.addFoodEntry(
                name: food.name,
                brand: food.brand,
                calories: food.calories * multiplier,
                protein: food.protein * multiplier,
                carbs: food.carbs * multiplier,
                fat: food.fat * multiplier,
                fiber: food.fiber * multiplier,
                sugar: (food.sugar ?? 0) * multiplier,
                sodium: (food.sodium ?? 0) * multiplier,
                servingSize: food.servingSize,
                servingUnit: food.servingUnit,
                mealType: selectedMealType,
                barcode: food.barcode
            )
        }
        dismiss()
    }

    private func onSearchTextChanged(_ newValue: String) {
        // Cancel previous USDA search
        searchTask?.cancel()
        usdaResults = []

        guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isLoadingUSDA = false
            return
        }

        // Phase 2: Debounced USDA API search (0.4s delay)
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)

            // Check if search text hasn't changed during debounce
            guard !Task.isCancelled, newValue == searchText else { return }

            await MainActor.run { isLoadingUSDA = true }

            do {
                let results = try await usdaService.searchFoods(newValue)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.usdaResults = results
                    self.isLoadingUSDA = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.isLoadingUSDA = false
                    print("USDA search error: \(error)")
                }
            }
        }
    }

    private var commonQuickAddFoods: [FoodItem] {
        let common = LocalFoodDatabase.shared.getCommonFoods(limit: 10)
        if common.isEmpty {
            // Fallback if SQLite DB not available
            return [
                FoodItem(name: "Apple", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4, sugar: 19, sodium: 2, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
                FoodItem(name: "Banana", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1, sugar: 14, sodium: 1, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
                FoodItem(name: "Chicken Breast", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 140, protein: 26, carbs: 0, fat: 3, fiber: 0, sugar: 0, sodium: 74, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
                FoodItem(name: "Rice", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup", calories: 205, protein: 4.3, carbs: 44.5, fat: 0.4, fiber: 0.6, sugar: 0.1, sodium: 1, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true),
                FoodItem(name: "Salad", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "bowl", calories: 50, protein: 3, carbs: 10, fat: 0.5, fiber: 4, sugar: 4, sodium: 100, cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: true)
            ]
        }
        return common
    }
}

// MARK: - Food Row View

struct FoodRowView: View {
    let food: FoodItem
    var isFavourite: Bool = false
    var onStar: (() -> Void)? = nil
    let onTap: () -> Void

    var body: some View {
        HStack {
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
                        MacroLabel(value: food.protein, label: "Pro", color: .red)
                        MacroLabel(value: food.carbs, label: "Carb", color: .blue)
                        MacroLabel(value: food.fat, label: "Fat", color: .green)

                        Spacer()

                        Text(food.servingUnit.first?.isNumber == true ? food.servingUnit : "\(food.servingSize) \(food.servingUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            if let onStar = onStar {
                Button(action: onStar) {
                    Image(systemName: isFavourite ? "star.fill" : "star")
                        .foregroundColor(isFavourite ? .yellow : .gray)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Serving Size Sheet

struct ServingSizeSheet: View {
    let food: FoodItem
    @Binding var multiplier: Double
    let onAdd: () -> Void
    let onCancel: () -> Void

    private var adjCalories: Double { food.calories * multiplier }
    private var adjProtein: Double { food.protein * multiplier }
    private var adjCarbs: Double { food.carbs * multiplier }
    private var adjFat: Double { food.fat * multiplier }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Food name
                VStack(spacing: 4) {
                    Text(food.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("Per serving: \(food.servingSize) \(food.servingUnit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Serving stepper
                VStack(spacing: 8) {
                    Text("Number of Servings")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack(spacing: 24) {
                        Button(action: {
                            if multiplier > 0.25 { multiplier = (multiplier - 0.25).rounded(toPlaces: 2) }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                        }
                        Text(String(format: "%.2f", multiplier))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(minWidth: 64)
                        Button(action: {
                            multiplier = (multiplier + 0.25).rounded(toPlaces: 2)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Adjusted nutrition
                HStack(spacing: 0) {
                    ServingNutrientCell(label: "Calories", value: adjCalories, format: "%.0f", color: .orange)
                    Divider().frame(height: 40)
                    ServingNutrientCell(label: "Protein", value: adjProtein, format: "%.1fg", color: .blue)
                    Divider().frame(height: 40)
                    ServingNutrientCell(label: "Carbs", value: adjCarbs, format: "%.1fg", color: .green)
                    Divider().frame(height: 40)
                    ServingNutrientCell(label: "Fat", value: adjFat, format: "%.1fg", color: .yellow)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)

                Spacer()

                Button(action: onAdd) {
                    Text("Add to Diary")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.horizontal)
            .navigationTitle("Adjust Serving")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

private struct ServingNutrientCell: View {
    let label: String
    let value: Double
    let format: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: format, value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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
