import Foundation

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let brand: String?
    let category: FoodCategory
    let servingSize: String
    let servingUnit: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double?
    let sodium: Double?
    let cholesterol: Double?
    let saturatedFat: Double?
    let barcode: String?
    let isCommon: Bool // Common foods appear first in search
}

enum FoodCategory: String, CaseIterable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case grains = "Grains & Cereals"
    case protein = "Protein Foods"
    case dairy = "Dairy"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case desserts = "Desserts"
    case fastFood = "Fast Food"
    case meals = "Prepared Meals"
    case condiments = "Condiments & Sauces"
    case oils = "Oils & Fats"
    case other = "Other"
}

class FoodDatabase {
    static let shared = FoodDatabase()
    
    // This is a sample database. In production, this would be loaded from a larger database
    let foods: [FoodItem] = [
        // FRUITS
        FoodItem(name: "Apple", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium (182g)", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4, sugar: 19, sodium: 2, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Banana", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium (118g)", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1, sugar: 14, sodium: 1, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Orange", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium (154g)", calories: 62, protein: 1.2, carbs: 15.4, fat: 0.2, fiber: 3.1, sugar: 12.2, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Strawberries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup (152g)", calories: 49, protein: 1, carbs: 11.7, fat: 0.5, fiber: 3, sugar: 7.4, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Blueberries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup (148g)", calories: 84, protein: 1.1, carbs: 21.4, fat: 0.5, fiber: 3.6, sugar: 14.7, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        
        // VEGETABLES
        FoodItem(name: "Broccoli", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup chopped (91g)", calories: 31, protein: 2.6, carbs: 6, fat: 0.3, fiber: 2.4, sugar: 1.5, sodium: 30, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Carrots", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "medium (61g)", calories: 25, protein: 0.6, carbs: 6, fat: 0.1, fiber: 1.7, sugar: 2.9, sodium: 42, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Spinach", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup (30g)", calories: 7, protein: 0.9, carbs: 1.1, fat: 0.1, fiber: 0.7, sugar: 0.1, sodium: 24, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Tomato", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "medium (123g)", calories: 22, protein: 1.1, carbs: 4.8, fat: 0.2, fiber: 1.5, sugar: 3.2, sodium: 6, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Sweet Potato", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "medium (114g)", calories: 103, protein: 2.3, carbs: 23.6, fat: 0.1, fiber: 3.8, sugar: 7.4, sodium: 41, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        
        // GRAINS
        FoodItem(name: "White Rice", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup cooked (158g)", calories: 205, protein: 4.3, carbs: 44.5, fat: 0.4, fiber: 0.6, sugar: 0.1, sodium: 2, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Brown Rice", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup cooked (195g)", calories: 216, protein: 5, carbs: 44.8, fat: 1.8, fiber: 3.5, sugar: 0.7, sodium: 10, cholesterol: 0, saturatedFat: 0.4, barcode: nil, isCommon: true),
        FoodItem(name: "Whole Wheat Bread", brand: nil, category: .grains, servingSize: "1", servingUnit: "slice (28g)", calories: 69, protein: 3.6, carbs: 11.6, fat: 1.1, fiber: 1.9, sugar: 1.4, sodium: 132, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Oatmeal", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup cooked (234g)", calories: 166, protein: 5.9, carbs: 28.1, fat: 3.6, fiber: 4, sugar: 0.6, sodium: 9, cholesterol: 0, saturatedFat: 0.6, barcode: nil, isCommon: true),
        FoodItem(name: "Quinoa", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup cooked (185g)", calories: 222, protein: 8.1, carbs: 39.4, fat: 3.6, fiber: 5.2, sugar: 1.6, sodium: 13, cholesterol: 0, saturatedFat: 0.4, barcode: nil, isCommon: true),
        
        // PROTEIN FOODS
        FoodItem(name: "Chicken Breast", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz (85g)", calories: 140, protein: 26.4, carbs: 0, fat: 3.1, fiber: 0, sugar: 0, sodium: 63, cholesterol: 73, saturatedFat: 0.9, barcode: nil, isCommon: true),
        FoodItem(name: "Salmon", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz (85g)", calories: 177, protein: 17.4, carbs: 0, fat: 11.4, fiber: 0, sugar: 0, sodium: 50, cholesterol: 54, saturatedFat: 2.6, barcode: nil, isCommon: true),
        FoodItem(name: "Eggs", brand: nil, category: .protein, servingSize: "1", servingUnit: "large (50g)", calories: 72, protein: 6.3, carbs: 0.4, fat: 4.8, fiber: 0, sugar: 0.2, sodium: 71, cholesterol: 186, saturatedFat: 1.6, barcode: nil, isCommon: true),
        FoodItem(name: "Black Beans", brand: nil, category: .protein, servingSize: "1", servingUnit: "cup (172g)", calories: 227, protein: 15.2, carbs: 40.8, fat: 0.9, fiber: 15, sugar: 0.6, sodium: 2, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Tofu", brand: nil, category: .protein, servingSize: "1/2", servingUnit: "cup (126g)", calories: 94, protein: 10, carbs: 2.3, fat: 6, fiber: 0.4, sugar: 0.7, sodium: 9, cholesterol: 0, saturatedFat: 0.9, barcode: nil, isCommon: true),
        FoodItem(name: "Ground Beef (90% lean)", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz (85g)", calories: 184, protein: 22.7, carbs: 0, fat: 10, fiber: 0, sugar: 0, sodium: 72, cholesterol: 70, saturatedFat: 3.9, barcode: nil, isCommon: true),
        
        // DAIRY
        FoodItem(name: "Milk (2%)", brand: nil, category: .dairy, servingSize: "1", servingUnit: "cup (244g)", calories: 122, protein: 8.1, carbs: 11.7, fat: 4.8, fiber: 0, sugar: 12.3, sodium: 115, cholesterol: 20, saturatedFat: 3.1, barcode: nil, isCommon: true),
        FoodItem(name: "Greek Yogurt", brand: nil, category: .dairy, servingSize: "1", servingUnit: "cup (245g)", calories: 133, protein: 23.1, carbs: 8.2, fat: 0.4, fiber: 0, sugar: 7.8, sodium: 92, cholesterol: 10, saturatedFat: 0.3, barcode: nil, isCommon: true),
        FoodItem(name: "Cheddar Cheese", brand: nil, category: .dairy, servingSize: "1", servingUnit: "oz (28g)", calories: 113, protein: 7, carbs: 0.4, fat: 9.3, fiber: 0, sugar: 0.1, sodium: 174, cholesterol: 28, saturatedFat: 5.9, barcode: nil, isCommon: true),
        
        // BEVERAGES
        FoodItem(name: "Coffee (black)", brand: nil, category: .beverages, servingSize: "1", servingUnit: "cup (237g)", calories: 2, protein: 0.3, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 5, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Orange Juice", brand: nil, category: .beverages, servingSize: "1", servingUnit: "cup (248g)", calories: 112, protein: 1.7, carbs: 25.8, fat: 0.5, fiber: 0.5, sugar: 20.8, sodium: 2, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        
        // FAST FOOD (with brands)
        FoodItem(name: "Big Mac", brand: "McDonald's", category: .fastFood, servingSize: "1", servingUnit: "sandwich", calories: 563, protein: 26, carbs: 45, fat: 33, fiber: 3, sugar: 9, sodium: 1040, cholesterol: 85, saturatedFat: 11, barcode: nil, isCommon: true),
        FoodItem(name: "Whopper", brand: "Burger King", category: .fastFood, servingSize: "1", servingUnit: "sandwich", calories: 657, protein: 28, carbs: 49, fat: 40, fiber: 2, sugar: 11, sodium: 980, cholesterol: 90, saturatedFat: 12, barcode: nil, isCommon: true),
        FoodItem(name: "Original Recipe Chicken", brand: "KFC", category: .fastFood, servingSize: "1", servingUnit: "breast", calories: 390, protein: 39, carbs: 12, fat: 21, fiber: 0, sugar: 0, sodium: 1190, cholesterol: 135, saturatedFat: 4.5, barcode: nil, isCommon: true),
        
        // SNACKS
        FoodItem(name: "Almonds", brand: nil, category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 164, protein: 6, carbs: 6.1, fat: 14.2, fiber: 3.5, sugar: 1.2, sodium: 0, cholesterol: 0, saturatedFat: 1.1, barcode: nil, isCommon: true),
        FoodItem(name: "Potato Chips", brand: "Lay's", category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 152, protein: 2, carbs: 15, fat: 10, fiber: 1, sugar: 0.2, sodium: 148, cholesterol: 0, saturatedFat: 1.5, barcode: nil, isCommon: true),
        
        // Add more foods as needed...
    ]
    
    func searchFoods(_ query: String) -> [FoodItem] {
        guard !query.isEmpty else { return [] }
        
        let searchQuery = query.lowercased()
        
        return foods.filter { food in
            food.name.lowercased().contains(searchQuery) ||
            (food.brand?.lowercased().contains(searchQuery) ?? false)
        }.sorted { first, second in
            // Prioritize common foods
            if first.isCommon && !second.isCommon { return true }
            if !first.isCommon && second.isCommon { return false }
            
            // Then prioritize exact matches
            let firstExact = first.name.lowercased() == searchQuery
            let secondExact = second.name.lowercased() == searchQuery
            if firstExact && !secondExact { return true }
            if !firstExact && secondExact { return false }
            
            // Then prioritize starts with
            let firstStarts = first.name.lowercased().hasPrefix(searchQuery)
            let secondStarts = second.name.lowercased().hasPrefix(searchQuery)
            if firstStarts && !secondStarts { return true }
            if !firstStarts && secondStarts { return false }
            
            // Finally alphabetical
            return first.name < second.name
        }
    }
    
    func getFoodsByCategory(_ category: FoodCategory) -> [FoodItem] {
        return foods.filter { $0.category == category }
            .sorted { $0.name < $1.name }
    }
    
    func getCommonFoods(limit: Int = 20) -> [FoodItem] {
        return foods.filter { $0.isCommon }
            .prefix(limit)
            .sorted { $0.name < $1.name }
    }
}