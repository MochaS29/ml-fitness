import Foundation

// MARK: - Food Search Service
// Stateless search orchestration and relevance ranking for food items.
// UnifiedDataManager.searchFoodDatabase delegates to this type, so all
// existing call sites continue to work without modification.

struct FoodSearchService {

    // MARK: - Orchestration

    /// Combine recent foods, local SQLite matches, and cached USDA foods into a
    /// single deduplicated list, limited to 50 results.
    ///
    /// - Parameters:
    ///   - query: The search query string.
    ///   - recentFoods: Caller-supplied recent food items (from CoreData history).
    ///   - cachedFoods: Caller-supplied USDA-cached food items (from CoreData).
    /// - Returns: Merged, deduplicated list of matching `FoodItem` values.
    static func search(
        _ query: String,
        recentFoods: [FoodItem],
        cachedFoods: [FoodItem]
    ) -> [FoodItem] {
        guard !query.isEmpty else { return [] }

        // 1. Recent foods that match the query
        let recentMatches = recentFoods.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }

        // 2. Local SQLite database (FTS5 search — fast, ~25K foods)
        let localMatches = LocalFoodDatabase.shared.searchFoods(query, limit: 30)

        // 3. Cached USDA API foods (passed in by caller from CoreData)
        let cachedMatches = cachedFoods

        // Combine and deduplicate
        var allMatches = recentMatches
        var seen = Set(recentMatches.map { "\($0.name.lowercased())|\($0.brand?.lowercased() ?? "")" })

        for food in localMatches {
            let key = "\(food.name.lowercased())|\(food.brand?.lowercased() ?? "")"
            if !seen.contains(key) {
                seen.insert(key)
                allMatches.append(food)
            }
        }

        for food in cachedMatches {
            let key = "\(food.name.lowercased())|\(food.brand?.lowercased() ?? "")"
            if !seen.contains(key) {
                seen.insert(key)
                allMatches.append(food)
            }
        }

        return Array(allMatches.prefix(50))
    }

    // MARK: - Relevance Ranking

    /// Sort a list of food items so the closest matches to `query` appear first.
    ///
    /// Ranking criteria (in order):
    /// 1. Exact match
    /// 2. Query is a whole word at the start of a short name ("Egg whites" for "egg")
    /// 3. Query is an exact word in a short name ("Coffee, Latte" for "latte")
    /// 4. Query is a whole word at the start of a longer name
    /// 5. Query is an exact word anywhere in a longer name
    /// 6. Name starts with query as a prefix of a word ("Eggnog" for "egg")
    /// 7. A word within the name starts with query
    /// 8. Substring match
    /// Within each tier: items with calorie data rank above 0-cal items, then shorter names rank higher.
    static func sortByRelevance(_ foods: [FoodItem], query: String) -> [FoodItem] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return foods }

        return foods.sorted { a, b in
            let tierA = relevanceScore(a.name, query: q)
            let tierB = relevanceScore(b.name, query: q)
            if tierA != tierB { return tierA < tierB }
            // Within same tier, prefer items with calorie data over 0-cal (bad data)
            if (a.calories > 0) != (b.calories > 0) { return a.calories > 0 }
            // Then prefer shorter names
            return a.name.count < b.name.count
        }
    }

    // MARK: - Private Helpers

    /// Returns a relevance tier for `name` against `query`. Lower = better match.
    /// `query` must already be lowercased.
    static func relevanceScore(_ name: String, query: String) -> Int {
        let lower = name.lowercased()
        let words = lower.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }

        // Tier 0: Exact match
        if lower == query { return 0 }

        // Check if query appears as a whole word at the start of the name
        // (not as a prefix of a longer word like "egg" in "eggnog")
        let queryIsWordAtStart: Bool = {
            guard lower.hasPrefix(query) else { return false }
            if lower.count == query.count { return true }
            let nextIdx = lower.index(lower.startIndex, offsetBy: query.count)
            let nextChar = lower[nextIdx]
            if !nextChar.isLetter { return true } // "Egg whites" — space after "egg"
            // Allow simple plural: "eggs" for "egg"
            if nextChar == "s" {
                let afterS = lower.index(after: nextIdx)
                return afterS >= lower.endIndex || !lower[afterS].isLetter
            }
            return false
        }()

        // Tier 1: Query is a whole word at start of a short name ("Egg whites", "Eggs, whole")
        if queryIsWordAtStart && words.count <= 3 { return 1 }
        // Tier 2: Query is an exact word in a short name ("Coffee, Latte" for "latte")
        if words.contains(query) && words.count <= 3 { return 2 }
        // Tier 3: Query is a whole word at start of a longer name ("Latte Blended Greek Yogurt")
        if queryIsWordAtStart { return 3 }
        // Tier 4: Query is an exact word in a longer name
        if words.contains(query) { return 4 }
        // Tier 5: Name starts with query as prefix of a word ("Eggnog" for "egg")
        if lower.hasPrefix(query) { return 5 }
        // Tier 6: A word starts with query
        if words.contains(where: { $0.hasPrefix(query) }) { return 6 }
        // Tier 7: Substring match
        if lower.contains(query) { return 7 }
        return 8
    }
}
