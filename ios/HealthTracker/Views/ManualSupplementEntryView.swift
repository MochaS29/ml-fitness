import SwiftUI

struct ManualSupplementEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var profileManager: UserProfileManager

    @State private var supplementName = ""
    @State private var brand = ""
    @State private var servingSize = "1 tablet"
    @State private var nutrients: [ManualNutrientEntry] = []
    @State private var showingNutrientPicker = false
    @State private var showingSupplementSelection = false
    @State private var showingBarcodeScanner = false
    @State private var selectedSupplement: Supplement?

    var body: some View {
        NavigationView {
            Form {
                Section("Select Supplement") {
                    Button(action: { showingSupplementSelection = true }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedSupplement?.name ?? "Choose from database")
                                    .foregroundColor(selectedSupplement != nil ? .primary : .blue)
                                if let supplement = selectedSupplement {
                                    Text("\(supplement.brand) • \(supplement.servingSize)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Button(action: { showingBarcodeScanner = true }) {
                        Label("Scan Barcode", systemImage: "barcode.viewfinder")
                            .foregroundColor(.blue)
                    }
                }

                Section("Or Enter Manually") {
                    TextField("Supplement Name", text: $supplementName)
                    TextField("Brand (Optional)", text: $brand)
                    TextField("Serving Size", text: $servingSize)
                }
                
                Section("Nutrients") {
                    ForEach(nutrients.indices, id: \.self) { index in
                        NutrientEntryRow(entry: $nutrients[index]) {
                            nutrients.remove(at: index)
                        }
                    }
                    
                    Button(action: { showingNutrientPicker = true }) {
                        Label("Add Nutrient", systemImage: "plus.circle")
                    }
                }
                
                if !nutrients.isEmpty {
                    Section("Personalized Analysis") {
                        if let profile = profileManager.currentProfile {
                            NutrientAnalysisPreview(
                                nutrients: nutrients,
                                profile: profile
                            )
                        }
                    }
                }
            }
            .navigationTitle("Add Supplement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSupplement()
                    }
                    .disabled(supplementName.isEmpty)
                }
            }
            .sheet(isPresented: $showingNutrientPicker) {
                NutrientPickerView { nutrient in
                    nutrients.append(ManualNutrientEntry(
                        id: nutrient.nutrientId,
                        name: nutrient.name,
                        amount: 0,
                        unit: .mg
                    ))
                }
            }
            .sheet(isPresented: $showingSupplementSelection) {
                SupplementSelectionView(
                    onSelect: { supplement in
                        selectedSupplement = supplement
                        supplementName = supplement.name
                        brand = supplement.brand
                        servingSize = supplement.servingSize
                        // Convert supplement nutrients to manual entries
                        loadNutrientsFromSupplement(supplement)
                        showingSupplementSelection = false
                    },
                    onCreateNew: { name in
                        supplementName = name
                        brand = ""
                        servingSize = "1 tablet"
                        showingSupplementSelection = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showingBarcodeScanner) {
                SupplementBarcodeScannerView()
            }
        }
    }

    func loadNutrientsFromSupplement(_ supplement: Supplement) {
        nutrients = []

        // Add vitamins
        if let vitA = supplement.vitamins.vitaminA {
            nutrients.append(ManualNutrientEntry(id: "vitaminA", name: "Vitamin A", amount: vitA.amount, unit: .mcg))
        }
        if let vitC = supplement.vitamins.vitaminC {
            nutrients.append(ManualNutrientEntry(id: "vitaminC", name: "Vitamin C", amount: vitC.amount, unit: .mg))
        }
        if let vitD = supplement.vitamins.vitaminD {
            nutrients.append(ManualNutrientEntry(id: "vitaminD", name: "Vitamin D", amount: vitD.amount, unit: .mcg))
        }
        if let vitE = supplement.vitamins.vitaminE {
            nutrients.append(ManualNutrientEntry(id: "vitaminE", name: "Vitamin E", amount: vitE.amount, unit: .mg))
        }
        if let b1 = supplement.vitamins.vitaminB1_thiamine {
            nutrients.append(ManualNutrientEntry(id: "thiamine", name: "Thiamine", amount: b1.amount, unit: .mg))
        }
        if let b2 = supplement.vitamins.vitaminB2_riboflavin {
            nutrients.append(ManualNutrientEntry(id: "riboflavin", name: "Riboflavin", amount: b2.amount, unit: .mg))
        }
        if let b3 = supplement.vitamins.vitaminB3_niacin {
            nutrients.append(ManualNutrientEntry(id: "niacin", name: "Niacin", amount: b3.amount, unit: .mg))
        }
        if let b6 = supplement.vitamins.vitaminB6 {
            nutrients.append(ManualNutrientEntry(id: "vitaminB6", name: "Vitamin B6", amount: b6.amount, unit: .mg))
        }
        if let b9 = supplement.vitamins.vitaminB9_folate {
            nutrients.append(ManualNutrientEntry(id: "folate", name: "Folate", amount: b9.amount, unit: .mcg))
        }
        if let b12 = supplement.vitamins.vitaminB12 {
            nutrients.append(ManualNutrientEntry(id: "vitaminB12", name: "Vitamin B12", amount: b12.amount, unit: .mcg))
        }

        // Add minerals
        if let calcium = supplement.minerals.calcium {
            nutrients.append(ManualNutrientEntry(id: "calcium", name: "Calcium", amount: calcium.amount, unit: .mg))
        }
        if let iron = supplement.minerals.iron {
            nutrients.append(ManualNutrientEntry(id: "iron", name: "Iron", amount: iron.amount, unit: .mg))
        }
        if let magnesium = supplement.minerals.magnesium {
            nutrients.append(ManualNutrientEntry(id: "magnesium", name: "Magnesium", amount: magnesium.amount, unit: .mg))
        }
        if let zinc = supplement.minerals.zinc {
            nutrients.append(ManualNutrientEntry(id: "zinc", name: "Zinc", amount: zinc.amount, unit: .mg))
        }

        // Add other ingredients (important for herbal supplements like EstroSmart)
        for ingredient in supplement.otherIngredients {
            if let amount = ingredient.amount {
                // Determine the unit based on the ingredient's unit string
                let unit: NutrientUnit = amount.unit.lowercased().contains("mg") ? .mg :
                                        amount.unit.lowercased().contains("mcg") ? .mcg :
                                        amount.unit.lowercased().contains("iu") ? .iu : .mg

                nutrients.append(ManualNutrientEntry(
                    id: ingredient.name.lowercased().replacingOccurrences(of: " ", with: "_"),
                    name: ingredient.name,
                    amount: amount.amount,
                    unit: unit
                ))
            }
        }
    }
    
    func saveSupplement() {
        let newSupplement = SupplementEntry(context: viewContext)
        newSupplement.id = UUID()
        newSupplement.name = supplementName
        newSupplement.brand = brand.isEmpty ? nil : brand
        newSupplement.servingSize = servingSize
        newSupplement.servingUnit = "serving"
        newSupplement.timestamp = Date()
        newSupplement.date = Date()

        // Convert nutrients to dictionary
        var nutrientDict: [String: Double] = [:]
        for nutrient in nutrients {
            nutrientDict[nutrient.id] = nutrient.amount
        }

        // Set nutrients directly - Core Data will handle the transformation
        if !nutrientDict.isEmpty {
            newSupplement.nutrients = nutrientDict
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving supplement: \(error)")
            // Show detailed error info
            if let nsError = error as NSError? {
                print("Core Data Error Code: \(nsError.code)")
                print("Core Data Error Domain: \(nsError.domain)")
                print("Core Data Error Info: \(nsError.userInfo)")
            }
        }
    }
}

struct ManualNutrientEntry: Identifiable {
    let id: String
    var name: String
    var amount: Double
    var unit: NutrientUnit
}

struct NutrientEntryRow: View {
    @Binding var entry: ManualNutrientEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(entry.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Amount", value: $entry.amount, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.decimalPad)
            
            Picker("Unit", selection: $entry.unit) {
                ForEach(NutrientUnit.allCases, id: \.self) { unit in
                    Text(unit.symbol).tag(unit)
                }
            }
            .pickerStyle(.menu)
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

extension NutrientUnit: CaseIterable {
    static var allCases: [NutrientUnit] {
        [.mg, .mcg, .g, .iu]
    }
}

struct NutrientPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSelect: (NutrientRDA) -> Void
    
    let nutrients = RDADatabase.shared.getAllNutrients()
    @State private var searchText = ""
    
    var filteredNutrients: [NutrientRDA] {
        if searchText.isEmpty {
            return nutrients
        } else {
            return nutrients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredNutrients, id: \.nutrientId) { nutrient in
                    Button(action: {
                        onSelect(nutrient)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(nutrient.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search nutrients")
            .navigationTitle("Select Nutrient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct NutrientAnalysisPreview: View {
    let nutrients: [ManualNutrientEntry]
    let profile: UserProfile
    
    var analyses: [NutrientAnalysis] {
        let calculator = RDACalculator()
        let intakes = nutrients.map { nutrient in
            NutrientIntake(nutrientId: nutrient.id, amount: nutrient.amount, unit: nutrient.unit)
        }
        return calculator.analyzeIntake(intakes, for: profile)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Based on your profile (\(profile.gender.rawValue), \(profile.age) years):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(analyses, id: \.nutrientId) { analysis in
                HStack {
                    Text(analysis.nutrientName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(analysis.percentageOfRDA))% of RDA")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(analysis.status.symbol)
                }
                
                if let recommendation = analysis.recommendation {
                    Text(recommendation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
    }
}