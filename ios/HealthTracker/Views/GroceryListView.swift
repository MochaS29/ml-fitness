import SwiftUI

struct GroceryListView: View {
    let mealPlan: MealPlan?
    @State private var groceryItems: [GroceryItem] = []
    @State private var groupByCategory = true
    @State private var showingShareSheet = false
    
    var groupedItems: [GroceryCategory: [GroceryItem]] {
        Dictionary(grouping: groceryItems) { $0.ingredient.category }
    }
    
    var checkedItemsCount: Int {
        groceryItems.filter { $0.isChecked }.count
    }
    
    var body: some View {
        VStack {
            if groceryItems.isEmpty {
                EmptyGroceryListView()
            } else {
                // Progress header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Shopping Progress")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(checkedItemsCount) of \(groceryItems.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: Double(checkedItemsCount), total: Double(groceryItems.count))
                        .tint(.wellnessGreen)
                }
                .padding()
                .background(Color.lightGray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Group toggle
                Toggle("Group by category", isOn: $groupByCategory)
                    .padding(.horizontal)
                
                // Grocery list
                List {
                    if groupByCategory {
                        ForEach(GroceryCategory.allCases, id: \.self) { category in
                            if let items = groupedItems[category], !items.isEmpty {
                                Section(category.rawValue) {
                                    ForEach(items) { item in
                                        GroceryItemRow(item: item) {
                                            toggleItem(item)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        ForEach(groceryItems) { item in
                            GroceryItemRow(item: item) {
                                toggleItem(item)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            generateGroceryList()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [generateShareableList()])
        }
    }
    
    func generateGroceryList() {
        guard let plan = mealPlan else { return }
        
        // Combine ingredients from all recipes
        var ingredientMap: [String: (Ingredient, Double)] = [:]
        
        for meal in plan.meals {
            for ingredient in meal.recipe.ingredients {
                let key = "\(ingredient.name)-\(ingredient.unit.rawValue)"
                if let existing = ingredientMap[key] {
                    // Combine quantities
                    let newQuantity = existing.1 + (ingredient.amount * meal.servingsMultiplier)
                    ingredientMap[key] = (ingredient, newQuantity)
                } else {
                    ingredientMap[key] = (ingredient, ingredient.amount * meal.servingsMultiplier)
                }
            }
        }
        
        // Convert to grocery items
        groceryItems = ingredientMap.values.map { ingredient, quantity in
            var adjustedIngredient = ingredient
            adjustedIngredient.amount = quantity
            return GroceryItem(
                ingredient: adjustedIngredient,
                isChecked: false,
                quantity: quantity,
                notes: nil
            )
        }.sorted { $0.ingredient.category.rawValue < $1.ingredient.category.rawValue }
    }
    
    func toggleItem(_ item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[index].isChecked.toggle()
        }
    }
    
    func generateShareableList() -> String {
        var text = "Grocery List\n\n"
        
        if groupByCategory {
            for category in GroceryCategory.allCases {
                if let items = groupedItems[category], !items.isEmpty {
                    text += "\(category.rawValue):\n"
                    for item in items {
                        let check = item.isChecked ? "✓" : "○"
                        text += "\(check) \(item.displayText)\n"
                    }
                    text += "\n"
                }
            }
        } else {
            for item in groceryItems {
                let check = item.isChecked ? "✓" : "○"
                text += "\(check) \(item.displayText)\n"
            }
        }
        
        return text
    }
}

struct EmptyGroceryListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.lightGray)
            
            Text("No items in your grocery list")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add meals to your weekly plan to generate a grocery list")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .wellnessGreen : .lightGray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredient.fullDescription)
                    .strikethrough(item.isChecked)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                
                if let notes = item.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}