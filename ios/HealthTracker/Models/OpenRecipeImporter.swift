import Foundation
import CoreData

class OpenRecipeImporter {
    static func importOpenRecipes(context: NSManagedObjectContext) {
        // Import a curated set of healthy recipes
        let recipes = getHealthyRecipes()
        
        var importedCount = 0
        
        for recipeData in recipes {
            // Check if recipe already exists
            let fetchRequest: NSFetchRequest<CustomRecipe> = CustomRecipe.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND isUserCreated == false", recipeData.name)
            
            do {
                let existingRecipes = try context.fetch(fetchRequest)
                
                if existingRecipes.isEmpty {
                    // Create new recipe
                    let recipe = CustomRecipe(context: context)
                    recipe.id = UUID()
                    recipe.name = recipeData.name
                    recipe.category = recipeData.category.rawValue
                    recipe.prepTime = Int32(recipeData.prepTime)
                    recipe.cookTime = Int32(recipeData.cookTime)
                    recipe.servings = Int32(recipeData.servings)
                    recipe.calories = recipeData.nutrition?.calories ?? 0
                    recipe.protein = recipeData.nutrition?.protein ?? 0
                    recipe.carbs = recipeData.nutrition?.carbs ?? 0
                    recipe.fat = recipeData.nutrition?.fat ?? 0
                    recipe.fiber = recipeData.nutrition?.fiber ?? 0
                    recipe.sugar = recipeData.nutrition?.sugar ?? 0
                    recipe.sodium = recipeData.nutrition?.sodium ?? 0
                    recipe.instructions = recipeData.instructions
                    recipe.ingredients = recipeData.ingredients.map { "\($0.amount) \($0.unit.rawValue) \($0.name)" }
                    recipe.tags = recipeData.tags
                    recipe.source = recipeData.source ?? "OpenRecipes"
                    recipe.isUserCreated = false
                    recipe.isFavorite = false
                    recipe.createdDate = Date()
                    
                    importedCount += 1
                }
            } catch {
                print("Error checking existing recipe: \(error)")
            }
        }
        
        // Save context
        if importedCount > 0 {
            do {
                try context.save()
                print("Successfully imported \(importedCount) open recipes")
            } catch {
                print("Error saving open recipes: \(error)")
            }
        }
    }
    
    private static func getHealthyRecipes() -> [RecipeModel] {
        var recipes: [RecipeModel] = []
        
        // Breakfast Recipes
        recipes.append(contentsOf: [
            RecipeModel(
                name: "Overnight Oats with Berries",
                category: .breakfast,
                prepTime: 10,
                cookTime: 0,
                servings: 1,
                ingredients: [
                    IngredientModel(name: "rolled oats", amount: 0.5, unit: .cup, category: .pantry),
                    IngredientModel(name: "almond milk", amount: 0.5, unit: .cup, category: .dairy),
                    IngredientModel(name: "Greek yogurt", amount: 0.25, unit: .cup, category: .dairy),
                    IngredientModel(name: "mixed berries", amount: 0.5, unit: .cup, category: .produce),
                    IngredientModel(name: "honey", amount: 1, unit: .tablespoon, category: .pantry),
                    IngredientModel(name: "chia seeds", amount: 1, unit: .tablespoon, category: .pantry)
                ],
                instructions: [
                    "In a jar or container, combine oats, almond milk, Greek yogurt, and chia seeds",
                    "Stir well to combine all ingredients",
                    "Add honey and mix again",
                    "Cover and refrigerate overnight (at least 6 hours)",
                    "In the morning, top with fresh berries and enjoy"
                ],
                nutrition: NutritionInfo(calories: 310, protein: 12, carbs: 48, fat: 9, fiber: 8, sugar: 18, sodium: 95),
                source: "OpenRecipes Database",
                tags: ["healthy", "make-ahead", "high-fiber", "vegetarian"]
            ),
            
            RecipeModel(
                name: "Veggie Scrambled Eggs",
                category: .breakfast,
                prepTime: 10,
                cookTime: 10,
                servings: 2,
                ingredients: [
                    IngredientModel(name: "eggs", amount: 4, unit: .piece, category: .dairy),
                    IngredientModel(name: "bell pepper", amount: 0.5, unit: .cup, notes: "diced", category: .produce),
                    IngredientModel(name: "spinach", amount: 1, unit: .cup, category: .produce),
                    IngredientModel(name: "mushrooms", amount: 0.5, unit: .cup, notes: "sliced", category: .produce),
                    IngredientModel(name: "olive oil", amount: 1, unit: .tablespoon, category: .condiments),
                    IngredientModel(name: "salt", amount: 0.25, unit: .teaspoon, category: .spices),
                    IngredientModel(name: "black pepper", amount: 0.25, unit: .teaspoon, category: .spices)
                ],
                instructions: [
                    "Heat olive oil in a non-stick pan over medium heat",
                    "Add bell pepper and mushrooms, sauté for 3-4 minutes",
                    "Add spinach and cook until wilted",
                    "Whisk eggs with salt and pepper",
                    "Pour eggs into the pan and scramble gently",
                    "Cook until eggs are set but still creamy"
                ],
                nutrition: NutritionInfo(calories: 180, protein: 14, carbs: 6, fat: 12, fiber: 2, sugar: 3, sodium: 320),
                source: "OpenRecipes Database",
                tags: ["high-protein", "low-carb", "gluten-free", "vegetarian"]
            )
        ])
        
        // Lunch Recipes
        recipes.append(contentsOf: [
            RecipeModel(
                name: "Quinoa Buddha Bowl",
                category: .lunch,
                prepTime: 15,
                cookTime: 20,
                servings: 2,
                ingredients: [
                    IngredientModel(name: "quinoa", amount: 1, unit: .cup, notes: "cooked", category: .pantry),
                    IngredientModel(name: "chickpeas", amount: 1, unit: .cup, notes: "cooked", category: .pantry),
                    IngredientModel(name: "sweet potato", amount: 1, unit: .piece, notes: "medium, cubed", category: .produce),
                    IngredientModel(name: "kale", amount: 2, unit: .cup, notes: "chopped", category: .produce),
                    IngredientModel(name: "avocado", amount: 1, unit: .piece, category: .produce),
                    IngredientModel(name: "tahini", amount: 2, unit: .tablespoon, category: .condiments),
                    IngredientModel(name: "lemon juice", amount: 1, unit: .tablespoon, category: .produce),
                    IngredientModel(name: "olive oil", amount: 1, unit: .tablespoon, category: .condiments)
                ],
                instructions: [
                    "Preheat oven to 400°F (200°C)",
                    "Toss sweet potato cubes with olive oil and roast for 20 minutes",
                    "Massage kale with a pinch of salt until softened",
                    "Mix tahini with lemon juice and 2-3 tbsp water for dressing",
                    "Divide quinoa between bowls",
                    "Top with roasted sweet potato, chickpeas, kale, and sliced avocado",
                    "Drizzle with tahini dressing"
                ],
                nutrition: NutritionInfo(calories: 485, protein: 16, carbs: 65, fat: 20, fiber: 14, sugar: 8, sodium: 280),
                source: "OpenRecipes Database",
                tags: ["vegan", "high-fiber", "meal-prep", "gluten-free"]
            ),
            
            RecipeModel(
                name: "Mediterranean Chicken Wrap",
                category: .lunch,
                prepTime: 15,
                cookTime: 15,
                servings: 2,
                ingredients: [
                    IngredientModel(name: "chicken breast", amount: 8, unit: .ounce, category: .meat),
                    IngredientModel(name: "whole wheat tortilla", amount: 2, unit: .piece, category: .bakery),
                    IngredientModel(name: "cucumber", amount: 0.5, unit: .cup, notes: "diced", category: .produce),
                    IngredientModel(name: "tomatoes", amount: 0.5, unit: .cup, notes: "diced", category: .produce),
                    IngredientModel(name: "red onion", amount: 0.25, unit: .cup, notes: "sliced", category: .produce),
                    IngredientModel(name: "hummus", amount: 4, unit: .tablespoon, category: .condiments),
                    IngredientModel(name: "Greek yogurt", amount: 2, unit: .tablespoon, category: .dairy),
                    IngredientModel(name: "mixed greens", amount: 1, unit: .cup, category: .produce)
                ],
                instructions: [
                    "Season and grill chicken breast until cooked through",
                    "Let chicken rest, then slice into strips",
                    "Warm tortillas in a dry pan or microwave",
                    "Spread hummus on each tortilla",
                    "Layer with mixed greens, chicken, cucumber, tomatoes, and onion",
                    "Add a dollop of Greek yogurt",
                    "Roll tightly and cut in half"
                ],
                nutrition: NutritionInfo(calories: 380, protein: 35, carbs: 38, fat: 10, fiber: 8, sugar: 6, sodium: 580),
                source: "OpenRecipes Database",
                tags: ["high-protein", "mediterranean", "meal-prep"]
            )
        ])
        
        // Dinner Recipes
        recipes.append(contentsOf: [
            RecipeModel(
                name: "Baked Salmon with Vegetables",
                category: .dinner,
                prepTime: 15,
                cookTime: 25,
                servings: 4,
                ingredients: [
                    IngredientModel(name: "salmon fillet", amount: 1.5, unit: .pound, category: .meat),
                    IngredientModel(name: "broccoli florets", amount: 2, unit: .cup, category: .produce),
                    IngredientModel(name: "cherry tomatoes", amount: 1, unit: .cup, category: .produce),
                    IngredientModel(name: "asparagus", amount: 1, unit: .pound, category: .produce),
                    IngredientModel(name: "olive oil", amount: 3, unit: .tablespoon, category: .condiments),
                    IngredientModel(name: "garlic", amount: 3, unit: .piece, category: .produce),
                    IngredientModel(name: "lemon", amount: 1, unit: .piece, category: .produce),
                    IngredientModel(name: "fresh herbs", amount: 2, unit: .tablespoon, notes: "dill or parsley", category: .produce)
                ],
                instructions: [
                    "Preheat oven to 425°F (220°C)",
                    "Line a baking sheet with parchment paper",
                    "Place salmon in center, surround with vegetables",
                    "Drizzle everything with olive oil, add garlic",
                    "Season with salt and pepper",
                    "Slice lemon and place on salmon",
                    "Bake for 20-25 minutes until salmon flakes easily",
                    "Garnish with fresh herbs before serving"
                ],
                nutrition: NutritionInfo(calories: 420, protein: 38, carbs: 18, fat: 24, fiber: 6, sugar: 5, sodium: 380),
                source: "OpenRecipes Database",
                tags: ["omega-3", "low-carb", "gluten-free", "heart-healthy"]
            ),
            
            RecipeModel(
                name: "Vegetarian Chili",
                category: .dinner,
                prepTime: 20,
                cookTime: 40,
                servings: 6,
                ingredients: [
                    IngredientModel(name: "black beans", amount: 2, unit: .cup, notes: "cooked", category: .pantry),
                    IngredientModel(name: "kidney beans", amount: 2, unit: .cup, notes: "cooked", category: .pantry),
                    IngredientModel(name: "diced tomatoes", amount: 28, unit: .ounce, notes: "canned", category: .pantry),
                    IngredientModel(name: "bell peppers", amount: 2, unit: .piece, notes: "diced", category: .produce),
                    IngredientModel(name: "onion", amount: 1, unit: .piece, category: .produce),
                    IngredientModel(name: "corn", amount: 1, unit: .cup, category: .produce),
                    IngredientModel(name: "chili powder", amount: 2, unit: .tablespoon, category: .spices),
                    IngredientModel(name: "cumin", amount: 1, unit: .tablespoon, category: .spices),
                    IngredientModel(name: "vegetable broth", amount: 2, unit: .cup, category: .pantry)
                ],
                instructions: [
                    "In a large pot, sauté onion and peppers until softened",
                    "Add chili powder and cumin, cook for 1 minute",
                    "Add tomatoes, beans, corn, and vegetable broth",
                    "Bring to a boil, then reduce heat and simmer",
                    "Cook for 30-40 minutes, stirring occasionally",
                    "Season with salt and pepper to taste",
                    "Serve hot with desired toppings"
                ],
                nutrition: NutritionInfo(calories: 295, protein: 16, carbs: 52, fat: 3, fiber: 18, sugar: 9, sodium: 480),
                source: "OpenRecipes Database",
                tags: ["vegan", "high-fiber", "meal-prep", "gluten-free", "budget-friendly"]
            )
        ])
        
        // Snack Recipes
        recipes.append(contentsOf: [
            RecipeModel(
                name: "Energy Balls",
                category: .snack,
                prepTime: 15,
                cookTime: 0,
                servings: 12,
                ingredients: [
                    IngredientModel(name: "dates", amount: 1, unit: .cup, notes: "pitted", category: .produce),
                    IngredientModel(name: "almonds", amount: 0.5, unit: .cup, category: .pantry),
                    IngredientModel(name: "rolled oats", amount: 0.5, unit: .cup, category: .pantry),
                    IngredientModel(name: "chia seeds", amount: 2, unit: .tablespoon, category: .pantry),
                    IngredientModel(name: "cocoa powder", amount: 2, unit: .tablespoon, category: .pantry),
                    IngredientModel(name: "vanilla extract", amount: 1, unit: .teaspoon, category: .pantry),
                    IngredientModel(name: "sea salt", amount: 0.25, unit: .teaspoon, category: .spices)
                ],
                instructions: [
                    "Soak dates in warm water for 10 minutes if very dry",
                    "In a food processor, pulse almonds and oats until coarsely ground",
                    "Add dates, chia seeds, cocoa powder, vanilla, and salt",
                    "Process until mixture sticks together",
                    "Roll into 12 balls, about 1 inch in diameter",
                    "Refrigerate for at least 30 minutes before serving",
                    "Store in an airtight container in the fridge"
                ],
                nutrition: NutritionInfo(calories: 85, protein: 2, carbs: 14, fat: 3, fiber: 3, sugar: 10, sodium: 50),
                source: "OpenRecipes Database",
                tags: ["vegan", "no-bake", "gluten-free", "energy-boost"]
            ),
            
            RecipeModel(
                name: "Hummus and Veggie Sticks",
                category: .snack,
                prepTime: 10,
                cookTime: 0,
                servings: 4,
                ingredients: [
                    IngredientModel(name: "chickpeas", amount: 15, unit: .ounce, category: .pantry),
                    IngredientModel(name: "tahini", amount: 0.25, unit: .cup, category: .condiments),
                    IngredientModel(name: "lemon juice", amount: 3, unit: .tablespoon, category: .produce),
                    IngredientModel(name: "garlic", amount: 2, unit: .piece, notes: "cloves", category: .produce),
                    IngredientModel(name: "olive oil", amount: 2, unit: .tablespoon, category: .condiments),
                    IngredientModel(name: "carrots", amount: 2, unit: .piece, notes: "cut into sticks", category: .produce),
                    IngredientModel(name: "celery", amount: 3, unit: .piece, category: .produce),
                    IngredientModel(name: "bell pepper", amount: 1, unit: .piece, notes: "cut into strips", category: .produce)
                ],
                instructions: [
                    "In a food processor, combine chickpeas, tahini, lemon juice, and garlic",
                    "Process until smooth, adding water as needed for consistency",
                    "Drizzle in olive oil while processing",
                    "Season with salt to taste",
                    "Transfer to a serving bowl",
                    "Arrange vegetable sticks around hummus",
                    "Drizzle with extra olive oil and serve"
                ],
                nutrition: NutritionInfo(calories: 180, protein: 7, carbs: 22, fat: 8, fiber: 6, sugar: 4, sodium: 240),
                source: "OpenRecipes Database",
                tags: ["vegan", "high-fiber", "mediterranean", "gluten-free"]
            )
        ])
        
        return recipes
    }
}