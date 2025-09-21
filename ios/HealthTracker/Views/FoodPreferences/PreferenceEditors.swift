import SwiftUI

// MARK: - Disliked Foods Editor

struct DislikedFoodsEditor: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var newFood = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                HStack {
                    TextField("Add disliked food", text: $newFood)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addFood()
                        }
                    
                    Button("Add") {
                        addFood()
                    }
                    .disabled(newFood.isEmpty)
                    
                    Button("Done") {
                        isEditing = false
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if !(userProfileManager.currentProfile?.foodPreferences.dislikedFoods ?? []).isEmpty {
                        ForEach(userProfileManager.currentProfile?.foodPreferences.dislikedFoods ?? [], id: \.self) { food in
                            FoodChip(text: food) {
                                removeFood(food)
                            }
                        }
                    }
                    
                    Button(action: { isEditing = true }) {
                        Label("Add", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundColor(.wellnessGreen)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func addFood() {
        guard !newFood.isEmpty else { return }
        
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.dislikedFoods.append(newFood)
            userProfileManager.saveProfile(profile)
        }
        newFood = ""
    }
    
    private func removeFood(_ food: String) {
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.dislikedFoods.removeAll { $0 == food }
            userProfileManager.saveProfile(profile)
        }
    }
}

// MARK: - Avoided Ingredients Editor

struct AvoidedIngredientsEditor: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var newIngredient = ""
    @State private var isEditing = false
    
    // Common ingredients to avoid
    let suggestions = ["MSG", "Artificial Colors", "High Fructose Corn Syrup", "Preservatives", "Artificial Flavors", "Palm Oil", "Hydrogenated Oils"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Add ingredient to avoid", text: $newIngredient)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                addIngredient()
                            }
                        
                        Button("Add") {
                            addIngredient()
                        }
                        .disabled(newIngredient.isEmpty)
                        
                        Button("Done") {
                            isEditing = false
                        }
                    }
                    
                    // Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions.filter { !isAlreadyAdded($0) }, id: \.self) { suggestion in
                                Button(action: {
                                    newIngredient = suggestion
                                    addIngredient()
                                }) {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if !(userProfileManager.currentProfile?.foodPreferences.avoidIngredients ?? []).isEmpty {
                        ForEach(userProfileManager.currentProfile?.foodPreferences.avoidIngredients ?? [], id: \.self) { ingredient in
                            FoodChip(text: ingredient) {
                                removeIngredient(ingredient)
                            }
                        }
                    }
                    
                    Button(action: { isEditing = true }) {
                        Label("Add", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundColor(.wellnessGreen)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func isAlreadyAdded(_ ingredient: String) -> Bool {
        userProfileManager.currentProfile?.foodPreferences.avoidIngredients.contains(ingredient) ?? false
    }
    
    private func addIngredient() {
        guard !newIngredient.isEmpty else { return }
        
        if !isAlreadyAdded(newIngredient) {
            if var profile = userProfileManager.currentProfile {
                profile.foodPreferences.avoidIngredients.append(newIngredient)
                userProfileManager.saveProfile(profile)
            }
        }
        newIngredient = ""
    }
    
    private func removeIngredient(_ ingredient: String) {
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.avoidIngredients.removeAll { $0 == ingredient }
            userProfileManager.saveProfile(profile)
        }
    }
}

// MARK: - Meal Preferences Editor

struct MealPreferencesEditor: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var portionSize: PortionPreference = .normal
    @State private var spiceLevel: SpiceLevel = .medium
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Portion Size
            VStack(alignment: .leading, spacing: 8) {
                Text("Portion Size")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Portion Size", selection: $portionSize) {
                    ForEach(PortionPreference.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: portionSize) { oldValue, newValue in
                    if var profile = userProfileManager.currentProfile {
                        profile.foodPreferences.mealPreferences.portionSize = newValue
                        userProfileManager.saveProfile(profile)
                    }
                }
            }
            
            // Spice Level
            VStack(alignment: .leading, spacing: 8) {
                Text("Spice Tolerance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Spice Level", selection: $spiceLevel) {
                    ForEach(SpiceLevel.allCases, id: \.self) { level in
                        HStack {
                            Text(level.rawValue)
                            Text(spiceIcon(for: level))
                        }
                        .tag(level)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: spiceLevel) { oldValue, newValue in
                    if var profile = userProfileManager.currentProfile {
                        profile.foodPreferences.mealPreferences.spiceLevel = newValue
                        userProfileManager.saveProfile(profile)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            portionSize = userProfileManager.currentProfile?.foodPreferences.mealPreferences.portionSize ?? .normal
            spiceLevel = userProfileManager.currentProfile?.foodPreferences.mealPreferences.spiceLevel ?? .medium
        }
    }
    
    private func spiceIcon(for level: SpiceLevel) -> String {
        switch level {
        case .none: return "🥛"
        case .mild: return "🌶️"
        case .medium: return "🌶️🌶️"
        case .hot: return "🌶️🌶️🌶️"
        case .veryHot: return "🔥🔥🔥"
        }
    }
}

// MARK: - Food Chip

struct FoodChip: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}

// #Preview {
//     VStack(spacing: 20) {
//         DislikedFoodsEditor()
//         AvoidedIngredientsEditor()
//         MealPreferencesEditor()
//     }
//     .environmentObject(UserProfileManager())
// }