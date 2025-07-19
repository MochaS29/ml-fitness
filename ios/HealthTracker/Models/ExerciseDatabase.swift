import Foundation

struct ExerciseTemplate {
    let name: String
    let type: ExerciseType
    let caloriesPerMinute: Double
    let category: String
}

class ExerciseDatabase {
    static let shared = ExerciseDatabase()
    
    let exercises: [ExerciseTemplate] = [
        // Cardio
        ExerciseTemplate(name: "Running", type: .cardio, caloriesPerMinute: 10, category: "Outdoor"),
        ExerciseTemplate(name: "Jogging", type: .cardio, caloriesPerMinute: 7, category: "Outdoor"),
        ExerciseTemplate(name: "Walking", type: .cardio, caloriesPerMinute: 4, category: "Outdoor"),
        ExerciseTemplate(name: "Cycling", type: .cardio, caloriesPerMinute: 8, category: "Outdoor"),
        ExerciseTemplate(name: "Swimming", type: .cardio, caloriesPerMinute: 11, category: "Water"),
        ExerciseTemplate(name: "Elliptical", type: .cardio, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplate(name: "Treadmill", type: .cardio, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplate(name: "Stair Climber", type: .cardio, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplate(name: "Rowing Machine", type: .cardio, caloriesPerMinute: 10, category: "Gym"),
        ExerciseTemplate(name: "Jump Rope", type: .cardio, caloriesPerMinute: 12, category: "Home"),
        ExerciseTemplate(name: "Dancing", type: .cardio, caloriesPerMinute: 6, category: "Home"),
        ExerciseTemplate(name: "Hiking", type: .cardio, caloriesPerMinute: 7, category: "Outdoor"),
        ExerciseTemplate(name: "Boxing", type: .cardio, caloriesPerMinute: 13, category: "Gym"),
        ExerciseTemplate(name: "Kickboxing", type: .cardio, caloriesPerMinute: 10, category: "Gym"),
        
        // Strength Training
        ExerciseTemplate(name: "Weight Training", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplate(name: "Bench Press", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplate(name: "Squats", type: .strength, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplate(name: "Deadlifts", type: .strength, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplate(name: "Pull-ups", type: .strength, caloriesPerMinute: 8, category: "Gym"),
        ExerciseTemplate(name: "Push-ups", type: .strength, caloriesPerMinute: 6, category: "Home"),
        ExerciseTemplate(name: "Dumbbell Exercises", type: .strength, caloriesPerMinute: 5, category: "Gym"),
        ExerciseTemplate(name: "Barbell Exercises", type: .strength, caloriesPerMinute: 6, category: "Gym"),
        ExerciseTemplate(name: "Resistance Band Training", type: .strength, caloriesPerMinute: 4, category: "Home"),
        ExerciseTemplate(name: "Bodyweight Training", type: .strength, caloriesPerMinute: 5, category: "Home"),
        ExerciseTemplate(name: "Core Workout", type: .strength, caloriesPerMinute: 5, category: "Home"),
        ExerciseTemplate(name: "Plank", type: .strength, caloriesPerMinute: 4, category: "Home"),
        
        // Flexibility
        ExerciseTemplate(name: "Yoga", type: .flexibility, caloriesPerMinute: 3, category: "Home"),
        ExerciseTemplate(name: "Pilates", type: .flexibility, caloriesPerMinute: 4, category: "Home"),
        ExerciseTemplate(name: "Stretching", type: .flexibility, caloriesPerMinute: 2, category: "Home"),
        ExerciseTemplate(name: "Tai Chi", type: .flexibility, caloriesPerMinute: 3, category: "Home"),
        ExerciseTemplate(name: "Foam Rolling", type: .flexibility, caloriesPerMinute: 2, category: "Home"),
        
        // Sports
        ExerciseTemplate(name: "Basketball", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplate(name: "Soccer", type: .sports, caloriesPerMinute: 9, category: "Sports"),
        ExerciseTemplate(name: "Tennis", type: .sports, caloriesPerMinute: 7, category: "Sports"),
        ExerciseTemplate(name: "Volleyball", type: .sports, caloriesPerMinute: 6, category: "Sports"),
        ExerciseTemplate(name: "Golf", type: .sports, caloriesPerMinute: 4, category: "Sports"),
        ExerciseTemplate(name: "Baseball", type: .sports, caloriesPerMinute: 5, category: "Sports"),
        ExerciseTemplate(name: "Football", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplate(name: "Hockey", type: .sports, caloriesPerMinute: 8, category: "Sports"),
        ExerciseTemplate(name: "Badminton", type: .sports, caloriesPerMinute: 6, category: "Sports"),
        ExerciseTemplate(name: "Table Tennis", type: .sports, caloriesPerMinute: 4, category: "Sports"),
        
        // Other
        ExerciseTemplate(name: "Rock Climbing", type: .other, caloriesPerMinute: 11, category: "Outdoor"),
        ExerciseTemplate(name: "Martial Arts", type: .other, caloriesPerMinute: 10, category: "Gym"),
        ExerciseTemplate(name: "CrossFit", type: .other, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplate(name: "Circuit Training", type: .other, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplate(name: "HIIT", type: .other, caloriesPerMinute: 12, category: "Gym"),
        ExerciseTemplate(name: "Zumba", type: .other, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplate(name: "Spin Class", type: .other, caloriesPerMinute: 9, category: "Gym"),
        ExerciseTemplate(name: "Aerobics", type: .other, caloriesPerMinute: 7, category: "Gym"),
        ExerciseTemplate(name: "Barre", type: .other, caloriesPerMinute: 5, category: "Gym")
    ]
    
    func searchExercises(_ query: String) -> [ExerciseTemplate] {
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
    
    func getExercise(named name: String) -> ExerciseTemplate? {
        return exercises.first { $0.name == name }
    }
}