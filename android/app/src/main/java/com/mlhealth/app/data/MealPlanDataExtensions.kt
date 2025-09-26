package com.mlhealth.app.data

// Additional Meal Plans Extension
object MealPlanDataExtensions {

    // Paleo Diet Plan
    fun paleoPlan(): MealPlanType {
        return MealPlanType(
            id = "paleo",
            name = "Paleo",
            description = "Eat like our ancestors - whole foods, no grains, dairy, or processed foods",
            benefits = listOf(
                "Reduced inflammation",
                "Improved blood sugar control",
                "Weight loss",
                "Increased energy",
                "Better digestion"
            ),
            restrictions = listOf(
                "No grains or legumes",
                "No dairy products",
                "No processed foods",
                "No refined sugar",
                "No artificial ingredients"
            ),
            monthlyPlans = generatePaleoMonth()
        )
    }

    private fun generatePaleoMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "paleo-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "paleo-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "paleo-b1",
                            name = "Sweet Potato Hash with Eggs",
                            description = "Savory sweet potato hash topped with perfectly cooked eggs",
                            calories = 420,
                            protein = 24.0,
                            carbs = 32.0,
                            fat = 22.0,
                            fiber = 6.0,
                            prepTime = 10,
                            cookTime = 20,
                            ingredients = listOf(
                                "2 eggs",
                                "1 medium sweet potato, diced",
                                "1/4 onion, diced",
                                "1 bell pepper, diced",
                                "2 tbsp coconut oil",
                                "Fresh herbs"
                            ),
                            instructions = listOf(
                                "Heat coconut oil in skillet",
                                "Sauté sweet potato until tender",
                                "Add onion and bell pepper",
                                "Create wells and crack eggs",
                                "Cook until eggs are set"
                            ),
                            tags = listOf("paleo", "whole30", "gluten-free", "dairy-free")
                        ),
                        lunch = Meal(
                            id = "paleo-l1",
                            name = "Grilled Chicken Salad with Avocado",
                            description = "Fresh salad with grilled chicken, avocado, and paleo-friendly dressing",
                            calories = 480,
                            protein = 35.0,
                            carbs = 18.0,
                            fat = 32.0,
                            fiber = 8.0,
                            prepTime = 15,
                            cookTime = 15,
                            ingredients = listOf(
                                "6 oz chicken breast",
                                "Mixed greens",
                                "1 avocado",
                                "Cherry tomatoes",
                                "Cucumber",
                                "Olive oil and lemon dressing"
                            ),
                            instructions = listOf(
                                "Grill chicken breast",
                                "Prepare salad greens",
                                "Slice avocado and vegetables",
                                "Top with chicken",
                                "Drizzle with olive oil and lemon"
                            ),
                            tags = listOf("paleo", "high-protein", "salad")
                        ),
                        dinner = Meal(
                            id = "paleo-d1",
                            name = "Beef and Vegetable Stir-Fry",
                            description = "Tender beef strips with colorful vegetables in coconut aminos",
                            calories = 520,
                            protein = 38.0,
                            carbs = 24.0,
                            fat = 30.0,
                            fiber = 6.0,
                            prepTime = 15,
                            cookTime = 15,
                            ingredients = listOf(
                                "8 oz grass-fed beef strips",
                                "Broccoli florets",
                                "Bell peppers",
                                "Snap peas",
                                "Coconut aminos",
                                "Ginger and garlic",
                                "Coconut oil"
                            ),
                            instructions = listOf(
                                "Heat wok with coconut oil",
                                "Stir-fry beef until browned",
                                "Remove beef, cook vegetables",
                                "Add coconut aminos and aromatics",
                                "Return beef to wok and toss"
                            ),
                            tags = listOf("paleo", "asian-inspired", "grain-free")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "paleo-s1",
                                name = "Almond Butter Apple Slices",
                                description = "Crisp apple slices with creamy almond butter",
                                calories = 180,
                                protein = 6.0,
                                carbs = 20.0,
                                fat = 10.0,
                                fiber = 4.0,
                                prepTime = 5,
                                cookTime = 0,
                                ingredients = listOf(
                                    "1 apple",
                                    "2 tbsp almond butter",
                                    "Cinnamon"
                                ),
                                instructions = listOf(
                                    "Slice apple",
                                    "Serve with almond butter",
                                    "Sprinkle with cinnamon"
                                ),
                                tags = listOf("paleo", "quick", "no-cook")
                            )
                        )
                    ),
                    // Generate rest of week
                    generatePaleoDay("Tuesday", 2),
                    generatePaleoDay("Wednesday", 3),
                    generatePaleoDay("Thursday", 4),
                    generatePaleoDay("Friday", 5),
                    generatePaleoDay("Saturday", 6),
                    generatePaleoDay("Sunday", 7)
                )
            ),
            generateWeek("paleo-week-2", 2, "paleo"),
            generateWeek("paleo-week-3", 3, "paleo"),
            generateWeek("paleo-week-4", 4, "paleo")
        )
    }

    // Whole30 Diet Plan
    fun whole30Plan(): MealPlanType {
        return MealPlanType(
            id = "whole30",
            name = "Whole30",
            description = "30-day reset focusing on whole foods to identify food sensitivities",
            benefits = listOf(
                "Identify food sensitivities",
                "Reset eating habits",
                "Improved energy levels",
                "Better sleep quality",
                "Reduced cravings",
                "Clearer skin"
            ),
            restrictions = listOf(
                "No sugar or sweeteners",
                "No alcohol",
                "No grains",
                "No legumes",
                "No dairy",
                "No MSG or sulfites",
                "No recreating baked goods"
            ),
            monthlyPlans = generateWhole30Month()
        )
    }

    private fun generateWhole30Month(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "whole30-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "whole30-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "whole30-b1",
                            name = "Veggie-Packed Breakfast Scramble",
                            description = "Eggs scrambled with rainbow vegetables and fresh herbs",
                            calories = 380,
                            protein = 26.0,
                            carbs = 18.0,
                            fat = 24.0,
                            fiber = 5.0,
                            prepTime = 10,
                            cookTime = 10,
                            ingredients = listOf(
                                "3 eggs",
                                "Spinach",
                                "Mushrooms",
                                "Bell peppers",
                                "Onion",
                                "Ghee or coconut oil",
                                "Fresh basil"
                            ),
                            instructions = listOf(
                                "Heat ghee in pan",
                                "Sauté vegetables until tender",
                                "Whisk eggs and pour over vegetables",
                                "Scramble until cooked through",
                                "Garnish with fresh basil"
                            ),
                            tags = listOf("whole30", "paleo", "vegetable-rich")
                        ),
                        lunch = Meal(
                            id = "whole30-l1",
                            name = "Tuna Salad Lettuce Wraps",
                            description = "Fresh tuna salad wrapped in crisp lettuce leaves",
                            calories = 420,
                            protein = 32.0,
                            carbs = 12.0,
                            fat = 28.0,
                            fiber = 4.0,
                            prepTime = 15,
                            cookTime = 0,
                            ingredients = listOf(
                                "2 cans wild-caught tuna",
                                "Whole30 mayo",
                                "Celery, diced",
                                "Red onion",
                                "Dill pickle, diced",
                                "Boston lettuce leaves"
                            ),
                            instructions = listOf(
                                "Drain tuna and flake",
                                "Mix with mayo and vegetables",
                                "Season with salt and pepper",
                                "Serve in lettuce cups",
                                "Top with fresh herbs"
                            ),
                            tags = listOf("whole30", "no-cook", "omega-3")
                        ),
                        dinner = Meal(
                            id = "whole30-d1",
                            name = "Slow Cooker Pot Roast",
                            description = "Tender pot roast with root vegetables in rich broth",
                            calories = 480,
                            protein = 42.0,
                            carbs = 28.0,
                            fat = 22.0,
                            fiber = 6.0,
                            prepTime = 20,
                            cookTime = 360,
                            ingredients = listOf(
                                "3 lb chuck roast",
                                "Carrots",
                                "Parsnips",
                                "Onions",
                                "Beef broth (Whole30)",
                                "Tomato paste",
                                "Fresh thyme"
                            ),
                            instructions = listOf(
                                "Season and sear roast",
                                "Place in slow cooker",
                                "Add vegetables and broth",
                                "Cook on low 6-8 hours",
                                "Shred and serve with vegetables"
                            ),
                            tags = listOf("whole30", "slow-cooker", "comfort-food")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "whole30-s1",
                                name = "Guacamole with Vegetable Sticks",
                                description = "Fresh guacamole with raw vegetable crudités",
                                calories = 160,
                                protein = 3.0,
                                carbs = 12.0,
                                fat = 14.0,
                                fiber = 6.0,
                                prepTime = 10,
                                cookTime = 0,
                                ingredients = listOf(
                                    "1 avocado",
                                    "Lime juice",
                                    "Cilantro",
                                    "Carrot sticks",
                                    "Celery sticks",
                                    "Bell pepper strips"
                                ),
                                instructions = listOf(
                                    "Mash avocado with lime and cilantro",
                                    "Cut vegetables into sticks",
                                    "Serve together"
                                ),
                                tags = listOf("whole30", "vegetarian", "raw")
                            )
                        )
                    ),
                    generateWhole30Day("Tuesday", 2),
                    generateWhole30Day("Wednesday", 3),
                    generateWhole30Day("Thursday", 4),
                    generateWhole30Day("Friday", 5),
                    generateWhole30Day("Saturday", 6),
                    generateWhole30Day("Sunday", 7)
                )
            ),
            generateWeek("whole30-week-2", 2, "whole30"),
            generateWeek("whole30-week-3", 3, "whole30"),
            generateWeek("whole30-week-4", 4, "whole30")
        )
    }

    // Vegan Diet Plan
    fun veganPlan(): MealPlanType {
        return MealPlanType(
            id = "vegan",
            name = "Vegan",
            description = "100% plant-based diet with no animal products for health and ethics",
            benefits = listOf(
                "Lower carbon footprint",
                "Reduced risk of heart disease",
                "High fiber intake",
                "Weight management",
                "Improved gut health",
                "Ethical eating"
            ),
            restrictions = listOf(
                "No meat or poultry",
                "No fish or seafood",
                "No dairy products",
                "No eggs",
                "No honey",
                "No animal-derived ingredients"
            ),
            monthlyPlans = generateVeganMonth()
        )
    }

    private fun generateVeganMonth(): List<WeeklyMealPlan> {
        return listOf(
            WeeklyMealPlan(
                id = "vegan-week-1",
                weekNumber = 1,
                days = listOf(
                    DailyMealPlan(
                        id = "vegan-w1-monday",
                        dayName = "Monday",
                        breakfast = Meal(
                            id = "vegan-b1",
                            name = "Chocolate Protein Smoothie Bowl",
                            description = "Thick smoothie bowl topped with granola, berries, and seeds",
                            calories = 420,
                            protein = 18.0,
                            carbs = 62.0,
                            fat = 14.0,
                            fiber = 10.0,
                            prepTime = 10,
                            cookTime = 0,
                            ingredients = listOf(
                                "1 frozen banana",
                                "1 cup plant milk",
                                "2 tbsp cocoa powder",
                                "1 scoop vegan protein powder",
                                "Granola",
                                "Mixed berries",
                                "Chia seeds"
                            ),
                            instructions = listOf(
                                "Blend banana, milk, cocoa, and protein powder",
                                "Pour into bowl",
                                "Top with granola",
                                "Add berries and seeds",
                                "Drizzle with almond butter"
                            ),
                            tags = listOf("vegan", "high-protein", "no-cook")
                        ),
                        lunch = Meal(
                            id = "vegan-l1",
                            name = "Chickpea Buddha Bowl",
                            description = "Roasted chickpeas over quinoa with tahini dressing",
                            calories = 520,
                            protein = 20.0,
                            carbs = 68.0,
                            fat = 20.0,
                            fiber = 14.0,
                            prepTime = 15,
                            cookTime = 30,
                            ingredients = listOf(
                                "1 cup cooked quinoa",
                                "1 cup chickpeas",
                                "Kale",
                                "Roasted sweet potato",
                                "Red cabbage",
                                "Tahini dressing",
                                "Hemp seeds"
                            ),
                            instructions = listOf(
                                "Roast chickpeas with spices",
                                "Cook quinoa",
                                "Massage kale",
                                "Roast sweet potato",
                                "Assemble bowl with all components",
                                "Drizzle with tahini"
                            ),
                            tags = listOf("vegan", "buddha-bowl", "protein-rich")
                        ),
                        dinner = Meal(
                            id = "vegan-d1",
                            name = "Lentil Bolognese with Zucchini Noodles",
                            description = "Rich lentil sauce over spiralized zucchini noodles",
                            calories = 380,
                            protein = 18.0,
                            carbs = 48.0,
                            fat = 14.0,
                            fiber = 12.0,
                            prepTime = 20,
                            cookTime = 30,
                            ingredients = listOf(
                                "1 cup red lentils",
                                "Crushed tomatoes",
                                "Onion",
                                "Garlic",
                                "Italian herbs",
                                "3 zucchini, spiralized",
                                "Nutritional yeast"
                            ),
                            instructions = listOf(
                                "Sauté onion and garlic",
                                "Add lentils and tomatoes",
                                "Simmer until thick",
                                "Spiralize zucchini",
                                "Serve sauce over zoodles",
                                "Top with nutritional yeast"
                            ),
                            tags = listOf("vegan", "italian", "low-carb-option")
                        ),
                        snacks = listOf(
                            Meal(
                                id = "vegan-s1",
                                name = "Energy Balls",
                                description = "No-bake date and nut energy balls",
                                calories = 140,
                                protein = 4.0,
                                carbs = 18.0,
                                fat = 8.0,
                                fiber = 3.0,
                                prepTime = 15,
                                cookTime = 0,
                                ingredients = listOf(
                                    "Medjool dates",
                                    "Almonds",
                                    "Coconut flakes",
                                    "Cocoa powder",
                                    "Vanilla extract"
                                ),
                                instructions = listOf(
                                    "Process dates and nuts",
                                    "Add cocoa and vanilla",
                                    "Roll into balls",
                                    "Roll in coconut",
                                    "Refrigerate"
                                ),
                                tags = listOf("vegan", "no-bake", "portable")
                            )
                        )
                    ),
                    generateVeganDay("Tuesday", 2),
                    generateVeganDay("Wednesday", 3),
                    generateVeganDay("Thursday", 4),
                    generateVeganDay("Friday", 5),
                    generateVeganDay("Saturday", 6),
                    generateVeganDay("Sunday", 7)
                )
            ),
            generateWeek("vegan-week-2", 2, "vegan"),
            generateWeek("vegan-week-3", 3, "vegan"),
            generateWeek("vegan-week-4", 4, "vegan")
        )
    }

    // Helper functions
    private fun generatePaleoDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "paleo-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Paleo Breakfast $dayNum", "paleo", 400),
            lunch = generateMeal("Paleo Lunch $dayNum", "paleo", 480),
            dinner = generateMeal("Paleo Dinner $dayNum", "paleo", 520),
            snacks = listOf(generateMeal("Paleo Snack $dayNum", "paleo", 150))
        )
    }

    private fun generateWhole30Day(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "whole30-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Whole30 Breakfast $dayNum", "whole30", 380),
            lunch = generateMeal("Whole30 Lunch $dayNum", "whole30", 450),
            dinner = generateMeal("Whole30 Dinner $dayNum", "whole30", 500),
            snacks = listOf(generateMeal("Whole30 Snack $dayNum", "whole30", 140))
        )
    }

    private fun generateVeganDay(dayName: String, dayNum: Int): DailyMealPlan {
        return DailyMealPlan(
            id = "vegan-w1-${dayName.lowercase()}",
            dayName = dayName,
            breakfast = generateMeal("Vegan Breakfast $dayNum", "vegan", 400),
            lunch = generateMeal("Vegan Lunch $dayNum", "vegan", 500),
            dinner = generateMeal("Vegan Dinner $dayNum", "vegan", 450),
            snacks = listOf(generateMeal("Vegan Snack $dayNum", "vegan", 160))
        )
    }

    private fun generateMeal(name: String, type: String, calories: Int): Meal {
        return Meal(
            id = java.util.UUID.randomUUID().toString(),
            name = name,
            description = "Delicious $type meal",
            calories = calories,
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
                    "paleo" -> generatePaleoDay(day, (weekNumber - 1) * 7 + index + 1)
                    "whole30" -> generateWhole30Day(day, (weekNumber - 1) * 7 + index + 1)
                    "vegan" -> generateVeganDay(day, (weekNumber - 1) * 7 + index + 1)
                    else -> generatePaleoDay(day, index + 1)
                }
            }
        )
    }
}

// Update MealPlanData to include new plans
fun MealPlanData.getAllMealPlansWithExtensions(): List<MealPlanType> {
    return listOf(
        mediterraneanPlan(),
        ketoPlan(),
        intermittentFastingPlan(),
        familyFriendlyPlan(),
        vegetarianPlan(),
        MealPlanDataExtensions.paleoPlan(),     // New
        MealPlanDataExtensions.whole30Plan(),   // New
        MealPlanDataExtensions.veganPlan()      // New
    )
}