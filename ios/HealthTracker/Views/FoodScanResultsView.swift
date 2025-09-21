import SwiftUI

struct FoodScanResultsView: View {
    let scanResult: FoodScanResult
    let capturedImage: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedMealType: MealType = .lunch
    @State private var adjustedFoods: [IdentifiedFood] = []
    @State private var showingSaveConfirmation = false
    
    init(scanResult: FoodScanResult, capturedImage: UIImage?) {
        self.scanResult = scanResult
        self.capturedImage = capturedImage
        self._adjustedFoods = State(initialValue: scanResult.identifiedFoods)
    }
    
    var totalNutrition: NutritionInfo {
        let calories = adjustedFoods.reduce(0) { $0 + $1.calories }
        let protein = adjustedFoods.reduce(0) { $0 + $1.protein }
        let carbs = adjustedFoods.reduce(0) { $0 + $1.carbs }
        let fat = adjustedFoods.reduce(0) { $0 + $1.fat }
        
        return NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: scanResult.totalNutrition.fiber,
            sugar: scanResult.totalNutrition.sugar,
            sodium: scanResult.totalNutrition.sodium
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Captured Image
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    
                    // Meal Type Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add to meal")
                            .font(.headline)
                        
                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { meal in
                                Text(mealTypeDisplayName(meal)).tag(meal)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    // Identified Foods
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Identified Foods")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(adjustedFoods.indices, id: \.self) { index in
                            IdentifiedFoodCard(
                                food: $adjustedFoods[index],
                                onRemove: {
                                    adjustedFoods.remove(at: index)
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Total Nutrition Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Total Nutrition")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            NutritionSummaryItem(
                                label: "Calories",
                                value: "0",
                                color: Color(red: 127/255, green: 176/255, blue: 105/255)
                            )
                            
                            NutritionSummaryItem(
                                label: "Protein",
                                value: "0",
                                color: .blue
                            )
                            
                            NutritionSummaryItem(
                                label: "Carbs",
                                value: "0",
                                color: .orange
                            )
                            
                            NutritionSummaryItem(
                                label: "Fat",
                                value: "0",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveFoods) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save to Diary")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add Custom") {
                    // Add custom food item
                }
            )
            .alert("Foods Saved", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("The identified foods have been added to your \(mealTypeDisplayName(selectedMealType)).")
            }
        }
    }
    
    private func saveFoods() {
        for food in adjustedFoods {
            let entry = FoodEntry(context: viewContext)
            entry.id = UUID()
            entry.name = food.name
            entry.calories = food.calories
            entry.protein = food.protein
            entry.carbs = food.carbs
            entry.fat = food.fat
            entry.servingSize = "\(Int(food.estimatedWeight))"
            entry.servingUnit = "g"
            entry.mealType = selectedMealType.rawValue
            entry.timestamp = Date()
            entry.date = Date()
        }
        
        do {
            try viewContext.save()
            showingSaveConfirmation = true
        } catch {
            print("Error saving foods: \(error)")
        }
    }
    
    private func mealTypeDisplayName(_ mealType: MealType) -> String {
        switch mealType {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
}

struct IdentifiedFoodCard: View {
    @Binding var food: IdentifiedFood
    let onRemove: () -> Void
    @State private var showingPortionAdjuster = false
    
    var confidenceColor: Color {
        if food.confidence > 0.9 {
            return .green
        } else if food.confidence > 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                    
                    HStack {
                        Label("\(Int(food.confidence * 100))% match", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(confidenceColor)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(food.estimatedWeight))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack(spacing: 16) {
                MacroInfo(value: Int(food.calories), label: "cal", color: .gray)
                MacroInfo(value: Int(food.protein), label: "g protein", color: .blue)
                MacroInfo(value: Int(food.carbs), label: "g carbs", color: .orange)
                MacroInfo(value: Int(food.fat), label: "g fat", color: .purple)
            }
            
            Button(action: { showingPortionAdjuster = true }) {
                Label("Adjust Portion", systemImage: "slider.horizontal.3")
                    .font(.caption)
                    .foregroundColor(Color(red: 74/255, green: 155/255, blue: 155/255))
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingPortionAdjuster) {
            PortionAdjusterView(food: $food)
        }
    }
}

struct MacroInfo: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NutritionSummaryItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PortionAdjusterView: View {
    @Binding var food: IdentifiedFood
    @Environment(\.presentationMode) var presentationMode
    @State private var adjustedWeight: Double
    
    init(food: Binding<IdentifiedFood>) {
        self._food = food
        self._adjustedWeight = State(initialValue: food.wrappedValue.estimatedWeight)
    }
    
    var scaleFactor: Double {
        adjustedWeight / food.estimatedWeight
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Adjust Portion Size")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(food.name)
                            .font(.headline)
                        
                        HStack {
                            Text("Weight:")
                            Spacer()
                            Text("\(Int(adjustedWeight))g")
                                .fontWeight(.semibold)
                        }
                        
                        Slider(value: $adjustedWeight, in: 10...500, step: 5)
                            .accentColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    }
                }
                
                Section(header: Text("Updated Nutrition")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(Int(food.calories * scaleFactor))")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        Text("\(Int(food.protein * scaleFactor))g")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        Text("\(Int(food.carbs * scaleFactor))g")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        Text("\(Int(food.fat * scaleFactor))g")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Adjust Portion")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    // Update the food with new values
                    food = IdentifiedFood(
                        name: food.name,
                        confidence: food.confidence,
                        estimatedWeight: adjustedWeight,
                        calories: food.calories * scaleFactor,
                        protein: food.protein * scaleFactor,
                        carbs: food.carbs * scaleFactor,
                        fat: food.fat * scaleFactor,
                        category: food.category
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// #Preview {
//     FoodScanResultsView(
//         scanResult: FoodScanResult(
//             id: UUID(),
//             timestamp: Date(),
//             identifiedFoods: [
//                 IdentifiedFood(
//                     name: "Grilled Chicken",
//                     confidence: 0.92,
//                     estimatedWeight: 150,
//                     calories: 250,
//                     protein: 46,
//                     carbs: 0,
//                     fat: 5.5,
//                     category: .protein
//                 )
//             ],
//             totalNutrition: NutritionInfo(
//                 calories: 250,
//                 protein: 46,
//                 carbs: 0,
//                 fat: 5.5,
//                 fiber: 0,
//                 sugar: 0,
//                 sodium: 100
//             )
//         ),
//         capturedImage: nil
//     )
// }