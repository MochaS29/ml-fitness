import SwiftUI
import CoreData

struct AddCustomFoodView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var brand = ""
    @State private var servingSize = ""
    @State private var servingUnit = ""
    @State private var category = FoodCategory.other
    
    // Macros
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0
    @State private var fiber: Double = 0
    @State private var sugar: Double = 0
    @State private var sodium: Double = 0
    @State private var cholesterol: Double = 0
    @State private var saturatedFat: Double = 0
    
    // Additional nutrients
    @State private var showingAdditionalNutrients = false
    @State private var additionalNutrients: [String: Double] = [:]
    
    @State private var barcode = ""
    @State private var showingBarcodeScanner = false
    
    var isValid: Bool {
        !name.isEmpty && !servingSize.isEmpty && !servingUnit.isEmpty && calories > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Food Name", text: $name)
                    TextField("Brand (Optional)", text: $brand)
                    
                    Picker("Category", selection: $category) {
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    HStack {
                        TextField("Serving Size", text: $servingSize)
                            .keyboardType(.decimalPad)
                        TextField("Unit (g, oz, cup, etc.)", text: $servingUnit)
                    }
                    
                    // Barcode scanner temporarily disabled - coming in next release
                    // HStack {
                    //     TextField("Barcode (Optional)", text: $barcode)
                    //     Button(action: { showingBarcodeScanner = true }) {
                    //         Image(systemName: "barcode.viewfinder")
                    //     }
                    // }
                }
                
                Section("Nutrition Facts (per serving)") {
                    NutritionInputRow(label: "Calories", value: $calories, unit: "cal")
                    NutritionInputRow(label: "Protein", value: $protein, unit: "g")
                    NutritionInputRow(label: "Total Carbs", value: $carbs, unit: "g")
                    NutritionInputRow(label: "Total Fat", value: $fat, unit: "g")
                    NutritionInputRow(label: "Fiber", value: $fiber, unit: "g")
                    NutritionInputRow(label: "Sugar", value: $sugar, unit: "g")
                    NutritionInputRow(label: "Sodium", value: $sodium, unit: "mg")
                    NutritionInputRow(label: "Cholesterol", value: $cholesterol, unit: "mg")
                    NutritionInputRow(label: "Saturated Fat", value: $saturatedFat, unit: "g")
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
                        // Vitamins
                        Group {
                            Text("Vitamins").font(.headline)
                            NutritionInputRow(label: "Vitamin A", value: binding(for: "vitamin_a"), unit: "mcg")
                            NutritionInputRow(label: "Vitamin C", value: binding(for: "vitamin_c"), unit: "mg")
                            NutritionInputRow(label: "Vitamin D", value: binding(for: "vitamin_d"), unit: "mcg")
                            NutritionInputRow(label: "Vitamin E", value: binding(for: "vitamin_e"), unit: "mg")
                            NutritionInputRow(label: "Vitamin K", value: binding(for: "vitamin_k"), unit: "mcg")
                            NutritionInputRow(label: "Thiamin (B1)", value: binding(for: "thiamin"), unit: "mg")
                            NutritionInputRow(label: "Riboflavin (B2)", value: binding(for: "riboflavin"), unit: "mg")
                            NutritionInputRow(label: "Niacin (B3)", value: binding(for: "niacin"), unit: "mg")
                            NutritionInputRow(label: "Vitamin B6", value: binding(for: "vitamin_b6"), unit: "mg")
                            NutritionInputRow(label: "Folate", value: binding(for: "folate"), unit: "mcg")
                        }
                        
                        Group {
                            NutritionInputRow(label: "Vitamin B12", value: binding(for: "vitamin_b12"), unit: "mcg")
                            NutritionInputRow(label: "Biotin", value: binding(for: "biotin"), unit: "mcg")
                            NutritionInputRow(label: "Pantothenic Acid", value: binding(for: "pantothenic_acid"), unit: "mg")
                        }
                        
                        // Minerals
                        Group {
                            Text("Minerals").font(.headline)
                            NutritionInputRow(label: "Calcium", value: binding(for: "calcium"), unit: "mg")
                            NutritionInputRow(label: "Iron", value: binding(for: "iron"), unit: "mg")
                            NutritionInputRow(label: "Magnesium", value: binding(for: "magnesium"), unit: "mg")
                            NutritionInputRow(label: "Phosphorus", value: binding(for: "phosphorus"), unit: "mg")
                            NutritionInputRow(label: "Potassium", value: binding(for: "potassium"), unit: "mg")
                            NutritionInputRow(label: "Zinc", value: binding(for: "zinc"), unit: "mg")
                            NutritionInputRow(label: "Copper", value: binding(for: "copper"), unit: "mg")
                            NutritionInputRow(label: "Manganese", value: binding(for: "manganese"), unit: "mg")
                            NutritionInputRow(label: "Selenium", value: binding(for: "selenium"), unit: "mcg")
                        }
                    }
                }
            }
            .navigationTitle("Add Custom Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomFood()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            // Barcode scanner view
        }
    }
    
    func binding(for nutrient: String) -> Binding<Double> {
        return Binding<Double>(
            get: { additionalNutrients[nutrient] ?? 0 },
            set: { additionalNutrients[nutrient] = $0 }
        )
    }
    
    func saveCustomFood() {
        let customFood = CustomFood(context: viewContext)
        customFood.id = UUID()
        customFood.name = name
        customFood.brand = brand.isEmpty ? nil : brand
        customFood.category = category.rawValue
        customFood.servingSize = servingSize
        customFood.servingUnit = servingUnit
        customFood.calories = calories
        customFood.protein = protein
        customFood.carbs = carbs
        customFood.fat = fat
        customFood.fiber = fiber
        customFood.sugar = sugar
        customFood.sodium = sodium
        customFood.cholesterol = cholesterol
        customFood.saturatedFat = saturatedFat
        customFood.barcode = barcode.isEmpty ? nil : barcode
        customFood.isUserCreated = true
        customFood.createdDate = Date()
        customFood.source = "User"
        
        // Add basic nutrients to additional nutrients
        additionalNutrients["calories"] = calories
        additionalNutrients["protein"] = protein
        additionalNutrients["carbs"] = carbs
        additionalNutrients["fat"] = fat
        additionalNutrients["fiber"] = fiber
        additionalNutrients["sugar"] = sugar
        additionalNutrients["sodium"] = sodium
        additionalNutrients["cholesterol"] = cholesterol
        additionalNutrients["saturatedFat"] = saturatedFat
        
        customFood.additionalNutrients = additionalNutrients
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving custom food: \(error)")
        }
    }
}

struct NutritionInputRow: View {
    let label: String
    @Binding var value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.decimalPad)
            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
    }
}