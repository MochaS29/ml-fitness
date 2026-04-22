import Foundation

struct ExerciseTemplateModel: Identifiable {
    let id = UUID()
    let name: String
    let type: ExerciseType
    let met: Double        // Metabolic Equivalent of Task (Compendium of Physical Activities)
    let category: String
    let sfSymbol: String

    // Backward-compat: calories per minute at 70 kg
    var caloriesPerMinute: Double { met * 70.0 / 60.0 }

    func calories(forDuration minutes: Double, weightKg: Double) -> Int {
        Int(met * weightKg * (minutes / 60.0))
    }
}

// MARK: - Database

class ExerciseDatabase {
    static let shared = ExerciseDatabase()

    static let allCategories: [String] = [
        "All", "Walking & Hiking", "Running", "Cycling", "Water",
        "Gym & Cardio", "Strength", "Mind & Body", "Team Sports",
        "Racquet Sports", "Combat & Martial Arts", "Dance & Performance",
        "Winter Sports", "Everyday Active", "Adventure"
    ]

    let exercises: [ExerciseTemplateModel] = [

        // MARK: Walking & Hiking
        ExerciseTemplateModel(name: "Walking (leisurely)", type: .cardio, met: 2.8, category: "Walking & Hiking", sfSymbol: "figure.walk"),
        ExerciseTemplateModel(name: "Walking (brisk)", type: .cardio, met: 4.3, category: "Walking & Hiking", sfSymbol: "figure.walk"),
        ExerciseTemplateModel(name: "Walking (uphill)", type: .cardio, met: 6.0, category: "Walking & Hiking", sfSymbol: "figure.walk"),
        ExerciseTemplateModel(name: "Hiking", type: .cardio, met: 5.3, category: "Walking & Hiking", sfSymbol: "mountain.2"),
        ExerciseTemplateModel(name: "Backpacking", type: .cardio, met: 7.0, category: "Walking & Hiking", sfSymbol: "mountain.2"),
        ExerciseTemplateModel(name: "Nordic Walking", type: .cardio, met: 6.8, category: "Walking & Hiking", sfSymbol: "figure.walk"),
        ExerciseTemplateModel(name: "Nature Walk", type: .cardio, met: 2.5, category: "Walking & Hiking", sfSymbol: "leaf"),
        ExerciseTemplateModel(name: "Dog Walking", type: .cardio, met: 3.5, category: "Walking & Hiking", sfSymbol: "pawprint"),

        // MARK: Running
        ExerciseTemplateModel(name: "Jogging (slow)", type: .cardio, met: 6.0, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Running (5 mph)", type: .cardio, met: 8.3, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Running (6 mph)", type: .cardio, met: 9.8, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Running (7.5 mph)", type: .cardio, met: 12.3, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Trail Running", type: .cardio, met: 9.0, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Sprinting", type: .cardio, met: 14.5, category: "Running", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Treadmill Running", type: .cardio, met: 9.0, category: "Running", sfSymbol: "figure.run"),

        // MARK: Cycling
        ExerciseTemplateModel(name: "Cycling (leisurely)", type: .cardio, met: 3.5, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseTemplateModel(name: "Cycling (moderate)", type: .cardio, met: 8.0, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseTemplateModel(name: "Cycling (vigorous)", type: .cardio, met: 10.0, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseTemplateModel(name: "Mountain Biking", type: .cardio, met: 8.5, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseTemplateModel(name: "BMX / Tricks", type: .cardio, met: 8.0, category: "Cycling", sfSymbol: "figure.outdoor.cycle"),
        ExerciseTemplateModel(name: "Stationary Bike (easy)", type: .cardio, met: 3.5, category: "Cycling", sfSymbol: "figure.indoor.cycle"),
        ExerciseTemplateModel(name: "Spin Class", type: .cardio, met: 8.5, category: "Cycling", sfSymbol: "figure.indoor.cycle"),

        // MARK: Water
        ExerciseTemplateModel(name: "Swimming (moderate)", type: .cardio, met: 5.8, category: "Water", sfSymbol: "figure.pool.swim"),
        ExerciseTemplateModel(name: "Swimming (vigorous)", type: .cardio, met: 9.8, category: "Water", sfSymbol: "figure.pool.swim"),
        ExerciseTemplateModel(name: "Water Aerobics", type: .cardio, met: 5.5, category: "Water", sfSymbol: "figure.water.fitness"),
        ExerciseTemplateModel(name: "Kayaking", type: .cardio, met: 5.0, category: "Water", sfSymbol: "figure.rowing"),
        ExerciseTemplateModel(name: "Paddleboarding", type: .cardio, met: 6.0, category: "Water", sfSymbol: "figure.surfing"),
        ExerciseTemplateModel(name: "Surfing", type: .cardio, met: 3.0, category: "Water", sfSymbol: "figure.surfing"),
        ExerciseTemplateModel(name: "Rowing (vigorous)", type: .cardio, met: 12.0, category: "Water", sfSymbol: "figure.rowing"),
        ExerciseTemplateModel(name: "Canoeing", type: .cardio, met: 4.0, category: "Water", sfSymbol: "figure.rowing"),

        // MARK: Gym & Cardio
        ExerciseTemplateModel(name: "Elliptical (moderate)", type: .cardio, met: 5.0, category: "Gym & Cardio", sfSymbol: "figure.elliptical"),
        ExerciseTemplateModel(name: "Elliptical (vigorous)", type: .cardio, met: 8.5, category: "Gym & Cardio", sfSymbol: "figure.elliptical"),
        ExerciseTemplateModel(name: "Rowing Machine", type: .cardio, met: 7.0, category: "Gym & Cardio", sfSymbol: "figure.rowing"),
        ExerciseTemplateModel(name: "Stair Climber", type: .cardio, met: 9.0, category: "Gym & Cardio", sfSymbol: "figure.stairs"),
        ExerciseTemplateModel(name: "Jump Rope", type: .cardio, met: 12.3, category: "Gym & Cardio", sfSymbol: "figure.jumprope"),
        ExerciseTemplateModel(name: "HIIT", type: .cardio, met: 8.0, category: "Gym & Cardio", sfSymbol: "bolt.heart"),
        ExerciseTemplateModel(name: "Tabata", type: .cardio, met: 8.5, category: "Gym & Cardio", sfSymbol: "bolt.heart"),
        ExerciseTemplateModel(name: "Bootcamp", type: .cardio, met: 8.0, category: "Gym & Cardio", sfSymbol: "bolt.heart"),
        ExerciseTemplateModel(name: "Circuit Training", type: .cardio, met: 8.0, category: "Gym & Cardio", sfSymbol: "arrow.triangle.2.circlepath"),
        ExerciseTemplateModel(name: "CrossFit", type: .cardio, met: 8.0, category: "Gym & Cardio", sfSymbol: "bolt.heart"),
        ExerciseTemplateModel(name: "Aerobics (high impact)", type: .cardio, met: 7.3, category: "Gym & Cardio", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Step Aerobics", type: .cardio, met: 8.5, category: "Gym & Cardio", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Zumba", type: .cardio, met: 6.5, category: "Gym & Cardio", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Kickboxing (cardio)", type: .cardio, met: 7.0, category: "Gym & Cardio", sfSymbol: "figure.boxing"),

        // MARK: Strength
        ExerciseTemplateModel(name: "Weight Training", type: .strength, met: 3.5, category: "Strength", sfSymbol: "dumbbell"),
        ExerciseTemplateModel(name: "Powerlifting", type: .strength, met: 6.0, category: "Strength", sfSymbol: "dumbbell"),
        ExerciseTemplateModel(name: "Kettlebell Training", type: .strength, met: 8.2, category: "Strength", sfSymbol: "dumbbell"),
        ExerciseTemplateModel(name: "Bodyweight Training", type: .strength, met: 5.0, category: "Strength", sfSymbol: "figure.strengthtraining.traditional"),
        ExerciseTemplateModel(name: "Pull-ups", type: .strength, met: 8.0, category: "Strength", sfSymbol: "figure.strengthtraining.traditional"),
        ExerciseTemplateModel(name: "Push-ups", type: .strength, met: 3.8, category: "Strength", sfSymbol: "figure.strengthtraining.traditional"),
        ExerciseTemplateModel(name: "Core Workout", type: .strength, met: 3.5, category: "Strength", sfSymbol: "figure.core.training"),
        ExerciseTemplateModel(name: "Resistance Bands", type: .strength, met: 3.5, category: "Strength", sfSymbol: "figure.strengthtraining.functional"),
        ExerciseTemplateModel(name: "Calisthenics", type: .strength, met: 4.0, category: "Strength", sfSymbol: "figure.strengthtraining.traditional"),
        ExerciseTemplateModel(name: "Plyometrics", type: .strength, met: 7.4, category: "Strength", sfSymbol: "figure.jumprope"),

        // MARK: Mind & Body
        ExerciseTemplateModel(name: "Yoga (gentle)", type: .flexibility, met: 2.5, category: "Mind & Body", sfSymbol: "figure.yoga"),
        ExerciseTemplateModel(name: "Yoga (power)", type: .flexibility, met: 4.0, category: "Mind & Body", sfSymbol: "figure.yoga"),
        ExerciseTemplateModel(name: "Pilates", type: .flexibility, met: 3.0, category: "Mind & Body", sfSymbol: "figure.pilates"),
        ExerciseTemplateModel(name: "Tai Chi", type: .flexibility, met: 3.0, category: "Mind & Body", sfSymbol: "figure.taichi"),
        ExerciseTemplateModel(name: "Stretching", type: .flexibility, met: 2.3, category: "Mind & Body", sfSymbol: "figure.flexibility"),
        ExerciseTemplateModel(name: "Barre", type: .flexibility, met: 3.0, category: "Mind & Body", sfSymbol: "figure.barre"),
        ExerciseTemplateModel(name: "Meditation", type: .flexibility, met: 1.0, category: "Mind & Body", sfSymbol: "brain.head.profile"),
        ExerciseTemplateModel(name: "Foam Rolling", type: .flexibility, met: 2.0, category: "Mind & Body", sfSymbol: "figure.flexibility"),

        // MARK: Team Sports
        ExerciseTemplateModel(name: "Basketball", type: .sports, met: 6.5, category: "Team Sports", sfSymbol: "basketball"),
        ExerciseTemplateModel(name: "Soccer", type: .sports, met: 7.0, category: "Team Sports", sfSymbol: "soccerball"),
        ExerciseTemplateModel(name: "Volleyball", type: .sports, met: 4.0, category: "Team Sports", sfSymbol: "volleyball"),
        ExerciseTemplateModel(name: "Football", type: .sports, met: 8.0, category: "Team Sports", sfSymbol: "football"),
        ExerciseTemplateModel(name: "Hockey (ice)", type: .sports, met: 8.0, category: "Team Sports", sfSymbol: "hockey.puck"),
        ExerciseTemplateModel(name: "Hockey (field)", type: .sports, met: 7.7, category: "Team Sports", sfSymbol: "hockey.puck"),
        ExerciseTemplateModel(name: "Baseball / Softball", type: .sports, met: 5.0, category: "Team Sports", sfSymbol: "baseball"),
        ExerciseTemplateModel(name: "Lacrosse", type: .sports, met: 8.0, category: "Team Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Rugby", type: .sports, met: 8.3, category: "Team Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Ultimate Frisbee", type: .sports, met: 3.5, category: "Team Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Dodgeball", type: .sports, met: 5.8, category: "Team Sports", sfSymbol: "sportscourt"),

        // MARK: Racquet Sports
        ExerciseTemplateModel(name: "Tennis (singles)", type: .sports, met: 7.3, category: "Racquet Sports", sfSymbol: "tennisball"),
        ExerciseTemplateModel(name: "Tennis (doubles)", type: .sports, met: 5.0, category: "Racquet Sports", sfSymbol: "tennisball"),
        ExerciseTemplateModel(name: "Pickleball", type: .sports, met: 4.8, category: "Racquet Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Badminton", type: .sports, met: 5.5, category: "Racquet Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Squash", type: .sports, met: 12.0, category: "Racquet Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Racquetball", type: .sports, met: 7.0, category: "Racquet Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Table Tennis", type: .sports, met: 4.0, category: "Racquet Sports", sfSymbol: "sportscourt"),
        ExerciseTemplateModel(name: "Paddle Tennis", type: .sports, met: 5.0, category: "Racquet Sports", sfSymbol: "sportscourt"),

        // MARK: Combat & Martial Arts
        ExerciseTemplateModel(name: "Karate", type: .other, met: 10.0, category: "Combat & Martial Arts", sfSymbol: "figure.martial.arts"),
        ExerciseTemplateModel(name: "Taekwondo", type: .other, met: 10.0, category: "Combat & Martial Arts", sfSymbol: "figure.martial.arts"),
        ExerciseTemplateModel(name: "Judo / Jiu-Jitsu", type: .other, met: 10.0, category: "Combat & Martial Arts", sfSymbol: "figure.martial.arts"),
        ExerciseTemplateModel(name: "MMA Training", type: .other, met: 10.0, category: "Combat & Martial Arts", sfSymbol: "figure.boxing"),
        ExerciseTemplateModel(name: "Boxing (bag work)", type: .other, met: 6.0, category: "Combat & Martial Arts", sfSymbol: "figure.boxing"),
        ExerciseTemplateModel(name: "Boxing (sparring)", type: .other, met: 12.8, category: "Combat & Martial Arts", sfSymbol: "figure.boxing"),
        ExerciseTemplateModel(name: "Wrestling", type: .other, met: 6.0, category: "Combat & Martial Arts", sfSymbol: "figure.wrestling"),
        ExerciseTemplateModel(name: "Kickboxing", type: .other, met: 7.0, category: "Combat & Martial Arts", sfSymbol: "figure.boxing"),
        ExerciseTemplateModel(name: "Fencing", type: .other, met: 6.0, category: "Combat & Martial Arts", sfSymbol: "figure.fencing"),
        ExerciseTemplateModel(name: "Kung Fu / Wushu", type: .other, met: 10.0, category: "Combat & Martial Arts", sfSymbol: "figure.martial.arts"),

        // MARK: Dance & Performance
        ExerciseTemplateModel(name: "Dancing (general)", type: .cardio, met: 4.5, category: "Dance & Performance", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Ballet", type: .flexibility, met: 5.0, category: "Dance & Performance", sfSymbol: "figure.dance"),
        ExerciseTemplateModel(name: "Hip Hop Dance", type: .cardio, met: 6.5, category: "Dance & Performance", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Ballroom Dancing", type: .cardio, met: 3.0, category: "Dance & Performance", sfSymbol: "music.note"),
        ExerciseTemplateModel(name: "Gymnastics", type: .flexibility, met: 3.8, category: "Dance & Performance", sfSymbol: "figure.gymnastics"),
        ExerciseTemplateModel(name: "Parkour", type: .cardio, met: 7.8, category: "Dance & Performance", sfSymbol: "figure.run"),
        ExerciseTemplateModel(name: "Cheerleading", type: .cardio, met: 4.8, category: "Dance & Performance", sfSymbol: "figure.gymnastics"),
        ExerciseTemplateModel(name: "Hula Hoop", type: .cardio, met: 4.5, category: "Dance & Performance", sfSymbol: "figure.dance"),

        // MARK: Winter Sports
        ExerciseTemplateModel(name: "Skiing (downhill)", type: .cardio, met: 5.3, category: "Winter Sports", sfSymbol: "figure.skiing.downhill"),
        ExerciseTemplateModel(name: "Skiing (cross-country)", type: .cardio, met: 9.0, category: "Winter Sports", sfSymbol: "figure.skiing.crosscountry"),
        ExerciseTemplateModel(name: "Snowboarding", type: .cardio, met: 5.3, category: "Winter Sports", sfSymbol: "figure.snowboarding"),
        ExerciseTemplateModel(name: "Ice Skating", type: .cardio, met: 5.5, category: "Winter Sports", sfSymbol: "figure.skating"),
        ExerciseTemplateModel(name: "Speed Skating", type: .cardio, met: 13.3, category: "Winter Sports", sfSymbol: "figure.skating"),
        ExerciseTemplateModel(name: "Snowshoeing", type: .cardio, met: 8.0, category: "Winter Sports", sfSymbol: "mountain.2"),
        ExerciseTemplateModel(name: "Ice Hockey", type: .sports, met: 8.0, category: "Winter Sports", sfSymbol: "hockey.puck"),

        // MARK: Everyday Active
        ExerciseTemplateModel(name: "Gardening", type: .other, met: 3.5, category: "Everyday Active", sfSymbol: "leaf"),
        ExerciseTemplateModel(name: "Mowing Lawn", type: .other, met: 5.5, category: "Everyday Active", sfSymbol: "leaf"),
        ExerciseTemplateModel(name: "Shoveling Snow", type: .other, met: 6.0, category: "Everyday Active", sfSymbol: "snowflake"),
        ExerciseTemplateModel(name: "Raking Leaves", type: .other, met: 4.3, category: "Everyday Active", sfSymbol: "leaf"),
        ExerciseTemplateModel(name: "Housecleaning", type: .other, met: 3.5, category: "Everyday Active", sfSymbol: "house"),
        ExerciseTemplateModel(name: "Moving / Carrying Boxes", type: .other, met: 7.0, category: "Everyday Active", sfSymbol: "shippingbox"),
        ExerciseTemplateModel(name: "Painting (house)", type: .other, met: 4.0, category: "Everyday Active", sfSymbol: "paintbrush"),
        ExerciseTemplateModel(name: "Chopping Wood", type: .other, met: 5.0, category: "Everyday Active", sfSymbol: "hammer"),
        ExerciseTemplateModel(name: "Playing with Kids", type: .other, met: 4.0, category: "Everyday Active", sfSymbol: "figure.2.and.child.holdinghands"),
        ExerciseTemplateModel(name: "Car Washing", type: .other, met: 4.0, category: "Everyday Active", sfSymbol: "car"),
        ExerciseTemplateModel(name: "Grocery Shopping", type: .other, met: 2.3, category: "Everyday Active", sfSymbol: "cart"),

        // MARK: Adventure
        ExerciseTemplateModel(name: "Rock Climbing (indoor)", type: .other, met: 8.0, category: "Adventure", sfSymbol: "figure.climbing"),
        ExerciseTemplateModel(name: "Rock Climbing (outdoor)", type: .other, met: 11.0, category: "Adventure", sfSymbol: "figure.climbing"),
        ExerciseTemplateModel(name: "Bouldering", type: .other, met: 8.0, category: "Adventure", sfSymbol: "figure.climbing"),
        ExerciseTemplateModel(name: "Skateboarding", type: .other, met: 5.0, category: "Adventure", sfSymbol: "figure.skating"),
        ExerciseTemplateModel(name: "Inline Skating", type: .other, met: 7.5, category: "Adventure", sfSymbol: "figure.skating"),
        ExerciseTemplateModel(name: "Golf (walking)", type: .sports, met: 4.8, category: "Adventure", sfSymbol: "figure.golf"),
        ExerciseTemplateModel(name: "Golf (cart)", type: .sports, met: 3.5, category: "Adventure", sfSymbol: "figure.golf"),
        ExerciseTemplateModel(name: "Disc Golf", type: .sports, met: 3.5, category: "Adventure", sfSymbol: "figure.golf"),
        ExerciseTemplateModel(name: "Horseback Riding", type: .other, met: 4.0, category: "Adventure", sfSymbol: "figure.equestrian.sports"),
        ExerciseTemplateModel(name: "Archery", type: .other, met: 3.5, category: "Adventure", sfSymbol: "scope"),
    ]

    func exercises(inCategory category: String) -> [ExerciseTemplateModel] {
        guard category != "All" else { return exercises }
        return exercises.filter { $0.category == category }
    }

    func search(_ query: String) -> [ExerciseTemplateModel] {
        guard !query.isEmpty else { return exercises }
        let q = query.lowercased()
        return exercises.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) }
            .sorted { a, b in
                let aStarts = a.name.lowercased().hasPrefix(q)
                let bStarts = b.name.lowercased().hasPrefix(q)
                if aStarts != bStarts { return aStarts }
                return a.name < b.name
            }
    }

    // Backward-compat
    func searchExercises(_ query: String) -> [ExerciseTemplateModel] { search(query) }
    func getExercise(named name: String) -> ExerciseTemplateModel? { exercises.first { $0.name == name } }
}
