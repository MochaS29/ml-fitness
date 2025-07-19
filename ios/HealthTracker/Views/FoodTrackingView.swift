import SwiftUI

struct FoodTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddFood = false
    @State private var selectedMealType = MealType.breakfast
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
        animation: .default)
    private var foods: FetchedResults<FoodEntry>
    
    var body: some View {
        NavigationView {
            VStack {
                if foods.isEmpty {
                    EmptyFoodView(showingAddFood: $showingAddFood)
                } else {
                    List {
                        Section {
                            CalorieSummaryCard(foods: Array(foods))
                        }
                        
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Section(mealType.rawValue) {
                                ForEach(foods.filter { $0.mealType == mealType.rawValue }) { food in
                                    FoodRow(food: food)
                                }
                                .onDelete { offsets in
                                    deleteFoods(offsets: offsets, mealType: mealType)
                                }
                                
                                Button(action: {
                                    selectedMealType = mealType
                                    showingAddFood = true
                                }) {
                                    Label("Add \(mealType.rawValue)", systemImage: "plus.circle")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food Tracking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(mealType: selectedMealType)
            }
        }
    }
    
    func deleteFoods(offsets: IndexSet, mealType: MealType) {
        let mealFoods = foods.filter { $0.mealType == mealType.rawValue }
        withAnimation {
            offsets.map { mealFoods[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting food: \(error)")
            }
        }
    }
}

struct EmptyFoodView: View {
    @Binding var showingAddFood: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Food Tracked Today")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your meals to monitor calories and nutrients")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddFood = true }) {
                Label("Add Food", systemImage: "plus.circle")
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct CalorieSummaryCard: View {
    let foods: [FoodEntry]
    
    var totalCalories: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        foods.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        foods.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        foods.reduce(0) { $0 + $1.fat }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Today's Summary")
                .font(.headline)
            
            HStack {
                MacroView(value: totalCalories, unit: "cal", label: "Calories", color: .orange)
                MacroView(value: totalProtein, unit: "g", label: "Protein", color: .red)
                MacroView(value: totalCarbs, unit: "g", label: "Carbs", color: .blue)
                MacroView(value: totalFat, unit: "g", label: "Fat", color: .green)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct MacroView: View {
    let value: Double
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodRow: View {
    let food: FoodEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name ?? "Unknown Food")
                    .font(.headline)
                
                if let servingSize = food.servingSize {
                    Text(servingSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(Int(food.calories)) cal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 5) {
                    Text("P: \(Int(food.protein))g")
                    Text("C: \(Int(food.carbs))g")
                    Text("F: \(Int(food.fat))g")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddFoodView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let mealType: MealType
    
    @State private var foodName = ""
    @State private var servingSize = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0
    @State private var fiber: Double = 0
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var searchResults: [FoodItem] = []
    
    private let foodDatabase = FoodDatabase.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: { showingSearch = true }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search Food Database")
                            Spacer()
                            Text("\(foodDatabase.foods.count) foods")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.mindfulTeal)
                }
                
                Section("Food Details") {
                    TextField("Food Name", text: $foodName)
                    TextField("Serving Size", text: $servingSize)
                        .placeholder(when: servingSize.isEmpty) {
                            Text("e.g., 1 cup, 100g").foregroundColor(.gray.opacity(0.5))
                        }
                }
                
                Section("Nutrition Facts") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Fiber (g)")
                        Spacer()
                        TextField("0", value: $fiber, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add \(mealType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(foodName.isEmpty)
                }
            }
            .sheet(isPresented: $showingSearch) {
                EnhancedFoodSearchView { selectedFood in
                    // Populate fields with selected food
                    foodName = selectedFood.name
                    if let brand = selectedFood.brand {
                        foodName += " (\(brand))"
                    }
                    servingSize = "\(selectedFood.servingSize) \(selectedFood.servingUnit)"
                    calories = selectedFood.calories
                    protein = selectedFood.protein
                    carbs = selectedFood.carbs
                    fat = selectedFood.fat
                    fiber = selectedFood.fiber
                    showingSearch = false
                }
            }
        }
    }
    
    func saveFood() {
        let newFood = FoodEntry(context: viewContext)
        newFood.id = UUID()
        newFood.name = foodName
        newFood.servingSize = servingSize.isEmpty ? nil : servingSize
        newFood.calories = calories
        newFood.protein = protein
        newFood.carbs = carbs
        newFood.fat = fat
        newFood.fiber = fiber
        newFood.mealType = mealType.rawValue
        newFood.timestamp = Date()
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving food: \(error)")
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}