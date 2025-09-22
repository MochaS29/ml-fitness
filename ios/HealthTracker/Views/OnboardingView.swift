import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var name = ""
    @State private var selectedGender = Gender.female
    @State private var birthDate = Date()

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Health Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Text("Let's set up your profile")
                .font(.title3)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 20) {
                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }

                // Gender selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.headline)
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Birth date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Birth Date")
                        .font(.headline)
                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Get Started button
            Button(action: {
                let profile = UserProfile(name: name, gender: selectedGender, birthDate: birthDate)
                profileManager.saveProfile(profile)
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .disabled(name.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

struct BasicInfoView: View {
    @Binding var name: String
    @Binding var gender: Gender
    @Binding var birthDate: Date
    @Binding var startingWeight: String

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Let's Get Started")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("Tell us a bit about yourself")
                    .font(.title3)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .font(.headline)
                        TextField("Your name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                VStack(alignment: .leading) {
                    Text("Gender")
                        .font(.headline)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading) {
                    Text("Birth Date")
                        .font(.headline)
                    DatePicker("Birth Date", selection: $birthDate,
                              in: ...Date(),
                              displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Text("Age: \(age) years")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    Text("Starting Weight (Optional)")
                        .font(.headline)
                    HStack {
                        TextField("Enter weight", text: $startingWeight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 150)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                    Text("This helps track your progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
        }
    }
}

struct ActivityLevelView: View {
    @Binding var activityLevel: ActivityLevel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Activity Level")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("How active are you typically?")
                .font(.title3)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    ActivityLevelCard(
                        level: level,
                        isSelected: activityLevel == level,
                        action: { activityLevel = level }
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var description: String {
        switch level {
        case .sedentary: return "Little to no exercise"
        case .light: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .active: return "Hard exercise 6-7 days/week"
        case .veryActive: return "Very hard exercise & physical job"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(level.rawValue)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct DietaryRestrictionsView: View {
    @Binding var selectedRestrictions: Set<DietaryRestriction>
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Dietary Restrictions")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select any that apply")
                .font(.title3)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                    RestrictionCard(
                        restriction: restriction,
                        isSelected: selectedRestrictions.contains(restriction),
                        action: {
                            if selectedRestrictions.contains(restriction) {
                                selectedRestrictions.remove(restriction)
                            } else {
                                selectedRestrictions.insert(restriction)
                            }
                        }
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct RestrictionCard: View {
    let restriction: DietaryRestriction
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(restriction.rawValue)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct HealthConditionsView: View {
    @Binding var selectedConditions: Set<HealthCondition>
    let gender: Gender
    @Binding var isPregnant: Bool
    @Binding var pregnancyTrimester: PregnancyTrimester?
    @Binding var isBreastfeeding: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Health Information")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select any that apply")
                .font(.title3)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Show pregnancy/breastfeeding options for females
                    if gender == .female {
                        VStack(alignment: .leading, spacing: 15) {
                            Toggle("Currently Pregnant", isOn: $isPregnant)
                            
                            if isPregnant {
                                Picker("Trimester", selection: $pregnancyTrimester) {
                                    Text("Select").tag(nil as PregnancyTrimester?)
                                    ForEach(PregnancyTrimester.allCases, id: \.self) { trimester in
                                        Text(trimester.rawValue).tag(trimester as PregnancyTrimester?)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            Toggle("Currently Breastfeeding", isOn: $isBreastfeeding)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Health conditions
                    Text("Medical Conditions")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(HealthCondition.allCases, id: \.self) { condition in
                            ConditionCard(
                                condition: condition,
                                isSelected: selectedConditions.contains(condition),
                                action: {
                                    if selectedConditions.contains(condition) {
                                        selectedConditions.remove(condition)
                                    } else {
                                        selectedConditions.insert(condition)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct ConditionCard: View {
    let condition: HealthCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(condition.rawValue)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct OnboardingSummaryView: View {
    let name: String
    let gender: Gender
    let birthDate: Date
    let startingWeight: String
    let activityLevel: ActivityLevel
    let restrictions: Set<DietaryRestriction>
    let conditions: Set<HealthCondition>
    let isPregnant: Bool
    let pregnancyTrimester: PregnancyTrimester?
    let isBreastfeeding: Bool
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Profile Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileSummaryRow(label: "Name", value: name)
                    ProfileSummaryRow(label: "Gender", value: gender.rawValue)
                    ProfileSummaryRow(label: "Age", value: "\(age) years")
                    if !startingWeight.isEmpty {
                        ProfileSummaryRow(label: "Starting Weight", value: "\(startingWeight) lbs")
                    }
                    ProfileSummaryRow(label: "Activity Level", value: activityLevel.rawValue)
                    
                    if !restrictions.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Dietary Restrictions")
                                .font(.headline)
                            Text(restrictions.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !conditions.isEmpty || isPregnant || isBreastfeeding {
                        VStack(alignment: .leading) {
                            Text("Health Information")
                                .font(.headline)
                            VStack(alignment: .leading) {
                                if isPregnant, let trimester = pregnancyTrimester {
                                    Text("Pregnant - \(trimester.rawValue)")
                                        .foregroundColor(.secondary)
                                }
                                if isBreastfeeding {
                                    Text("Breastfeeding")
                                        .foregroundColor(.secondary)
                                }
                                if !conditions.isEmpty {
                                    Text(conditions.map { $0.rawValue }.joined(separator: ", "))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Text("Your personalized RDA values will be calculated based on this information.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ProfileSummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}