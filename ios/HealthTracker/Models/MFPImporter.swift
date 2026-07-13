import Foundation
import CoreData

/// Imports a MyFitnessPal "Nutrition" CSV export into the food diary.
///
/// MFP exports one row per logged food, and each row already carries the
/// *consumed* macros (not per-serving values times a count), so every row maps
/// cleanly to a single `FoodEntry` with `servingCount` = 1. No serving math.
///
/// Column lookup is header-name based (case-insensitive, tolerant of the
/// "(g)"/"(mg)" suffixes and column reordering) so small format drift between
/// MFP export versions doesn't break the import.
enum MFPImporter {

    // MARK: - Types

    struct ParsedFoodRow {
        let date: Date
        let mealType: MealType
        let name: String
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double
        let sugar: Double
        let saturatedFat: Double
        let cholesterol: Double
        let sodium: Double
        let additional: [String: Double]
    }

    struct Summary {
        let totalRows: Int
        let importableRows: Int
        let skippedRows: Int
        let startDate: Date?
        let endDate: Date?
        let mealCounts: [MealType: Int]
        let sampleNames: [String]
        let entries: [ParsedFoodRow]
    }

    enum ImportError: LocalizedError {
        case empty
        case missingRequiredColumns

        var errorDescription: String? {
            switch self {
            case .empty:
                return "That file has no rows to import."
            case .missingRequiredColumns:
                return "This doesn't look like a MyFitnessPal Nutrition export. It needs at least Date, Food, and Calories columns."
            }
        }
    }

    // MARK: - Preview (parse only, no insert)

    static func preview(csvText: String) throws -> Summary {
        let (headers, rows) = CSVParser.parseWithHeaders(csvText)
        guard !rows.isEmpty else { throw ImportError.empty }

        let keys = headers.map { $0.lowercased() }
        guard column(keys, ["date"]) != nil,
              column(keys, ["food", "name"]) != nil,
              column(keys, ["calories", "energy"]) != nil else {
            throw ImportError.missingRequiredColumns
        }

        var parsed: [ParsedFoodRow] = []
        var skipped = 0
        for row in rows {
            if let entry = parseRow(row) {
                parsed.append(entry)
            } else {
                skipped += 1
            }
        }

        let sorted = parsed.sorted { $0.date < $1.date }
        var mealCounts: [MealType: Int] = [:]
        for e in parsed { mealCounts[e.mealType, default: 0] += 1 }

        return Summary(
            totalRows: rows.count,
            importableRows: parsed.count,
            skippedRows: skipped,
            startDate: sorted.first?.date,
            endDate: sorted.last?.date,
            mealCounts: mealCounts,
            sampleNames: Array(parsed.prefix(5).map { $0.name }),
            entries: parsed
        )
    }

    // MARK: - Import (batched insert with dedupe)

    /// Inserts the parsed rows on a background context and returns how many were
    /// actually added (duplicates already present in the diary are skipped).
    /// Dedupe is against entries that existed *before* this import, so a full
    /// re-import of the same file adds nothing, while legitimately repeated
    /// foods within one file are all kept.
    @discardableResult
    static func importEntries(
        _ entries: [ParsedFoodRow],
        container: NSPersistentContainer,
        progress: @escaping (Double) -> Void
    ) async throws -> Int {
        guard !entries.isEmpty else { return 0 }

        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return try await context.perform {
            let existingKeys = try existingDedupeKeys(in: context, entries: entries)

            var inserted = 0
            let total = entries.count
            for (idx, row) in entries.enumerated() {
                let key = dedupeKey(day: row.date, name: row.name, calories: row.calories)
                if existingKeys.contains(key) { continue }

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
                if !row.additional.isEmpty {
                    entry.additionalNutrients = row.additional
                }
                inserted += 1

                // Save + report periodically to keep memory flat on large files.
                if inserted % 500 == 0 {
                    try context.save()
                    context.reset()
                }
                if idx % 100 == 0 {
                    progress(Double(idx) / Double(total))
                }
            }
            if context.hasChanges { try context.save() }
            progress(1.0)
            return inserted
        }
    }

    // MARK: - Row parsing

    private static func parseRow(_ row: [String: String]) -> ParsedFoodRow? {
        guard let dateStr = value(row, ["date"]), let date = parseDate(dateStr) else { return nil }
        guard let name = value(row, ["food", "name"]), !name.isEmpty else { return nil }

        let meal = mapMeal(value(row, ["meal"]) ?? "", date: date)
        let dated = timestamp(for: meal, on: date)

        var additional: [String: Double] = [:]
        if let potassium = number(row, ["potassium"]) { additional["Potassium"] = potassium }
        if let vitA = number(row, ["vitamin a"]) { additional["Vitamin A"] = vitA }
        if let vitC = number(row, ["vitamin c"]) { additional["Vitamin C"] = vitC }
        if let calcium = number(row, ["calcium"]) { additional["Calcium"] = calcium }
        if let iron = number(row, ["iron"]) { additional["Iron"] = iron }

        return ParsedFoodRow(
            date: dated,
            mealType: meal,
            name: name,
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

    // MARK: - Meal + time mapping

    private static func mapMeal(_ raw: String, date: Date) -> MealType {
        switch raw.trimmingCharacters(in: .whitespaces).lowercased() {
        case "breakfast": return .breakfast
        case "lunch": return .lunch
        case "dinner": return .dinner
        case "snack", "snacks": return .snack
        default: return .snack   // custom / renamed meals map to Snack
        }
    }

    /// MFP exports carry no time of day, so assign a stable per-meal time so the
    /// diary orders entries sensibly. Matches DemoDataGenerator's conventions.
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

    private static func dedupeKey(day: Date, name: String, calories: Double) -> String {
        let dayStr = Calendar.current.startOfDay(for: day).timeIntervalSince1970
        return "\(dayStr)|\(name.lowercased())|\(Int(calories.rounded()))"
    }

    private static func existingDedupeKeys(in context: NSManagedObjectContext, entries: [ParsedFoodRow]) throws -> Set<String> {
        let dates = entries.map { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: minDate)
        let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: maxDate)) ?? maxDate

        let request = NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        let existing = try context.fetch(request)
        var keys = Set<String>()
        for e in existing {
            keys.insert(dedupeKey(day: e.date ?? start, name: e.name ?? "", calories: e.calories))
        }
        return keys
    }

    // MARK: - Column helpers

    private static func column(_ keys: [String], _ candidates: [String]) -> Int? {
        for candidate in candidates {
            if let idx = keys.firstIndex(where: { $0 == candidate || $0.hasPrefix(candidate) }) {
                return idx
            }
        }
        return nil
    }

    private static func value(_ row: [String: String], _ candidates: [String]) -> String? {
        for candidate in candidates {
            if let exact = row[candidate], !exact.isEmpty { return exact.trimmingCharacters(in: .whitespaces) }
        }
        // Prefix match (e.g. "protein (g)" when only "protein" was requested, or vice-versa)
        for candidate in candidates {
            if let match = row.first(where: { $0.key.hasPrefix(candidate) })?.value, !match.isEmpty {
                return match.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    private static func number(_ row: [String: String], _ candidates: [String]) -> Double? {
        guard let raw = value(row, candidates) else { return nil }
        // Strip thousands separators and any stray unit text.
        let cleaned = raw.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
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
