import Foundation
import CoreData

class SampleDataImporter {
    static func importSampleUSDAFoods(context: NSManagedObjectContext) {
        // Sample USDA foods
        let sampleFoods = [
            (name: "Banana, raw", calories: 89.0, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6, sugar: 12.2, category: "Fruits"),
            (name: "Apple, raw, with skin", calories: 52.0, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4, sugar: 10.4, category: "Fruits"),
            (name: "Chicken breast, boneless, skinless, raw", calories: 165.0, protein: 31.0, carbs: 0.0, fat: 3.6, fiber: 0.0, sugar: 0.0, category: "Protein Foods"),
            (name: "Brown rice, cooked", calories: 112.0, protein: 2.3, carbs: 23.5, fat: 0.9, fiber: 1.8, sugar: 0.4, category: "Grains & Cereals"),
            (name: "Broccoli, raw", calories: 34.0, protein: 2.8, carbs: 6.6, fat: 0.4, fiber: 2.6, sugar: 1.7, category: "Vegetables"),
            (name: "Salmon, Atlantic, wild, raw", calories: 142.0, protein: 19.8, carbs: 0.0, fat: 6.3, fiber: 0.0, sugar: 0.0, category: "Protein Foods"),
            (name: "Milk, whole, 3.25% milkfat", calories: 61.0, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0.0, sugar: 5.1, category: "Dairy"),
            (name: "Egg, whole, raw", calories: 143.0, protein: 12.6, carbs: 0.7, fat: 9.5, fiber: 0.0, sugar: 0.4, category: "Protein Foods"),
            (name: "Almonds, raw", calories: 579.0, protein: 21.2, carbs: 21.6, fat: 49.9, fiber: 12.5, sugar: 4.4, category: "Protein Foods"),
            (name: "Sweet potato, raw", calories: 86.0, protein: 1.6, carbs: 20.1, fat: 0.1, fiber: 3.0, sugar: 4.2, category: "Vegetables")
        ]
        
        for food in sampleFoods {
            let customFood = CustomFood(context: context)
            customFood.id = UUID()
            customFood.name = food.name
            customFood.source = "USDA"
            customFood.isUserCreated = false
            customFood.calories = food.calories
            customFood.protein = food.protein
            customFood.carbs = food.carbs
            customFood.fat = food.fat
            customFood.fiber = food.fiber
            customFood.sugar = food.sugar
            customFood.category = food.category
            customFood.servingSize = "100"
            customFood.servingUnit = "g"
            customFood.createdDate = Date()
            
            // Add some additional nutrients for demonstration
            var additionalNutrients: [String: Double] = [:]
            additionalNutrients["calories"] = food.calories
            additionalNutrients["protein"] = food.protein
            additionalNutrients["carbs"] = food.carbs
            additionalNutrients["fat"] = food.fat
            additionalNutrients["fiber"] = food.fiber
            additionalNutrients["sugar"] = food.sugar
            
            // Add some vitamins and minerals (sample values)
            if food.category == "Fruits" {
                additionalNutrients["vitamin_c"] = Double.random(in: 10...50)
                additionalNutrients["potassium"] = Double.random(in: 200...400)
            } else if food.category == "Vegetables" {
                additionalNutrients["vitamin_a"] = Double.random(in: 100...500)
                additionalNutrients["vitamin_k"] = Double.random(in: 20...100)
                additionalNutrients["folate"] = Double.random(in: 20...80)
            } else if food.category == "Protein Foods" {
                additionalNutrients["vitamin_b12"] = Double.random(in: 0.5...2.5)
                additionalNutrients["zinc"] = Double.random(in: 2...8)
                additionalNutrients["iron"] = Double.random(in: 1...5)
            }
            
            customFood.additionalNutrients = additionalNutrients
        }
        
        do {
            try context.save()
            print("Sample USDA foods imported successfully!")
        } catch {
            print("Error importing sample foods: \(error)")
        }
    }
    
    static func importSampleUserRecipes(context: NSManagedObjectContext) {
        // Sample user recipes
        let sampleRecipes = [
            (
                name: "Green Smoothie Bowl",
                category: "Breakfast",
                prepTime: 10,
                cookTime: 0,
                servings: 1,
                calories: 320.0,
                protein: 12.0,
                carbs: 45.0,
                fat: 15.0,
                ingredients: ["1 cup spinach", "1 banana", "1/2 cup berries", "1 tbsp almond butter", "1/2 cup almond milk"],
                instructions: ["Blend all ingredients until smooth", "Pour into bowl", "Top with granola and fresh fruit"],
                tags: ["vegetarian", "gluten-free", "quick"]
            ),
            (
                name: "Protein Power Salad",
                category: "Lunch",
                prepTime: 15,
                cookTime: 0,
                servings: 2,
                calories: 380.0,
                protein: 28.0,
                carbs: 22.0,
                fat: 24.0,
                ingredients: ["4 cups mixed greens", "1 grilled chicken breast", "1/2 avocado", "1/4 cup nuts", "2 tbsp olive oil"],
                instructions: ["Chop all ingredients", "Mix in a large bowl", "Drizzle with dressing"],
                tags: ["high-protein", "low-carb", "paleo"]
            )
        ]
        
        for recipe in sampleRecipes {
            let customRecipe = CustomRecipe(context: context)
            customRecipe.id = UUID()
            customRecipe.name = recipe.name
            customRecipe.category = recipe.category
            customRecipe.prepTime = Int32(recipe.prepTime)
            customRecipe.cookTime = Int32(recipe.cookTime)
            customRecipe.servings = Int32(recipe.servings)
            customRecipe.calories = recipe.calories
            customRecipe.protein = recipe.protein
            customRecipe.carbs = recipe.carbs
            customRecipe.fat = recipe.fat
            customRecipe.ingredients = recipe.ingredients
            customRecipe.instructions = recipe.instructions
            customRecipe.tags = recipe.tags
            customRecipe.isUserCreated = true
            customRecipe.source = "User"
            customRecipe.createdDate = Date()
        }
        
        do {
            try context.save()
            print("Sample user recipes imported successfully!")
        } catch {
            print("Error importing sample recipes: \(error)")
        }
    }
}