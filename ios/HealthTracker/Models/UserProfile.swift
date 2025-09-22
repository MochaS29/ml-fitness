import Foundation

struct UserProfile: Codable {
    let id: UUID
    var name: String
    var gender: Gender
    var birthDate: Date
    var startingWeight: Double?
    var activityLevel: ActivityLevel
    var dietaryRestrictions: [DietaryRestriction]
    var healthConditions: [HealthCondition]
    var foodPreferences: UserFoodPreferences
    var isPregnant: Bool
    var pregnancyTrimester: PregnancyTrimester?
    var isBreastfeeding: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, gender: Gender, birthDate: Date) {
        self.id = UUID()
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.startingWeight = nil
        self.activityLevel = .moderate
        self.dietaryRestrictions = []
        self.healthConditions = []
        self.foodPreferences = UserFoodPreferences()
        self.isPregnant = false
        self.pregnancyTrimester = nil
        self.isBreastfeeding = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var ageGroup: AgeGroup {
        switch age {
        case 0..<19:
            return .child
        case 19..<31:
            return .adult19to30
        case 31..<51:
            return .adult31to50
        case 51..<71:
            return .adult51to70
        default:
            return .adult71plus
        }
    }
    
    var lifeStage: LifeStage {
        if isPregnant, let trimester = pregnancyTrimester {
            return .pregnant(trimester)
        } else if isBreastfeeding {
            return .breastfeeding
        } else {
            return .standard(ageGroup)
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum AgeGroup: String, Codable {
    case child = "Under 19"
    case adult19to30 = "19-30 years"
    case adult31to50 = "31-50 years"
    case adult51to70 = "51-70 years"
    case adult71plus = "71+ years"
}

enum LifeStage: Codable {
    case standard(AgeGroup)
    case pregnant(PregnancyTrimester)
    case breastfeeding
}

enum PregnancyTrimester: String, Codable, CaseIterable {
    case first = "First Trimester"
    case second = "Second Trimester"
    case third = "Third Trimester"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Light Activity"
    case moderate = "Moderate Activity"
    case active = "Active"
    case veryActive = "Very Active"
}

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case nutAllergy = "Nut Allergy"
    case kosher = "Kosher"
    case halal = "Halal"
}

enum HealthCondition: String, Codable, CaseIterable {
    case diabetes = "Diabetes"
    case hypertension = "Hypertension"
    case heartDisease = "Heart Disease"
    case osteoporosis = "Osteoporosis"
    case anemia = "Anemia"
    case thyroidDisorder = "Thyroid Disorder"
}