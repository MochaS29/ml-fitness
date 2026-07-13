import Foundation
import CoreData

/// Imports a MyFitnessPal CSV export into the diary. Handles the three export
/// types MyFitnessPal produces, auto-detected from the header row:
///   - Nutrition  -> FoodEntry  (one row per logged food, macros already consumed)
///   - Exercise   -> ExerciseEntry
///   - Measurement -> WeightEntry
///
/// Column lookup is header-name based (case-insensitive, tolerant of the
/// "(g)"/"(mg)" suffixes and column reordering) so small format drift between
/// MFP export versions doesn't break the import.
enum MFPImporter {

    // MARK: - Types

    enum Kind {
        case nutrition, exercise, weight
    }

    /// MFP measurement exports don't reliably label the weight unit, so the user
    /// confirms it before importing. The app stores weight in pounds.
    enum WeightUnit {
        case pounds, kilograms
        var toPounds: Double { self == .kilograms ? 2.2046226218 : 1.0 }
    }

    struct ParsedFoodRow {
        let date: Date
        let mealType: MealType
        let name: String
        let calories, protein, carbs, fat, fiber, sugar, saturatedFat, cholesterol, sodium: Double
        let additional: [String: Double]
    }

    struct ParsedExerciseRow {
        let date: Date
        let name: String
        let category: String
        let durationMinutes: Int
        let caloriesBurned: Double
    }

    struct ParsedWeightRow {
        let date: Date
        let rawWeight: Double
    }

    struct Summary {
        let kind: Kind
        let totalRows: Int
        let importableRows: Int
        let skippedRows: Int
        let startDate: Date?
        let endDate: Date?
        let mealCounts: [MealType: Int]       // nutrition only
        let sampleNames: [String]
        let foodEntries: [ParsedFoodRow]
        let exerciseEntries: [ParsedExerciseRow]
        let weightEntries: [ParsedWeightRow]

        /// Human label for the kind of thing being imported (e.g. "42 entries").
        var noun: String {
            switch kind {
            case .nutrition: return importableRows == 1 ? "entry" : "entries"
            case .exercise: return importableRows == 1 ? "workout" : "workouts"
            case .weight: return importableRows == 1 ? "weigh-in" : "weigh-ins"
            }
        }
    }

    enum ImportError: LocalizedError {
        case empty
        case unrecognized

        var errorDescription: String? {
            switch self {
            case .empty:
                return "That file has no rows to import."
            case .unrecognized:
                return "This doesn't look like a MyFitnessPal export. Choose the Nutrition, Exercise, or Measurement CSV from your MyFitnessPal data."
            }
        }
    }

    // MARK: - Preview (parse only, no insert)

    static func preview(csvText: String) throws -> Summary {
        let (headers, rows) = CSVParser.parseWithHeaders(csvText)
        guard !rows.isEmpty else { throw ImportError.empty }

        let keys = headers.map { $0.lowercased() }
        guard let kind = detectKind(keys) else { throw ImportError.unrecognized }

        switch kind {
        case .nutrition: return previewNutrition(rows)
        case .exercise: return previewExercise(rows)
        case .weight: return previewWeight(rows)
        }
    }

    private static func detectKind(_ keys: [String]) -> Kind? {
        func has(_ prefix: String) -> Bool { keys.contains { $0.hasPrefix(prefix) } }
        // Order matters: a strength row in an exercise export can carry a "weight"
        // column, so check food and exercise before falling back to weight.
        if has("food") { return .nutrition }
        if has("exercise") { return .exercise }
        if has("weight") { return .weight }
        return nil
    }

    // MARK: - Import (batched insert with dedupe)

    /// Inserts the summary's rows and returns how many were actually added
    /// (duplicates already in the diary are skipped). Dedupe is against entries
    /// that existed *before* this import, so a full re-import adds nothing.
    @discardableResult
    static func importSummary(
        _ summary: Summary,
        weightUnit: WeightUnit,
        container: NSPersistentContainer,
        progress: @escaping (Double) -> Void
    ) async throws -> Int {
        switch summary.kind {
        case .nutrition:
            return try await insert(summary.foodEntries, container: container, progress: progress)
        case .exercise:
            return try await insert(summary.exerciseEntries, container: container, progress: progress)
        case .weight:
            return try await insert(summary.weightEntries, unit: weightUnit, container: container, progress: progress)
        }
    }

    // MARK: - Nutrition

    private static func previewNutrition(_ rows: [[String: String]]) -> Summary {
        var parsed: [ParsedFoodRow] = []
        var skipped = 0
        for row in rows {
            if let e = parseFood(row) { parsed.append(e) } else { skipped += 1 }
        }
        let sorted = parsed.sorted { $0.date < $1.date }
        var mealCounts: [MealType: Int] = [:]
        for e in parsed { mealCounts[e.mealType, default: 0] += 1 }
        return Summary(
            kind: .nutrition, totalRows: rows.count, importableRows: parsed.count, skippedRows: skipped,
            startDate: sorted.first?.date, endDate: sorted.last?.date, mealCounts: mealCounts,
            sampleNames: Array(parsed.prefix(5).map { $0.name }),
            foodEntries: parsed, exerciseEntries: [], weightEntries: []
        )
    }

    private static func insert(_ entries: [ParsedFoodRow], container: NSPersistentContainer, progress: @escaping (Double) -> Void) async throws -> Int {
        guard !entries.isEmpty else { return 0 }
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return try await context.perform {
            let existing = try existingKeys(in: context, entity: "FoodEntry", dates: entries.map { $0.date }) { e in
                dedupeKey(day: e.value(forKey: "date") as? Date, name: e.value(forKey: "name") as? String ?? "", n: e.value(forKey: "calories") as? Double ?? 0)
            }
            var inserted = 0
            let total = entries.count
            for (idx, row) in entries.enumerated() {
                let key = dedupeKey(day: row.date, name: row.name, n: row.calories)
                if existing.contains(key) { continue }
                let entry = FoodEntry(context: context)
                entry.id = UUID()
                entry.name = row.name
                entry.mealType = row.mealType.rawValue
                entry.date = row.date
                entry.timestamp = row.date
                entry.calories = row.calories
                entry.protein = row.protein
                entry.carbs = row.carbs
                entry.fat = row.fat
                entry.fiber = row.fiber
                entry.sugar = row.sugar
                entry.saturatedFat = row.saturatedFat
                entry.cholesterol = row.cholesterol
                entry.sodium = row.sodium
                entry.servingSize = "1"
                entry.servingUnit = "serving"
                entry.servingCount = 1
                if !row.additional.isEmpty { entry.additionalNutrients = row.additional }
                inserted += 1
                if inserted % 500 == 0 { try context.save(); context.reset() }
                if idx % 100 == 0 { progress(Double(idx) / Double(total)) }
            }
            if context.hasChanges { try context.save() }
            progress(1.0)
            return inserted
        }
    }

    private static func parseFood(_ row: [String: String]) -> ParsedFoodRow? {
        guard let dateStr = value(row, ["date"]), let date = parseDate(dateStr) else { return nil }
        guard let name = value(row, ["food", "name"]), !name.isEmpty else { return nil }
        let meal = mapMeal(value(row, ["meal"]) ?? "")
        let dated = timestamp(for: meal, on: date)
        var additional: [String: Double] = [:]
        if let p = number(row, ["potassium"]) { additional["Potassium"] = p }
        if let v = number(row, ["vitamin a"]) { additional["Vitamin A"] = v }
        if let v = number(row, ["vitamin c"]) { additional["Vitamin C"] = v }
        if let v = number(row, ["calcium"]) { additional["Calcium"] = v }
        if let v = number(row, ["iron"]) { additional["Iron"] = v }
        return ParsedFoodRow(
            date: dated, mealType: meal, name: name,
            calories: number(row, ["calories", "energy"]) ?? 0,
            protein: number(row, ["protein (g)", "protein"]) ?? 0,
            carbs: number(row, ["carbohydrates (g)", "carbohydrates", "carbs"]) ?? 0,
            fat: number(row, ["fat (g)", "fat"]) ?? 0,
            fiber: number(row, ["fiber", "fibre"]) ?? 0,
            sugar: number(row, ["sugar"]) ?? 0,
            saturatedFat: number(row, ["saturated fat"]) ?? 0,
            cholesterol: number(row, ["cholesterol"]) ?? 0,
            sodium: number(row, ["sodium (mg)", "sodium"]) ?? 0,
            additional: additional
        )
    }

    // MARK: - Exercise

    private static func previewExercise(_ rows: [[String: String]]) -> Summary {
        var parsed: [ParsedExerciseRow] = []
        var skipped = 0
        for row in rows {
            if let e = parseExercise(row) { parsed.append(e) } else { skipped += 1 }
        }
        let sorted = parsed.sorted { $0.date < $1.date }
        return Summary(
            kind: .exercise, totalRows: rows.count, importableRows: parsed.count, skippedRows: skipped,
            startDate: sorted.first?.date, endDate: sorted.last?.date, mealCounts: [:],
            sampleNames: Array(parsed.prefix(5).map { $0.name }),
            foodEntries: [], exerciseEntries: parsed, weightEntries: []
        )
    }

    private static func insert(_ entries: [ParsedExerciseRow], container: NSPersistentContainer, progress: @escaping (Double) -> Void) async throws -> Int {
        guard !entries.isEmpty else { return 0 }
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return try await context.perform {
            let existing = try existingKeys(in: context, entity: "ExerciseEntry", dates: entries.map { $0.date }) { e in
                dedupeKey(day: e.value(forKey: "date") as? Date, name: e.value(forKey: "name") as? String ?? "", n: e.value(forKey: "caloriesBurned") as? Double ?? 0)
            }
            var inserted = 0
            let total = entries.count
            for (idx, row) in entries.enumerated() {
                let key = dedupeKey(day: row.date, name: row.name, n: row.caloriesBurned)
                if existing.contains(key) { continue }
                let entry = ExerciseEntry(context: context)
                entry.id = UUID()
                entry.name = row.name
                entry.category = row.category
                entry.type = row.category
                entry.duration = Int32(row.durationMinutes)
                entry.caloriesBurned = row.caloriesBurned
                entry.date = row.date
                entry.timestamp = row.date
                inserted += 1
                if inserted % 500 == 0 { try context.save(); context.reset() }
                if idx % 100 == 0 { progress(Double(idx) / Double(total)) }
            }
            if context.hasChanges { try context.save() }
            progress(1.0)
            return inserted
        }
    }

    private static func parseExercise(_ row: [String: String]) -> ParsedExerciseRow? {
        guard let dateStr = value(row, ["date"]), let date = parseDate(dateStr) else { return nil }
        guard let name = value(row, ["exercise", "name"]), !name.isEmpty else { return nil }
        let type = value(row, ["type"]) ?? "Cardio"
        let category = mapExerciseCategory(type)
        let minutes = Int(number(row, ["exercise minutes", "minutes", "duration"]) ?? 0)
        let calories = number(row, ["exercise calories", "calories burned", "calories"]) ?? 0
        // Assign a stable midday time so imported workouts order sensibly.
        let dated = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
        return ParsedExerciseRow(date: dated, name: name, category: category, durationMinutes: minutes, caloriesBurned: calories)
    }

    private static func mapExerciseCategory(_ raw: String) -> String {
        let lower = raw.lowercased()
        if lower.contains("strength") || lower.contains("weight") { return "Strength" }
        if lower.contains("cardio") { return "Cardio" }
        return raw.isEmpty ? "Cardio" : raw
    }

    // MARK: - Weight

    private static func previewWeight(_ rows: [[String: String]]) -> Summary {
        var parsed: [ParsedWeightRow] = []
        var skipped = 0
        for row in rows {
            if let e = parseWeight(row) { parsed.append(e) } else { skipped += 1 }
        }
        let sorted = parsed.sorted { $0.date < $1.date }
        return Summary(
            kind: .weight, totalRows: rows.count, importableRows: parsed.count, skippedRows: skipped,
            startDate: sorted.first?.date, endDate: sorted.last?.date, mealCounts: [:],
            sampleNames: [], foodEntries: [], exerciseEntries: [], weightEntries: parsed
        )
    }

    private static func insert(_ entries: [ParsedWeightRow], unit: WeightUnit, container: NSPersistentContainer, progress: @escaping (Double) -> Void) async throws -> Int {
        guard !entries.isEmpty else { return 0 }
        let factor = unit.toPounds
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return try await context.perform {
            let existing = try existingKeys(in: context, entity: "WeightEntry", dates: entries.map { $0.date }) { e in
                weightKey(day: e.value(forKey: "date") as? Date ?? e.value(forKey: "timestamp") as? Date, pounds: e.value(forKey: "weight") as? Double ?? 0)
            }
            var inserted = 0
            let total = entries.count
            for (idx, row) in entries.enumerated() {
                let pounds = row.rawWeight * factor
                let key = weightKey(day: row.date, pounds: pounds)
                if existing.contains(key) { continue }
                let entry = WeightEntry(context: context)
                entry.id = UUID()
                entry.weight = pounds
                entry.date = row.date
                entry.timestamp = row.date
                inserted += 1
                if idx % 100 == 0 { progress(Double(idx) / Double(total)) }
            }
            if context.hasChanges { try context.save() }
            progress(1.0)
            return inserted
        }
    }

    private static func parseWeight(_ row: [String: String]) -> ParsedWeightRow? {
        guard let dateStr = value(row, ["date"]), let date = parseDate(dateStr) else { return nil }
        guard let w = number(row, ["weight"]), w > 0 else { return nil }
        let dated = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: date) ?? date
        return ParsedWeightRow(date: dated, rawWeight: w)
    }

    // MARK: - Meal + time mapping

    private static func mapMeal(_ raw: String) -> MealType {
        switch raw.trimmingCharacters(in: .whitespaces).lowercased() {
        case "breakfast": return .breakfast
        case "lunch": return .lunch
        case "dinner": return .dinner
        case "snack", "snacks": return .snack
        default: return .snack
        }
    }

    private static func timestamp(for meal: MealType, on date: Date) -> Date {
        let cal = Calendar.current
        let (h, m): (Int, Int)
        switch meal {
        case .breakfast: (h, m) = (8, 0)
        case .lunch: (h, m) = (12, 30)
        case .dinner: (h, m) = (19, 0)
        case .snack: (h, m) = (15, 0)
        }
        return cal.date(bySettingHour: h, minute: m, second: 0, of: date) ?? date
    }

    // MARK: - Dedupe

    private static func dedupeKey(day: Date?, name: String, n: Double) -> String {
        let dayStr = (day.map { Calendar.current.startOfDay(for: $0).timeIntervalSince1970 } ?? 0)
        return "\(dayStr)|\(name.lowercased())|\(Int(n.rounded()))"
    }

    private static func weightKey(day: Date?, pounds: Double) -> String {
        let dayStr = (day.map { Calendar.current.startOfDay(for: $0).timeIntervalSince1970 } ?? 0)
        return "\(dayStr)|\(Int((pounds * 10).rounded()))"   // 0.1 lb resolution
    }

    private static func existingKeys(in context: NSManagedObjectContext, entity: String, dates: [Date], key: (NSManagedObject) -> String) throws -> Set<String> {
        guard let minDate = dates.min(), let maxDate = dates.max() else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: minDate)
        let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: maxDate)) ?? maxDate
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let existing = try context.fetch(request)
        return Set(existing.map(key))
    }

    // MARK: - Column helpers

    private static func value(_ row: [String: String], _ candidates: [String]) -> String? {
        for candidate in candidates {
            if let exact = row[candidate], !exact.isEmpty { return exact.trimmingCharacters(in: .whitespaces) }
        }
        for candidate in candidates {
            if let match = row.first(where: { $0.key.hasPrefix(candidate) })?.value, !match.isEmpty {
                return match.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    private static func number(_ row: [String: String], _ candidates: [String]) -> Double? {
        guard let raw = value(row, candidates) else { return nil }
        let cleaned = raw.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
        return Double(cleaned)
    }

    private static func parseDate(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        for format in dateFormats {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = format
            if let d = df.date(from: trimmed) { return d }
        }
        return nil
    }

    private static let dateFormats = [
        "yyyy-MM-dd", "MM/dd/yyyy", "M/d/yyyy", "dd/MM/yyyy", "d/M/yyyy", "yyyy/MM/dd", "MMMM d, yyyy"
    ]
}
