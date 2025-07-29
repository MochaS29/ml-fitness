import SwiftUI

struct FoodPreferencesView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var selectedTab = 0
    @State private var showingAddAllergy = false
    @State private var showingAddIntolerance = false
    @State private var showingAddPreference = false
    @State private var editingAllergy: AllergyInfo?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Category", selection: $selectedTab) {
                    Text("Allergies").tag(0)
                    Text("Intolerances").tag(1)
                    Text("Dietary").tag(2)
                    Text("Preferences").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case 0:
                        allergiesSection
                    case 1:
                        intolerancesSection
                    case 2:
                        dietaryPreferencesSection
                    case 3:
                        foodPreferencesSection
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Food Preferences")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddAllergy) {
                AddAllergyView()
                    .environmentObject(userProfileManager)
            }
            .sheet(isPresented: $showingAddIntolerance) {
                AddIntoleranceView()
                    .environmentObject(userProfileManager)
            }
            .sheet(isPresented: $showingAddPreference) {
                AddDietaryPreferenceView()
                    .environmentObject(userProfileManager)
            }
            .sheet(item: $editingAllergy) { allergy in
                EditAllergyView(allergyInfo: allergy)
                    .environmentObject(userProfileManager)
            }
        }
    }
    
    // MARK: - Sections
    
    private var allergiesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let allergies = userProfileManager.currentProfile?.foodPreferences.allergies,
               !allergies.isEmpty {
                ForEach(allergies) { allergyInfo in
                    AllergyCard(allergyInfo: allergyInfo) {
                        editingAllergy = allergyInfo
                    } onDelete: {
                        removeAllergy(allergyInfo)
                    }
                }
                .padding(.horizontal)
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "No Allergies Added",
                    subtitle: "Add your food allergies to get warnings when logging foods"
                )
                .padding()
            }
        }
        .padding(.vertical)
    }
    
    private var intolerancesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let intolerances = userProfileManager.currentProfile?.foodPreferences.intolerances,
               !intolerances.isEmpty {
                ForEach(intolerances, id: \.self) { intolerance in
                    IntoleranceRow(intolerance: intolerance) {
                        removeIntolerance(intolerance)
                    }
                }
                .padding(.horizontal)
            } else {
                EmptyStateView(
                    icon: "stomach",
                    title: "No Intolerances Added",
                    subtitle: "Track foods that cause digestive issues"
                )
                .padding()
            }
        }
        .padding(.vertical)
    }
    
    private var dietaryPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let preferences = userProfileManager.currentProfile?.foodPreferences.dietaryPreferences,
               !preferences.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(preferences, id: \.self) { preference in
                        DietaryPreferenceCard(preference: preference) {
                            removeDietaryPreference(preference)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                EmptyStateView(
                    icon: "leaf",
                    title: "No Dietary Preferences",
                    subtitle: "Add your dietary lifestyle choices"
                )
                .padding()
            }
        }
        .padding(.vertical)
    }
    
    private var foodPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Disliked Foods
            VStack(alignment: .leading, spacing: 12) {
                Text("Disliked Foods")
                    .font(.headline)
                    .padding(.horizontal)
                
                DislikedFoodsEditor()
                    .environmentObject(userProfileManager)
            }
            
            // Avoided Ingredients
            VStack(alignment: .leading, spacing: 12) {
                Text("Avoided Ingredients")
                    .font(.headline)
                    .padding(.horizontal)
                
                AvoidedIngredientsEditor()
                    .environmentObject(userProfileManager)
            }
            
            // Meal Preferences
            VStack(alignment: .leading, spacing: 12) {
                Text("Meal Preferences")
                    .font(.headline)
                    .padding(.horizontal)
                
                MealPreferencesEditor()
                    .environmentObject(userProfileManager)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var addButton: some View {
        switch selectedTab {
        case 0:
            Button(action: { showingAddAllergy = true }) {
                Image(systemName: "plus")
            }
        case 1:
            Button(action: { showingAddIntolerance = true }) {
                Image(systemName: "plus")
            }
        case 2:
            Button(action: { showingAddPreference = true }) {
                Image(systemName: "plus")
            }
        default:
            EmptyView()
        }
    }
    
    // MARK: - Actions
    
    private func removeAllergy(_ allergyInfo: AllergyInfo) {
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.allergies.removeAll { $0.id == allergyInfo.id }
            userProfileManager.saveProfile(profile)
        }
    }
    
    private func removeIntolerance(_ intolerance: FoodIntolerance) {
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.intolerances.removeAll { $0 == intolerance }
            userProfileManager.saveProfile(profile)
        }
    }
    
    private func removeDietaryPreference(_ preference: DietaryPreference) {
        if var profile = userProfileManager.currentProfile {
            profile.foodPreferences.dietaryPreferences.removeAll { $0 == preference }
            userProfileManager.saveProfile(profile)
        }
    }
}

// MARK: - Allergy Card

struct AllergyCard: View {
    let allergyInfo: AllergyInfo
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(allergyInfo.allergy.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(allergyInfo.allergy.rawValue)
                        .font(.headline)
                    
                    HStack {
                        SeverityBadge(severity: allergyInfo.severity)
                        
                        if let notes = allergyInfo.notes, !notes.isEmpty {
                            Text("• \(notes)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Severity Badge

struct SeverityBadge: View {
    let severity: AllergySeverity
    
    var body: some View {
        Text(severity.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch severity {
        case .mild:
            return .yellow
        case .moderate:
            return .orange
        case .severe:
            return .red
        case .lifeThreatening:
            return Color(red: 0.5, green: 0, blue: 0)
        }
    }
}

// MARK: - Intolerance Row

struct IntoleranceRow: View {
    let intolerance: FoodIntolerance
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(intolerance.icon)
                .font(.title3)
            
            Text(intolerance.rawValue)
                .font(.body)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - Dietary Preference Card

struct DietaryPreferenceCard: View {
    let preference: DietaryPreference
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(preference.icon)
                .font(.title)
            
            Text(preference.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    FoodPreferencesView()
        .environmentObject(UserProfileManager())
}