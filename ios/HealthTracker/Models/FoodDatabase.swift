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
        FoodItem(name: "Peanut Butter", brand: nil, category: .snacks, servingSize: "2", servingUnit: "tbsp", calories: 188, protein: 8, carbs: 8, fat: 16, fiber: 2.6, sugar: 3, sodium: 147, cholesterol: 0, saturatedFat: 3.3, barcode: nil, isCommon: true),
        FoodItem(name: "Walnuts", brand: nil, category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 185, protein: 4.3, carbs: 3.9, fat: 18.5, fiber: 1.9, sugar: 0.7, sodium: 1, cholesterol: 0, saturatedFat: 1.7, barcode: nil, isCommon: true),
        FoodItem(name: "Cashews", brand: nil, category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 157, protein: 5.2, carbs: 8.6, fat: 12.4, fiber: 0.9, sugar: 1.7, sodium: 3, cholesterol: 0, saturatedFat: 2.2, barcode: nil, isCommon: true),
        FoodItem(name: "Trail Mix", brand: nil, category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 131, protein: 4, carbs: 12, fat: 8, fiber: 2, sugar: 7, sodium: 45, cholesterol: 0, saturatedFat: 1.5, barcode: nil, isCommon: true),
        FoodItem(name: "Protein Bar", brand: "RXBAR", category: .snacks, servingSize: "1", servingUnit: "bar", calories: 210, protein: 12, carbs: 23, fat: 9, fiber: 3, sugar: 13, sodium: 200, cholesterol: 0, saturatedFat: 2, barcode: nil, isCommon: true),
        FoodItem(name: "Granola Bar", brand: "Nature Valley", category: .snacks, servingSize: "1", servingUnit: "bar", calories: 95, protein: 1.5, carbs: 14, fat: 3.5, fiber: 1, sugar: 7, sodium: 95, cholesterol: 0, saturatedFat: 0.5, barcode: nil, isCommon: true),
        FoodItem(name: "Popcorn", brand: nil, category: .snacks, servingSize: "3", servingUnit: "cups", calories: 93, protein: 3, carbs: 19, fat: 1, fiber: 3.5, sugar: 0.2, sodium: 2, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Pretzels", brand: nil, category: .snacks, servingSize: "1", servingUnit: "oz (28g)", calories: 108, protein: 2.9, carbs: 22.8, fat: 0.8, fiber: 1, sugar: 0.8, sodium: 611, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),

        // Additional Common Foods
        FoodItem(name: "Pizza", brand: nil, category: .fastFood, servingSize: "1", servingUnit: "slice", calories: 285, protein: 12, carbs: 36, fat: 10, fiber: 2.5, sugar: 3.8, sodium: 640, cholesterol: 18, saturatedFat: 4.8, barcode: nil, isCommon: true),
        FoodItem(name: "Hamburger", brand: nil, category: .fastFood, servingSize: "1", servingUnit: "burger", calories: 354, protein: 20, carbs: 29, fat: 17, fiber: 1.5, sugar: 5, sodium: 600, cholesterol: 47, saturatedFat: 6.5, barcode: nil, isCommon: true),
        FoodItem(name: "French Fries", brand: nil, category: .fastFood, servingSize: "1", servingUnit: "medium", calories: 365, protein: 4, carbs: 48, fat: 17, fiber: 4.5, sugar: 0.3, sodium: 246, cholesterol: 0, saturatedFat: 3, barcode: nil, isCommon: true),
        FoodItem(name: "Taco", brand: nil, category: .fastFood, servingSize: "1", servingUnit: "taco", calories: 210, protein: 9, carbs: 21, fat: 10, fiber: 3, sugar: 2, sodium: 570, cholesterol: 27, saturatedFat: 4.5, barcode: nil, isCommon: true),
        FoodItem(name: "Burrito", brand: "Chipotle", category: .fastFood, servingSize: "1", servingUnit: "burrito", calories: 970, protein: 30, carbs: 110, fat: 40, fiber: 10, sugar: 5, sodium: 1540, cholesterol: 60, saturatedFat: 13, barcode: nil, isCommon: true),
        FoodItem(name: "Sushi Roll", brand: nil, category: .meals, servingSize: "6", servingUnit: "pieces", calories: 200, protein: 9, carbs: 38, fat: 1, fiber: 1.5, sugar: 8, sodium: 380, cholesterol: 11, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Caesar Salad", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 94, protein: 5, carbs: 8, fat: 4, fiber: 1.8, sugar: 1.5, sodium: 180, cholesterol: 11, saturatedFat: 1.8, barcode: nil, isCommon: true),
        FoodItem(name: "Ice Cream", brand: nil, category: .desserts, servingSize: "1/2", servingUnit: "cup", calories: 137, protein: 2.3, carbs: 16, fat: 7.3, fiber: 0.5, sugar: 14, sodium: 53, cholesterol: 29, saturatedFat: 4.5, barcode: nil, isCommon: true),
        FoodItem(name: "Cookie", brand: nil, category: .desserts, servingSize: "1", servingUnit: "cookie", calories: 49, protein: 0.6, carbs: 6.9, fat: 2.3, fiber: 0.2, sugar: 4.3, sodium: 28, cholesterol: 5, saturatedFat: 0.6, barcode: nil, isCommon: true),
        FoodItem(name: "Brownie", brand: nil, category: .desserts, servingSize: "1", servingUnit: "square", calories: 112, protein: 1.5, carbs: 12, fat: 7, fiber: 0.5, sugar: 10, sodium: 82, cholesterol: 18, saturatedFat: 1.7, barcode: nil, isCommon: true),
        FoodItem(name: "Avocado", brand: nil, category: .fruits, servingSize: "1/2", servingUnit: "fruit", calories: 160, protein: 2, carbs: 9, fat: 15, fiber: 7, sugar: 0.7, sodium: 7, cholesterol: 0, saturatedFat: 2.1, barcode: nil, isCommon: true),
        FoodItem(name: "Sweet Potato", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "medium", calories: 103, protein: 2.3, carbs: 24, fat: 0.1, fiber: 3.8, sugar: 7.4, sodium: 41, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Quinoa", brand: nil, category: .grains, servingSize: "1", servingUnit: "cup cooked", calories: 222, protein: 8.1, carbs: 39, fat: 3.6, fiber: 5.2, sugar: 1.6, sodium: 13, cholesterol: 0, saturatedFat: 0.4, barcode: nil, isCommon: true),
        FoodItem(name: "Lentils", brand: nil, category: .protein, servingSize: "1", servingUnit: "cup cooked", calories: 230, protein: 18, carbs: 40, fat: 0.8, fiber: 15.6, sugar: 3.6, sodium: 4, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Black Beans", brand: nil, category: .protein, servingSize: "1", servingUnit: "cup", calories: 227, protein: 15, carbs: 41, fat: 0.9, fiber: 15, sugar: 0.6, sodium: 2, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Hummus", brand: nil, category: .snacks, servingSize: "2", servingUnit: "tbsp", calories: 70, protein: 2, carbs: 6, fat: 5, fiber: 2, sugar: 0, sodium: 110, cholesterol: 0, saturatedFat: 0.7, barcode: nil, isCommon: true),
        FoodItem(name: "Cottage Cheese", brand: nil, category: .dairy, servingSize: "1/2", servingUnit: "cup", calories: 92, protein: 12, carbs: 5, fat: 2.5, fiber: 0, sugar: 4, sodium: 348, cholesterol: 15, saturatedFat: 1.4, barcode: nil, isCommon: true),
        FoodItem(name: "Mozzarella Cheese", brand: nil, category: .dairy, servingSize: "1", servingUnit: "oz", calories: 85, protein: 6.3, carbs: 0.6, fat: 6.3, fiber: 0, sugar: 0.3, sodium: 178, cholesterol: 22, saturatedFat: 3.8, barcode: nil, isCommon: true),
        FoodItem(name: "Bagel", brand: nil, category: .grains, servingSize: "1", servingUnit: "bagel", calories: 245, protein: 10, carbs: 48, fat: 1.5, fiber: 2, sugar: 6, sodium: 430, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "English Muffin", brand: nil, category: .grains, servingSize: "1", servingUnit: "muffin", calories: 134, protein: 4.4, carbs: 27, fat: 1, fiber: 1.5, sugar: 2, sodium: 264, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Croissant", brand: nil, category: .grains, servingSize: "1", servingUnit: "medium", calories: 231, protein: 4.7, carbs: 26, fat: 12, fiber: 1.4, sugar: 6.4, sodium: 424, cholesterol: 39, saturatedFat: 6.7, barcode: nil, isCommon: true),
        FoodItem(name: "Pancakes", brand: nil, category: .grains, servingSize: "3", servingUnit: "cakes", calories: 219, protein: 6.3, carbs: 41, fat: 3.5, fiber: 1.3, sugar: 9, sodium: 439, cholesterol: 40, saturatedFat: 0.8, barcode: nil, isCommon: true),
        FoodItem(name: "Waffles", brand: nil, category: .grains, servingSize: "1", servingUnit: "waffle", calories: 103, protein: 2.8, carbs: 16.5, fat: 3.2, fiber: 0.5, sugar: 2.6, sodium: 288, cholesterol: 14, saturatedFat: 0.6, barcode: nil, isCommon: true),
        FoodItem(name: "Bacon", brand: nil, category: .protein, servingSize: "3", servingUnit: "slices", calories: 161, protein: 12, carbs: 0.6, fat: 12, fiber: 0, sugar: 0, sodium: 581, cholesterol: 40, saturatedFat: 4.3, barcode: nil, isCommon: true),
        FoodItem(name: "Sausage", brand: nil, category: .protein, servingSize: "2", servingUnit: "links", calories: 165, protein: 10, carbs: 1, fat: 14, fiber: 0, sugar: 0, sodium: 420, cholesterol: 43, saturatedFat: 4.7, barcode: nil, isCommon: true),
        FoodItem(name: "Ham", brand: nil, category: .protein, servingSize: "2", servingUnit: "slices", calories: 60, protein: 10, carbs: 2, fat: 1.5, fiber: 0, sugar: 1, sodium: 630, cholesterol: 30, saturatedFat: 0.5, barcode: nil, isCommon: true),
        FoodItem(name: "Turkey Breast", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 125, protein: 26, carbs: 0, fat: 1.8, fiber: 0, sugar: 0, sodium: 55, cholesterol: 62, saturatedFat: 0.4, barcode: nil, isCommon: true),
        FoodItem(name: "Tuna (canned)", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 99, protein: 22, carbs: 0, fat: 0.7, fiber: 0, sugar: 0, sodium: 287, cholesterol: 26, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Shrimp", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 84, protein: 18, carbs: 0, fat: 0.9, fiber: 0, sugar: 0, sodium: 94, cholesterol: 161, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Lobster", brand: nil, category: .protein, servingSize: "3", servingUnit: "oz", calories: 76, protein: 16, carbs: 0, fat: 0.7, fiber: 0, sugar: 0, sodium: 380, cholesterol: 60, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Butter", brand: nil, category: .oils, servingSize: "1", servingUnit: "tbsp", calories: 102, protein: 0.1, carbs: 0, fat: 11.5, fiber: 0, sugar: 0, sodium: 82, cholesterol: 31, saturatedFat: 7.3, barcode: nil, isCommon: true),
        FoodItem(name: "Olive Oil", brand: nil, category: .oils, servingSize: "1", servingUnit: "tbsp", calories: 119, protein: 0, carbs: 0, fat: 13.5, fiber: 0, sugar: 0, sodium: 0, cholesterol: 0, saturatedFat: 1.9, barcode: nil, isCommon: true),
        FoodItem(name: "Coconut Oil", brand: nil, category: .oils, servingSize: "1", servingUnit: "tbsp", calories: 117, protein: 0, carbs: 0, fat: 13.6, fiber: 0, sugar: 0, sodium: 0, cholesterol: 0, saturatedFat: 11.8, barcode: nil, isCommon: true),
        FoodItem(name: "Mayonnaise", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 94, protein: 0.1, carbs: 0.1, fat: 10.3, fiber: 0, sugar: 0.1, sodium: 88, cholesterol: 6, saturatedFat: 1.6, barcode: nil, isCommon: true),
        FoodItem(name: "Ketchup", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 17, protein: 0.2, carbs: 4.7, fat: 0, fiber: 0, sugar: 3.7, sodium: 154, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Mustard", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tsp", calories: 3, protein: 0.2, carbs: 0.3, fat: 0.2, fiber: 0.1, sugar: 0.1, sodium: 57, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Soy Sauce", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 8, protein: 1.3, carbs: 0.8, fat: 0.1, fiber: 0.1, sugar: 0.1, sodium: 902, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Hot Sauce", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tsp", calories: 0, protein: 0, carbs: 0.1, fat: 0, fiber: 0, sugar: 0.1, sodium: 124, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Ranch Dressing", brand: nil, category: .condiments, servingSize: "2", servingUnit: "tbsp", calories: 129, protein: 0.4, carbs: 1.4, fat: 13.4, fiber: 0, sugar: 1.4, sodium: 270, cholesterol: 10, saturatedFat: 2.1, barcode: nil, isCommon: true),
        FoodItem(name: "Honey", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 64, protein: 0.1, carbs: 17.3, fat: 0, fiber: 0, sugar: 17.2, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Maple Syrup", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 52, protein: 0, carbs: 13.4, fat: 0, fiber: 0, sugar: 12, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Peanut Butter (smooth)", brand: "Jif", category: .snacks, servingSize: "2", servingUnit: "tbsp", calories: 190, protein: 8, carbs: 8, fat: 16, fiber: 2, sugar: 3, sodium: 140, cholesterol: 0, saturatedFat: 3, barcode: nil, isCommon: true),
        FoodItem(name: "Nutella", brand: "Ferrero", category: .snacks, servingSize: "2", servingUnit: "tbsp", calories: 200, protein: 2, carbs: 23, fat: 11, fiber: 1, sugar: 21, sodium: 15, cholesterol: 0, saturatedFat: 3.5, barcode: nil, isCommon: true),
        FoodItem(name: "Jam", brand: nil, category: .condiments, servingSize: "1", servingUnit: "tbsp", calories: 56, protein: 0.1, carbs: 13.8, fat: 0, fiber: 0.2, sugar: 9.7, sodium: 6, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Corn", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "ear", calories: 88, protein: 3.3, carbs: 19, fat: 1.3, fiber: 2.4, sugar: 6.4, sodium: 15, cholesterol: 0, saturatedFat: 0.2, barcode: nil, isCommon: true),
        FoodItem(name: "Peas", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 117, protein: 8, carbs: 21, fat: 0.6, fiber: 8.3, sugar: 8, sodium: 7, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Green Beans", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 34, protein: 2, carbs: 7.8, fat: 0.3, fiber: 3.7, sugar: 3.5, sodium: 7, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Mushrooms", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup sliced", calories: 15, protein: 2.2, carbs: 2.3, fat: 0.2, fiber: 0.7, sugar: 1.4, sodium: 4, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Onion", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "medium", calories: 44, protein: 1.2, carbs: 10.3, fat: 0.1, fiber: 1.9, sugar: 4.7, sodium: 4, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Garlic", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "clove", calories: 4, protein: 0.2, carbs: 1, fat: 0, fiber: 0.1, sugar: 0, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Ginger", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "tsp", calories: 2, protein: 0, carbs: 0.4, fat: 0, fiber: 0, sugar: 0, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Asparagus", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 27, protein: 2.9, carbs: 5.2, fat: 0.2, fiber: 2.8, sugar: 2.5, sodium: 3, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Zucchini", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup sliced", calories: 19, protein: 1.4, carbs: 3.5, fat: 0.4, fiber: 1.1, sugar: 2.2, sodium: 10, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Eggplant", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup cubed", calories: 20, protein: 0.8, carbs: 4.8, fat: 0.1, fiber: 2.5, sugar: 3, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Cauliflower", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 25, protein: 1.9, carbs: 5.3, fat: 0.3, fiber: 2, sugar: 1.9, sodium: 30, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Brussels Sprouts", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 38, protein: 3, carbs: 8, fat: 0.3, fiber: 3.3, sugar: 1.9, sodium: 22, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Kale", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup", calories: 33, protein: 2.9, carbs: 6, fat: 0.6, fiber: 2.6, sugar: 1.3, sodium: 29, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Cabbage", brand: nil, category: .vegetables, servingSize: "1", servingUnit: "cup shredded", calories: 22, protein: 1.1, carbs: 5.2, fat: 0.1, fiber: 2.2, sugar: 2.9, sodium: 16, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Mango", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup", calories: 99, protein: 1.4, carbs: 25, fat: 0.6, fiber: 2.6, sugar: 23, sodium: 2, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Pineapple", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup chunks", calories: 83, protein: 0.9, carbs: 22, fat: 0.2, fiber: 2.3, sugar: 16, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Watermelon", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup diced", calories: 46, protein: 0.9, carbs: 11.5, fat: 0.2, fiber: 0.6, sugar: 9.4, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Cantaloupe", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup cubed", calories: 53, protein: 1.3, carbs: 13, fat: 0.3, fiber: 1.4, sugar: 12, sodium: 25, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Honeydew", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup diced", calories: 61, protein: 0.9, carbs: 15.5, fat: 0.2, fiber: 1.4, sugar: 14, sodium: 31, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Peach", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 59, protein: 1.4, carbs: 14, fat: 0.4, fiber: 2.3, sugar: 13, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Plum", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 30, protein: 0.5, carbs: 7.5, fat: 0.2, fiber: 0.9, sugar: 6.6, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Nectarine", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 62, protein: 1.5, carbs: 15, fat: 0.4, fiber: 2.4, sugar: 11, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Apricot", brand: nil, category: .fruits, servingSize: "1", servingUnit: "fruit", calories: 17, protein: 0.5, carbs: 3.9, fat: 0.1, fiber: 0.7, sugar: 3.2, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Kiwi", brand: nil, category: .fruits, servingSize: "1", servingUnit: "fruit", calories: 42, protein: 0.8, carbs: 10, fat: 0.4, fiber: 2.1, sugar: 6.2, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Pomegranate", brand: nil, category: .fruits, servingSize: "1/2", servingUnit: "cup seeds", calories: 72, protein: 1.5, carbs: 16, fat: 1, fiber: 3.5, sugar: 12, sodium: 3, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Coconut", brand: nil, category: .fruits, servingSize: "1", servingUnit: "oz shredded", calories: 100, protein: 0.9, carbs: 4.3, fat: 9.5, fiber: 2.5, sugar: 1.8, sodium: 6, cholesterol: 0, saturatedFat: 8.4, barcode: nil, isCommon: true),
        FoodItem(name: "Dates", brand: nil, category: .fruits, servingSize: "3", servingUnit: "dates", calories: 66, protein: 0.4, carbs: 18, fat: 0, fiber: 1.6, sugar: 16, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Figs", brand: nil, category: .fruits, servingSize: "1", servingUnit: "medium", calories: 37, protein: 0.4, carbs: 9.6, fat: 0.2, fiber: 1.5, sugar: 8, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Raisins", brand: nil, category: .fruits, servingSize: "1", servingUnit: "oz", calories: 85, protein: 0.9, carbs: 22, fat: 0.1, fiber: 1, sugar: 17, sodium: 3, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Cranberries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup", calories: 46, protein: 0.4, carbs: 12, fat: 0.1, fiber: 4.6, sugar: 4, sodium: 2, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Blackberries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup", calories: 62, protein: 2, carbs: 14, fat: 0.7, fiber: 7.6, sugar: 7, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Raspberries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup", calories: 64, protein: 1.5, carbs: 15, fat: 0.8, fiber: 8, sugar: 5.4, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Cherries", brand: nil, category: .fruits, servingSize: "1", servingUnit: "cup", calories: 87, protein: 1.5, carbs: 22, fat: 0.3, fiber: 2.9, sugar: 18, sodium: 0, cholesterol: 0, saturatedFat: 0.1, barcode: nil, isCommon: true),
        FoodItem(name: "Grapefruit", brand: nil, category: .fruits, servingSize: "1/2", servingUnit: "medium", calories: 52, protein: 1, carbs: 13, fat: 0.2, fiber: 2, sugar: 8.5, sodium: 0, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Lemon", brand: nil, category: .fruits, servingSize: "1", servingUnit: "fruit", calories: 17, protein: 0.6, carbs: 5.4, fat: 0.2, fiber: 1.6, sugar: 1.5, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true),
        FoodItem(name: "Lime", brand: nil, category: .fruits, servingSize: "1", servingUnit: "fruit", calories: 20, protein: 0.5, carbs: 7, fat: 0.1, fiber: 1.9, sugar: 1.1, sodium: 1, cholesterol: 0, saturatedFat: 0, barcode: nil, isCommon: true)
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