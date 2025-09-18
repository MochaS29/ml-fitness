import Foundation
import CoreData

class ExerciseAutofillService {
    static let shared = ExerciseAutofillService()
    private let maxSuggestions = 5
    private let minOccurrencesForSuggestion = 2
    
    private init() {}
    
    // MARK: - Suggestion Models
    
    struct ExerciseSuggestion {
        let exercise: ExerciseTemplateModel
        let confidence: Double
        let reason: SuggestionReason
        let typicalDuration: Int?
        let typicalCalories: Int?
        let lastPerformed: Date?
    }
    
    enum SuggestionReason {
        case frequentlyUsed
        case timeOfDay
        case dayOfWeek
        case recentlyUsed
        case similarToInput
        case followsPattern
    }
    
    // MARK: - Public Methods
    
    func getSuggestions(for input: String, at date: Date = Date(), context: NSManagedObjectContext) -> [ExerciseSuggestion] {
        var suggestions: [ExerciseSuggestion] = []
        
        // Get user's exercise history
        let history = fetchExerciseHistory(context: context)
        
        // 1. Match based on partial input
        if !input.isEmpty {
            suggestions.append(contentsOf: getMatchingSuggestions(input: input, history: history))
        }
        
        // 2. Time-based suggestions
        suggestions.append(contentsOf: getTimeBasedSuggestions(date: date, history: history))
        
        // 3. Day of week patterns
        suggestions.append(contentsOf: getDayBasedSuggestions(date: date, history: history))
        
        // 4. Recently used exercises
        suggestions.append(contentsOf: getRecentSuggestions(history: history))
        
        // 5. Frequently used exercises
        suggestions.append(contentsOf: getFrequentSuggestions(history: history))
        
        // Remove duplicates and sort by confidence
        let uniqueSuggestions = removeDuplicates(from: suggestions)
        return Array(uniqueSuggestions.sorted { $0.confidence > $1.confidence }.prefix(maxSuggestions))
    }
    
    func getTypicalDuration(for exerciseName: String, context: NSManagedObjectContext) -> Int? {
        let fetchRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", exerciseName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)]
        fetchRequest.fetchLimit = 10
        
        do {
            let entries = try context.fetch(fetchRequest)
            guard !entries.isEmpty else { return nil }
            
            let durations = entries.map { Int($0.duration) }
            let averageDuration = durations.reduce(0, +) / durations.count
            return averageDuration
        } catch {
            print("Error fetching typical duration: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchExerciseHistory(context: NSManagedObjectContext) -> [ExerciseEntry] {
        let fetchRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseEntry.timestamp, ascending: false)]
        fetchRequest.fetchLimit = 200 // Last 200 exercises
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching exercise history: \(error)")
            return []
        }
    }
    
    private func getMatchingSuggestions(input: String, history: [ExerciseEntry]) -> [ExerciseSuggestion] {
        let lowercasedInput = input.lowercased()
        var exerciseMatches: [String: (count: Int, lastDate: Date?, totalDuration: Int, totalCalories: Int)] = [:]
        
        // Analyze history for matching exercises
        for entry in history {
            guard let name = entry.name?.lowercased() else { continue }
            
            if name.contains(lowercasedInput) || name.hasPrefix(lowercasedInput) {
                let key = entry.name ?? ""
                var data = exerciseMatches[key] ?? (count: 0, lastDate: nil, totalDuration: 0, totalCalories: 0)
                data.count += 1
                data.totalDuration += Int(entry.duration)
                data.totalCalories += Int(entry.caloriesBurned)
                if data.lastDate == nil || (entry.timestamp ?? Date()) > data.lastDate! {
                    data.lastDate = entry.timestamp
                }
                exerciseMatches[key] = data
            }
        }
        
        // Convert to suggestions
        return exerciseMatches.compactMap { name, data in
            guard let exercise = ExerciseDatabase.shared.findExercise(by: name) else { return nil }
            
            let avgDuration = data.count > 0 ? data.totalDuration / data.count : nil
            let avgCalories = data.count > 0 ? data.totalCalories / data.count : nil
            let confidence = calculateMatchConfidence(input: lowercasedInput, exerciseName: name.lowercased(), occurrences: data.count)
            
            return ExerciseSuggestion(
                exercise: exercise,
                confidence: confidence,
                reason: .similarToInput,
                typicalDuration: avgDuration,
                typicalCalories: avgCalories,
                lastPerformed: data.lastDate
            )
        }
    }
    
    private func getTimeBasedSuggestions(date: Date, history: [ExerciseEntry]) -> [ExerciseSuggestion] {
        let hour = Calendar.current.component(.hour, from: date)
        let timeWindow = 2 // +/- 2 hours
        
        var timePatterns: [String: (count: Int, totalDuration: Int, lastDate: Date?)] = [:]
        
        for entry in history {
            guard let timestamp = entry.timestamp,
                  let name = entry.name else { continue }
            
            let entryHour = Calendar.current.component(.hour, from: timestamp)
            if abs(entryHour - hour) <= timeWindow {
                var data = timePatterns[name] ?? (count: 0, totalDuration: 0, lastDate: nil)
                data.count += 1
                data.totalDuration += Int(entry.duration)
                if data.lastDate == nil || timestamp > data.lastDate! {
                    data.lastDate = timestamp
                }
                timePatterns[name] = data
            }
        }
        
        return timePatterns.compactMap { name, data in
            guard data.count >= minOccurrencesForSuggestion,
                  let exercise = ExerciseDatabase.shared.findExercise(by: name) else { return nil }
            
            let avgDuration = data.totalDuration / data.count
            let confidence = Double(data.count) / 20.0 // Max confidence at 20 occurrences
            
            return ExerciseSuggestion(
                exercise: exercise,
                confidence: min(confidence * 0.8, 0.8), // Time-based suggestions max at 0.8
                reason: .timeOfDay,
                typicalDuration: avgDuration,
                typicalCalories: nil,
                lastPerformed: data.lastDate
            )
        }
    }
    
    private func getDayBasedSuggestions(date: Date, history: [ExerciseEntry]) -> [ExerciseSuggestion] {
        let weekday = Calendar.current.component(.weekday, from: date)
        var dayPatterns: [String: (count: Int, totalDuration: Int, lastDate: Date?)] = [:]
        
        for entry in history {
            guard let timestamp = entry.timestamp,
                  let name = entry.name else { continue }
            
            let entryWeekday = Calendar.current.component(.weekday, from: timestamp)
            if entryWeekday == weekday {
                var data = dayPatterns[name] ?? (count: 0, totalDuration: 0, lastDate: nil)
                data.count += 1
                data.totalDuration += Int(entry.duration)
                if data.lastDate == nil || timestamp > data.lastDate! {
                    data.lastDate = timestamp
                }
                dayPatterns[name] = data
            }
        }
        
        return dayPatterns.compactMap { name, data in
            guard data.count >= minOccurrencesForSuggestion,
                  let exercise = ExerciseDatabase.shared.findExercise(by: name) else { return nil }
            
            let avgDuration = data.totalDuration / data.count
            let confidence = Double(data.count) / 15.0 // Max confidence at 15 occurrences
            
            return ExerciseSuggestion(
                exercise: exercise,
                confidence: min(confidence * 0.7, 0.7), // Day-based suggestions max at 0.7
                reason: .dayOfWeek,
                typicalDuration: avgDuration,
                typicalCalories: nil,
                lastPerformed: data.lastDate
            )
        }
    }
    
    private func getRecentSuggestions(history: [ExerciseEntry]) -> [ExerciseSuggestion] {
        var recentExercises: [String: (date: Date, duration: Int)] = [:]
        
        // Get unique recent exercises
        for entry in history.prefix(20) { // Last 20 entries
            guard let name = entry.name,
                  let timestamp = entry.timestamp else { continue }
            
            if recentExercises[name] == nil {
                recentExercises[name] = (date: timestamp, duration: Int(entry.duration))
            }
        }
        
        return recentExercises.compactMap { name, data in
            guard let exercise = ExerciseDatabase.shared.findExercise(by: name) else { return nil }
            
            let daysSinceLastUse = Calendar.current.dateComponents([.day], from: data.date, to: Date()).day ?? 0
            let recencyScore = max(0.0, 1.0 - (Double(daysSinceLastUse) / 30.0)) // Decay over 30 days
            
            return ExerciseSuggestion(
                exercise: exercise,
                confidence: recencyScore * 0.6, // Recent suggestions max at 0.6
                reason: .recentlyUsed,
                typicalDuration: data.duration,
                typicalCalories: nil,
                lastPerformed: data.date
            )
        }
    }
    
    private func getFrequentSuggestions(history: [ExerciseEntry]) -> [ExerciseSuggestion] {
        var frequency: [String: (count: Int, totalDuration: Int, lastDate: Date?)] = [:]
        
        for entry in history {
            guard let name = entry.name else { continue }
            
            var data = frequency[name] ?? (count: 0, totalDuration: 0, lastDate: nil)
            data.count += 1
            data.totalDuration += Int(entry.duration)
            if let timestamp = entry.timestamp {
                if data.lastDate == nil || timestamp > data.lastDate! {
                    data.lastDate = timestamp
                }
            }
            frequency[name] = data
        }
        
        // Sort by frequency and take top exercises
        let topExercises = frequency.sorted { $0.value.count > $1.value.count }.prefix(10)
        
        return topExercises.compactMap { name, data in
            guard let exercise = ExerciseDatabase.shared.findExercise(by: name) else { return nil }
            
            let avgDuration = data.totalDuration / data.count
            let frequencyScore = min(Double(data.count) / 50.0, 1.0) // Max at 50 uses
            
            return ExerciseSuggestion(
                exercise: exercise,
                confidence: frequencyScore * 0.5, // Frequency suggestions max at 0.5
                reason: .frequentlyUsed,
                typicalDuration: avgDuration,
                typicalCalories: nil,
                lastPerformed: data.lastDate
            )
        }
    }
    
    private func calculateMatchConfidence(input: String, exerciseName: String, occurrences: Int) -> Double {
        var confidence = 0.0
        
        // Exact match
        if exerciseName == input {
            confidence = 1.0
        }
        // Starts with input
        else if exerciseName.hasPrefix(input) {
            confidence = 0.9
        }
        // Contains input
        else if exerciseName.contains(input) {
            confidence = 0.7
        }
        // Fuzzy match (simple Levenshtein distance approximation)
        else {
            let similarity = calculateSimilarity(input, exerciseName)
            confidence = similarity * 0.6
        }
        
        // Boost confidence based on usage frequency
        let usageBoost = min(Double(occurrences) / 20.0, 0.2)
        return min(confidence + usageBoost, 1.0)
    }
    
    private func calculateSimilarity(_ s1: String, _ s2: String) -> Double {
        let longer = s1.count > s2.count ? s1 : s2
        let shorter = s1.count > s2.count ? s2 : s1
        
        if longer.isEmpty { return 1.0 }
        
        let editDistance = levenshteinDistance(shorter, longer)
        return Double(longer.count - editDistance) / Double(longer.count)
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count
        
        if m == 0 { return n }
        if n == 0 { return m }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            matrix[i][0] = i
        }
        
        for j in 0...n {
            matrix[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] == s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[m][n]
    }
    
    private func removeDuplicates(from suggestions: [ExerciseSuggestion]) -> [ExerciseSuggestion] {
        var seen = Set<String>()
        var unique: [ExerciseSuggestion] = []
        
        for suggestion in suggestions {
            if !seen.contains(suggestion.exercise.name) {
                seen.insert(suggestion.exercise.name)
                unique.append(suggestion)
            }
        }
        
        return unique
    }
}

// MARK: - ExerciseDatabase Extension

extension ExerciseDatabase {
    func findExercise(by name: String) -> ExerciseTemplateModel? {
        return exercises.first { $0.name.lowercased() == name.lowercased() }
    }
}