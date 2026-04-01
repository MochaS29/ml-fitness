import Foundation
import Combine

// MARK: - Codable wrapper for FoodItem (used only for persistence)

struct FavouriteFood: Codable, Identifiable {
    let id: UUID
    let name: String
    let brand: String?
    let categoryRaw: String
    let servingSize: String
    let servingUnit: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double?
    let sodium: Double?

    init(from food: FoodItem) {
        self.id = UUID()
        self.name = food.name
        self.brand = food.brand
        self.categoryRaw = food.category.rawValue
        self.servingSize = food.servingSize
        self.servingUnit = food.servingUnit
        self.calories = food.calories
        self.protein = food.protein
        self.carbs = food.carbs
        self.fat = food.fat
        self.fiber = food.fiber
        self.sugar = food.sugar
        self.sodium = food.sodium
    }

    func toFoodItem() -> FoodItem {
        FoodItem(
            name: name, brand: brand,
            category: FoodCategory(rawValue: categoryRaw) ?? .other,
            servingSize: servingSize, servingUnit: servingUnit,
            calories: calories, protein: protein, carbs: carbs, fat: fat,
            fiber: fiber, sugar: sugar, sodium: sodium,
            cholesterol: nil, saturatedFat: nil, barcode: nil, isCommon: false
        )
    }
}

// MARK: - Favourites Manager

class FavouriteFoodsManager: ObservableObject {
    static let shared = FavouriteFoodsManager()

    @Published private(set) var favourites: [FavouriteFood] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "favouriteFoods_v1"

    private init() {
        load()
    }

    func isFavourite(_ food: FoodItem) -> Bool {
        favourites.contains { $0.name.lowercased() == food.name.lowercased() }
    }

    func toggle(_ food: FoodItem) {
        if isFavourite(food) {
            favourites.removeAll { $0.name.lowercased() == food.name.lowercased() }
        } else {
            favourites.insert(FavouriteFood(from: food), at: 0)
        }
        save()
    }

    var favouriteFoodItems: [FoodItem] {
        favourites.map { $0.toFoodItem() }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(favourites) {
            defaults.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([FavouriteFood].self, from: data) else { return }
        favourites = saved
    }
}
