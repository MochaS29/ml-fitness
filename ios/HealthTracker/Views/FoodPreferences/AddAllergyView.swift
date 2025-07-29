import SwiftUI

struct AddAllergyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    @State private var selectedAllergy: FoodAllergy = .milk
    @State private var selectedSeverity: AllergySeverity = .moderate
    @State private var notes = ""
    @State private var showingDuplicateAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allergen")) {
                    Picker("Select Allergen", selection: $selectedAllergy) {
                        ForEach(FoodAllergy.allCases, id: \.self) { allergy in
                            HStack {
                                Text(allergy.icon)
                                Text(allergy.rawValue)
                            }
                            .tag(allergy)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Severity")) {
                    Picker("Severity Level", selection: $selectedSeverity) {
                        ForEach(AllergySeverity.allCases, id: \.self) { severity in
                            HStack {
                                SeverityBadge(severity: severity)
                                Spacer()
                            }
                            .tag(severity)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(severityDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Additional Notes (Optional)")) {
                    TextField("e.g., Only raw milk, cooked is okay", text: $notes)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section {
                    Button(action: saveAllergy) {
                        Text("Add Allergy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add Allergy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Duplicate Allergy", isPresented: $showingDuplicateAlert) {
                Button("OK") { }
            } message: {
                Text("You have already added \(selectedAllergy.rawValue) to your allergies.")
            }
        }
    }
    
    private var severityDescription: String {
        switch selectedSeverity {
        case .mild:
            return "Minor symptoms like mild discomfort or skin irritation"
        case .moderate:
            return "Noticeable symptoms like hives, stomach upset, or breathing issues"
        case .severe:
            return "Serious symptoms requiring immediate medical attention"
        case .lifeThreatening:
            return "Anaphylactic reaction risk - carry EpiPen"
        }
    }
    
    private func saveAllergy() {
        guard var profile = userProfileManager.currentProfile else { return }
        
        // Check for duplicates
        if profile.foodPreferences.allergies.contains(where: { $0.allergy == selectedAllergy }) {
            showingDuplicateAlert = true
            return
        }
        
        let allergyInfo = AllergyInfo(
            allergy: selectedAllergy,
            severity: selectedSeverity,
            notes: notes.isEmpty ? nil : notes
        )
        
        profile.foodPreferences.allergies.append(allergyInfo)
        userProfileManager.saveProfile(profile)
        
        dismiss()
    }
}

// MARK: - Edit Allergy View

struct EditAllergyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    let allergyInfo: AllergyInfo
    @State private var selectedSeverity: AllergySeverity
    @State private var notes: String
    
    init(allergyInfo: AllergyInfo) {
        self.allergyInfo = allergyInfo
        _selectedSeverity = State(initialValue: allergyInfo.severity)
        _notes = State(initialValue: allergyInfo.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allergen")) {
                    HStack {
                        Text(allergyInfo.allergy.icon)
                        Text(allergyInfo.allergy.rawValue)
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Severity")) {
                    Picker("Severity Level", selection: $selectedSeverity) {
                        ForEach(AllergySeverity.allCases, id: \.self) { severity in
                            HStack {
                                SeverityBadge(severity: severity)
                                Spacer()
                            }
                            .tag(severity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Additional Notes")) {
                    TextField("e.g., Only raw milk, cooked is okay", text: $notes)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section {
                    Button(action: updateAllergy) {
                        Text("Update Allergy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Edit Allergy")
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
    
    private func updateAllergy() {
        guard var profile = userProfileManager.currentProfile else { return }
        
        if let index = profile.foodPreferences.allergies.firstIndex(where: { $0.id == allergyInfo.id }) {
            profile.foodPreferences.allergies[index].severity = selectedSeverity
            profile.foodPreferences.allergies[index].notes = notes.isEmpty ? nil : notes
            
            userProfileManager.saveProfile(profile)
        }
        
        dismiss()
    }
}

// MARK: - Add Intolerance View

struct AddIntoleranceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    @State private var selectedIntolerances: Set<FoodIntolerance> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Intolerances")) {
                    ForEach(FoodIntolerance.allCases, id: \.self) { intolerance in
                        HStack {
                            Text(intolerance.icon)
                            Text(intolerance.rawValue)
                            Spacer()
                            if selectedIntolerances.contains(intolerance) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.wellnessGreen)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedIntolerances.contains(intolerance) {
                                selectedIntolerances.remove(intolerance)
                            } else {
                                selectedIntolerances.insert(intolerance)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: saveIntolerances) {
                        Text("Add Intolerances")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(selectedIntolerances.isEmpty)
                }
            }
            .navigationTitle("Add Intolerances")
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
    
    private func saveIntolerances() {
        guard var profile = userProfileManager.currentProfile else { return }
        
        // Add only new intolerances
        for intolerance in selectedIntolerances {
            if !profile.foodPreferences.intolerances.contains(intolerance) {
                profile.foodPreferences.intolerances.append(intolerance)
            }
        }
        
        userProfileManager.saveProfile(profile)
        
        dismiss()
    }
}

// MARK: - Add Dietary Preference View

struct AddDietaryPreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    @State private var selectedPreferences: Set<DietaryPreference> = []
    
    let groupedPreferences: [(String, [DietaryPreference])] = [
        ("Vegetarian/Vegan", [.vegetarian, .vegan, .pescatarian, .flexitarian]),
        ("Religious", [.kosher, .halal, .hindu, .jain]),
        ("Health-Based", [.lowCarb, .keto, .paleo, .whole30, .mediterranean, .lowFat, .lowSodium, .diabeticFriendly, .heartHealthy, .antiInflammatory]),
        ("Other", [.organic, .nonGMO, .local, .sustainable])
    ]
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(groupedPreferences, id: \.0) { group, preferences in
                    Section(header: Text(group)) {
                        ForEach(preferences, id: \.self) { preference in
                            HStack {
                                Text(preference.icon)
                                Text(preference.rawValue)
                                Spacer()
                                if selectedPreferences.contains(preference) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.wellnessGreen)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedPreferences.contains(preference) {
                                    selectedPreferences.remove(preference)
                                } else {
                                    selectedPreferences.insert(preference)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: savePreferences) {
                        Text("Add Preferences")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(selectedPreferences.isEmpty)
                }
            }
            .navigationTitle("Dietary Preferences")
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
    
    private func savePreferences() {
        guard var profile = userProfileManager.currentProfile else { return }
        
        // Add only new preferences
        for preference in selectedPreferences {
            if !profile.foodPreferences.dietaryPreferences.contains(preference) {
                profile.foodPreferences.dietaryPreferences.append(preference)
            }
        }
        
        userProfileManager.saveProfile(profile)
        
        dismiss()
    }
}

#Preview {
    AddAllergyView()
        .environmentObject(UserProfileManager())
}