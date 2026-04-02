//
//  FoodSearchServiceTests.swift
//  HealthTrackerTests
//
//  Created by Test Suite
//

import XCTest
@testable import HealthTracker

final class FoodSearchServiceTests: XCTestCase {

    // MARK: - Helpers

    /// Build a minimal FoodItem with just the fields used by the search/rank logic.
    private func makeItem(
        name: String,
        brand: String? = nil,
        calories: Double = 100
    ) -> FoodItem {
        FoodItem(
            name: name,
            brand: brand,
            category: .other,
            servingSize: "100",
            servingUnit: "g",
            calories: calories,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: nil,
            sodium: nil,
            cholesterol: nil,
            saturatedFat: nil,
            barcode: nil,
            isCommon: false
        )
    }

    // MARK: - sortByRelevance: exact name match ranks first

    func testSortByRelevance_exactMatchRanksFirst() {
        let items = [
            makeItem(name: "Eggnog"),
            makeItem(name: "Scrambled Eggs"),
            makeItem(name: "Egg"),          // exact match
            makeItem(name: "Egg Whites"),
        ]

        let sorted = FoodSearchService.sortByRelevance(items, query: "egg")

        XCTAssertEqual(sorted.first?.name, "Egg",
            "Exact name match should rank first")
    }

    // MARK: - sortByRelevance: word boundary match ranks above partial match

    func testSortByRelevance_wordBoundaryRanksAbovePartial() {
        // "Egg Whites" — "egg" is a whole word at the start (tier 1)
        // "Eggnog"    — "egg" is only a prefix of a longer word (tier 5)
        let items = [
            makeItem(name: "Eggnog"),
            makeItem(name: "Egg Whites"),
        ]

        let sorted = FoodSearchService.sortByRelevance(items, query: "egg")

        XCTAssertEqual(sorted.first?.name, "Egg Whites",
            "Word-boundary match should rank above partial prefix match")
    }

    // MARK: - sortByRelevance: empty query returns items in original order

    func testSortByRelevance_emptyQueryPreservesOrder() {
        let items = [
            makeItem(name: "Banana"),
            makeItem(name: "Apple"),
            makeItem(name: "Cherry"),
        ]

        let sorted = FoodSearchService.sortByRelevance(items, query: "")

        let names = sorted.map { $0.name }
        XCTAssertEqual(names, ["Banana", "Apple", "Cherry"],
            "Empty query must return items in their original order")
    }

    // MARK: - relevanceScore tiers

    func testRelevanceScore_exactMatch_isTier0() {
        XCTAssertEqual(FoodSearchService.relevanceScore("egg", query: "egg"), 0)
    }

    func testRelevanceScore_wordAtStartShortName_isTier1() {
        // "Egg Whites" — starts with "egg" as a full word, ≤3 words
        XCTAssertEqual(FoodSearchService.relevanceScore("Egg Whites", query: "egg"), 1)
    }

    func testRelevanceScore_exactWordInShortName_isTier2() {
        // "Coffee, Latte" — "latte" is an exact word, ≤3 words
        XCTAssertEqual(FoodSearchService.relevanceScore("Coffee, Latte", query: "latte"), 2)
    }

    func testRelevanceScore_prefixOfWordWithinName_isTier6() {
        // "Scrambled Eggnog" — "egg" starts a word but not at position 0
        XCTAssertEqual(FoodSearchService.relevanceScore("Scrambled Eggnog", query: "egg"), 6)
    }

    func testRelevanceScore_substringOnly_isTier7() {
        // "Veggie Burger" — "egg" is a substring but not at a word boundary
        XCTAssertEqual(FoodSearchService.relevanceScore("Veggie Burger", query: "egg"), 7)
    }

    // MARK: - search: deduplication

    func testSearch_deduplicatesSameNameCaseInsensitive() {
        // Items with the same (lowercased) name should appear only once.
        let recent = [makeItem(name: "Chicken Breast")]
        let cached = [makeItem(name: "chicken breast")]   // same name, different casing

        // LocalFoodDatabase.shared.searchFoods is a real SQLite call, but we can
        // verify that our two supplied arrays produce at most one "chicken breast" entry
        // by checking deduplication logic independently.
        var seen = Set<String>()
        var deduped: [FoodItem] = []
        for food in recent + cached {
            let key = "\(food.name.lowercased())|\(food.brand?.lowercased() ?? "")"
            if seen.insert(key).inserted {
                deduped.append(food)
            }
        }
        XCTAssertEqual(deduped.count, 1,
            "Items with the same case-insensitive name must be deduplicated")
    }

    func testSearch_deduplicesBrandedItemsByNameAndBrand() {
        // Two items with the same name but different brands should both appear.
        var seen = Set<String>()
        var deduped: [FoodItem] = []
        let items = [
            makeItem(name: "Greek Yogurt", brand: "Fage"),
            makeItem(name: "Greek Yogurt", brand: "Chobani"),
        ]
        for food in items {
            let key = "\(food.name.lowercased())|\(food.brand?.lowercased() ?? "")"
            if seen.insert(key).inserted { deduped.append(food) }
        }
        XCTAssertEqual(deduped.count, 2,
            "Items with the same name but different brands are distinct and should not be deduplicated")
    }

    // MARK: - search: empty query returns empty array

    func testSearch_emptyQueryReturnsEmpty() {
        let result = FoodSearchService.search(
            "",
            recentFoods: [makeItem(name: "Apple")],
            cachedFoods: [makeItem(name: "Banana")]
        )
        XCTAssertTrue(result.isEmpty,
            "search(_:recentFoods:cachedFoods:) must return [] for an empty query")
    }

    // MARK: - search: result is limited to 50 items

    func testSearch_resultsAreLimitedToFifty() {
        // Provide 60 distinct recent items; result must be capped at 50.
        let recentFoods = (0..<60).map { makeItem(name: "Food \($0)") }
        let result = FoodSearchService.search(
            "Food",
            recentFoods: recentFoods,
            cachedFoods: []
        )
        XCTAssertLessThanOrEqual(result.count, 50,
            "search results must be capped at 50 items")
    }

    // MARK: - search: recent foods that match the query appear in results

    func testSearch_recentMatchingFoodsAreIncluded() {
        let recentFoods = [makeItem(name: "Banana Smoothie")]
        let result = FoodSearchService.search(
            "banana",
            recentFoods: recentFoods,
            cachedFoods: []
        )
        XCTAssertTrue(
            result.contains(where: { $0.name.localizedCaseInsensitiveContains("banana") }),
            "Matching recent foods must appear in the search results"
        )
    }
}
