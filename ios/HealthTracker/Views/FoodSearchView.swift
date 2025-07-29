import SwiftUI

struct FoodSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?
    @State private var searchResults: [FoodItem] = []
    
    let onSelect: (FoodItem) -> Void
    private let foodDatabase = FoodDatabase.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search foods...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onChange(of: searchText) {
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
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FoodCategoryChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: {
                                selectedCategory = nil
                                performSearch()
                            }
                        )
                        
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            FoodCategoryChip(
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
                .padding(.bottom)
                
                // Results List
                if searchText.isEmpty && selectedCategory == nil {
                    // Show common foods when no search
                    List {
                        Section("Common Foods") {
                            ForEach(foodDatabase.getCommonFoods()) { food in
                                FoodSearchRow(food: food) {
                                    onSelect(food)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                } else if searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.lightGray)
                        
                        Text("No foods found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for a different food")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List(searchResults) { food in
                        FoodSearchRow(food: food) {
                            onSelect(food)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Food Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                performSearch()
            }
        }
    }
    
    func performSearch() {
        if searchText.isEmpty && selectedCategory == nil {
            searchResults = []
        } else if let category = selectedCategory, searchText.isEmpty {
            searchResults = foodDatabase.getFoodsByCategory(category)
        } else {
            var results = foodDatabase.searchFoods(searchText)
            if let category = selectedCategory {
                results = results.filter { $0.category == category }
            }
            searchResults = results
        }
    }
}

struct FoodSearchRow: View {
    let food: FoodItem
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(food.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let brand = food.brand {
                                Text("• \(brand)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("\(food.servingSize) \(food.servingUnit)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(Int(food.calories)) cal")
                            .font(.headline)
                            .foregroundColor(.mochaBrown)
                    }
                }
                
                // Macro breakdown
                HStack(spacing: 15) {
                    MacroTag(label: "P", value: food.protein, color: .red)
                    MacroTag(label: "C", value: food.carbs, color: .blue)
                    MacroTag(label: "F", value: food.fat, color: .green)
                    MacroTag(label: "Fiber", value: food.fiber, color: .brown)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct MacroTag: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
            Text("\(Int(value))g")
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(4)
    }
}

struct FoodCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.mindfulTeal : Color.lightGray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}