import Foundation

struct ExerciseTemplateModel {
    let name: String
    let type: ExerciseType
    let caloriesPerMinute: Double
    let category: String
}

class ExerciseDatabase {
    static let shared = ExerciseDatabase()
    
    let exercises: [ExerciseTemplateModel] = [
        // Cardio
        ExerciseTemplateModel(name: "Running", type: .cardio, caloriesPerMinute: 10, category: "Outdoor"),
        ExerciseTemplateModel(name: "Jogging", type: .cardio, caloriesPerMinute: 7, category: "Outdoor"),
        ExerciseTemplateModel(name: "Walking", type: .cardio, caloriesPerMinute: 4, category: "Outdoor"),
        ExerciseTemplateModel(name: "Cycling", type: .cardio, caloriesPerMinute: 8, category: "Outdoor"),
        ExerciseTemplateModel(name: "Swimming", type: .cardio, caloriesPerMinute: 11, category: "Water"),
        ExerciseTemplateModel(name: "Elliptical", type: .cardio, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplateModel(name: "Treadmill", type: .cardio, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplateModel(name: "Stair Climber", type: .cardio, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplateModel(name: "Rowing Machine", type: .cardio, caloriesPerMinute: 10, category: "Gym"),
        ExerciseTemplateModel(name: "Jump Rope", type: .cardio, caloriesPerMinute: 12, category: "Home"),
        ExerciseTemplateModel(name: "Dancing", type: .cardio, caloriesPerMinute: 6, category: "Home"),
        ExerciseTemplateModel(name: "Hiking", type: .cardio, caloriesPerMinute: 7, category: "Outdoor"),
        ExerciseTemplateModel(name: "Boxing", type: .cardio, caloriesPerMinute: 13, category: "Gym"),
        ExerciseTemplateModel(name: "Kickboxing", type: .cardio, caloriesPerMinute: 10, category: "Gym"),
        
        // Strength Training
        ExerciseTemplateModel(name: "Weight Training", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplateModel(name: "Bench Press", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplateModel(name: "Squats", type: .strength, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplateModel(name: "Deadlifts", type: .strength, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplateModel(name: "Pull-ups", type: .strength, caloriesPerMinute: 8, category: "Gym"),
        ExerciseTemplateModel(name: "Push-ups", type: .strength, caloriesPerMinute: 6, category: "Home"),
        ExerciseTemplateModel(name: "Dumbbell Exercises", type: .strength, caloriesPerMinute: 5, category: "Gym"),
        ExerciseTemplateModel(name: "Barbell Exercises", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplateModel(name: "Resistance Band Training", type: .strength, caloriesPerMinute: 4, category: "Home"),
        ExerciseTemplateModel(name: "Bodyweight Training", type: .strength, caloriesPerMinute: 5, category: "Home"),
        ExerciseTemplateModel(name: "Core Workout", type: .strength, caloriesPerMinute: 5, category: "Home"),
        ExerciseTemplateModel(name: "Plank", type: .strength, caloriesPerMinute: 4, category: "Home"),
        
        // Flexibility
        ExerciseTemplateModel(name: "Yoga", type: .flexibility, caloriesPerMinute: 3, category: "Home"),
        ExerciseTemplateModel(name: "Pilates", type: .flexibility, caloriesPerMinute: 4, category: "Home"),
        ExerciseTemplateModel(name: "Stretching", type: .flexibility, caloriesPerMinute: 2, category: "Home"),
        ExerciseTemplateModel(name: "Tai Chi", type: .flexibility, caloriesPerMinute: 3, category: "Home"),
        ExerciseTemplateModel(name: "Foam Rolling", type: .flexibility, caloriesPerMinute: 2, category: "Home"),
        
        // Sports
        ExerciseTemplateModel(name: "Basketball", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplateModel(name: "Soccer", type: .sports, caloriesPerMinute: 9, category: "Sports"),
        ExerciseTemplateModel(name: "Tennis", type: .sports, caloriesPerMinute: 7, category: "Sports"),
        ExerciseTemplateModel(name: "Volleyball", type: .sports, caloriesPerMinute: 6, category: "Sports"),
        ExerciseTemplateModel(name: "Golf", type: .sports, caloriesPerMinute: 4, category: "Sports"),
        ExerciseTemplateModel(name: "Baseball", type: .sports, caloriesPerMinute: 5, category: "Sports"),
        ExerciseTemplateModel(name: "Football", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplateModel(name: "Hockey", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplateModel(name: "Badminton", type: .sports, caloriesPerMinute: 6, category: "Sports"),
        ExerciseTemplateModel(name: "Table Tennis", type: .sports, caloriesPerMinute: 4, category: "Sports"),
        
        // Other
        ExerciseTemplateModel(name: "Rock Climbing", type: .other, caloriesPerMinute: 11, category: "Outdoor"),
        ExerciseTemplateModel(name: "Martial Arts", type: .other, caloriesPerMinute: 10, category: "Gym"),
        ExerciseTemplateModel(name: "CrossFit", type: .other, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplateModel(name: "Circuit Training", type: .other, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplateModel(name: "HIIT", type: .other, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplateModel(name: "Zumba", type: .other, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplateModel(name: "Spin Class", type: .other, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplateModel(name: "Aerobics", type: .other, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplateModel(name: "Barre", type: .other, caloriesPerMinute: 5, category: "Gym")
    ]
    
    func searchExercises(_ query: String) -> [ExerciseTemplateModel] {
        guard !query.isEmpty else { return [] }
        
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query)
        }.sorted { first, second in
            // Prioritize exercises that start with the query
            let firstStarts = first.name.lowercased().hasPrefix(query.lowercased())
            let secondStarts = second.name.lowercased().hasPrefix(query.lowercased())
            
            if firstStarts && !secondStarts {
                return true
            } else if !firstStarts && secondStarts {
                return false
            } else {
                return first.name < second.name
            }
        }
    }
    
    func getExercise(named name: String) -> ExerciseTemplateModel? {
        return exercises.first { $0.name == name }
    }
}