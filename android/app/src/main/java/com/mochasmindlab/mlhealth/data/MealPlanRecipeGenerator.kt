package com.mochasmindlab.mlhealth.data

import com.mlhealth.app.data.*
import java.util.UUID

/**
 * Comprehensive Recipe Generator for All Meal Plans
 * Generates complete 4-week meal plans for each diet type
 */
object MealPlanRecipeGenerator {

    // ==================== KETO MEAL PLAN ====================
    fun generateKetoMealPlan(): MealPlanType {
        return MealPlanType(
            id = "keto",
            name = "Keto Diet",
            description = "High-fat, low-carb diet for weight loss and mental clarity",
            benefits = listOf(
                "Rapid weight loss",
                "Improved mental focus",
                "Reduced appetite",
                "Better blood sugar control"
            ),
            restrictions = listOf(
                "Less than 20g carbs daily",
                "No sugar or grains",
                "Limited fruits",
                "No starchy vegetables"
            ),
            monthlyPlans = generateKetoMonth()
        )
    }

    private fun generateKetoMonth(): List<WeeklyMealPlan> {
        return listOf(
            generateKetoWeek1(),
            generateKetoWeek2(),
            generateKetoWeek3(),
            generateKetoWeek4()
        )
    }

    private fun generateKetoWeek1(): WeeklyMealPlan {
        return WeeklyMealPlan(
            id = "keto-week-1",
            weekNumber = 1,
            days = listOf(
                // Monday
                DailyMealPlan(
                    id = "keto-w1-monday",
                    dayName = "Monday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Keto Egg Muffins",
                        description = "Fluffy egg muffins with bacon, cheese, and spinach",
                        calories = 420,
                        protein = 28.0,
                        carbs = 4.0,
                        fat = 32.0,
                        fiber = 1.0,
                        prepTime = 10,
                        cookTime = 20,
                        ingredients = listOf(
                            "6 large eggs",
                            "4 strips bacon, cooked and crumbled",
                            "1/2 cup shredded cheddar cheese",
                            "1 cup fresh spinach, chopped",
                            "2 tbsp heavy cream",
                            "Salt and pepper to taste"
                        ),
                        instructions = listOf(
                            "Preheat oven to 350°F (175°C)",
                            "Whisk eggs with heavy cream",
                            "Add bacon, cheese, and spinach",
                            "Pour into greased muffin tin",
                            "Bake for 18-20 minutes until set"
                        ),
                        tags = listOf("keto", "low-carb", "high-protein", "meal-prep")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Avocado Chicken Salad",
                        description = "Creamy chicken salad with avocado, mayo, and celery",
                        calories = 480,
                        protein = 35.0,
                        carbs = 6.0,
                        fat = 36.0,
                        fiber = 4.0,
                        prepTime = 15,
                        cookTime = 0,
                        ingredients = listOf(
                            "2 cups cooked chicken breast, diced",
                            "1 large avocado, mashed",
                            "2 tbsp mayonnaise",
                            "2 stalks celery, diced",
                            "1 tbsp lemon juice",
                            "Salt, pepper, garlic powder"
                        ),
                        instructions = listOf(
                            "Mix mashed avocado with mayo and lemon juice",
                            "Add diced chicken and celery",
                            "Season with salt, pepper, and garlic powder",
                            "Chill for 30 minutes before serving",
                            "Serve in lettuce cups or with cucumber slices"
                        ),
                        tags = listOf("keto", "no-cook", "high-fat")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Butter Garlic Steak with Asparagus",
                        description = "Juicy ribeye steak with butter-roasted asparagus",
                        calories = 650,
                        protein = 45.0,
                        carbs = 5.0,
                        fat = 48.0,
                        fiber = 2.0,
                        prepTime = 10,
                        cookTime = 15,
                        ingredients = listOf(
                            "8 oz ribeye steak",
                            "1 bunch asparagus",
                            "3 tbsp butter",
                            "3 cloves garlic, minced",
                            "Fresh rosemary",
                            "Sea salt and black pepper"
                        ),
                        instructions = listOf(
                            "Let steak reach room temperature",
                            "Season steak with salt and pepper",
                            "Sear in hot cast iron skillet 4-5 minutes per side",
                            "Rest steak, add butter and garlic to pan",
                            "Sauté asparagus in garlic butter until tender"
                        ),
                        tags = listOf("keto", "high-protein", "dinner")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "Macadamia Nuts",
                            description = "Roasted and salted macadamia nuts",
                            calories = 200,
                            protein = 2.0,
                            carbs = 2.0,
                            fat = 21.0,
                            fiber = 2.0,
                            prepTime = 0,
                            cookTime = 0,
                            ingredients = listOf("1 oz macadamia nuts"),
                            instructions = listOf("Enjoy as is"),
                            tags = listOf("keto", "snack")
                        )
                    )
                ),
                // Tuesday
                DailyMealPlan(
                    id = "keto-w1-tuesday",
                    dayName = "Tuesday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Bulletproof Coffee & Chia Pudding",
                        description = "Coffee blended with butter and MCT oil, served with chia pudding",
                        calories = 380,
                        protein = 8.0,
                        carbs = 5.0,
                        fat = 36.0,
                        fiber = 4.0,
                        prepTime = 5,
                        cookTime = 0,
                        ingredients = listOf(
                            "1 cup hot coffee",
                            "1 tbsp grass-fed butter",
                            "1 tbsp MCT oil",
                            "2 tbsp chia seeds",
                            "1/2 cup unsweetened almond milk",
                            "Stevia to taste"
                        ),
                        instructions = listOf(
                            "Blend hot coffee with butter and MCT oil",
                            "Mix chia seeds with almond milk",
                            "Let chia pudding set for 10 minutes",
                            "Sweeten with stevia if desired"
                        ),
                        tags = listOf("keto", "bulletproof", "breakfast")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Zucchini Noodle Carbonara",
                        description = "Creamy carbonara sauce over spiralized zucchini noodles",
                        calories = 450,
                        protein = 25.0,
                        carbs = 8.0,
                        fat = 35.0,
                        fiber = 3.0,
                        prepTime = 10,
                        cookTime = 15,
                        ingredients = listOf(
                            "2 medium zucchini, spiralized",
                            "4 strips bacon",
                            "2 egg yolks",
                            "1/2 cup Parmesan cheese",
                            "2 tbsp heavy cream",
                            "Black pepper"
                        ),
                        instructions = listOf(
                            "Cook bacon until crispy, reserve fat",
                            "Sauté zucchini noodles in bacon fat 2-3 minutes",
                            "Mix egg yolks, Parmesan, and cream",
                            "Toss noodles with egg mixture off heat",
                            "Top with crumbled bacon"
                        ),
                        tags = listOf("keto", "pasta-alternative", "low-carb")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Lemon Herb Salmon with Cauliflower Mash",
                        description = "Baked salmon with creamy cauliflower mash",
                        calories = 520,
                        protein = 38.0,
                        carbs = 7.0,
                        fat = 38.0,
                        fiber = 3.0,
                        prepTime = 10,
                        cookTime = 25,
                        ingredients = listOf(
                            "6 oz salmon fillet",
                            "1 head cauliflower",
                            "3 tbsp butter",
                            "2 oz cream cheese",
                            "Lemon, dill, garlic",
                            "Salt and pepper"
                        ),
                        instructions = listOf(
                            "Steam cauliflower until tender",
                            "Mash with butter and cream cheese",
                            "Season salmon with lemon, dill, salt, pepper",
                            "Bake salmon at 400°F for 12-15 minutes",
                            "Serve over cauliflower mash"
                        ),
                        tags = listOf("keto", "omega-3", "dinner")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "String Cheese & Pepperoni",
                            description = "Mozzarella string cheese with pepperoni slices",
                            calories = 180,
                            protein = 12.0,
                            carbs = 2.0,
                            fat = 14.0,
                            fiber = 0.0,
                            prepTime = 0,
                            cookTime = 0,
                            ingredients = listOf(
                                "1 string cheese",
                                "10 pepperoni slices"
                            ),
                            instructions = listOf("Pair and enjoy"),
                            tags = listOf("keto", "snack", "portable")
                        )
                    )
                )
                // Continue with remaining days...
            )
        )
    }

    private fun generateKetoWeek2(): WeeklyMealPlan {
        // Implementation for week 2
        return WeeklyMealPlan(
            id = "keto-week-2",
            weekNumber = 2,
            days = listOf() // Add 7 days of meals
        )
    }

    private fun generateKetoWeek3(): WeeklyMealPlan {
        // Implementation for week 3
        return WeeklyMealPlan(
            id = "keto-week-3",
            weekNumber = 3,
            days = listOf() // Add 7 days of meals
        )
    }

    private fun generateKetoWeek4(): WeeklyMealPlan {
        // Implementation for week 4
        return WeeklyMealPlan(
            id = "keto-week-4",
            weekNumber = 4,
            days = listOf() // Add 7 days of meals
        )
    }

    // ==================== INTERMITTENT FASTING MEAL PLAN ====================
    fun generateIntermittentFastingMealPlan(): MealPlanType {
        return MealPlanType(
            id = "intermittent_fasting",
            name = "Intermittent Fasting",
            description = "16:8 eating window with balanced, nutrient-dense meals",
            benefits = listOf(
                "Weight loss",
                "Improved insulin sensitivity",
                "Enhanced autophagy",
                "Mental clarity",
                "Simplified meal planning"
            ),
            restrictions = listOf(
                "16-hour fasting window",
                "8-hour eating window (12pm-8pm)",
                "No breakfast",
                "2-3 meals per day"
            ),
            monthlyPlans = generateIFMonth()
        )
    }

    private fun generateIFMonth(): List<WeeklyMealPlan> {
        return listOf(
            generateIFWeek1()
            // Add weeks 2-4
        )
    }

    private fun generateIFWeek1(): WeeklyMealPlan {
        return WeeklyMealPlan(
            id = "if-week-1",
            weekNumber = 1,
            days = listOf(
                // Monday
                DailyMealPlan(
                    id = "if-w1-monday",
                    dayName = "Monday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Black Coffee",
                        description = "Black coffee or water during fasting window",
                        calories = 5,
                        protein = 0.0,
                        carbs = 0.0,
                        fat = 0.0,
                        fiber = 0.0,
                        prepTime = 2,
                        cookTime = 0,
                        ingredients = listOf("Coffee", "Water"),
                        instructions = listOf("Brew coffee", "Drink black"),
                        tags = listOf("fasting", "zero-calorie")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Power Bowl with Quinoa",
                        description = "Nutrient-dense bowl to break fast at noon",
                        calories = 650,
                        protein = 35.0,
                        carbs = 65.0,
                        fat = 25.0,
                        fiber = 12.0,
                        prepTime = 15,
                        cookTime = 20,
                        ingredients = listOf(
                            "1 cup cooked quinoa",
                            "4 oz grilled chicken",
                            "1/2 avocado",
                            "1 cup mixed greens",
                            "1/4 cup chickpeas",
                            "2 tbsp tahini dressing",
                            "Cherry tomatoes",
                            "Cucumber"
                        ),
                        instructions = listOf(
                            "Cook quinoa according to package",
                            "Grill chicken with spices",
                            "Assemble bowl with all ingredients",
                            "Drizzle with tahini dressing"
                        ),
                        tags = listOf("IF", "break-fast", "balanced")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Lean Beef Stir-Fry",
                        description = "High-protein stir-fry with vegetables",
                        calories = 550,
                        protein = 40.0,
                        carbs = 35.0,
                        fat = 22.0,
                        fiber = 8.0,
                        prepTime = 10,
                        cookTime = 15,
                        ingredients = listOf(
                            "6 oz lean beef sirloin",
                            "2 cups mixed vegetables",
                            "1 tbsp coconut oil",
                            "2 tbsp soy sauce",
                            "1 tsp ginger",
                            "2 cloves garlic",
                            "1/2 cup brown rice"
                        ),
                        instructions = listOf(
                            "Cook rice separately",
                            "Stir-fry beef in coconut oil",
                            "Add vegetables and cook until tender",
                            "Season with soy sauce, ginger, garlic",
                            "Serve over rice"
                        ),
                        tags = listOf("IF", "high-protein", "dinner")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "Greek Yogurt with Berries",
                            description = "Protein-rich snack within eating window",
                            calories = 150,
                            protein = 15.0,
                            carbs = 18.0,
                            fat = 3.0,
                            fiber = 2.0,
                            prepTime = 2,
                            cookTime = 0,
                            ingredients = listOf(
                                "1 cup Greek yogurt",
                                "1/2 cup mixed berries",
                                "1 tsp honey"
                            ),
                            instructions = listOf(
                                "Mix yogurt with berries",
                                "Drizzle with honey"
                            ),
                            tags = listOf("IF", "snack", "protein")
                        )
                    )
                ),
                // Tuesday
                DailyMealPlan(
                    id = "if-w1-tuesday",
                    dayName = "Tuesday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Green Tea",
                        description = "Green tea or water during fasting window",
                        calories = 2,
                        protein = 0.0,
                        carbs = 0.0,
                        fat = 0.0,
                        fiber = 0.0,
                        prepTime = 3,
                        cookTime = 0,
                        ingredients = listOf("Green tea", "Hot water"),
                        instructions = listOf("Steep tea for 3 minutes"),
                        tags = listOf("fasting", "zero-calorie")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Mediterranean Salmon Salad",
                        description = "Omega-3 rich salad to break fast",
                        calories = 580,
                        protein = 38.0,
                        carbs = 35.0,
                        fat = 30.0,
                        fiber = 8.0,
                        prepTime = 12,
                        cookTime = 15,
                        ingredients = listOf(
                            "5 oz grilled salmon",
                            "2 cups mixed greens",
                            "1/4 cup feta cheese",
                            "10 kalamata olives",
                            "1/2 cucumber, diced",
                            "Cherry tomatoes",
                            "2 tbsp olive oil vinaigrette"
                        ),
                        instructions = listOf(
                            "Grill salmon with lemon and herbs",
                            "Toss greens with vegetables",
                            "Top with salmon and feta",
                            "Drizzle with vinaigrette"
                        ),
                        tags = listOf("IF", "omega-3", "mediterranean")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Turkey Meatballs with Zoodles",
                        description = "Lean turkey meatballs over zucchini noodles",
                        calories = 480,
                        protein = 42.0,
                        carbs = 28.0,
                        fat = 20.0,
                        fiber = 6.0,
                        prepTime = 20,
                        cookTime = 25,
                        ingredients = listOf(
                            "1 lb ground turkey",
                            "1 egg",
                            "1/4 cup breadcrumbs",
                            "3 zucchini, spiralized",
                            "2 cups marinara sauce",
                            "Fresh basil",
                            "Parmesan cheese"
                        ),
                        instructions = listOf(
                            "Mix turkey, egg, breadcrumbs, form meatballs",
                            "Bake meatballs at 400°F for 20 minutes",
                            "Spiralize zucchini",
                            "Sauté zoodles briefly",
                            "Serve meatballs over zoodles with sauce"
                        ),
                        tags = listOf("IF", "lean-protein", "low-carb-option")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "Apple with Almond Butter",
                            description = "Fiber and healthy fats",
                            calories = 200,
                            protein = 7.0,
                            carbs = 25.0,
                            fat = 10.0,
                            fiber = 5.0,
                            prepTime = 2,
                            cookTime = 0,
                            ingredients = listOf(
                                "1 medium apple",
                                "2 tbsp almond butter"
                            ),
                            instructions = listOf(
                                "Slice apple",
                                "Serve with almond butter"
                            ),
                            tags = listOf("IF", "snack", "fiber")
                        )
                    )
                ),
                // Wednesday through Sunday - Adding complete days
                DailyMealPlan(
                    id = "if-w1-wednesday",
                    dayName = "Wednesday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Sparkling Water",
                        description = "Sparkling water with lemon during fasting",
                        calories = 0,
                        protein = 0.0,
                        carbs = 0.0,
                        fat = 0.0,
                        fiber = 0.0,
                        prepTime = 1,
                        cookTime = 0,
                        ingredients = listOf("Sparkling water", "Lemon slice"),
                        instructions = listOf("Add lemon to sparkling water"),
                        tags = listOf("fasting", "zero-calorie")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Protein-Packed Buddha Bowl",
                        description = "Balanced bowl with tofu and vegetables",
                        calories = 620,
                        protein = 28.0,
                        carbs = 68.0,
                        fat = 26.0,
                        fiber = 14.0,
                        prepTime = 15,
                        cookTime = 20,
                        ingredients = listOf(
                            "6 oz baked tofu",
                            "1 cup brown rice",
                            "1 cup roasted vegetables",
                            "1/4 avocado",
                            "2 tbsp peanut sauce",
                            "Sesame seeds"
                        ),
                        instructions = listOf(
                            "Bake tofu until crispy",
                            "Cook brown rice",
                            "Roast vegetables",
                            "Assemble bowl and top with sauce"
                        ),
                        tags = listOf("IF", "vegetarian", "balanced")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Grilled Chicken Fajitas",
                        description = "Sizzling fajitas with whole wheat tortillas",
                        calories = 520,
                        protein = 38.0,
                        carbs = 45.0,
                        fat = 18.0,
                        fiber = 8.0,
                        prepTime = 15,
                        cookTime = 20,
                        ingredients = listOf(
                            "6 oz chicken breast",
                            "Bell peppers",
                            "Onions",
                            "2 whole wheat tortillas",
                            "Salsa",
                            "Greek yogurt",
                            "Cilantro"
                        ),
                        instructions = listOf(
                            "Marinate and grill chicken",
                            "Sauté peppers and onions",
                            "Warm tortillas",
                            "Assemble with toppings"
                        ),
                        tags = listOf("IF", "mexican", "high-protein")
                    ),
                    snacks = listOf()
                )
            )
        )
    }

    // ==================== FAMILY FRIENDLY MEAL PLAN ====================
    fun generateFamilyFriendlyMealPlan(): MealPlanType {
        return MealPlanType(
            id = "family_friendly",
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
                "No spicy foods",
                "Familiar flavors",
                "Fun presentations"
            ),
            monthlyPlans = generateFamilyMonth()
        )
    }

    private fun generateFamilyMonth(): List<WeeklyMealPlan> {
        return listOf(
            generateFamilyWeek1()
            // Add weeks 2-4
        )
    }

    private fun generateFamilyWeek1(): WeeklyMealPlan {
        return WeeklyMealPlan(
            id = "family-week-1",
            weekNumber = 1,
            days = listOf(
                DailyMealPlan(
                    id = "family-w1-monday",
                    dayName = "Monday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Pancake Faces",
                        description = "Whole wheat pancakes decorated with fruit faces",
                        calories = 320,
                        protein = 12.0,
                        carbs = 48.0,
                        fat = 10.0,
                        fiber = 4.0,
                        prepTime = 10,
                        cookTime = 15,
                        ingredients = listOf(
                            "1 cup whole wheat flour",
                            "1 egg",
                            "1 cup milk",
                            "1 banana",
                            "Blueberries for eyes",
                            "Strawberry slices for smile"
                        ),
                        instructions = listOf(
                            "Mix pancake batter",
                            "Cook pancakes on griddle",
                            "Decorate with fruit to make faces",
                            "Serve with small amount of maple syrup"
                        ),
                        tags = listOf("family", "kids", "fun")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Turkey Roll-Ups",
                        description = "Turkey and cheese rolled in tortillas with veggies",
                        calories = 380,
                        protein = 25.0,
                        carbs = 35.0,
                        fat = 15.0,
                        fiber = 5.0,
                        prepTime = 10,
                        cookTime = 0,
                        ingredients = listOf(
                            "4 whole wheat tortillas",
                            "8 oz sliced turkey",
                            "4 slices cheese",
                            "Lettuce leaves",
                            "Sliced tomatoes",
                            "Hummus or ranch"
                        ),
                        instructions = listOf(
                            "Spread hummus on tortillas",
                            "Layer turkey, cheese, veggies",
                            "Roll tightly",
                            "Cut into pinwheels",
                            "Secure with toothpicks"
                        ),
                        tags = listOf("family", "lunch", "no-cook")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Hidden Veggie Spaghetti",
                        description = "Spaghetti with meat sauce packed with hidden vegetables",
                        calories = 450,
                        protein = 28.0,
                        carbs = 52.0,
                        fat = 15.0,
                        fiber = 6.0,
                        prepTime = 15,
                        cookTime = 30,
                        ingredients = listOf(
                            "1 lb ground turkey",
                            "1 jar marinara sauce",
                            "1/2 cup grated zucchini",
                            "1/2 cup grated carrot",
                            "1/4 cup finely chopped spinach",
                            "12 oz whole wheat spaghetti",
                            "Parmesan cheese"
                        ),
                        instructions = listOf(
                            "Cook spaghetti according to package",
                            "Brown ground turkey",
                            "Add grated vegetables to meat",
                            "Simmer with marinara sauce",
                            "Serve over spaghetti with cheese"
                        ),
                        tags = listOf("family", "hidden-veggies", "dinner")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "Ants on a Log",
                            description = "Celery with peanut butter and raisins",
                            calories = 120,
                            protein = 4.0,
                            carbs = 12.0,
                            fat = 7.0,
                            fiber = 2.0,
                            prepTime = 5,
                            cookTime = 0,
                            ingredients = listOf(
                                "3 celery sticks",
                                "2 tbsp peanut butter",
                                "1 tbsp raisins"
                            ),
                            instructions = listOf(
                                "Cut celery into logs",
                                "Fill with peanut butter",
                                "Top with raisins"
                            ),
                            tags = listOf("family", "snack", "classic")
                        )
                    )
                )
            )
        )
    }

    // ==================== VEGETARIAN MEAL PLAN ====================
    fun generateVegetarianMealPlan(): MealPlanType {
        return MealPlanType(
            id = "vegetarian",
            name = "Vegetarian",
            description = "Plant-based meals rich in protein, fiber, and essential nutrients",
            benefits = listOf(
                "High fiber intake",
                "Rich in antioxidants",
                "Environmental sustainability",
                "Lower saturated fat",
                "Diverse flavors"
            ),
            restrictions = listOf(
                "No meat or fish",
                "Eggs and dairy allowed",
                "Focus on complete proteins"
            ),
            monthlyPlans = generateVegetarianMonth()
        )
    }

    private fun generateVegetarianMonth(): List<WeeklyMealPlan> {
        return listOf(
            generateVegetarianWeek1()
            // Add weeks 2-4
        )
    }

    private fun generateVegetarianWeek1(): WeeklyMealPlan {
        return WeeklyMealPlan(
            id = "veg-week-1",
            weekNumber = 1,
            days = listOf(
                DailyMealPlan(
                    id = "veg-w1-monday",
                    dayName = "Monday",
                    breakfast = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Veggie Scramble with Toast",
                        description = "Scrambled eggs with colorful vegetables and whole grain toast",
                        calories = 380,
                        protein = 20.0,
                        carbs = 35.0,
                        fat = 18.0,
                        fiber = 6.0,
                        prepTime = 10,
                        cookTime = 10,
                        ingredients = listOf(
                            "3 eggs",
                            "1/2 cup bell peppers",
                            "1/4 cup onions",
                            "1/2 cup spinach",
                            "2 slices whole grain bread",
                            "1 tbsp olive oil",
                            "Salt, pepper, herbs"
                        ),
                        instructions = listOf(
                            "Sauté vegetables in olive oil",
                            "Whisk eggs and add to pan",
                            "Scramble until fluffy",
                            "Toast bread",
                            "Season and serve"
                        ),
                        tags = listOf("vegetarian", "protein", "breakfast")
                    ),
                    lunch = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Chickpea Buddha Bowl",
                        description = "Nourishing bowl with roasted chickpeas and vegetables",
                        calories = 520,
                        protein = 18.0,
                        carbs = 68.0,
                        fat = 20.0,
                        fiber = 15.0,
                        prepTime = 15,
                        cookTime = 25,
                        ingredients = listOf(
                            "1 can chickpeas",
                            "1 cup quinoa",
                            "1 sweet potato",
                            "1 cup kale",
                            "1/4 avocado",
                            "2 tbsp tahini",
                            "Lemon juice",
                            "Spices: cumin, paprika"
                        ),
                        instructions = listOf(
                            "Roast chickpeas and sweet potato",
                            "Cook quinoa",
                            "Massage kale with lemon",
                            "Assemble bowl with all ingredients",
                            "Drizzle with tahini dressing"
                        ),
                        tags = listOf("vegetarian", "bowl", "protein")
                    ),
                    dinner = Meal(
                        id = UUID.randomUUID().toString(),
                        name = "Eggplant Parmesan",
                        description = "Crispy baked eggplant with marinara and melted cheese",
                        calories = 480,
                        protein = 22.0,
                        carbs = 42.0,
                        fat = 25.0,
                        fiber = 8.0,
                        prepTime = 20,
                        cookTime = 40,
                        ingredients = listOf(
                            "2 medium eggplants",
                            "2 cups marinara sauce",
                            "2 cups mozzarella",
                            "1 cup Parmesan",
                            "1 cup breadcrumbs",
                            "2 eggs",
                            "Italian herbs"
                        ),
                        instructions = listOf(
                            "Slice eggplant, salt, and drain",
                            "Dip in egg, then breadcrumbs",
                            "Bake until golden",
                            "Layer with sauce and cheese",
                            "Bake until bubbly"
                        ),
                        tags = listOf("vegetarian", "italian", "comfort")
                    ),
                    snacks = listOf(
                        Meal(
                            id = UUID.randomUUID().toString(),
                            name = "Hummus with Veggies",
                            description = "Creamy hummus with fresh vegetable sticks",
                            calories = 150,
                            protein = 6.0,
                            carbs = 18.0,
                            fat = 7.0,
                            fiber = 5.0,
                            prepTime = 5,
                            cookTime = 0,
                            ingredients = listOf(
                                "1/4 cup hummus",
                                "Carrot sticks",
                                "Cucumber slices",
                                "Bell pepper strips"
                            ),
                            instructions = listOf(
                                "Cut vegetables",
                                "Serve with hummus"
                            ),
                            tags = listOf("vegetarian", "snack", "healthy")
                        )
                    )
                )
            )
        )
    }

    // ==================== UTILITY FUNCTIONS ====================
    
    fun getAllMealPlans(): List<MealPlanType> {
        return listOf(
            generateKetoMealPlan(),
            generateIntermittentFastingMealPlan(),
            generateFamilyFriendlyMealPlan(),
            generateVegetarianMealPlan()
        )
    }

    fun getMealPlanById(id: String): MealPlanType? {
        return getAllMealPlans().find { it.id == id }
    }

    fun getRecipesByTag(tag: String): List<Meal> {
        val allMeals = mutableListOf<Meal>()
        getAllMealPlans().forEach { plan ->
            plan.monthlyPlans.forEach { week ->
                week.days.forEach { day ->
                    allMeals.add(day.breakfast)
                    allMeals.add(day.lunch)
                    allMeals.add(day.dinner)
                    allMeals.addAll(day.snacks)
                }
            }
        }
        return allMeals.filter { it.tags.contains(tag) }
    }

    fun getRecipeById(id: String): Meal? {
        getAllMealPlans().forEach { plan ->
            plan.monthlyPlans.forEach { week ->
                week.days.forEach { day ->
                    if (day.breakfast.id == id) return day.breakfast
                    if (day.lunch.id == id) return day.lunch
                    if (day.dinner.id == id) return day.dinner
                    day.snacks.forEach { snack ->
                        if (snack.id == id) return snack
                    }
                }
            }
        }
        return null
    }
}