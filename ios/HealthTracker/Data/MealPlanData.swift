import Foundation

// MARK: - Meal Plan Models
struct MealPlanType: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let benefits: [String]
    let restrictions: [String]
    let monthlyPlans: [WeeklyMealPlan]
}

struct WeeklyMealPlan: Identifiable, Codable {
    let id: String
    let weekNumber: Int
    let days: [DailyMealPlan]
}

struct DailyMealPlan: Identifiable, Codable {
    let id: String
    let dayName: String
    let breakfast: Meal
    let lunch: Meal
    let dinner: Meal
    let snacks: [Meal]
}

struct Meal: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let prepTime: Int // minutes
    let cookTime: Int // minutes
    let ingredients: [String]
    let instructions: [String]
    let tags: [String]
}

// MARK: - Meal Plan Data
class MealPlanData {
    static let shared = MealPlanData()

    private init() {}

    lazy var allMealPlans: [MealPlanType] = [
        mediterraneanPlan(),
        ketoPlan(),
        intermittentFastingPlan(),
        familyFriendlyPlan(),
        vegetarianPlan()
    ]

    // MARK: - Mediterranean Diet Plan
    func mediterraneanPlan() -> MealPlanType {
        MealPlanType(
            id: "mediterranean",
            name: "Mediterranean",
            description: "Heart-healthy diet rich in fruits, vegetables, whole grains, and olive oil",
            benefits: [
                "Reduces heart disease risk",
                "Supports brain health",
                "Anti-inflammatory",
                "Promotes longevity"
            ],
            restrictions: [
                "Limited red meat",
                "Moderate dairy",
                "No processed foods"
            ],
            monthlyPlans: generateMediterraneanMonth()
        )
    }

    private func generateMediterraneanMonth() -> [WeeklyMealPlan] {
        return [
            // Week 1
            WeeklyMealPlan(
                id: "med-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "med-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "med-b1",
                            name: "Greek Yogurt Parfait",
                            description: "Creamy Greek yogurt layered with honey, walnuts, and fresh berries",
                            calories: 350,
                            protein: 18,
                            carbs: 42,
                            fat: 12,
                            fiber: 5,
                            prepTime: 5,
                            cookTime: 0,
                            ingredients: ["1 cup Greek yogurt", "2 tbsp honey", "1/4 cup walnuts", "1/2 cup mixed berries", "1 tbsp chia seeds"],
                            instructions: ["Layer yogurt in a bowl", "Drizzle with honey", "Top with berries, walnuts, and chia seeds"],
                            tags: ["vegetarian", "high-protein", "quick"]
                        ),
                        lunch: Meal(
                            id: "med-l1",
                            name: "Mediterranean Quinoa Bowl",
                            description: "Fluffy quinoa topped with roasted vegetables, feta, and olive tapenade",
                            calories: 480,
                            protein: 16,
                            carbs: 58,
                            fat: 22,
                            fiber: 9,
                            prepTime: 15,
                            cookTime: 25,
                            ingredients: ["1 cup quinoa", "1 zucchini", "1 bell pepper", "1/4 cup feta", "2 tbsp olive tapenade", "Cherry tomatoes", "Olive oil"],
                            instructions: ["Cook quinoa", "Roast vegetables with olive oil", "Assemble bowl with quinoa base", "Top with vegetables, feta, and tapenade"],
                            tags: ["vegetarian", "meal-prep", "fiber-rich"]
                        ),
                        dinner: Meal(
                            id: "med-d1",
                            name: "Grilled Salmon with Lemon Herbs",
                            description: "Fresh salmon fillet with Mediterranean herbs and roasted asparagus",
                            calories: 420,
                            protein: 34,
                            carbs: 18,
                            fat: 24,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 20,
                            ingredients: ["6 oz salmon fillet", "1 bunch asparagus", "2 lemons", "Fresh dill", "Garlic", "Olive oil"],
                            instructions: ["Season salmon with herbs", "Grill for 12-15 minutes", "Roast asparagus", "Serve with lemon wedges"],
                            tags: ["omega-3", "high-protein", "gluten-free"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s1",
                                name: "Hummus with Vegetables",
                                description: "Classic hummus with fresh cut vegetables",
                                calories: 150,
                                protein: 6,
                                carbs: 18,
                                fat: 8,
                                fiber: 5,
                                prepTime: 5,
                                cookTime: 0,
                                ingredients: ["1/2 cup hummus", "Carrot sticks", "Cucumber", "Bell pepper"],
                                instructions: ["Cut vegetables", "Serve with hummus"],
                                tags: ["vegan", "fiber-rich", "quick"]
                            )
                        ]
                    ),
                    DailyMealPlan(
                        id: "med-w1-tuesday",
                        dayName: "Tuesday",
                        breakfast: Meal(
                            id: "med-b2",
                            name: "Mediterranean Scrambled Eggs",
                            description: "Eggs scrambled with tomatoes, spinach, and feta cheese",
                            calories: 320,
                            protein: 22,
                            carbs: 12,
                            fat: 20,
                            fiber: 3,
                            prepTime: 5,
                            cookTime: 10,
                            ingredients: ["3 eggs", "Handful spinach", "Cherry tomatoes", "2 tbsp feta", "Olive oil", "Whole grain toast"],
                            instructions: ["Sauté spinach and tomatoes", "Scramble eggs", "Add feta at the end", "Serve with toast"],
                            tags: ["vegetarian", "high-protein", "low-carb"]
                        ),
                        lunch: Meal(
                            id: "med-l2",
                            name: "Greek Salad with Chickpeas",
                            description: "Traditional Greek salad with added chickpeas for protein",
                            calories: 380,
                            protein: 12,
                            carbs: 32,
                            fat: 24,
                            fiber: 9,
                            prepTime: 15,
                            cookTime: 0,
                            ingredients: ["Mixed greens", "Cucumber", "Tomatoes", "Red onion", "Kalamata olives", "Feta", "Chickpeas", "Olive oil", "Lemon"],
                            instructions: ["Chop vegetables", "Mix with greens", "Add chickpeas and feta", "Dress with olive oil and lemon"],
                            tags: ["vegetarian", "no-cook", "fiber-rich"]
                        ),
                        dinner: Meal(
                            id: "med-d2",
                            name: "Chicken Souvlaki with Tzatziki",
                            description: "Marinated chicken skewers with cucumber yogurt sauce and pita",
                            calories: 460,
                            protein: 38,
                            carbs: 34,
                            fat: 18,
                            fiber: 4,
                            prepTime: 20,
                            cookTime: 15,
                            ingredients: ["Chicken breast", "Greek yogurt", "Cucumber", "Garlic", "Lemon", "Oregano", "Pita bread"],
                            instructions: ["Marinate chicken", "Thread onto skewers", "Grill 12-15 minutes", "Make tzatziki", "Serve with pita"],
                            tags: ["high-protein", "grilled", "lean-meat"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s2",
                                name: "Mixed Nuts and Dried Fruit",
                                description: "Mediterranean nut mix with apricots",
                                calories: 180,
                                protein: 5,
                                carbs: 16,
                                fat: 12,
                                fiber: 3,
                                prepTime: 0,
                                cookTime: 0,
                                ingredients: ["Almonds", "Walnuts", "Dried apricots", "Dates"],
                                instructions: ["Mix and portion"],
                                tags: ["vegan", "portable", "energy-boost"]
                            )
                        ]
                    ),
                    // Continue with Wednesday through Sunday...
                    DailyMealPlan(
                        id: "med-w1-wednesday",
                        dayName: "Wednesday",
                        breakfast: Meal(
                            id: "med-b3",
                            name: "Overnight Oats with Figs",
                            description: "Creamy oats soaked overnight with figs and almonds",
                            calories: 380,
                            protein: 12,
                            carbs: 58,
                            fat: 14,
                            fiber: 8,
                            prepTime: 5,
                            cookTime: 0,
                            ingredients: ["1/2 cup oats", "1 cup almond milk", "2 figs", "Almonds", "Honey", "Cinnamon"],
                            instructions: ["Mix oats with milk", "Add chopped figs", "Refrigerate overnight", "Top with almonds"],
                            tags: ["vegetarian", "make-ahead", "fiber-rich"]
                        ),
                        lunch: Meal(
                            id: "med-l3",
                            name: "Lentil and Vegetable Soup",
                            description: "Hearty Mediterranean lentil soup with vegetables",
                            calories: 340,
                            protein: 18,
                            carbs: 48,
                            fat: 8,
                            fiber: 12,
                            prepTime: 15,
                            cookTime: 30,
                            ingredients: ["Red lentils", "Carrots", "Celery", "Onion", "Tomatoes", "Vegetable broth", "Olive oil"],
                            instructions: ["Sauté vegetables", "Add lentils and broth", "Simmer 25 minutes", "Season with herbs"],
                            tags: ["vegan", "high-fiber", "comfort-food"]
                        ),
                        dinner: Meal(
                            id: "med-d3",
                            name: "Baked Cod with Tomatoes",
                            description: "Flaky cod baked with tomatoes, olives, and capers",
                            calories: 380,
                            protein: 32,
                            carbs: 22,
                            fat: 16,
                            fiber: 5,
                            prepTime: 10,
                            cookTime: 25,
                            ingredients: ["Cod fillet", "Cherry tomatoes", "Kalamata olives", "Capers", "Garlic", "White wine", "Olive oil"],
                            instructions: ["Place cod in baking dish", "Top with tomatoes and olives", "Drizzle with oil and wine", "Bake at 400°F for 20-25 min"],
                            tags: ["lean-protein", "omega-3", "low-carb"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s3",
                                name: "Olive and Cheese Plate",
                                description: "Assorted olives with feta and whole grain crackers",
                                calories: 160,
                                protein: 6,
                                carbs: 14,
                                fat: 10,
                                fiber: 2,
                                prepTime: 3,
                                cookTime: 0,
                                ingredients: ["Mixed olives", "Feta cheese", "Whole grain crackers"],
                                instructions: ["Arrange on plate", "Serve"],
                                tags: ["vegetarian", "quick", "savory"]
                            )
                        ]
                    ),
                    DailyMealPlan(
                        id: "med-w1-thursday",
                        dayName: "Thursday",
                        breakfast: Meal(
                            id: "med-b4",
                            name: "Shakshuka",
                            description: "Eggs poached in spicy tomato sauce with herbs",
                            calories: 340,
                            protein: 18,
                            carbs: 28,
                            fat: 16,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 20,
                            ingredients: ["2 eggs", "Crushed tomatoes", "Bell pepper", "Onion", "Garlic", "Cumin", "Paprika", "Feta"],
                            instructions: ["Sauté vegetables", "Add tomatoes and spices", "Make wells and crack eggs", "Cover and cook until set"],
                            tags: ["vegetarian", "spicy", "one-pan"]
                        ),
                        lunch: Meal(
                            id: "med-l4",
                            name: "Tabbouleh with Grilled Halloumi",
                            description: "Fresh parsley and bulgur salad with grilled cheese",
                            calories: 420,
                            protein: 16,
                            carbs: 42,
                            fat: 22,
                            fiber: 8,
                            prepTime: 20,
                            cookTime: 5,
                            ingredients: ["Bulgur", "Parsley", "Tomatoes", "Cucumber", "Halloumi", "Lemon", "Olive oil"],
                            instructions: ["Soak bulgur", "Chop vegetables and herbs", "Mix with lemon dressing", "Grill halloumi", "Serve together"],
                            tags: ["vegetarian", "fresh", "whole-grain"]
                        ),
                        dinner: Meal(
                            id: "med-d4",
                            name: "Mediterranean Stuffed Peppers",
                            description: "Bell peppers stuffed with rice, pine nuts, and herbs",
                            calories: 380,
                            protein: 14,
                            carbs: 48,
                            fat: 16,
                            fiber: 7,
                            prepTime: 20,
                            cookTime: 40,
                            ingredients: ["4 bell peppers", "Brown rice", "Pine nuts", "Raisins", "Onion", "Herbs", "Olive oil"],
                            instructions: ["Cook rice with herbs", "Mix with nuts and raisins", "Stuff peppers", "Bake 35-40 minutes"],
                            tags: ["vegetarian", "comfort-food", "colorful"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s4",
                                name: "Fresh Fruit with Yogurt Dip",
                                description: "Seasonal fruit with honey yogurt",
                                calories: 140,
                                protein: 6,
                                carbs: 24,
                                fat: 3,
                                fiber: 3,
                                prepTime: 5,
                                cookTime: 0,
                                ingredients: ["Greek yogurt", "Honey", "Apple slices", "Grapes"],
                                instructions: ["Mix yogurt with honey", "Serve with fruit"],
                                tags: ["vegetarian", "fresh", "light"]
                            )
                        ]
                    ),
                    DailyMealPlan(
                        id: "med-w1-friday",
                        dayName: "Friday",
                        breakfast: Meal(
                            id: "med-b5",
                            name: "Whole Grain Toast with Avocado",
                            description: "Multigrain toast topped with avocado and poached egg",
                            calories: 360,
                            protein: 14,
                            carbs: 32,
                            fat: 20,
                            fiber: 8,
                            prepTime: 5,
                            cookTime: 10,
                            ingredients: ["2 slices whole grain bread", "1 avocado", "2 eggs", "Lemon", "Red pepper flakes"],
                            instructions: ["Toast bread", "Mash avocado with lemon", "Poach eggs", "Assemble and season"],
                            tags: ["vegetarian", "trendy", "fiber-rich"]
                        ),
                        lunch: Meal(
                            id: "med-l5",
                            name: "Mediterranean Tuna Salad",
                            description: "Tuna salad with white beans and fresh herbs",
                            calories: 380,
                            protein: 28,
                            carbs: 32,
                            fat: 16,
                            fiber: 8,
                            prepTime: 15,
                            cookTime: 0,
                            ingredients: ["Tuna", "White beans", "Red onion", "Parsley", "Capers", "Olive oil", "Lemon"],
                            instructions: ["Flake tuna", "Mix with beans", "Add herbs and dressing", "Chill before serving"],
                            tags: ["high-protein", "no-cook", "omega-3"]
                        ),
                        dinner: Meal(
                            id: "med-d5",
                            name: "Lamb Kofta with Yogurt Sauce",
                            description: "Spiced lamb meatballs with cucumber yogurt",
                            calories: 440,
                            protein: 32,
                            carbs: 28,
                            fat: 22,
                            fiber: 4,
                            prepTime: 20,
                            cookTime: 15,
                            ingredients: ["Ground lamb", "Onion", "Herbs", "Spices", "Yogurt", "Cucumber", "Pita"],
                            instructions: ["Mix lamb with spices", "Form into ovals", "Grill or bake", "Make yogurt sauce", "Serve with pita"],
                            tags: ["protein-rich", "spiced", "traditional"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s5",
                                name: "Roasted Chickpeas",
                                description: "Crispy seasoned chickpeas",
                                calories: 130,
                                protein: 6,
                                carbs: 20,
                                fat: 3,
                                fiber: 6,
                                prepTime: 5,
                                cookTime: 30,
                                ingredients: ["Chickpeas", "Olive oil", "Paprika", "Cumin", "Salt"],
                                instructions: ["Drain and dry chickpeas", "Toss with oil and spices", "Roast at 400°F for 30 min"],
                                tags: ["vegan", "crunchy", "high-fiber"]
                            )
                        ]
                    ),
                    DailyMealPlan(
                        id: "med-w1-saturday",
                        dayName: "Saturday",
                        breakfast: Meal(
                            id: "med-b6",
                            name: "Mediterranean Frittata",
                            description: "Baked egg dish with vegetables and herbs",
                            calories: 340,
                            protein: 20,
                            carbs: 18,
                            fat: 22,
                            fiber: 4,
                            prepTime: 15,
                            cookTime: 25,
                            ingredients: ["6 eggs", "Zucchini", "Tomatoes", "Onion", "Feta", "Basil", "Olive oil"],
                            instructions: ["Sauté vegetables", "Beat eggs", "Combine and pour into pan", "Bake until set"],
                            tags: ["vegetarian", "meal-prep", "protein-rich"]
                        ),
                        lunch: Meal(
                            id: "med-l6",
                            name: "Falafel Bowl",
                            description: "Crispy falafel with tahini sauce and vegetables",
                            calories: 460,
                            protein: 16,
                            carbs: 52,
                            fat: 24,
                            fiber: 10,
                            prepTime: 20,
                            cookTime: 15,
                            ingredients: ["Falafel", "Quinoa", "Cucumber", "Tomatoes", "Tahini", "Lemon", "Herbs"],
                            instructions: ["Cook falafel", "Prepare quinoa", "Chop vegetables", "Make tahini sauce", "Assemble bowl"],
                            tags: ["vegetarian", "protein-rich", "Middle-Eastern"]
                        ),
                        dinner: Meal(
                            id: "med-d6",
                            name: "Seafood Paella",
                            description: "Spanish rice dish with mixed seafood",
                            calories: 480,
                            protein: 28,
                            carbs: 54,
                            fat: 16,
                            fiber: 4,
                            prepTime: 20,
                            cookTime: 35,
                            ingredients: ["Rice", "Shrimp", "Mussels", "Calamari", "Saffron", "Peppers", "Peas", "Olive oil"],
                            instructions: ["Sauté vegetables", "Add rice and saffron", "Add broth gradually", "Add seafood last 10 min"],
                            tags: ["seafood", "one-pot", "Spanish"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s6",
                                name: "Stuffed Dates",
                                description: "Dates stuffed with almonds and orange zest",
                                calories: 150,
                                protein: 3,
                                carbs: 28,
                                fat: 5,
                                fiber: 3,
                                prepTime: 10,
                                cookTime: 0,
                                ingredients: ["Medjool dates", "Almonds", "Orange zest", "Cinnamon"],
                                instructions: ["Pit dates", "Stuff with almonds", "Sprinkle with zest"],
                                tags: ["vegan", "sweet", "energy-boost"]
                            )
                        ]
                    ),
                    DailyMealPlan(
                        id: "med-w1-sunday",
                        dayName: "Sunday",
                        breakfast: Meal(
                            id: "med-b7",
                            name: "Mediterranean Pancakes",
                            description: "Whole wheat pancakes with honey and nuts",
                            calories: 380,
                            protein: 12,
                            carbs: 54,
                            fat: 14,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 15,
                            ingredients: ["Whole wheat flour", "Eggs", "Milk", "Honey", "Walnuts", "Cinnamon"],
                            instructions: ["Mix batter", "Cook on griddle", "Top with honey and nuts"],
                            tags: ["vegetarian", "weekend-treat", "whole-grain"]
                        ),
                        lunch: Meal(
                            id: "med-l7",
                            name: "Mezze Platter",
                            description: "Assorted Mediterranean appetizers",
                            calories: 420,
                            protein: 14,
                            carbs: 44,
                            fat: 22,
                            fiber: 8,
                            prepTime: 20,
                            cookTime: 0,
                            ingredients: ["Hummus", "Baba ganoush", "Olives", "Feta", "Pita", "Vegetables"],
                            instructions: ["Arrange all items on platter", "Serve with pita"],
                            tags: ["vegetarian", "sharing", "variety"]
                        ),
                        dinner: Meal(
                            id: "med-d7",
                            name: "Roasted Chicken with Herbs",
                            description: "Whole roasted chicken with lemon and herbs",
                            calories: 420,
                            protein: 36,
                            carbs: 24,
                            fat: 18,
                            fiber: 4,
                            prepTime: 15,
                            cookTime: 60,
                            ingredients: ["Whole chicken", "Lemons", "Rosemary", "Thyme", "Garlic", "Potatoes", "Olive oil"],
                            instructions: ["Season chicken", "Stuff with lemon", "Roast with potatoes", "Rest before carving"],
                            tags: ["protein-rich", "Sunday-dinner", "family-style"]
                        ),
                        snacks: [
                            Meal(
                                id: "med-s7",
                                name: "Yogurt with Honey",
                                description: "Greek yogurt drizzled with honey",
                                calories: 120,
                                protein: 12,
                                carbs: 16,
                                fat: 2,
                                fiber: 0,
                                prepTime: 2,
                                cookTime: 0,
                                ingredients: ["Greek yogurt", "Honey", "Cinnamon"],
                                instructions: ["Spoon yogurt", "Drizzle honey", "Dust with cinnamon"],
                                tags: ["vegetarian", "simple", "protein-rich"]
                            )
                        ]
                    )
                ]
            ),
            // Week 2-4 would follow similar pattern with different meals
            generateMediterraneanWeek2(),
            generateMediterraneanWeek3(),
            generateMediterraneanWeek4()
        ]
    }

    private func generateMediterraneanWeek2() -> WeeklyMealPlan {
        // Simplified for brevity - would contain full 7 days
        WeeklyMealPlan(
            id: "med-week-2",
            weekNumber: 2,
            days: generateWeek2Days()
        )
    }

    private func generateMediterraneanWeek3() -> WeeklyMealPlan {
        WeeklyMealPlan(
            id: "med-week-3",
            weekNumber: 3,
            days: generateWeek3Days()
        )
    }

    private func generateMediterraneanWeek4() -> WeeklyMealPlan {
        WeeklyMealPlan(
            id: "med-week-4",
            weekNumber: 4,
            days: generateWeek4Days()
        )
    }

    // MARK: - Keto Diet Plan
    func ketoPlan() -> MealPlanType {
        MealPlanType(
            id: "keto",
            name: "Keto",
            description: "High-fat, low-carb diet for ketosis and weight loss",
            benefits: [
                "Rapid weight loss",
                "Improved mental clarity",
                "Reduced appetite",
                "Better blood sugar control"
            ],
            restrictions: [
                "Less than 20g carbs daily",
                "No grains or sugar",
                "Limited fruits",
                "No starchy vegetables"
            ],
            monthlyPlans: generateKetoMonth()
        )
    }

    private func generateKetoMonth() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "keto-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "keto-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "keto-b1",
                            name: "Bacon and Eggs with Avocado",
                            description: "Classic keto breakfast with healthy fats",
                            calories: 480,
                            protein: 24,
                            carbs: 6,
                            fat: 42,
                            fiber: 4,
                            prepTime: 5,
                            cookTime: 10,
                            ingredients: ["3 eggs", "3 strips bacon", "1/2 avocado", "Butter", "Salt", "Pepper"],
                            instructions: ["Cook bacon until crispy", "Fry eggs in bacon fat", "Serve with sliced avocado"],
                            tags: ["keto", "high-fat", "low-carb"]
                        ),
                        lunch: Meal(
                            id: "keto-l1",
                            name: "Chicken Caesar Salad (No Croutons)",
                            description: "Crisp romaine with grilled chicken and parmesan",
                            calories: 520,
                            protein: 42,
                            carbs: 8,
                            fat: 36,
                            fiber: 3,
                            prepTime: 10,
                            cookTime: 15,
                            ingredients: ["Chicken breast", "Romaine lettuce", "Parmesan", "Caesar dressing", "Anchovies"],
                            instructions: ["Grill chicken", "Chop romaine", "Toss with dressing", "Top with chicken and parmesan"],
                            tags: ["keto", "high-protein", "salad"]
                        ),
                        dinner: Meal(
                            id: "keto-d1",
                            name: "Ribeye Steak with Butter",
                            description: "Juicy ribeye with herb butter and asparagus",
                            calories: 680,
                            protein: 48,
                            carbs: 6,
                            fat: 52,
                            fiber: 3,
                            prepTime: 10,
                            cookTime: 20,
                            ingredients: ["10 oz ribeye", "Butter", "Garlic", "Herbs", "Asparagus", "Olive oil"],
                            instructions: ["Season steak", "Sear in hot pan", "Make herb butter", "Roast asparagus", "Rest steak before serving"],
                            tags: ["keto", "carnivore", "high-fat"]
                        ),
                        snacks: [
                            Meal(
                                id: "keto-s1",
                                name: "Macadamia Nuts",
                                description: "Rich, buttery nuts perfect for keto",
                                calories: 200,
                                protein: 2,
                                carbs: 4,
                                fat: 21,
                                fiber: 2,
                                prepTime: 0,
                                cookTime: 0,
                                ingredients: ["1 oz macadamia nuts"],
                                instructions: ["Portion and enjoy"],
                                tags: ["keto", "portable", "high-fat"]
                            )
                        ]
                    ),
                    // Continue with more keto days...
                ]
            ),
            // More keto weeks...
        ]
    }

    // MARK: - Intermittent Fasting Plan
    func intermittentFastingPlan() -> MealPlanType {
        MealPlanType(
            id: "intermittent-fasting",
            name: "Intermittent Fasting (16:8)",
            description: "Time-restricted eating with 16-hour fast and 8-hour eating window",
            benefits: [
                "Weight loss",
                "Improved insulin sensitivity",
                "Cellular repair",
                "Mental clarity",
                "Longevity benefits"
            ],
            restrictions: [
                "No calories during fasting window",
                "Eating window: 12pm-8pm",
                "Stay hydrated during fast"
            ],
            monthlyPlans: generateIntermittentFastingMonth()
        )
    }

    private func generateIntermittentFastingMonth() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "if-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "if-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "if-b1",
                            name: "Black Coffee/Water (Fasting)",
                            description: "Fasting period - only water, black coffee, or tea",
                            calories: 0,
                            protein: 0,
                            carbs: 0,
                            fat: 0,
                            fiber: 0,
                            prepTime: 2,
                            cookTime: 0,
                            ingredients: ["Black coffee", "Water", "Herbal tea (optional)"],
                            instructions: ["Drink water throughout morning", "Black coffee allowed", "No calories until noon"],
                            tags: ["fasting", "zero-calorie", "IF"]
                        ),
                        lunch: Meal(
                            id: "if-l1",
                            name: "Breaking Fast: Protein Bowl",
                            description: "Nutrient-dense first meal with protein and vegetables",
                            calories: 580,
                            protein: 42,
                            carbs: 38,
                            fat: 26,
                            fiber: 10,
                            prepTime: 15,
                            cookTime: 20,
                            ingredients: ["Grilled chicken", "Quinoa", "Broccoli", "Sweet potato", "Tahini", "Spinach"],
                            instructions: ["Cook quinoa", "Grill chicken", "Steam vegetables", "Assemble bowl", "Drizzle with tahini"],
                            tags: ["IF", "breaking-fast", "balanced"]
                        ),
                        dinner: Meal(
                            id: "if-d1",
                            name: "Salmon with Cauliflower Rice",
                            description: "Last meal before fast - high protein and fiber",
                            calories: 520,
                            protein: 38,
                            carbs: 24,
                            fat: 30,
                            fiber: 8,
                            prepTime: 10,
                            cookTime: 20,
                            ingredients: ["Salmon fillet", "Cauliflower rice", "Brussels sprouts", "Olive oil", "Lemon"],
                            instructions: ["Bake salmon", "Sauté cauliflower rice", "Roast Brussels sprouts", "Finish by 8pm"],
                            tags: ["IF", "last-meal", "omega-3"]
                        ),
                        snacks: [
                            Meal(
                                id: "if-s1",
                                name: "Protein Smoothie (3pm)",
                                description: "Mid-eating window protein boost",
                                calories: 280,
                                protein: 25,
                                carbs: 28,
                                fat: 10,
                                fiber: 5,
                                prepTime: 5,
                                cookTime: 0,
                                ingredients: ["Protein powder", "Banana", "Almond butter", "Almond milk", "Spinach"],
                                instructions: ["Blend all ingredients", "Consume between meals"],
                                tags: ["IF", "protein", "smoothie"]
                            )
                        ]
                    ),
                    // Continue with more IF days...
                ]
            ),
            // More IF weeks...
        ]
    }

    // MARK: - Family Friendly Plan
    func familyFriendlyPlan() -> MealPlanType {
        MealPlanType(
            id: "family-friendly",
            name: "Family Friendly",
            description: "Kid-approved meals that are healthy and delicious for the whole family",
            benefits: [
                "Appeals to all ages",
                "Hidden vegetables",
                "Balanced nutrition",
                "Easy to prepare",
                "Budget-friendly"
            ],
            restrictions: [
                "No overly spicy foods",
                "Familiar flavors",
                "Fun presentations"
            ],
            monthlyPlans: generateFamilyFriendlyMonth()
        )
    }

    private func generateFamilyFriendlyMonth() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "family-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "family-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "family-b1",
                            name: "Banana Pancakes",
                            description: "Fluffy pancakes with fresh banana slices",
                            calories: 380,
                            protein: 12,
                            carbs: 62,
                            fat: 10,
                            fiber: 4,
                            prepTime: 10,
                            cookTime: 15,
                            ingredients: ["Flour", "Eggs", "Milk", "Bananas", "Maple syrup", "Butter"],
                            instructions: ["Mix batter", "Cook on griddle", "Top with banana slices", "Serve with syrup"],
                            tags: ["family", "kid-friendly", "breakfast"]
                        ),
                        lunch: Meal(
                            id: "family-l1",
                            name: "Turkey and Cheese Wraps",
                            description: "Whole wheat wraps with turkey, cheese, and veggies",
                            calories: 420,
                            protein: 28,
                            carbs: 38,
                            fat: 18,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 0,
                            ingredients: ["Whole wheat tortillas", "Turkey", "Cheese", "Lettuce", "Tomato", "Ranch dressing"],
                            instructions: ["Layer ingredients", "Roll tightly", "Cut in half", "Serve with fruit"],
                            tags: ["family", "no-cook", "lunch-box"]
                        ),
                        dinner: Meal(
                            id: "family-d1",
                            name: "Spaghetti with Hidden Veggie Sauce",
                            description: "Classic spaghetti with vegetables blended in sauce",
                            calories: 480,
                            protein: 22,
                            carbs: 68,
                            fat: 14,
                            fiber: 8,
                            prepTime: 15,
                            cookTime: 25,
                            ingredients: ["Spaghetti", "Ground beef", "Tomato sauce", "Carrots", "Zucchini", "Bell peppers", "Parmesan"],
                            instructions: ["Brown meat", "Blend vegetables into sauce", "Cook pasta", "Combine and top with cheese"],
                            tags: ["family", "hidden-veggies", "comfort-food"]
                        ),
                        snacks: [
                            Meal(
                                id: "family-s1",
                                name: "Apple Slices with Peanut Butter",
                                description: "Classic kid-friendly snack",
                                calories: 180,
                                protein: 7,
                                carbs: 20,
                                fat: 10,
                                fiber: 4,
                                prepTime: 5,
                                cookTime: 0,
                                ingredients: ["Apple", "Peanut butter", "Cinnamon"],
                                instructions: ["Slice apple", "Serve with peanut butter for dipping"],
                                tags: ["family", "healthy", "quick"]
                            )
                        ]
                    ),
                    // Continue with more family-friendly days...
                ]
            ),
            // More family weeks...
        ]
    }

    // MARK: - Vegetarian Plan
    func vegetarianPlan() -> MealPlanType {
        MealPlanType(
            id: "vegetarian",
            name: "Vegetarian",
            description: "Plant-based meals rich in protein and nutrients",
            benefits: [
                "High fiber intake",
                "Lower carbon footprint",
                "Heart healthy",
                "Rich in antioxidants",
                "Diverse flavors"
            ],
            restrictions: [
                "No meat or fish",
                "Focus on protein sources",
                "B12 supplementation recommended"
            ],
            monthlyPlans: generateVegetarianMonth()
        )
    }

    private func generateVegetarianMonth() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "veg-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "veg-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "veg-b1",
                            name: "Tofu Scramble with Vegetables",
                            description: "Protein-rich scrambled tofu with colorful veggies",
                            calories: 340,
                            protein: 20,
                            carbs: 28,
                            fat: 18,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 15,
                            ingredients: ["Firm tofu", "Bell peppers", "Onions", "Spinach", "Turmeric", "Nutritional yeast"],
                            instructions: ["Crumble tofu", "Sauté vegetables", "Add tofu and spices", "Cook until heated through"],
                            tags: ["vegetarian", "vegan", "high-protein"]
                        ),
                        lunch: Meal(
                            id: "veg-l1",
                            name: "Buddha Bowl",
                            description: "Colorful bowl with quinoa, vegetables, and tahini",
                            calories: 480,
                            protein: 18,
                            carbs: 62,
                            fat: 20,
                            fiber: 12,
                            prepTime: 20,
                            cookTime: 25,
                            ingredients: ["Quinoa", "Chickpeas", "Sweet potato", "Kale", "Avocado", "Tahini", "Lemon"],
                            instructions: ["Cook quinoa", "Roast sweet potato and chickpeas", "Massage kale", "Assemble bowl", "Drizzle tahini"],
                            tags: ["vegetarian", "vegan", "bowl"]
                        ),
                        dinner: Meal(
                            id: "veg-d1",
                            name: "Eggplant Parmesan",
                            description: "Crispy breaded eggplant with marinara and cheese",
                            calories: 420,
                            protein: 18,
                            carbs: 48,
                            fat: 20,
                            fiber: 8,
                            prepTime: 20,
                            cookTime: 40,
                            ingredients: ["Eggplant", "Breadcrumbs", "Eggs", "Mozzarella", "Parmesan", "Marinara sauce"],
                            instructions: ["Slice and bread eggplant", "Bake until crispy", "Layer with sauce and cheese", "Bake until bubbly"],
                            tags: ["vegetarian", "Italian", "comfort-food"]
                        ),
                        snacks: [
                            Meal(
                                id: "veg-s1",
                                name: "Trail Mix",
                                description: "Nuts, seeds, and dried fruit mix",
                                calories: 160,
                                protein: 5,
                                carbs: 18,
                                fat: 10,
                                fiber: 3,
                                prepTime: 2,
                                cookTime: 0,
                                ingredients: ["Almonds", "Cashews", "Pumpkin seeds", "Raisins", "Dark chocolate chips"],
                                instructions: ["Mix ingredients", "Portion into servings"],
                                tags: ["vegetarian", "portable", "energy"]
                            )
                        ]
                    ),
                    // Continue with more vegetarian days...
                ]
            ),
            // More vegetarian weeks...
        ]
    }

    // MARK: - Helper Functions for Additional Weeks
    private func generateWeek2Days() -> [DailyMealPlan] {
        // Return 7 days of meals for week 2
        // Simplified for brevity
        return []
    }

    private func generateWeek3Days() -> [DailyMealPlan] {
        // Return 7 days of meals for week 3
        return []
    }

    private func generateWeek4Days() -> [DailyMealPlan] {
        // Return 7 days of meals for week 4
        return []
    }
}

// MARK: - Meal Plan Manager
class MealPlanManager: ObservableObject {
    @Published var selectedPlanType: MealPlanType?
    @Published var currentWeek: Int = 1
    @Published var favoriteMeals: Set<String> = []
    @Published var shoppingList: [String] = []

    private let mealData = MealPlanData.shared

    func selectPlan(_ planId: String) {
        selectedPlanType = mealData.allMealPlans.first { $0.id == planId }
    }

    func getCurrentWeekPlan() -> WeeklyMealPlan? {
        guard let plan = selectedPlanType,
              currentWeek > 0 && currentWeek <= plan.monthlyPlans.count else {
            return nil
        }
        return plan.monthlyPlans[currentWeek - 1]
    }

    func generateShoppingList(for week: WeeklyMealPlan) {
        shoppingList.removeAll()
        var ingredients: [String: Int] = [:]

        for day in week.days {
            addIngredientsToList(from: day.breakfast, to: &ingredients)
            addIngredientsToList(from: day.lunch, to: &ingredients)
            addIngredientsToList(from: day.dinner, to: &ingredients)
            for snack in day.snacks {
                addIngredientsToList(from: snack, to: &ingredients)
            }
        }

        shoppingList = ingredients.keys.sorted()
    }

    private func addIngredientsToList(from meal: Meal, to list: inout [String: Int]) {
        for ingredient in meal.ingredients {
            list[ingredient, default: 0] += 1
        }
    }

    func toggleFavorite(_ mealId: String) {
        if favoriteMeals.contains(mealId) {
            favoriteMeals.remove(mealId)
        } else {
            favoriteMeals.insert(mealId)
        }
    }
}