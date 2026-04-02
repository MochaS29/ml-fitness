//
//  FavouriteFoodsManagerTests.swift
//  HealthTrackerTests
//

import XCTest
@testable import HealthTracker

final class FavouriteFoodsManagerTests: XCTestCase {

    // FavouriteFoodsManager.shared writes to UserDefaults.standard under the key
    // "favouriteFoods_v1". Because both the key and the defaults suite are private,
    // tests operate against the shared singleton and wipe the storage key in setUp
    // and tearDown to keep runs fully isolated.
    private let storageKey = "favouriteFoods_v1"
    var manager: FavouriteFoodsManager!

    override func setUp() {
        super.setUp()
        manager = FavouriteFoodsManager.shared
        // Drain all existing favourites via toggle so the manager's @Published
        // property and UserDefaults stay in sync (the singleton is long-lived).
        // We snapshot the list first to avoid mutating while iterating.
        let current = manager.favourites.map { $0.toFoodItem() }
        current.forEach { manager.toggle($0) }
        // Belt-and-suspenders: also wipe the defaults key directly.
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        manager = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Builds a minimal FoodItem with a unique name for testing.
    private func makeFoodItem(
        name: String,
        calories: Double = 100,
        brand: String? = nil
    ) -> FoodItem {
        FoodItem(
            name: name,
            brand: brand,
            category: .other,
            servingSize: "1",
            servingUnit: "serving",
            calories: calories,
            protein: 5,
            carbs: 10,
            fat: 3,
            fiber: 1,
            sugar: 2,
            sodium: 50,
            cholesterol: nil,
            saturatedFat: nil,
            barcode: nil,
            isCommon: false
        )
    }

    // MARK: - Tests

    func testAddingFoodItemStoresIt() {
        let food = makeFoodItem(name: "Greek Yogurt")
        manager.toggle(food)
        XCTAssertEqual(manager.favourites.count, 1)
        XCTAssertEqual(manager.favourites.first?.name, "Greek Yogurt")
    }

    func testAddingTheSameFoodTwiceDoesNotDuplicate() {
        let food = makeFoodItem(name: "Oatmeal")
        manager.toggle(food)   // adds
        manager.toggle(food)   // removes (toggle semantics)
        // After two toggles the item should be gone, not duplicated.
        XCTAssertEqual(manager.favourites.count, 0)
    }

    func testTogglingFoodOnThenOffRemovesIt() {
        let food = makeFoodItem(name: "Banana")
        manager.toggle(food)
        XCTAssertTrue(manager.isFavourite(food))
        manager.toggle(food)
        XCTAssertFalse(manager.isFavourite(food))
        XCTAssertEqual(manager.favourites.count, 0)
    }

    func testIsFavouriteReturnsTrueForAddedItem() {
        let food = makeFoodItem(name: "Almonds")
        manager.toggle(food)
        XCTAssertTrue(manager.isFavourite(food))
    }

    func testIsFavouriteReturnsFalseForNonAddedItem() {
        let added = makeFoodItem(name: "Walnuts")
        let other = makeFoodItem(name: "Cashews")
        manager.toggle(added)
        XCTAssertFalse(manager.isFavourite(other))
    }

    func testIsFavouriteIsCaseInsensitive() {
        let food = makeFoodItem(name: "Brown Rice")
        let foodUppercase = makeFoodItem(name: "BROWN RICE")
        manager.toggle(food)
        XCTAssertTrue(manager.isFavourite(foodUppercase))
    }

    func testAddingMultipleDifferentFoodsStoresAllOfThem() {
        let foods = ["Chicken", "Broccoli", "Salmon"].map { makeFoodItem(name: $0) }
        foods.forEach { manager.toggle($0) }
        XCTAssertEqual(manager.favourites.count, 3)
        let names = manager.favourites.map { $0.name }
        for food in foods {
            XCTAssertTrue(names.contains(food.name))
        }
    }

    func testFavouritesListPersistsAcrossManagerAccess() {
        // Add an item, then re-access the singleton (simulating an app relaunch
        // within the same process by reading from UserDefaults directly).
        let food = makeFoodItem(name: "Quinoa")
        manager.toggle(food)

        // Retrieve the raw data that was saved.
        let savedData = UserDefaults.standard.data(forKey: storageKey)
        XCTAssertNotNil(savedData, "Manager should persist favourites to UserDefaults")

        // Decode the persisted data and verify the item is present.
        let decoded = try? JSONDecoder().decode([FavouriteFood].self, from: savedData!)
        XCTAssertEqual(decoded?.count, 1)
        XCTAssertEqual(decoded?.first?.name, "Quinoa")
    }

    func testFavouriteFoodItemsReturnsConvertedFoodItems() {
        let food = makeFoodItem(name: "Lentils", calories: 230)
        manager.toggle(food)

        let items = manager.favouriteFoodItems
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Lentils")
        XCTAssertEqual(items.first?.calories, 230)
    }

    func testNewlyAddedFoodAppearsAtFrontOfList() {
        // toggle() inserts at index 0, so the last-added item should be first.
        let first = makeFoodItem(name: "Egg")
        let second = makeFoodItem(name: "Avocado")
        manager.toggle(first)
        manager.toggle(second)
        XCTAssertEqual(manager.favourites.first?.name, "Avocado")
    }

    func testEmptyFavouritesOnFreshState() {
        // After setUp clears defaults, the list should be empty.
        XCTAssertTrue(manager.favourites.isEmpty)
    }
}
