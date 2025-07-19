import Foundation

class RecipeDatabase {
    static let shared = RecipeDatabase()
    
    let recipes: [Recipe] = [
        // Breakfast Recipes
        Recipe(
            name: "Overnight Oats with Berries",
            category: .breakfast,
            prepTime: 10,
            cookTime: 0,
            servings: 2,
            ingredients: [
                Ingredient(name: "rolled oats", amount: 1, unit: .cup, notes: nil, category: .pantry),
                Ingredient(name: "almond milk", amount: 1, unit: .cup, notes: nil, category: .dairy),
                Ingredient(name: "Greek yogurt", amount: 0.5, unit: .cup, notes: nil, category: .dairy),
                Ingredient(name: "blueberries", amount: 0.5, unit: .cup, notes: "fresh or frozen", category: .produce),
                Ingredient(name: "strawberries", amount: 0.5, unit: .cup, notes: "sliced", category: .produce),
                Ingredient(name: "honey", amount: 2, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "chia seeds", amount: 1, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "vanilla extract", amount: 1, unit: .teaspoon, notes: nil, category: .pantry)
            ],
            instructions: [
                "In a jar or container, combine oats, almond milk, Greek yogurt, honey, chia seeds, and vanilla extract.",
                "Stir well to combine all ingredients.",
                "Add half the berries and gently fold in.",
                "Cover and refrigerate overnight or for at least 4 hours.",
                "Before serving, top with remaining berries.",
                "Can be stored in the refrigerator for up to 3 days."
            ],
            nutrition: NutritionInfo(calories: 285, protein: 12, carbs: 48, fat: 6, fiber: 8, sugar: 18, sodium: 65),
            imageURL: nil,
            source: "Healthy Living",
            tags: ["vegetarian", "make-ahead", "no-cook", "high-fiber"],
            isFavorite: false,
            rating: 0
        ),
        
        Recipe(
            name: "Veggie Scrambled Eggs",
            category: .breakfast,
            prepTime: 10,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Ingredient(name: "eggs", amount: 4, unit: .piece, notes: "large", category: .dairy),
                Ingredient(name: "spinach", amount: 1, unit: .cup, notes: "fresh", category: .produce),
                Ingredient(name: "cherry tomatoes", amount: 0.5, unit: .cup, notes: "halved", category: .produce),
                Ingredient(name: "mushrooms", amount: 0.5, unit: .cup, notes: "sliced", category: .produce),
                Ingredient(name: "cheddar cheese", amount: 0.25, unit: .cup, notes: "shredded", category: .dairy),
                Ingredient(name: "olive oil", amount: 1, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "salt", amount: 1, unit: .pinch, notes: "to taste", category: .spices),
                Ingredient(name: "black pepper", amount: 1, unit: .pinch, notes: "to taste", category: .spices)
            ],
            instructions: [
                "Heat olive oil in a non-stick pan over medium heat.",
                "Add mushrooms and cook for 3-4 minutes until softened.",
                "Add cherry tomatoes and spinach, cook for 2 minutes until spinach wilts.",
                "Beat eggs in a bowl and season with salt and pepper.",
                "Pour eggs into the pan with vegetables.",
                "Gently scramble eggs with a spatula until just set.",
                "Sprinkle cheese on top and fold gently.",
                "Serve immediately while hot."
            ],
            nutrition: NutritionInfo(calories: 320, protein: 24, carbs: 8, fat: 22, fiber: 2, sugar: 4, sodium: 380),
            imageURL: nil,
            source: "Classic Cooking",
            tags: ["vegetarian", "gluten-free", "low-carb", "quick"],
            isFavorite: false,
            rating: 0
        ),
        
        // Lunch Recipes
        Recipe(
            name: "Grilled Chicken Salad",
            category: .lunch,
            prepTime: 15,
            cookTime: 15,
            servings: 2,
            ingredients: [
                Ingredient(name: "chicken breast", amount: 8, unit: .ounce, notes: "boneless, skinless", category: .meat),
                Ingredient(name: "mixed greens", amount: 4, unit: .cup, notes: nil, category: .produce),
                Ingredient(name: "cherry tomatoes", amount: 1, unit: .cup, notes: nil, category: .produce),
                Ingredient(name: "cucumber", amount: 1, unit: .piece, notes: "diced", category: .produce),
                Ingredient(name: "red onion", amount: 0.25, unit: .piece, notes: "thinly sliced", category: .produce),
                Ingredient(name: "avocado", amount: 1, unit: .piece, notes: "sliced", category: .produce),
                Ingredient(name: "olive oil", amount: 3, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "lemon juice", amount: 2, unit: .tablespoon, notes: "fresh", category: .produce),
                Ingredient(name: "garlic", amount: 1, unit: .clove, notes: "minced", category: .produce),
                Ingredient(name: "salt", amount: 1, unit: .pinch, notes: nil, category: .spices),
                Ingredient(name: "pepper", amount: 1, unit: .pinch, notes: nil, category: .spices)
            ],
            instructions: [
                "Season chicken breasts with salt and pepper.",
                "Grill chicken for 6-7 minutes per side until cooked through.",
                "Let chicken rest for 5 minutes, then slice.",
                "In a large bowl, combine mixed greens, tomatoes, cucumber, and red onion.",
                "Make dressing by whisking olive oil, lemon juice, garlic, salt, and pepper.",
                "Toss salad with half the dressing.",
                "Top with sliced chicken and avocado.",
                "Drizzle remaining dressing over top."
            ],
            nutrition: NutritionInfo(calories: 380, protein: 35, carbs: 15, fat: 22, fiber: 7, sugar: 6, sodium: 280),
            imageURL: nil,
            source: "Fit & Fresh",
            tags: ["gluten-free", "low-carb", "high-protein", "paleo"],
            isFavorite: false,
            rating: 0
        ),
        
        Recipe(
            name: "Quinoa Buddha Bowl",
            category: .lunch,
            prepTime: 20,
            cookTime: 20,
            servings: 2,
            ingredients: [
                Ingredient(name: "quinoa", amount: 1, unit: .cup, notes: "uncooked", category: .pantry),
                Ingredient(name: "chickpeas", amount: 1, unit: .can, notes: "15 oz, drained", category: .pantry),
                Ingredient(name: "sweet potato", amount: 1, unit: .piece, notes: "medium, cubed", category: .produce),
                Ingredient(name: "broccoli", amount: 2, unit: .cup, notes: "florets", category: .produce),
                Ingredient(name: "red cabbage", amount: 1, unit: .cup, notes: "shredded", category: .produce),
                Ingredient(name: "tahini", amount: 0.25, unit: .cup, notes: nil, category: .condiments),
                Ingredient(name: "lemon juice", amount: 2, unit: .tablespoon, notes: nil, category: .produce),
                Ingredient(name: "olive oil", amount: 2, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "cumin", amount: 1, unit: .teaspoon, notes: nil, category: .spices),
                Ingredient(name: "paprika", amount: 1, unit: .teaspoon, notes: nil, category: .spices)
            ],
            instructions: [
                "Cook quinoa according to package directions.",
                "Preheat oven to 425°F (220°C).",
                "Toss sweet potato and broccoli with 1 tbsp olive oil, salt, and pepper.",
                "Roast vegetables for 20 minutes until tender.",
                "Toss chickpeas with remaining oil, cumin, and paprika.",
                "Add chickpeas to oven for last 10 minutes of roasting.",
                "Make tahini dressing by mixing tahini, lemon juice, and 2-3 tbsp water.",
                "Divide quinoa between bowls, top with roasted vegetables and chickpeas.",
                "Add shredded cabbage and drizzle with tahini dressing."
            ],
            nutrition: NutritionInfo(calories: 450, protein: 18, carbs: 62, fat: 16, fiber: 14, sugar: 8, sodium: 320),
            imageURL: nil,
            source: "Plant Power",
            tags: ["vegan", "vegetarian", "high-fiber", "meal-prep"],
            isFavorite: false,
            rating: 0
        ),
        
        // Dinner Recipes
        Recipe(
            name: "Baked Salmon with Asparagus",
            category: .dinner,
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            ingredients: [
                Ingredient(name: "salmon fillets", amount: 1.5, unit: .pound, notes: "4 fillets", category: .meat),
                Ingredient(name: "asparagus", amount: 1, unit: .pound, notes: "trimmed", category: .produce),
                Ingredient(name: "lemon", amount: 1, unit: .piece, notes: "sliced", category: .produce),
                Ingredient(name: "garlic", amount: 3, unit: .clove, notes: "minced", category: .produce),
                Ingredient(name: "olive oil", amount: 3, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "dill", amount: 2, unit: .tablespoon, notes: "fresh, chopped", category: .produce),
                Ingredient(name: "salt", amount: 1, unit: .teaspoon, notes: nil, category: .spices),
                Ingredient(name: "black pepper", amount: 0.5, unit: .teaspoon, notes: nil, category: .spices)
            ],
            instructions: [
                "Preheat oven to 400°F (200°C).",
                "Line a baking sheet with parchment paper.",
                "Place salmon fillets on one side of the sheet.",
                "Arrange asparagus on the other side.",
                "Mix olive oil, garlic, dill, salt, and pepper.",
                "Brush salmon and asparagus with the oil mixture.",
                "Top salmon with lemon slices.",
                "Bake for 15-20 minutes until salmon flakes easily.",
                "Serve immediately with additional lemon wedges."
            ],
            nutrition: NutritionInfo(calories: 350, protein: 35, carbs: 8, fat: 20, fiber: 4, sugar: 3, sodium: 380),
            imageURL: nil,
            source: "Seafood Sensations",
            tags: ["gluten-free", "low-carb", "omega-3", "quick"],
            isFavorite: false,
            rating: 0
        ),
        
        Recipe(
            name: "Vegetarian Chili",
            category: .dinner,
            prepTime: 15,
            cookTime: 30,
            servings: 6,
            ingredients: [
                Ingredient(name: "black beans", amount: 2, unit: .can, notes: "15 oz each", category: .pantry),
                Ingredient(name: "kidney beans", amount: 1, unit: .can, notes: "15 oz", category: .pantry),
                Ingredient(name: "diced tomatoes", amount: 2, unit: .can, notes: "14.5 oz each", category: .pantry),
                Ingredient(name: "tomato paste", amount: 2, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "onion", amount: 1, unit: .piece, notes: "large, diced", category: .produce),
                Ingredient(name: "bell pepper", amount: 2, unit: .piece, notes: "any color, diced", category: .produce),
                Ingredient(name: "corn", amount: 1, unit: .cup, notes: "frozen or fresh", category: .frozen),
                Ingredient(name: "vegetable broth", amount: 2, unit: .cup, notes: nil, category: .pantry),
                Ingredient(name: "chili powder", amount: 2, unit: .tablespoon, notes: nil, category: .spices),
                Ingredient(name: "cumin", amount: 1, unit: .tablespoon, notes: nil, category: .spices),
                Ingredient(name: "paprika", amount: 1, unit: .teaspoon, notes: nil, category: .spices)
            ],
            instructions: [
                "Heat oil in a large pot over medium heat.",
                "Sauté onion and bell peppers for 5 minutes until softened.",
                "Add garlic and cook for 1 minute.",
                "Stir in chili powder, cumin, and paprika.",
                "Add tomato paste and cook for 2 minutes.",
                "Add diced tomatoes, beans, corn, and vegetable broth.",
                "Bring to a boil, then reduce heat and simmer for 20-25 minutes.",
                "Stir occasionally and add more broth if needed.",
                "Season with salt and pepper to taste.",
                "Serve with toppings like cheese, sour cream, or avocado."
            ],
            nutrition: NutritionInfo(calories: 280, protein: 14, carbs: 48, fat: 4, fiber: 16, sugar: 8, sodium: 620),
            imageURL: nil,
            source: "Comfort Classics",
            tags: ["vegan", "vegetarian", "high-fiber", "meal-prep", "freezer-friendly"],
            isFavorite: false,
            rating: 0
        ),
        
        Recipe(
            name: "Chicken Stir-Fry",
            category: .dinner,
            prepTime: 20,
            cookTime: 15,
            servings: 4,
            ingredients: [
                Ingredient(name: "chicken breast", amount: 1, unit: .pound, notes: "cut into strips", category: .meat),
                Ingredient(name: "broccoli", amount: 2, unit: .cup, notes: "florets", category: .produce),
                Ingredient(name: "bell pepper", amount: 1, unit: .piece, notes: "sliced", category: .produce),
                Ingredient(name: "snap peas", amount: 1, unit: .cup, notes: nil, category: .produce),
                Ingredient(name: "carrots", amount: 2, unit: .piece, notes: "julienned", category: .produce),
                Ingredient(name: "soy sauce", amount: 3, unit: .tablespoon, notes: "low sodium", category: .condiments),
                Ingredient(name: "sesame oil", amount: 1, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "ginger", amount: 1, unit: .tablespoon, notes: "fresh, grated", category: .produce),
                Ingredient(name: "garlic", amount: 2, unit: .clove, notes: "minced", category: .produce),
                Ingredient(name: "cornstarch", amount: 1, unit: .tablespoon, notes: nil, category: .pantry),
                Ingredient(name: "vegetable oil", amount: 2, unit: .tablespoon, notes: nil, category: .pantry)
            ],
            instructions: [
                "Mix soy sauce, sesame oil, and cornstarch for sauce. Set aside.",
                "Heat 1 tbsp oil in a wok or large skillet over high heat.",
                "Cook chicken strips until golden, about 5-6 minutes. Remove and set aside.",
                "Add remaining oil to pan.",
                "Stir-fry garlic and ginger for 30 seconds.",
                "Add broccoli and carrots, stir-fry for 3 minutes.",
                "Add bell pepper and snap peas, cook for 2 more minutes.",
                "Return chicken to pan.",
                "Pour sauce over and toss everything together for 1-2 minutes.",
                "Serve immediately over rice or noodles."
            ],
            nutrition: NutritionInfo(calories: 320, protein: 28, carbs: 18, fat: 14, fiber: 5, sugar: 8, sodium: 580),
            imageURL: nil,
            source: "Asian Fusion",
            tags: ["gluten-free-option", "low-carb", "high-protein", "quick"],
            isFavorite: false,
            rating: 0
        )
    ]
    
    func searchRecipes(_ query: String) -> [Recipe] {
        guard !query.isEmpty else { return recipes }
        
        let searchQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.name.lowercased().contains(searchQuery) ||
            recipe.category.rawValue.lowercased().contains(searchQuery) ||
            recipe.tags.contains { $0.lowercased().contains(searchQuery) } ||
            recipe.ingredients.contains { $0.name.lowercased().contains(searchQuery) }
        }
    }
    
    func getRecipesByCategory(_ category: RecipeCategory) -> [Recipe] {
        return recipes.filter { $0.category == category }
    }
    
    func getQuickRecipes(maxTime: Int = 30) -> [Recipe] {
        return recipes.filter { $0.totalTime <= maxTime }
    }
}