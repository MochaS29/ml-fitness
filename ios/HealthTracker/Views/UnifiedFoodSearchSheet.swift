import SwiftUI
import CoreData

// MARK: - Unified Food Search Sheet
// Single food search interface used by all views in the app

struct UnifiedFoodSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @ObservedObject private var favourites = FavouriteFoodsManager.shared
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
        return FoodSearchService.sortByRelevance(sqliteResults + uniqueStatic, query: searchText)
    }

    // Phase 2: USDA API results, deduplicated against local
    var onlineResults: [FoodItem] {
        let localNames = Set(localResults.map { $0.name.lowercased() })
        let filtered = usdaResults
            .map { $0.toFoodItem() }
            .filter { !localNames.contains($0.name.lowercased()) }
        return FoodSearchService.sortByRelevance(filtered, query: searchText)
    }

    var recentFoods: [FoodItem] {
        return dataManager.getRecentFoods()
    }

    /// User's previously-logged foods (FoodEntry) and user-created custom foods
    /// (CustomFood) that match the current search query. Surfaces familiar items
    /// above generic database hits so re-logging is one tap, and keeps custom foods
    /// retrievable even after every diary entry referencing them is deleted.
    var userPriorMatches: [FoodItem] {
        guard !searchText.isEmpty else { return [] }
        let context = PersistenceController.shared.container.viewContext
        var seen = Set<String>()
        var out: [FoodItem] = []

        // Recent diary entries first — most recently logged surfaces highest.
        let entryRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        entryRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        entryRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        entryRequest.fetchLimit = 100
        if let entries = try? context.fetch(entryRequest) {
            for entry in entries {
                guard let name = entry.name else { continue }
                let key = "\(name.lowercased())-\(entry.brand?.lowercased() ?? "")"
                guard !seen.contains(key) else { continue }
                seen.insert(key)
                let count = entry.servingCount > 0 ? entry.servingCount : 1.0
                out.append(FoodItem(
                    name: name, brand: entry.brand,
                    category: .other,
                    servingSize: entry.servingSize ?? "1",
                    servingUnit: entry.servingUnit ?? "serving",
                    calories: entry.calories / count, protein: entry.protein / count,
                    carbs: entry.carbs / count, fat: entry.fat / count, fiber: entry.fiber / count,
                    sugar: entry.sugar / count, sodium: entry.sodium / count,
                    cholesterol: nil, saturatedFat: nil, barcode: entry.barcode, isCommon: false
                ))
                if out.count == 10 { break }
            }
        }

        // User-created CustomFoods — these survive diary deletion.
        if out.count < 10 {
            let customRequest: NSFetchRequest<CustomFood> = CustomFood.fetchRequest()
            customRequest.predicate = NSPredicate(
                format: "(name CONTAINS[cd] %@ OR brand CONTAINS[cd] %@) AND isUserCreated == YES",
                searchText, searchText
            )
            customRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            customRequest.fetchLimit = 20
            if let customs = try? context.fetch(customRequest) {
                for c in customs {
                    guard let name = c.name else { continue }
                    let key = "\(name.lowercased())-\(c.brand?.lowercased() ?? "")"
                    guard !seen.contains(key) else { continue }
                    seen.insert(key)
                    out.append(FoodItem(
                        name: name, brand: c.brand,
                        category: FoodCategory(rawValue: c.category ?? "") ?? .other,
                        servingSize: c.servingSize ?? "1",
                        servingUnit: c.servingUnit ?? "serving",
                        calories: c.calories, protein: c.protein,
                        carbs: c.carbs, fat: c.fat, fiber: c.fiber,
                        sugar: c.sugar, sodium: c.sodium,
                        cholesterol: c.cholesterol, saturatedFat: c.saturatedFat,
                        barcode: c.barcode, isCommon: false
                    ))
                    if out.count == 10 { break }
                }
            }
        }

        return out
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
                        // Your Foods — items you've logged before that match this query
                        let priorMatches = userPriorMatches
                        if !priorMatches.isEmpty {
                            Section("Your Foods") {
                                ForEach(priorMatches, id: \.id) { food in
                                    FoodRowView(food: food, isFavourite: favourites.isFavourite(food), onStar: { favourites.toggle(food) }) {
                                        selectFood(food)
                                    }
                                }
                            }
                        }

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
                onSave: { payload in
                    let extras = payload.additionalNutrients.isEmpty ? nil : payload.additionalNutrients
                    // Persist as a reusable CustomFood so it survives diary deletions
                    // and shows up in future searches.
                    dataManager.saveUserCustomFood(
                        name: payload.name,
                        calories: payload.calories,
                        protein: payload.protein,
                        carbs: payload.carbs,
                        fat: payload.fat,
                        fiber: payload.fiber,
                        sugar: payload.sugar,
                        sodium: payload.sodium,
                        cholesterol: payload.cholesterol,
                        saturatedFat: payload.saturatedFat,
                        additionalNutrients: extras,
                        servingSize: payload.servingSize,
                        servingUnit: payload.servingUnit
                    )
                    dataManager.addFoodEntry(
                        name: payload.name,
                        calories: payload.calories,
                        protein: payload.protein,
                        carbs: payload.carbs,
                        fat: payload.fat,
                        fiber: payload.fiber,
                        sugar: payload.sugar,
                        sodium: payload.sodium,
                        cholesterol: payload.cholesterol,
                        saturatedFat: payload.saturatedFat,
                        additionalNutrients: extras,
                        servingSize: payload.servingSize,
                        servingUnit: payload.servingUnit,
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

// MARK: - Unit Conversion Model

enum ServingUnit: String, CaseIterable, Identifiable {
    // Original serving
    case serving = "serving"
    // Weight
    case grams = "g"
    case oz = "oz"
    case lb = "lb"
    // Volume
    case cup = "cup"
    case tbsp = "tbsp"
    case tsp = "tsp"
    case flOz = "fl oz"
    case ml = "ml"

    var id: String { rawValue }

    var category: String {
        switch self {
        case .serving: return "Serving"
        case .grams, .oz, .lb: return "Weight"
        case .cup, .tbsp, .tsp, .flOz, .ml: return "Volume"
        }
    }
}

// MARK: - Serving Size Sheet

struct ServingSizeSheet: View {
    let food: FoodItem
    @Binding var multiplier: Double
    let onAdd: () -> Void
    let onCancel: () -> Void

    @State private var selectedUnit: ServingUnit = .serving
    @State private var quantity: Double = 1.0
    @State private var quantityText: String = "1"
    @FocusState private var quantityFocused: Bool

    // grams encoded in the unit string e.g. "cup (244g)", "medium (182g)", "oz (28g)"
    private var gramsPerServing: Double? {
        let unit = food.servingUnit
        // Match pattern like "(244g)" or "(28.5g)"
        if let range = unit.range(of: #"\((\d+(?:\.\d+)?)g\)"#, options: .regularExpression) {
            let inner = String(unit[range]).dropFirst().dropLast(2) // strip "(" and "g)"
            return Double(inner.filter { $0.isNumber || $0 == "." })
        }
        // Plain "oz" unit — 1 oz = 28.3495g
        let lower = unit.lowercased()
        if lower == "oz" || lower.hasPrefix("oz ") { return 28.3495 }
        // Plain "g" unit
        if lower == "g" || lower.hasPrefix("g ") { return 1.0 }
        return nil
    }

    private var servingSizeNumber: Double {
        let s = food.servingSize.trimmingCharacters(in: .whitespaces)
        if s.contains("/") {
            let parts = s.split(separator: "/")
            if parts.count == 2, let n = Double(parts[0]), let d = Double(parts[1]), d != 0 {
                return n / d
            }
        }
        return Double(s) ?? 1.0
    }

    private var isCupBased: Bool {
        food.servingUnit.lowercased().contains("cup") ||
        food.servingUnit.lowercased().contains("fl oz") ||
        food.servingUnit.lowercased().contains("ml")
    }

    var availableUnits: [ServingUnit] {
        var units: [ServingUnit] = [.serving]
        if gramsPerServing != nil {
            units += [.grams, .oz, .lb]
        }
        if isCupBased {
            units += [.cup, .tbsp, .tsp, .flOz, .ml]
        }
        return units
    }

    // How many of `selectedUnit` equals 1 multiplier (1 serving)
    private var unitsPerServing: Double {
        let sn = servingSizeNumber
        switch selectedUnit {
        case .serving: return 1.0
        case .grams:
            guard let g = gramsPerServing else { return 1.0 }
            return g * sn
        case .oz:
            guard let g = gramsPerServing else { return 1.0 }
            return (g * sn) / 28.3495
        case .lb:
            guard let g = gramsPerServing else { return 1.0 }
            return (g * sn) / 453.592
        case .cup:
            // base unit is cups — sn cups per serving
            return sn
        case .tbsp:
            return sn * 16.0
        case .tsp:
            return sn * 48.0
        case .flOz:
            return sn * 8.0
        case .ml:
            return sn * 240.0
        }
    }

    private var adjCalories: Double { food.calories * multiplier }
    private var adjProtein: Double { food.protein * multiplier }
    private var adjCarbs: Double { food.carbs * multiplier }
    private var adjFat: Double { food.fat * multiplier }

    private func quantityLabel() -> String {
        let q = quantity
        let fmt = q.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2g"
        return String(format: fmt, q)
    }

    private func applyUnit(_ unit: ServingUnit) {
        selectedUnit = unit
        // Convert current multiplier → quantity in new unit
        quantity = max(0.01, (multiplier * unitsPerServing).rounded(toPlaces: 3))
        quantityText = quantityLabel()
    }

    private func applyQuantity(_ raw: String) {
        guard let val = Double(raw), val > 0 else { return }
        quantity = val
        multiplier = max(0.01, (val / unitsPerServing).rounded(toPlaces: 4))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Food name header
                    VStack(spacing: 4) {
                        Text(food.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        if let brand = food.brand {
                            Text(brand).font(.caption).foregroundColor(.secondary)
                        }
                        Text("1 serving = \(food.servingSize) \(food.servingUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Unit selector chips
                    if availableUnits.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unit")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(availableUnits) { unit in
                                        Button(action: { applyUnit(unit) }) {
                                            Text(unit == .serving ? "\(food.servingSize) \(food.servingUnit.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? food.servingUnit)" : unit.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(selectedUnit == unit ? .semibold : .regular)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(selectedUnit == unit ? Color.accentColor : Color(.systemGray5))
                                                .foregroundColor(selectedUnit == unit ? .white : .primary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Quantity control
                    VStack(spacing: 10) {
                        Text("Amount")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        HStack(spacing: 20) {
                            Button(action: {
                                let step = stepSize()
                                let newVal = max(step, (quantity - step).rounded(toPlaces: 3))
                                quantity = newVal
                                quantityText = quantityLabel()
                                multiplier = max(0.01, (newVal / unitsPerServing).rounded(toPlaces: 4))
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                            }

                            TextField("Amount", text: $quantityText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .font(.title2.weight(.semibold))
                                .frame(minWidth: 80)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(quantityFocused ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .focused($quantityFocused)
                                .onChange(of: quantityText) { _, newVal in
                                    applyQuantity(newVal)
                                }

                            Button(action: {
                                let step = stepSize()
                                let newVal = (quantity + step).rounded(toPlaces: 3)
                                quantity = newVal
                                quantityText = quantityLabel()
                                multiplier = max(0.01, (newVal / unitsPerServing).rounded(toPlaces: 4))
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
                    .padding(.horizontal)

                    // Nutrition summary
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
                    .padding(.horizontal)

                    Spacer(minLength: 8)
                }
            }

            // Add button pinned at bottom — always visible regardless of keyboard or scroll
            Button(action: {
                quantityFocused = false
                onAdd()
            }) {
                Text("Add to Diary")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground).shadow(radius: 4, y: -2))
            } // end outer VStack
            .navigationTitle("Adjust Serving")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if quantityFocused {
                        Button("Done") { quantityFocused = false }
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            selectedUnit = .serving
            quantity = multiplier
            quantityText = quantityLabel()
        }
    }

    private func stepSize() -> Double {
        switch selectedUnit {
        case .serving: return 0.25
        case .grams: return 10.0
        case .oz: return 0.5
        case .lb: return 0.1
        case .cup: return 0.25
        case .tbsp: return 1.0
        case .tsp: return 1.0
        case .flOz: return 1.0
        case .ml: return 10.0
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

struct ManualFoodEntryPayload {
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var sodium: Double
    var cholesterol: Double
    var saturatedFat: Double
    var additionalNutrients: [String: Double]
    var servingSize: String
    var servingUnit: String
}

struct ManualFoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let foodName: String
    let mealType: MealType
    let onSave: (ManualFoodEntryPayload) -> Void

    @State private var name: String
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var sugar = ""
    @State private var sodium = ""
    @State private var cholesterol = ""
    @State private var saturatedFat = ""
    @State private var servingSize = "1"
    @State private var servingUnit = "serving"

    @State private var showingAdditionalNutrients = false
    @State private var additionalNutrients: [String: Double] = [:]

    init(foodName: String, mealType: MealType, onSave: @escaping (ManualFoodEntryPayload) -> Void) {
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
                    nutritionField("Calories", text: $calories, unit: "cal", icon: "flame", iconColor: .orange)
                    nutritionField("Protein", text: $protein, unit: "g", icon: "p.square", iconColor: .red)
                    nutritionField("Carbs", text: $carbs, unit: "g", icon: "c.square", iconColor: .blue)
                    nutritionField("Fat", text: $fat, unit: "g", icon: "f.square", iconColor: .green)
                    nutritionField("Fiber", text: $fiber, unit: "g", icon: "leaf", iconColor: .green)
                    nutritionField("Sugar", text: $sugar, unit: "g", icon: "cube", iconColor: .pink)
                    nutritionField("Sodium", text: $sodium, unit: "mg", icon: "drop", iconColor: .blue)
                    nutritionField("Cholesterol", text: $cholesterol, unit: "mg", icon: "heart", iconColor: .red)
                    nutritionField("Saturated Fat", text: $saturatedFat, unit: "g", icon: "f.square.fill", iconColor: .green)
                }

                Section {
                    Button(action: { showingAdditionalNutrients.toggle() }) {
                        HStack {
                            Text("Additional Nutrients")
                            Spacer()
                            Image(systemName: showingAdditionalNutrients ? "chevron.up" : "chevron.down")
                        }
                    }

                    if showingAdditionalNutrients {
                        Group {
                            Text("Vitamins").font(.headline)
                            extraNutrientRow("Vitamin A", key: "vitamin_a", unit: "mcg")
                            extraNutrientRow("Vitamin C", key: "vitamin_c", unit: "mg")
                            extraNutrientRow("Vitamin D", key: "vitamin_d", unit: "mcg")
                            extraNutrientRow("Vitamin E", key: "vitamin_e", unit: "mg")
                            extraNutrientRow("Vitamin K", key: "vitamin_k", unit: "mcg")
                            extraNutrientRow("Thiamin (B1)", key: "thiamin", unit: "mg")
                            extraNutrientRow("Riboflavin (B2)", key: "riboflavin", unit: "mg")
                            extraNutrientRow("Niacin (B3)", key: "niacin", unit: "mg")
                            extraNutrientRow("Vitamin B6", key: "vitamin_b6", unit: "mg")
                            extraNutrientRow("Folate", key: "folate", unit: "mcg")
                        }

                        Group {
                            extraNutrientRow("Vitamin B12", key: "vitamin_b12", unit: "mcg")
                            extraNutrientRow("Biotin", key: "biotin", unit: "mcg")
                            extraNutrientRow("Pantothenic Acid", key: "pantothenic_acid", unit: "mg")
                        }

                        Group {
                            Text("Minerals").font(.headline)
                            extraNutrientRow("Calcium", key: "calcium", unit: "mg")
                            extraNutrientRow("Iron", key: "iron", unit: "mg")
                            extraNutrientRow("Magnesium", key: "magnesium", unit: "mg")
                            extraNutrientRow("Phosphorus", key: "phosphorus", unit: "mg")
                            extraNutrientRow("Potassium", key: "potassium", unit: "mg")
                            extraNutrientRow("Zinc", key: "zinc", unit: "mg")
                            extraNutrientRow("Copper", key: "copper", unit: "mg")
                            extraNutrientRow("Manganese", key: "manganese", unit: "mg")
                            extraNutrientRow("Selenium", key: "selenium", unit: "mcg")
                        }
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
                        let payload = ManualFoodEntryPayload(
                            name: name,
                            calories: Double(calories) ?? 0,
                            protein: Double(protein) ?? 0,
                            carbs: Double(carbs) ?? 0,
                            fat: Double(fat) ?? 0,
                            fiber: Double(fiber) ?? 0,
                            sugar: Double(sugar) ?? 0,
                            sodium: Double(sodium) ?? 0,
                            cholesterol: Double(cholesterol) ?? 0,
                            saturatedFat: Double(saturatedFat) ?? 0,
                            additionalNutrients: additionalNutrients.filter { $0.value > 0 },
                            servingSize: servingSize,
                            servingUnit: servingUnit
                        )
                        onSave(payload)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    @ViewBuilder
    private func nutritionField(_ label: String, text: Binding<String>, unit: String, icon: String, iconColor: Color) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundColor(iconColor)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func extraNutrientRow(_ label: String, key: String, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: extraBinding(for: key), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.decimalPad)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
    }

    private func extraBinding(for key: String) -> Binding<Double> {
        Binding<Double>(
            get: { additionalNutrients[key] ?? 0 },
            set: { additionalNutrients[key] = $0 }
        )
    }
}
