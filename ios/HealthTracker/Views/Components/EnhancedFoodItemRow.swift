import SwiftUI

struct EnhancedFoodItemRow: View {
    let food: FoodItem
    let userProfile: UserProfile?
    let onSelect: () -> Void
    
    @State private var detectedAllergens: [AllergenInfo] = []
    @State private var dietaryCompliance: DietaryComplianceResult?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Main content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        if let brand = food.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(food.calories)) cal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(food.servingSize) \(food.servingUnit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Warnings row
                if !detectedAllergens.isEmpty || (dietaryCompliance != nil && !dietaryCompliance!.isCompliant) {
                    HStack(spacing: 8) {
                        // Allergen warnings
                        if !detectedAllergens.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(allergenWarningColor)
                                
                                Text(allergenWarningText)
                                    .font(.caption)
                                    .foregroundColor(allergenWarningColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(allergenWarningColor.opacity(0.15))
                            .cornerRadius(6)
                        }
                        
                        // Dietary compliance
                        if let compliance = dietaryCompliance, !compliance.isCompliant {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                Text(dietaryWarningText(compliance))
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .onAppear {
            checkForAllergens()
            checkDietaryCompliance()
        }
    }
    
    private var allergenWarningColor: Color {
        let severestAllergen = detectedAllergens.max { a, b in
            let aSeverity = userProfile?.foodPreferences.allergies.first { $0.allergy == a.allergen }?.severity ?? .mild
            let bSeverity = userProfile?.foodPreferences.allergies.first { $0.allergy == b.allergen }?.severity ?? .mild
            return severityValue(aSeverity) < severityValue(bSeverity)
        }
        
        if let allergen = severestAllergen,
           let allergyInfo = userProfile?.foodPreferences.allergies.first(where: { $0.allergy == allergen.allergen }) {
            switch allergyInfo.severity {
            case .mild: return .yellow
            case .moderate: return .orange
            case .severe, .lifeThreatening: return .red
            }
        }
        
        return .orange
    }
    
    private var allergenWarningText: String {
        if detectedAllergens.count == 1 {
            return "Contains \(detectedAllergens[0].allergen.rawValue)"
        } else {
            return "Contains \(detectedAllergens.count) allergens"
        }
    }
    
    private func dietaryWarningText(_ compliance: DietaryComplianceResult) -> String {
        let violatedPreferences = compliance.violations.map { $0.preference.rawValue }
        if violatedPreferences.count == 1 {
            return "Not \(violatedPreferences[0])"
        } else {
            return "Violates \(violatedPreferences.count) preferences"
        }
    }
    
    private func severityValue(_ severity: AllergySeverity) -> Int {
        switch severity {
        case .mild: return 1
        case .moderate: return 2
        case .severe: return 3
        case .lifeThreatening: return 4
        }
    }
    
    private func checkForAllergens() {
        guard let profile = userProfile else { return }
        
        // For basic FoodItem, we can only check the food name and brand
        detectedAllergens = AllergenDetectionService.shared.checkFoodForAllergens(
            food.name,
            ingredients: nil,
            userProfile: profile
        )
    }
    
    private func checkDietaryCompliance() {
        guard let profile = userProfile else { return }
        
        let preferences = profile.foodPreferences.dietaryPreferences
        guard !preferences.isEmpty else { return }
        
        // For basic FoodItem, we can only check the food name
        dietaryCompliance = AllergenDetectionService.shared.checkDietaryCompliance(
            food.name,
            ingredients: nil,
            preferences: preferences
        )
    }
}

// MARK: - Enhanced Recipe Row

struct EnhancedRecipeRow: View {
    let recipe: Recipe
    let userProfile: UserProfile?
    let onSelect: () -> Void
    
    @State private var detectedAllergens: [AllergenInfo] = []
    @State private var showingAllergenDetails = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Main content
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Label("\(recipe.servings) servings", systemImage: "person.2")
                            Label("\(recipe.totalTime) min", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let nutrition = recipe.nutrition {
                        VStack(alignment: .trailing) {
                            Text("\(Int(nutrition.calories)) cal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("per serving")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Allergen warning
                if !detectedAllergens.isEmpty {
                    Button(action: { showingAllergenDetails = true }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            
                            Text("Contains \(detectedAllergens.count) allergen\(detectedAllergens.count == 1 ? "" : "s")")
                                .font(.caption)
                            
                            ForEach(detectedAllergens.prefix(3), id: \.allergen) { info in
                                Text(info.allergen.icon)
                                    .font(.caption)
                            }
                            
                            if detectedAllergens.count > 3 {
                                Text("+\(detectedAllergens.count - 3)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(allergenWarningColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(allergenWarningColor.opacity(0.15))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .onAppear {
            checkForAllergens()
        }
        .sheet(isPresented: $showingAllergenDetails) {
            RecipeAllergenDetails(recipe: recipe, allergens: detectedAllergens)
        }
    }
    
    private var allergenWarningColor: Color {
        // Similar logic as EnhancedFoodItemRow
        let hasSevereAllergy = detectedAllergens.contains { allergen in
            if let allergyInfo = userProfile?.foodPreferences.allergies.first(where: { $0.allergy == allergen.allergen }) {
                return allergyInfo.severity == .severe || allergyInfo.severity == .lifeThreatening
            }
            return false
        }
        
        return hasSevereAllergy ? .red : .orange
    }
    
    private func checkForAllergens() {
        guard let profile = userProfile else { return }
        detectedAllergens = AllergenDetectionService.shared.checkRecipe(recipe, userProfile: profile)
    }
}

// MARK: - Recipe Allergen Details

struct RecipeAllergenDetails: View {
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe
    let allergens: [AllergenInfo]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Detected Allergens")) {
                    ForEach(allergens, id: \.allergen) { info in
                        HStack {
                            Text(info.allergen.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(info.allergen.rawValue)
                                    .font(.headline)
                                Text("Found in: \(info.ingredientSource)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("All Ingredients")) {
                    ForEach(recipe.ingredients) { ingredient in
                        Text("• \(ingredient.fullDescription)")
                            .font(.body)
                    }
                }
            }
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

