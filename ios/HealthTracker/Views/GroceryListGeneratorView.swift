import SwiftUI
import CoreData

struct GroceryListGeneratorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var groceryItems: [GroceryItem] = []
    @State private var isGenerating = false
    @State private var selectedList: GroceryList?
    @State private var showingListSelector = false
    @State private var showingNewList = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.date, ascending: true)]
    ) private var mealPlans: FetchedResults<MealPlan>
    
    var filteredMealPlans: [MealPlan] {
        mealPlans.filter { mealPlan in
            guard let date = mealPlan.date else { return false }
            return date >= startDate && date <= endDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date range selector
                VStack(spacing: 16) {
                    Text("Generate Grocery List")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("From")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("To")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                    
                    // Meal count
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.secondary)
                        Text("\(filteredMealPlans.count) meals planned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                
                if groceryItems.isEmpty && !isGenerating {
                    // Empty state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Generate a grocery list from your meal plans")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: generateGroceryList) {
                            Label("Generate List", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.wellnessGreen)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    Spacer()
                } else if isGenerating {
                    // Loading state
                    Spacer()
                    ProgressView("Generating list...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    // Generated list
                    List {
                        ForEach(GroceryCategory.allCases, id: \.self) { category in
                            let items = groceryItems.filter { $0.category == category }
                            if !items.isEmpty {
                                Section(category.rawValue) {
                                    ForEach(items) { item in
                                        GeneratedGroceryItemRow(item: item)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: { showingListSelector = true }) {
                            Label("Add to Grocery List", systemImage: "cart.badge.plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.wellnessGreen)
                                .cornerRadius(10)
                        }
                        
                        Button(action: shareList) {
                            Label("Share List", systemImage: "square.and.arrow.up")
                                .font(.subheadline)
                                .foregroundColor(.wellnessGreen)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Grocery List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !groceryItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Regenerate") {
                            generateGroceryList()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingListSelector) {
                GroceryListSelector(
                    groceryItems: groceryItems,
                    onSelect: { list in
                        addItemsToList(list)
                    },
                    showingNewList: $showingNewList
                )
            }
            .sheet(isPresented: $showingNewList) {
                CreateGroceryListView { newList in
                    selectedList = newList
                    addItemsToList(newList)
                }
            }
        }
    }
    
    private func generateGroceryList() {
        isGenerating = true
        groceryItems = []
        
        // Simulate async generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var ingredientMap: [String: GroceryItem] = [:]
            
            for mealPlan in filteredMealPlans {
                // Get recipe ingredients
                if let recipeName = mealPlan.recipeName {
                    // Find recipe in database
                    if let recipe = RecipeDatabase.shared.recipes.first(where: { $0.name == recipeName }) {
                        for ingredient in recipe.ingredients {
                            let key = ingredient.name.lowercased()
                            
                            if let existing = ingredientMap[key] {
                                // Update amount
                                existing.amount += ingredient.amount * Double(mealPlan.servings)
                            } else {
                                // Create new grocery item
                                let groceryItem = GroceryItem(
                                    name: ingredient.name,
                                    amount: ingredient.amount * Double(mealPlan.servings),
                                    unit: ingredient.unit.rawValue,
                                    category: ingredient.category
                                )
                                ingredientMap[key] = groceryItem
                            }
                        }
                    }
                }
            }
            
            groceryItems = Array(ingredientMap.values).sorted { $0.name < $1.name }
            isGenerating = false
        }
    }
    
    private func addItemsToList(_ list: GroceryList) {
        // Implementation to add items to the selected grocery list
        dismiss()
    }
    
    private func shareList() {
        let text = generateShareText()
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func generateShareText() -> String {
        var text = "Grocery List\n"
        text += "Generated from meal plans: \(startDate.formatted(date: .abbreviated, time: .omitted)) - \(endDate.formatted(date: .abbreviated, time: .omitted))\n\n"
        
        for category in GroceryCategory.allCases {
            let items = groceryItems.filter { $0.category == category }
            if !items.isEmpty {
                text += "\(category.rawValue):\n"
                for item in items {
                    text += "• \(item.name) - \(item.formattedAmount)\n"
                }
                text += "\n"
            }
        }
        
        return text
    }
}

// Grocery item model
class GroceryItem: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    @Published var amount: Double
    let unit: String
    let category: GroceryCategory
    @Published var isChecked = false
    
    init(name: String, amount: Double, unit: String, category: GroceryCategory) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let amountString = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(amountString) \(unit)"
    }
}

// Grocery item row
struct GeneratedGroceryItemRow: View {
    @ObservedObject var item: GroceryItem
    
    var body: some View {
        HStack {
            Button(action: { item.isChecked.toggle() }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .wellnessGreen : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isChecked)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                
                Text(item.formattedAmount)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            item.isChecked.toggle()
        }
    }
}

// Grocery list selector
struct GroceryListSelector: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let groceryItems: [GroceryItem]
    let onSelect: (GroceryList) -> Void
    @Binding var showingNewList: Bool
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GroceryList.createdDate, ascending: false)]
    ) private var groceryLists: FetchedResults<GroceryList>
    
    var body: some View {
        NavigationView {
            List {
                // Create new list option
                Button(action: {
                    dismiss()
                    showingNewList = true
                }) {
                    Label("Create New List", systemImage: "plus.circle.fill")
                        .foregroundColor(.wellnessGreen)
                }
                
                // Existing lists
                Section("Existing Lists") {
                    ForEach(groceryLists) { list in
                        Button(action: {
                            onSelect(list)
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.name ?? "Untitled List")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(list.items?.count ?? 0) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Create grocery list view
struct CreateGroceryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var listName = ""
    let onCreate: (GroceryList) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("List Name") {
                    TextField("Enter list name", text: $listName)
                }
            }
            .navigationTitle("New Grocery List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createList()
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
    }
    
    private func createList() {
        let newList = GroceryList(context: viewContext)
        newList.id = UUID()
        newList.name = listName
        newList.createdDate = Date()
        
        do {
            try viewContext.save()
            onCreate(newList)
            dismiss()
        } catch {
            print("Error creating grocery list: \(error)")
        }
    }
}

#Preview {
    GroceryListGeneratorView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}