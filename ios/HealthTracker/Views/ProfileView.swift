import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @StateObject private var stepCounter = StepCounterService.shared
    @State private var showingEditProfile = false

    var body: some View {
        NavigationView {
            List {
                if let profile = profileManager.currentProfile {
                    Section {
                        ProfileHeaderView(profile: profile)
                    }
                    
                    Section("Personal Information") {
                        ProfileInfoRow(label: "Age", value: "0")
                        ProfileInfoRow(label: "Gender", value: profile.gender.rawValue)
                        ProfileInfoRow(label: "Activity Level", value: profile.activityLevel.rawValue)
                        
                        if profile.isPregnant, let trimester = profile.pregnancyTrimester {
                            ProfileInfoRow(label: "Pregnancy", value: trimester.rawValue)
                        }
                        
                        if profile.isBreastfeeding {
                            ProfileInfoRow(label: "Status", value: "0")
                        }
                    }
                    
                    if !profile.dietaryRestrictions.isEmpty {
                        Section("Dietary Restrictions") {
                            ForEach(profile.dietaryRestrictions, id: \.self) { restriction in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(restriction.rawValue)
                                }
                            }
                        }
                    }
                    
                    if !profile.healthConditions.isEmpty {
                        Section("Health Conditions") {
                            ForEach(profile.healthConditions, id: \.self) { condition in
                                HStack {
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundColor(.red)
                                    Text(condition.rawValue)
                                }
                            }
                        }
                    }
                    
                    Section("Health & Dietary") {
                        NavigationLink(destination: FoodPreferencesView()) {
                            Label("Food Preferences", systemImage: "fork.knife")
                        }
                    }
                    
                    Section("Settings") {
                        HStack {
                            Label("Distance Unit", systemImage: "ruler")
                            Spacer()
                            Picker("Distance Unit", selection: $stepCounter.distanceUnit) {
                                ForEach(StepCounterService.DistanceUnit.allCases, id: \.self) { unit in
                                    Text(unit == .miles ? "Miles" : "Kilometers")
                                        .tag(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                            .onChange(of: stepCounter.distanceUnit) {
                                stepCounter.setDistanceUnit(stepCounter.distanceUnit)
                            }
                        }

                        Button(action: { showingEditProfile = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }

                        Button(action: {
                            profileManager.resetProfile()
                        }) {
                            Label("Reset Profile", systemImage: "arrow.counterclockwise")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    let profile: UserProfile
    @EnvironmentObject var profileManager: UserProfileManager

    var body: some View {
        HStack {
            if let avatar = profileManager.avatarImage {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
            }

            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Member since \(profile.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileManager: UserProfileManager

    @State private var name = ""
    @State private var gender = Gender.female
    @State private var birthDate = Date()
    @State private var activityLevel = ActivityLevel.moderate
    @State private var selectedRestrictions: Set<DietaryRestriction> = []
    @State private var selectedConditions: Set<HealthCondition> = []
    @State private var isPregnant = false
    @State private var pregnancyTrimester: PregnancyTrimester?
    @State private var isBreastfeeding = false

    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingAvatarGrid = false
    @State private var pickedImage: UIImage?

    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        if let avatar = profileManager.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)

                    Button(action: { showingCamera = true }) {
                        Label("Take Photo", systemImage: "camera")
                    }

                    Button(action: { showingPhotoLibrary = true }) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }

                    Button(action: { showingAvatarGrid = true }) {
                        Label("Choose Avatar", systemImage: "person.crop.square")
                    }

                    if profileManager.avatarType != "none" {
                        Button(role: .destructive, action: {
                            profileManager.removeAvatar()
                        }) {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                }

                Section("Basic Information") {
                    TextField("Name", text: $name)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                }
                
                Section("Activity Level") {
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section("Dietary Restrictions") {
                    ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                        MultipleSelectionRow(
                            title: restriction.rawValue,
                            isSelected: selectedRestrictions.contains(restriction)
                        ) {
                            if selectedRestrictions.contains(restriction) {
                                selectedRestrictions.remove(restriction)
                            } else {
                                selectedRestrictions.insert(restriction)
                            }
                        }
                    }
                }
                
                if gender == .female {
                    Section("Female Health") {
                        Toggle("Currently Pregnant", isOn: $isPregnant)
                        
                        if isPregnant {
                            Picker("Trimester", selection: $pregnancyTrimester) {
                                Text("Select").tag(nil as PregnancyTrimester?)
                                ForEach(PregnancyTrimester.allCases, id: \.self) { trimester in
                                    Text(trimester.rawValue).tag(trimester as PregnancyTrimester?)
                                }
                            }
                        }
                        
                        Toggle("Currently Breastfeeding", isOn: $isBreastfeeding)
                    }
                }
                
                Section("Health Conditions") {
                    ForEach(HealthCondition.allCases, id: \.self) { condition in
                        MultipleSelectionRow(
                            title: condition.rawValue,
                            isSelected: selectedConditions.contains(condition)
                        ) {
                            if selectedConditions.contains(condition) {
                                selectedConditions.remove(condition)
                            } else {
                                selectedConditions.insert(condition)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
            .sheet(isPresented: $showingCamera) {
                CameraImagePicker(selectedImage: $pickedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                CameraImagePicker(selectedImage: $pickedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingAvatarGrid) {
                AvatarGridView()
            }
            .onChange(of: pickedImage) {
                if let image = pickedImage {
                    profileManager.savePhotoAvatar(image)
                    pickedImage = nil
                }
            }
        }
    }
    
    func loadCurrentProfile() {
        guard let profile = profileManager.currentProfile else { return }
        
        name = profile.name
        gender = profile.gender
        birthDate = profile.birthDate
        activityLevel = profile.activityLevel
        selectedRestrictions = Set(profile.dietaryRestrictions)
        selectedConditions = Set(profile.healthConditions)
        isPregnant = profile.isPregnant
        pregnancyTrimester = profile.pregnancyTrimester
        isBreastfeeding = profile.isBreastfeeding
    }
    
    func saveProfile() {
        var profile = UserProfile(name: name, gender: gender, birthDate: birthDate)
        profile.activityLevel = activityLevel
        profile.dietaryRestrictions = Array(selectedRestrictions)
        profile.healthConditions = Array(selectedConditions)
        profile.isPregnant = isPregnant
        profile.pregnancyTrimester = pregnancyTrimester
        profile.isBreastfeeding = isBreastfeeding
        
        profileManager.updateProfile(profile)
        presentationMode.wrappedValue.dismiss()
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

// MARK: - Avatar Grid View

struct AvatarGridView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileManager: UserProfileManager

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(BundledAvatar.all) { avatar in
                        Button(action: {
                            profileManager.selectBundledAvatar(avatar.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(avatar.color.opacity(0.15))
                                        .frame(width: 70, height: 70)
                                    Image(systemName: avatar.sfSymbol)
                                        .font(.system(size: 28))
                                        .foregroundColor(avatar.color)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            profileManager.avatarType == "bundled:\(avatar.id)"
                                                ? avatar.color : Color.clear,
                                            lineWidth: 3
                                        )
                                        .frame(width: 74, height: 74)
                                )

                                Text(avatar.name)
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Avatar")
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