package com.mlhealth.app.data

import java.util.UUID

// Meal Plan Models
data class MealPlanType(
    val id: String,
    val name: String,
    val description: String,
    val benefits: List<String>,
    val restrictions: List<String>,
    val monthlyPlans: List<WeeklyMealPlan>
)

data class WeeklyMealPlan(
    val id: String,
    val weekNumber: Int,
    val days: List<DailyMealPlan>
)

data class DailyMealPlan(
    val id: String,
    val dayName: String,
    val breakfast: Meal,
    val lunch: Meal,
    val dinner: Meal,
    val snacks: List<Meal>
)

data class Meal(
    val id: String,
    val name: String,
    val description: String,
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,
    val prepTime: Int, // minutes
    val cookTime: Int, // minutes
    val ingredients: List<String>,
    val instructions: List<String>,
    val tags: List<String>
)

// Meal Plan Data Provider
object MealPlanData {
    val allMealPlans: List<MealPlanType> by lazy {
        listOf(
            mediterraneanPlan(),
            ketoPlan(),
            intermittentFastingPlan(),
            familyFriendlyPlan(),
            vegetarianPlan()
        )
    }

    // Mediterranean Diet Plan
    private fun mediterraneanPlan(): MealPlanType {
        return MealPlanType(
            id = "mediterranean",
            name = "Mediterranean",
            description = "Heart-healthy diet rich in fruits, vegetables, whole grains, and olive oil",
            benefits = listOf(
                "Reduces heart disease risk",
                "Supports brain health",
                "Anti-inflammatory",
                "Promotes longevity"
            ),
            restrictions = listOf(
                "Limited red meat",
                "Moderate dairy",
                "No processed foods"
            ),
            monthlyPlans = generateMediterraneanMonth()
        )
    }

    private fun generateMediterraneanMonth(): List<WeeklyMealPlan> {
        return listOf(
            // Week 1
            WeeklyMealPlan(
                id = "med-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "med-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "med-b1",
                            name = "Greek Yogurt Parfait",
                            description = "Creamy Greek yogurt layered with honey, walnuts, and fresh berries",
                            calories = 350,
                            protein = 18.0,
                            carbs = 42.0,
                            fat = 12.0,
                            fiber = 5.0,
                            prepTime = 5,
                            cookTime = 0,
                            ingredients = listOf(
                                "1 cup Greek yogurt",
                                "2 tbsp honey",
                                "1/4 cup walnuts",
                                "1/2 cup mixed berries",
                                "1 tbsp chia seeds"
                            ),
                            instructions = listOf(
                                "Layer yogurt in a bowl",
                                "Drizzle with honey",
                                "Top with berries, walnuts, and chia seeds"
                            ),
                            tags = listOf("vegetarian", "high-protein", "quick")
                        ),
                        lunch = Meal(
                            id = "med-l1",
                            name = "Mediterranean Quinoa Bowl",
                            description = "Fluffy quinoa topped with roasted vegetables, feta, and olive tapenade",
                            calories = 480,
                            protein = 16.0,
                            carbs = 58.0,
                            fat = 22.0,
                            fiber = 9.0,
                            prepTime = 15,
                            cookTime = 25,
                            ingredients = listOf(
                                "1 cup quinoa",
                                "1 zucchini",
                                "1 bell pepper",
                                "1/4 cup feta",
                                "2 tbsp olive tapenade",
                                "Cherry tomatoes",
                                "Olive oil"
                            ),
                            instructions = listOf(
                                "Cook quinoa",
                                "Roast vegetables with olive oil",
                                "Assemble bowl with quinoa base",
                                "Top with vegetables, feta, and tapenade"
                            ),
                            tags = listOf("vegetarian", "meal-prep", "fiber-rich")
                        ),
                        dinner = Meal(
                            id = "med-d1",
                            name = "Grilled Salmon with Lemon Herbs",
                            description = "Fresh salmon fillet with Mediterranean herbs and roasted asparagus",
                            calories = 420,
                            protein = 34.0,
                            carbs = 18.0,
                            fat = 24.0,
                            fiber = 6.0,
                            prepTime = 10,
                            cookTime = 20,
                            ingredients = listOf(
                                "6 oz salmon fillet",
                                "1 bunch asparagus",
                                "2 lemons",
                                "Fresh dill",
                                "Garlic",
                                "Olive oil"
                            ),
                            instructions = listOf(
                                "Season salmon with herbs",
                                "Grill for 12-15 minutes",
                                "Roast asparagus",
                                "Serve with lemon wedges"
                            ),
                            tags = listOf("omega-3", "high-protein", "gluten-free")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "med-s1",
                                name = "Hummus with Vegetables",
                                description = "Classic hummus with fresh cut vegetables",
                                calories = 150,
                                protein = 6.0,
                                carbs = 18.0,
                                fat = 8.0,
                                fiber = 5.0,
                                prepTime = 5,
                                cookTime = 0,
                                ingredients = listOf(
                                    "1/2 cup hummus",
                                    "Carrot sticks",
                                    "Cucumber",
                                    "Bell pepper"
                                ),
                                instructions = listOf(
                                    "Cut vegetables",
                                    "Serve with hummus"
                                ),
                                tags = listOf("vegan", "fiber-rich", "quick")
                            )
                        )
                    ),
                    // Continue with Tuesday through Sunday
                    generateMediterraneanDay("Tuesday", 2),
                    generateMediterraneanDay("Wednesday", 3),
                    generateMediterraneanDay("Thursday", 4),
                    generateMediterraneanDay("Friday", 5),
                    generateMediterraneanDay("Saturday", 6),
                    generateMediterraneanDay("Sunday", 7)
                )
            ),
            // Week 2-4
            generateWeek("med-week-2", 2, "mediterranean"),
            generateWeek("med-week-3", 3, "mediterranean"),
            generateWeek("med-week-4", 4, "mediterranean")
        )
    }

    // Keto Diet Plan
    private fun ketoPlan(): MealPlanType {
        return MealPlanType(
            id = "keto",
            name = "Keto",
            description = "High-fat, low-carb diet for ketosis and weight loss",
            benefits = listOf(
                "Rapid weight loss",
                "Improved mental clarity",
                "Reduced appetite",
                "Better blood sugar control"
            ),
            restrictions = listOf(
                "Less than 20g carbs daily",
                "No grains or sugar",
                "Limited fruits",
                "No starchy vegetables"
            ),
            monthlyPlans = generateKetoMonth()
        )
    }

    private fun generateKetoMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "keto-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "keto-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "keto-b1",
                            name = "Bacon and Eggs with Avocado",
                            description = "Classic keto breakfast with healthy fats",
                            calories = 480,
                            protein = 24.0,
                            carbs = 6.0,
                            fat = 42.0,
                            fiber = 4.0,
                            prepTime = 5,
                            cookTime = 10,
                            ingredients = listOf(
                                "3 eggs",
                                "3 strips bacon",
                                "1/2 avocado",
                                "Butter",
                                "Salt",
                                "Pepper"
                            ),
                            instructions = listOf(
                                "Cook bacon until crispy",
                                "Fry eggs in bacon fat",
                                "Serve with sliced avocado"
                            ),
                            tags = listOf("keto", "high-fat", "low-carb")
                        ),
                        lunch = Meal(
                            id = "keto-l1",
                            name = "Chicken Caesar Salad (No Croutons)",
                            description = "Crisp romaine with grilled chicken and parmesan",
                            calories = 520,
                            protein = 42.0,
                            carbs = 8.0,
                            fat = 36.0,
                            fiber = 3.0,
                            prepTime = 10,
                            cookTime = 15,
                            ingredients = listOf(
                                "Chicken breast",
                                "Romaine lettuce",
                                "Parmesan",
                                "Caesar dressing",
                                "Anchovies"
                            ),
                            instructions = listOf(
                                "Grill chicken",
                                "Chop romaine",
                                "Toss with dressing",
                                "Top with chicken and parmesan"
                            ),
                            tags = listOf("keto", "high-protein", "salad")
                        ),
                        dinner = Meal(
                            id = "keto-d1",
                            name = "Ribeye Steak with Butter",
                            description = "Juicy ribeye with herb butter and asparagus",
                            calories = 680,
                            protein = 48.0,
                            carbs = 6.0,
                            fat = 52.0,
                            fiber = 3.0,
                            prepTime = 10,
                            cookTime = 20,
                            ingredients = listOf(
                                "10 oz ribeye",
                                "Butter",
                                "Garlic",
                                "Herbs",
                                "Asparagus",
                                "Olive oil"
                            ),
                            instructions = listOf(
                                "Season steak",
                                "Sear in hot pan",
                                "Make herb butter",
                                "Roast asparagus",
                                "Rest steak before serving"
                            ),
                            tags = listOf("keto", "carnivore", "high-fat")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "keto-s1",
                                name = "Macadamia Nuts",
                                description = "Rich, buttery nuts perfect for keto",
                                calories = 200,
                                protein = 2.0,
                                carbs = 4.0,
                                fat = 21.0,
                                fiber = 2.0,
                                prepTime = 0,
                                cookTime = 0,
                                ingredients = listOf("1 oz macadamia nuts"),
                                instructions = listOf("Portion and enjoy"),
                                tags = listOf("keto", "portable", "high-fat")
                            )
                        )
                    ),
                    generateKetoDay("Tuesday", 2),
                    generateKetoDay("Wednesday", 3),
                    generateKetoDay("Thursday", 4),
                    generateKetoDay("Friday", 5),
                    generateKetoDay("Saturday", 6),
                    generateKetoDay("Sunday", 7)
                )
            ),
            generateWeek("keto-week-2", 2, "keto"),
            generateWeek("keto-week-3", 3, "keto"),
            generateWeek("keto-week-4", 4, "keto")
        )
    }

    // Intermittent Fasting Plan
    private fun intermittentFastingPlan(): MealPlanType {
        return MealPlanType(
            id = "intermittent-fasting",
            name = "Intermittent Fasting (16:8)",
            description = "Time-restricted eating with 16-hour fast and 8-hour eating window",
            benefits = listOf(
                "Weight loss",
                "Improved insulin sensitivity",
                "Cellular repair",
                "Mental clarity",
                "Longevity benefits"
            ),
            restrictions = listOf(
                "No calories during fasting window",
                "Eating window: 12pm-8pm",
                "Stay hydrated during fast"
            ),
            monthlyPlans = generateIntermittentFastingMonth()
        )
    }

    private fun generateIntermittentFastingMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "if-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "if-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "if-b1",
                            name = "Black Coffee/Water (Fasting)",
                            description = "Fasting period - only water, black coffee, or tea",
                            calories = 0,
                            protein = 0.0,
                            carbs = 0.0,
                            fat = 0.0,
                            fiber = 0.0,
                            prepTime = 2,
                            cookTime = 0,
                            ingredients = listOf(
                                "Black coffee",
                                "Water",
                                "Herbal tea (optional)"
                            ),
                            instructions = listOf(
                                "Drink water throughout morning",
                                "Black coffee allowed",
                                "No calories until noon"
                            ),
                            tags = listOf("fasting", "zero-calorie", "IF")
                        ),
                        lunch = Meal(
                            id = "if-l1",
                            name = "Breaking Fast: Protein Bowl",
                            description = "Nutrient-dense first meal with protein and vegetables",
                            calories = 580,
                            protein = 42.0,
                            carbs = 38.0,
                            fat = 26.0,
                            fiber = 10.0,
                            prepTime = 15,
                            cookTime = 20,
                            ingredients = listOf(
                                "Grilled chicken",
                                "Quinoa",
                                "Broccoli",
                                "Sweet potato",
                                "Tahini",
                                "Spinach"
                            ),
                            instructions = listOf(
                                "Cook quinoa",
                                "Grill chicken",
                                "Steam vegetables",
                                "Assemble bowl",
                                "Drizzle with tahini"
                            ),
                            tags = listOf("IF", "breaking-fast", "balanced")
                        ),
                        dinner = Meal(
                            id = "if-d1",
                            name = "Salmon with Cauliflower Rice",
                            description = "Last meal before fast - high protein and fiber",
                            calories = 520,
                            protein = 38.0,
                            carbs = 24.0,
                            fat = 30.0,
                            fiber = 8.0,
                            prepTime = 10,
                            cookTime = 20,
                            ingredients = listOf(
                                "Salmon fillet",
                                "Cauliflower rice",
                                "Brussels sprouts",
                                "Olive oil",
                                "Lemon"
                            ),
                            instructions = listOf(
                                "Bake salmon",
                                "Sauté cauliflower rice",
                                "Roast Brussels sprouts",
                                "Finish by 8pm"
                            ),
                            tags = listOf("IF", "last-meal", "omega-3")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "if-s1",
                                name = "Protein Smoothie (3pm)",
                                description = "Mid-eating window protein boost",
                                calories = 280,
                                protein = 25.0,
                                carbs = 28.0,
                                fat = 10.0,
                                fiber = 5.0,
                                prepTime = 5,
                                cookTime = 0,
                                ingredients = listOf(
                                    "Protein powder",
                                    "Banana",
                                    "Almond butter",
                                    "Almond milk",
                                    "Spinach"
                                ),
                                instructions = listOf(
                                    "Blend all ingredients",
                                    "Consume between meals"
                                ),
                                tags = listOf("IF", "protein", "smoothie")
                            )
                        )
                    ),
                    generateIFDay("Tuesday", 2),
                    generateIFDay("Wednesday", 3),
                    generateIFDay("Thursday", 4),
                    generateIFDay("Friday", 5),
                    generateIFDay("Saturday", 6),
                    generateIFDay("Sunday", 7)
                )
            ),
            generateWeek("if-week-2", 2, "intermittent-fasting"),
            generateWeek("if-week-3", 3, "intermittent-fasting"),
            generateWeek("if-week-4", 4, "intermittent-fasting")
        )
    }

    // Family Friendly Plan
    private fun familyFriendlyPlan(): MealPlanType {
        return MealPlanType(
            id = "family-friendly",
            name = "Family Friendly",
            description = "Kid-approved meals that are healthy and delicious for the whole family",
            benefits = listOf(
                "Appeals to all ages",
                "Hidden vegetables",
                "Balanced nutrition",
                "Easy to prepare",
                "Budget-friendly"
            ),
            restrictions = listOf(
                "No overly spicy foods",
                "Familiar flavors",
                "Fun presentations"
            ),
            monthlyPlans = generateFamilyMonth()
        )
    }

    private fun generateFamilyMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "family-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "family-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "family-b1",
                            name = "Banana Pancakes",
                            description = "Fluffy pancakes with fresh banana slices",
                            calories = 380,
                            protein = 12.0,
                            carbs = 62.0,
                            fat = 10.0,
                            fiber = 4.0,
                            prepTime = 10,
                            cookTime = 15,
                            ingredients = listOf(
                                "Flour",
                                "Eggs",
                                "Milk",
                                "Bananas",
                                "Maple syrup",
                                "Butter"
                            ),
                            instructions = listOf(
                                "Mix batter",
                                "Cook on griddle",
                                "Top with banana slices",
                                "Serve with syrup"
                            ),
                            tags = listOf("family", "kid-friendly", "breakfast")
                        ),
                        lunch = Meal(
                            id = "family-l1",
                            name = "Turkey and Cheese Wraps",
                            description = "Whole wheat wraps with turkey, cheese, and veggies",
                            calories = 420,
                            protein = 28.0,
                            carbs = 38.0,
                            fat = 18.0,
                            fiber = 6.0,
                            prepTime = 10,
                            cookTime = 0,
                            ingredients = listOf(
                                "Whole wheat tortillas",
                                "Turkey",
                                "Cheese",
                                "Lettuce",
                                "Tomato",
                                "Ranch dressing"
                            ),
                            instructions = listOf(
                                "Layer ingredients",
                                "Roll tightly",
                                "Cut in half",
                                "Serve with fruit"
                            ),
                            tags = listOf("family", "no-cook", "lunch-box")
                        ),
                        dinner = Meal(
                            id = "family-d1",
                            name = "Spaghetti with Hidden Veggie Sauce",
                            description = "Classic spaghetti with vegetables blended in sauce",
                            calories = 480,
                            protein = 22.0,
                            carbs = 68.0,
                            fat = 14.0,
                            fiber = 8.0,
                            prepTime = 15,
                            cookTime = 25,
                            ingredients = listOf(
                                "Spaghetti",
                                "Ground beef",
                                "Tomato sauce",
                                "Carrots",
                                "Zucchini",
                                "Bell peppers",
                                "Parmesan"
                            ),
                            instructions = listOf(
                                "Brown meat",
                                "Blend vegetables into sauce",
                                "Cook pasta",
                                "Combine and top with cheese"
                            ),
                            tags = listOf("family", "hidden-veggies", "comfort-food")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "family-s1",
                                name = "Apple Slices with Peanut Butter",
                                description = "Classic kid-friendly snack",
                                calories = 180,
                                protein = 7.0,
                                carbs = 20.0,
                                fat = 10.0,
                                fiber = 4.0,
                                prepTime = 5,
                                cookTime = 0,
                                ingredients = listOf(
                                    "Apple",
                                    "Peanut butter",
                                    "Cinnamon"
                                ),
                                instructions = listOf(
                                    "Slice apple",
                                    "Serve with peanut butter for dipping"
                                ),
                                tags = listOf("family", "healthy", "quick")
                            )
                        )
                    ),
                    generateFamilyDay("Tuesday", 2),
                    generateFamilyDay("Wednesday", 3),
                    generateFamilyDay("Thursday", 4),
                    generateFamilyDay("Friday", 5),
                    generateFamilyDay("Saturday", 6),
                    generateFamilyDay("Sunday", 7)
                )
            ),
            generateWeek("family-week-2", 2, "family-friendly"),
            generateWeek("family-week-3", 3, "family-friendly"),
            generateWeek("family-week-4", 4, "family-friendly")
        )
    }

    // Vegetarian Plan
    private fun vegetarianPlan(): MealPlanType {
        return MealPlanType(
            id = "vegetarian",
            name = "Vegetarian",
            description = "Plant-based meals rich in protein and nutrients",
            benefits = listOf(
                "High fiber intake",
                "Lower carbon footprint",
                "Heart healthy",
                "Rich in antioxidants",
                "Diverse flavors"
            ),
            restrictions = listOf(
                "No meat or fish",
                "Focus on protein sources",
                "B12 supplementation recommended"
            ),
            monthlyPlans = generateVegetarianMonth()
        )
    }

    private fun generateVegetarianMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "veg-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "veg-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "veg-b1",
                            name = "Tofu Scramble with Vegetables",
                            description = "Protein-rich scrambled tofu with colorful veggies",
                            calories = 340,
                            protein = 20.0,
                            carbs = 28.0,
                            fat = 18.0,
                            fiber = 6.0,
                            prepTime = 10,
                            cookTime = 15,
                            ingredients = listOf(
                                "Firm tofu",
                                "Bell peppers",
                                "Onions",
                                "Spinach",
                                "Turmeric",
                                "Nutritional yeast"
                            ),
                            instructions = listOf(
                                "Crumble tofu",
                                "Sauté vegetables",
                                "Add tofu and spices",
                                "Cook until heated through"
                            ),
                            tags = listOf("vegetarian", "vegan", "high-protein")
                        ),
                        lunch = Meal(
                            id = "veg-l1",
                            name = "Buddha Bowl",
                            description = "Colorful bowl with quinoa, vegetables, and tahini",
                            calories = 480,
                            protein = 18.0,
                            carbs = 62.0,
                            fat = 20.0,
                            fiber = 12.0,
                            prepTime = 20,
                            cookTime = 25,
                            ingredients = listOf(
                                "Quinoa",
                                "Chickpeas",
                                "Sweet potato",
                                "Kale",
                                "Avocado",
                                "Tahini",
                                "Lemon"
                            ),
                            instructions = listOf(
                                "Cook quinoa",
                                "Roast sweet potato and chickpeas",
                                "Massage kale",
                                "Assemble bowl",
                                "Drizzle tahini"
                            ),
                            tags = listOf("vegetarian", "vegan", "bowl")
                        ),
                        dinner = Meal(
                            id = "veg-d1",
                            name = "Eggplant Parmesan",
                            description = "Crispy breaded eggplant with marinara and cheese",
                            calories = 420,
                            protein = 18.0,
                            carbs = 48.0,
                            fat = 20.0,
                            fiber = 8.0,
                            prepTime = 20,
                            cookTime = 40,
                            ingredients = listOf(
                                "Eggplant",
                                "Breadcrumbs",
                                "Eggs",
                                "Mozzarella",
                                "Parmesan",
                                "Marinara sauce"
                            ),
                            instructions = listOf(
                                "Slice and bread eggplant",
                                "Bake until crispy",
                                "Layer with sauce and cheese",
                                "Bake until bubbly"
                            ),
                            tags = listOf("vegetarian", "Italian", "comfort-food")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "veg-s1",
                                name = "Trail Mix",
                                description = "Nuts, seeds, and dried fruit mix",
                                calories = 160,
                                protein = 5.0,
                                carbs = 18.0,
                                fat = 10.0,
                                fiber = 3.0,
                                prepTime = 2,
                                cookTime = 0,
                                ingredients = listOf(
                                    "Almonds",
                                    "Cashews",
                                    "Pumpkin seeds",
                                    "Raisins",
                                    "Dark chocolate chips"
                                ),
                                instructions = listOf(
                                    "Mix ingredients",
                                    "Portion into servings"
                                ),
                                tags = listOf("vegetarian", "portable", "energy")
                            )
                        )
                    ),
                    generateVegetarianDay("Tuesday", 2),
                    generateVegetarianDay("Wednesday", 3),
                    generateVegetarianDay("Thursday", 4),
                    generateVegetarianDay("Friday", 5),
                    generateVegetarianDay("Saturday", 6),
                    generateVegetarianDay("Sunday", 7)
                )
            ),
            generateWeek("veg-week-2", 2, "vegetarian"),
            generateWeek("veg-week-3", 3, "vegetarian"),
            generateWeek("veg-week-4", 4, "vegetarian")
        )
    }

    // Helper functions to generate additional days
    private fun generateMediterraneanDay(dayName: String, dayNum: Int): DailyMealPlan {
        // Simplified - would have unique meals for each day
        return DailyMealPlan(
            id = "med-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Mediterranean Breakfast $dayNum", "mediterranean"),
            lunch = generateMeal("Mediterranean Lunch $dayNum", "mediterranean"),
            dinner = generateMeal("Mediterranean Dinner $dayNum", "mediterranean"),
            snacks = listOf(generateMeal("Mediterranean Snack $dayNum", "mediterranean"))
        )
    }

    private fun generateKetoDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "keto-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Keto Breakfast $dayNum", "keto"),
            lunch = generateMeal("Keto Lunch $dayNum", "keto"),
            dinner = generateMeal("Keto Dinner $dayNum", "keto"),
            snacks = listOf(generateMeal("Keto Snack $dayNum", "keto"))
        )
    }

    private fun generateIFDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "if-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Fasting Period", "fasting"),
            lunch = generateMeal("IF Breaking Fast Meal $dayNum", "intermittent-fasting"),
            dinner = generateMeal("IF Last Meal $dayNum", "intermittent-fasting"),
            snacks = listOf(generateMeal("IF Snack $dayNum", "intermittent-fasting"))
        )
    }

    private fun generateFamilyDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "family-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Family Breakfast $dayNum", "family"),
            lunch = generateMeal("Family Lunch $dayNum", "family"),
            dinner = generateMeal("Family Dinner $dayNum", "family"),
            snacks = listOf(generateMeal("Family Snack $dayNum", "family"))
        )
    }

    private fun generateVegetarianDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "veg-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Vegetarian Breakfast $dayNum", "vegetarian"),
            lunch = generateMeal("Vegetarian Lunch $dayNum", "vegetarian"),
            dinner = generateMeal("Vegetarian Dinner $dayNum", "vegetarian"),
            snacks = listOf(generateMeal("Vegetarian Snack $dayNum", "vegetarian"))
        )
    }

    private fun generateMeal(name: String, type: String): Meal {
        return Meal(
            id = UUID.randomUUID().toString(),
            name = name,
            description = "Delicious $type meal",
            calories = (300..600).random(),
            protein = (15..40).random().toDouble(),
            carbs = (20..60).random().toDouble(),
            fat = (10..30).random().toDouble(),
            fiber = (3..10).random().toDouble(),
            prepTime = (5..20).random(),
            cookTime = (0..30).random(),
            ingredients = listOf("Ingredient 1", "Ingredient 2", "Ingredient 3"),
            instructions = listOf("Step 1", "Step 2", "Step 3"),
            tags = listOf(type, "healthy")
        )
    }

    private fun generateWeek(id: String, weekNumber: Int, type: String): WeeklyMealPlan {
        val days = listOf("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
        return WeeklyMealPlan(
            id = id,
            weekNumber = weekNumber,
            days = days.mapIndexed { index, day ->
                when (type) {
                    "mediterranean" -> generateMediterraneanDay(day, index + 1)
                    "keto" -> generateKetoDay(day, index + 1)
                    "intermittent-fasting" -> generateIFDay(day, index + 1)
                    "family-friendly" -> generateFamilyDay(day, index + 1)
                    "vegetarian" -> generateVegetarianDay(day, index + 1)
                    else -> generateMediterraneanDay(day, index + 1)
                }
            }
        )
    }
}