import Foundation
import SQLite3

/// SQLite-backed local food database with FTS5 full-text search.
/// Reads from a bundled `food_database.sqlite` file containing ~25,000 USDA foods.
/// Falls back to the hardcoded FoodDatabase if the SQLite file is missing.
class LocalFoodDatabase {
    static let shared = LocalFoodDatabase()

    private var db: OpaquePointer?
    private var isAvailable = false

    private init() {
        openDatabase()
    }

    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }

    // MARK: - Database Setup

    private func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "food_database", ofType: "sqlite") else {
            print("LocalFoodDatabase: food_database.sqlite not found in bundle, using fallback.")
            return
        }

        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
            isAvailable = true
            print("LocalFoodDatabase: Opened successfully with \(getFoodCount()) foods.")
        } else {
            print("LocalFoodDatabase: Failed to open database.")
            db = nil
        }
    }

    /// Whether the SQLite database is available
    var isDatabaseAvailable: Bool {
        return isAvailable
    }

    // MARK: - Search

    /// Search foods using FTS5 full-text search with relevance ranking.
    /// Falls back to FoodDatabase.shared if SQLite is unavailable.
    func searchFoods(_ query: String, limit: Int = 50) -> [FoodItem] {
        guard isAvailable, let db = db else {
            return FoodDatabase.shared.searchFoods(query)
        }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Build FTS5 query: each word gets prefix matching with "*"
        // e.g. "flat white" -> "\"flat\"* \"white\"*"
        let words = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let ftsQuery = words.map { "\"\($0)\"*" }.joined(separator: " ")

        let sql = """
            SELECT f.fdcId, f.name, f.brand, f.category, f.servingSize, f.servingUnit,
                   f.calories, f.protein, f.carbs, f.fat, f.fiber, f.sugar, f.sodium,
                   f.cholesterol, f.saturatedFat, f.isCommon
            FROM foods f
            JOIN foods_fts fts ON f.fdcId = fts.rowid
            WHERE foods_fts MATCH ?
            ORDER BY f.isCommon DESC, rank
            LIMIT ?
            """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            // FTS match failed — try LIKE fallback for partial matches
            return searchFoodsLike(trimmed, limit: limit)
        }

        sqlite3_bind_text(stmt, 1, (ftsQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(limit))

        var results = [FoodItem]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let food = foodItemFromRow(stmt) {
                results.append(food)
            }
        }
        sqlite3_finalize(stmt)

        // If FTS found nothing, fall back to LIKE search
        if results.isEmpty {
            return searchFoodsLike(trimmed, limit: limit)
        }

        return results
    }

    /// Fallback search using LIKE when FTS5 doesn't match (e.g. partial words).
    private func searchFoodsLike(_ query: String, limit: Int) -> [FoodItem] {
        guard let db = db else { return [] }

        let sql = """
            SELECT fdcId, name, brand, category, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium,
                   cholesterol, saturatedFat, isCommon
            FROM foods
            WHERE name LIKE ? OR brand LIKE ?
            ORDER BY isCommon DESC,
                     CASE WHEN LOWER(name) = LOWER(?) THEN 0
                          WHEN LOWER(name) LIKE LOWER(? || '%') THEN 1
                          ELSE 2 END,
                     name
            LIMIT ?
            """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }

        let likePattern = "%\(query)%"
        sqlite3_bind_text(stmt, 1, (likePattern as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (likePattern as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (query as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (query as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 5, Int32(limit))

        var results = [FoodItem]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let food = foodItemFromRow(stmt) {
                results.append(food)
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    /// Get a single food by its USDA FDC ID.
    func getFoodById(_ fdcId: Int) -> FoodItem? {
        guard isAvailable, let db = db else { return nil }

        let sql = """
            SELECT fdcId, name, brand, category, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium,
                   cholesterol, saturatedFat, isCommon
            FROM foods WHERE fdcId = ?
            """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }

        sqlite3_bind_int(stmt, 1, Int32(fdcId))

        var result: FoodItem?
        if sqlite3_step(stmt) == SQLITE_ROW {
            result = foodItemFromRow(stmt)
        }
        sqlite3_finalize(stmt)
        return result
    }

    /// Get common/popular foods for display when search is empty.
    func getCommonFoods(limit: Int = 20) -> [FoodItem] {
        guard isAvailable, let db = db else {
            return FoodDatabase.shared.getCommonFoods(limit: limit)
        }

        let sql = """
            SELECT fdcId, name, brand, category, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium,
                   cholesterol, saturatedFat, isCommon
            FROM foods
            WHERE isCommon = 1
            ORDER BY name
            LIMIT ?
            """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }

        sqlite3_bind_int(stmt, 1, Int32(limit))

        var results = [FoodItem]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let food = foodItemFromRow(stmt) {
                results.append(food)
            }
        }
        sqlite3_finalize(stmt)
        return results
    }

    /// Get total number of foods in the database.
    func getFoodCount() -> Int {
        guard let db = db else { return 0 }

        let sql = "SELECT COUNT(*) FROM foods"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }

        var count = 0
        if sqlite3_step(stmt) == SQLITE_ROW {
            count = Int(sqlite3_column_int(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return count
    }

    // MARK: - Helpers

    /// Convert a SQLite row into a FoodItem.
    private func foodItemFromRow(_ stmt: OpaquePointer?) -> FoodItem? {
        guard let stmt = stmt else { return nil }

        let name = String(cString: sqlite3_column_text(stmt, 1))
        let brand: String? = sqlite3_column_type(stmt, 2) != SQLITE_NULL
            ? String(cString: sqlite3_column_text(stmt, 2))
            : nil
        let categoryStr = String(cString: sqlite3_column_text(stmt, 3))
        let servingSize = String(cString: sqlite3_column_text(stmt, 4))
        let servingUnit = String(cString: sqlite3_column_text(stmt, 5))
        let calories = sqlite3_column_double(stmt, 6)
        let protein = sqlite3_column_double(stmt, 7)
        let carbs = sqlite3_column_double(stmt, 8)
        let fat = sqlite3_column_double(stmt, 9)
        let fiber = sqlite3_column_double(stmt, 10)
        let sugar: Double? = sqlite3_column_type(stmt, 11) != SQLITE_NULL ? sqlite3_column_double(stmt, 11) : nil
        let sodium: Double? = sqlite3_column_type(stmt, 12) != SQLITE_NULL ? sqlite3_column_double(stmt, 12) : nil
        let cholesterol: Double? = sqlite3_column_type(stmt, 13) != SQLITE_NULL ? sqlite3_column_double(stmt, 13) : nil
        let saturatedFat: Double? = sqlite3_column_type(stmt, 14) != SQLITE_NULL ? sqlite3_column_double(stmt, 14) : nil
        let isCommon = sqlite3_column_int(stmt, 15) == 1

        let category = FoodCategory(rawValue: categoryStr) ?? .other

        return FoodItem(
            name: name,
            brand: brand,
            category: category,
            servingSize: servingSize,
            servingUnit: servingUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            cholesterol: cholesterol,
            saturatedFat: saturatedFat,
            barcode: nil,
            isCommon: isCommon
        )
    }

    /// Map a FoodCategory string to enum, matching FoodCategory raw values.
    private func categoryFromString(_ str: String) -> FoodCategory {
        return FoodCategory(rawValue: str) ?? .other
    }
}
