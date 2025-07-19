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
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
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
                    .disabled(supplementName.isEmpty || nutrients.isEmpty)
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
        }
    }
    
    func saveSupplement() {
        let newSupplement = SupplementEntry(context: viewContext)
        newSupplement.id = UUID()
        newSupplement.name = supplementName
        newSupplement.brand = brand.isEmpty ? nil : brand
        newSupplement.servingSize = servingSize
        newSupplement.timestamp = Date()
        
        // Convert nutrients to dictionary
        var nutrientDict: [String: Double] = [:]
        for nutrient in nutrients {
            nutrientDict[nutrient.id] = nutrient.amount
        }
        // Store as NSData for Core Data Transformable attribute
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: nutrientDict, requiringSecureCoding: false) {
            newSupplement.setValue(data, forKey: "nutrients")
        }
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving supplement: \(error)")
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