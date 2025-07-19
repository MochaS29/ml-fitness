import SwiftUI
import CoreData

struct EnhancedFoodSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let onSelect: (FoodItem) -> Void
    
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?
    @State private var selectedSource: FoodSource = .all
    @State private var searchResults: [FoodItem] = []
    @State private var customFoodResults: [CustomFood] = []
    @State private var showingAddCustomFood = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomFood.name, ascending: true)],
        animation: .default)
    private var allCustomFoods: FetchedResults<CustomFood>
    
    enum FoodSource: String, CaseIterable {
        case all = "All"
        case database = "Database"
        case usda = "USDA"
        case userCreated = "My Foods"
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
                        .onChange(of: searchText) { _, _ in
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { 
                            searchText = ""
                            performSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.lightGray.opacity(0.2))
                .cornerRadius(10)
                .padding()
                
                // Source Filter
                Picker("Source", selection: $selectedSource) {
                    ForEach(FoodSource.allCases, id: \.self) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedSource) { _, _ in
                    performSearch()
                }
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: {
                                selectedCategory = nil
                                performSearch()
                            }
                        )
                        
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = category
                                    performSearch()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Results List
                List {
                    // Add Custom Food Button
                    if !searchText.isEmpty {
                        Button(action: { showingAddCustomFood = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.mindfulTeal)
                                VStack(alignment: .leading) {
                                    Text("Add \"\(searchText)\"")
                                        .font(.headline)
                                    Text("Create custom food")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Database Foods
                    if selectedSource == .all || selectedSource == .database {
                        Section(header: Text("Database Foods")) {
                            ForEach(searchResults) { food in
                                FoodRowView(food: food) {
                                    onSelect(food)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    
                    // Custom Foods
                    if selectedSource == .all || selectedSource == .userCreated || selectedSource == .usda {
                        let filteredCustomFoods = filterCustomFoods()
                        if !filteredCustomFoods.isEmpty {
                            Section(header: Text(selectedSource == .usda ? "USDA Foods" : "Custom Foods")) {
                                ForEach(filteredCustomFoods) { customFood in
                                    CustomFoodRowView(customFood: customFood) {
                                        // Convert CustomFood to FoodItem
                                        let foodItem = FoodItem(
                                            name: customFood.name ?? "",
                                            brand: customFood.brand,
                                            category: FoodCategory(rawValue: customFood.category ?? "") ?? .other,
                                            servingSize: customFood.servingSize ?? "1",
                                            servingUnit: customFood.servingUnit ?? "serving",
                                            calories: customFood.calories,
                                            protein: customFood.protein,
                                            carbs: customFood.carbs,
                                            fat: customFood.fat,
                                            fiber: customFood.fiber,
                                            sugar: customFood.sugar,
                                            sodium: customFood.sodium,
                                            cholesterol: customFood.cholesterol,
                                            saturatedFat: customFood.saturatedFat,
                                            barcode: customFood.barcode,
                                            isCommon: false
                                        )
                                        onSelect(foodItem)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Foods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCustomFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            performSearch()
        }
        .sheet(isPresented: $showingAddCustomFood) {
            AddCustomFoodView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    func performSearch() {
        // Search built-in database
        if selectedSource == .all || selectedSource == .database {
            searchResults = FoodDatabase.shared.searchFoods(searchText)
            // Filter by category if selected
            if let category = selectedCategory {
                searchResults = searchResults.filter { $0.category == category }
            }
        } else {
            searchResults = []
        }
    }
    
    func filterCustomFoods() -> [CustomFood] {
        var filtered = Array(allCustomFoods)
        
        // Filter by source
        switch selectedSource {
        case .usda:
            filtered = filtered.filter { $0.source == "USDA" }
        case .userCreated:
            filtered = filtered.filter { $0.isUserCreated }
        default:
            break
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { food in
                (food.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (food.brand ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category.rawValue }
        }
        
        return filtered
    }
}

struct CustomFoodRowView: View {
    let customFood: CustomFood
    let onTap: () -> Void
    
    var sourceIcon: String {
        if customFood.source == "USDA" {
            return "leaf.fill"
        } else if customFood.isUserCreated {
            return "person.fill"
        } else {
            return "doc.text.fill"
        }
    }
    
    var sourceColor: Color {
        if customFood.source == "USDA" {
            return .green
        } else if customFood.isUserCreated {
            return .mindfulTeal
        } else {
            return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(customFood.name ?? "Unknown Food")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: sourceIcon)
                        .font(.caption)
                        .foregroundColor(sourceColor)
                }
                
                if let brand = customFood.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("\(customFood.servingSize ?? "1") \(customFood.servingUnit ?? "serving")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(customFood.calories)) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        MacroLabel(value: customFood.protein, label: "P", color: .blue)
                        MacroLabel(value: customFood.carbs, label: "C", color: .orange)
                        MacroLabel(value: customFood.fat, label: "F", color: .purple)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct MacroLabel: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(Int(value))")
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(color)
    }
}

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
                    
                    Spacer()
                    
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if let brand = food.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("\(food.servingSize) \(food.servingUnit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(food.calories)) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        MacroLabel(value: food.protein, label: "P", color: .blue)
                        MacroLabel(value: food.carbs, label: "C", color: .orange)
                        MacroLabel(value: food.fat, label: "F", color: .purple)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}