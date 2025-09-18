import Foundation

// MARK: - Additional Meal Plans Extension
extension MealPlanData {

    // MARK: - Paleo Diet Plan
    func paleoPlan() -> MealPlanType {
        MealPlanType(
            id: "paleo",
            name: "Paleo",
            description: "Eat like our ancestors - whole foods, no grains, dairy, or processed foods",
            benefits: [
                "Reduced inflammation",
                "Improved blood sugar control",
                "Weight loss",
                "Increased energy",
                "Better digestion"
            ],
            restrictions: [
                "No grains or legumes",
                "No dairy products",
                "No processed foods",
                "No refined sugar",
                "No artificial ingredients"
            ],
            monthlyPlans: generatePaleoMonth()
        )
    }

    private func generatePaleoMonth() -> [WeeklyMealPlan] {
        return [
            // Week 1
            WeeklyMealPlan(
                id: "paleo-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "paleo-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "paleo-b1",
                            name: "Sweet Potato Hash with Eggs",
                            description: "Savory sweet potato hash topped with perfectly cooked eggs",
                            calories: 420,
                            protein: 24,
                            carbs: 32,
                            fat: 22,
                            fiber: 6,
                            prepTime: 10,
                            cookTime: 20,
                            ingredients: [
                                "2 eggs",
                                "1 medium sweet potato, diced",
                                "1/4 onion, diced",
                                "1 bell pepper, diced",
                                "2 tbsp coconut oil",
                                "Fresh herbs"
                            ],
                            instructions: [
                                "Heat coconut oil in skillet",
                                "Sauté sweet potato until tender",
                                "Add onion and bell pepper",
                                "Create wells and crack eggs",
                                "Cook until eggs are set"
                            ],
                            tags: ["paleo", "whole30", "gluten-free", "dairy-free"]
                        ),
                        lunch: Meal(
                            id: "paleo-l1",
                            name: "Grilled Chicken Salad with Avocado",
                            description: "Fresh salad with grilled chicken, avocado, and paleo-friendly dressing",
                            calories: 480,
                            protein: 35,
                            carbs: 18,
                            fat: 32,
                            fiber: 8,
                            prepTime: 15,
                            cookTime: 15,
                            ingredients: [
                                "6 oz chicken breast",
                                "Mixed greens",
                                "1 avocado",
                                "Cherry tomatoes",
                                "Cucumber",
                                "Olive oil and lemon dressing"
                            ],
                            instructions: [
                                "Grill chicken breast",
                                "Prepare salad greens",
                                "Slice avocado and vegetables",
                                "Top with chicken",
                                "Drizzle with olive oil and lemon"
                            ],
                            tags: ["paleo", "high-protein", "salad"]
                        ),
                        dinner: Meal(
                            id: "paleo-d1",
                            name: "Beef and Vegetable Stir-Fry",
                            description: "Tender beef strips with colorful vegetables in coconut aminos",
                            calories: 520,
                            protein: 38,
                            carbs: 24,
                            fat: 30,
                            fiber: 6,
                            prepTime: 15,
                            cookTime: 15,
                            ingredients: [
                                "8 oz grass-fed beef strips",
                                "Broccoli florets",
                                "Bell peppers",
                                "Snap peas",
                                "Coconut aminos",
                                "Ginger and garlic",
                                "Coconut oil"
                            ],
                            instructions: [
                                "Heat wok with coconut oil",
                                "Stir-fry beef until browned",
                                "Remove beef, cook vegetables",
                                "Add coconut aminos and aromatics",
                                "Return beef to wok and toss"
                            ],
                            tags: ["paleo", "asian-inspired", "grain-free"]
                        ),
                        snacks: [
                            Meal(
                                id: "paleo-s1",
                                name: "Almond Butter Apple Slices",
                                description: "Crisp apple slices with creamy almond butter",
                                calories: 180,
                                protein: 6,
                                carbs: 20,
                                fat: 10,
                                fiber: 4,
                                prepTime: 5,
                                cookTime: 0,
                                ingredients: ["1 apple", "2 tbsp almond butter", "Cinnamon"],
                                instructions: ["Slice apple", "Serve with almond butter", "Sprinkle with cinnamon"],
                                tags: ["paleo", "quick", "no-cook"]
                            )
                        ]
                    ),
                    // Continue with Tuesday through Sunday
                    generatePaleoDay("Tuesday", 2),
                    generatePaleoDay("Wednesday", 3),
                    generatePaleoDay("Thursday", 4),
                    generatePaleoDay("Friday", 5),
                    generatePaleoDay("Saturday", 6),
                    generatePaleoDay("Sunday", 7)
                ]
            ),
            // Weeks 2-4
            generatePaleoWeek(2),
            generatePaleoWeek(3),
            generatePaleoWeek(4)
        ]
    }

    // MARK: - Whole30 Diet Plan
    func whole30Plan() -> MealPlanType {
        MealPlanType(
            id: "whole30",
            name: "Whole30",
            description: "30-day reset focusing on whole foods to identify food sensitivities",
            benefits: [
                "Identify food sensitivities",
                "Reset eating habits",
                "Improved energy levels",
                "Better sleep quality",
                "Reduced cravings",
                "Clearer skin"
            ],
            restrictions: [
                "No sugar or sweeteners",
                "No alcohol",
                "No grains",
                "No legumes",
                "No dairy",
                "No MSG or sulfites",
                "No recreating baked goods"
            ],
            monthlyPlans: generateWhole30Month()
        )
    }

    private func generateWhole30Month() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "whole30-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "whole30-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "whole30-b1",
                            name: "Veggie-Packed Breakfast Scramble",
                            description: "Eggs scrambled with rainbow vegetables and fresh herbs",
                            calories: 380,
                            protein: 26,
                            carbs: 18,
                            fat: 24,
                            fiber: 5,
                            prepTime: 10,
                            cookTime: 10,
                            ingredients: [
                                "3 eggs",
                                "Spinach",
                                "Mushrooms",
                                "Bell peppers",
                                "Onion",
                                "Ghee or coconut oil",
                                "Fresh basil"
                            ],
                            instructions: [
                                "Heat ghee in pan",
                                "Sauté vegetables until tender",
                                "Whisk eggs and pour over vegetables",
                                "Scramble until cooked through",
                                "Garnish with fresh basil"
                            ],
                            tags: ["whole30", "paleo", "vegetable-rich"]
                        ),
                        lunch: Meal(
                            id: "whole30-l1",
                            name: "Tuna Salad Lettuce Wraps",
                            description: "Fresh tuna salad wrapped in crisp lettuce leaves",
                            calories: 420,
                            protein: 32,
                            carbs: 12,
                            fat: 28,
                            fiber: 4,
                            prepTime: 15,
                            cookTime: 0,
                            ingredients: [
                                "2 cans wild-caught tuna",
                                "Whole30 mayo",
                                "Celery, diced",
                                "Red onion",
                                "Dill pickle, diced",
                                "Boston lettuce leaves"
                            ],
                            instructions: [
                                "Drain tuna and flake",
                                "Mix with mayo and vegetables",
                                "Season with salt and pepper",
                                "Serve in lettuce cups",
                                "Top with fresh herbs"
                            ],
                            tags: ["whole30", "no-cook", "omega-3"]
                        ),
                        dinner: Meal(
                            id: "whole30-d1",
                            name: "Slow Cooker Pot Roast",
                            description: "Tender pot roast with root vegetables in rich broth",
                            calories: 480,
                            protein: 42,
                            carbs: 28,
                            fat: 22,
                            fiber: 6,
                            prepTime: 20,
                            cookTime: 360,
                            ingredients: [
                                "3 lb chuck roast",
                                "Carrots",
                                "Parsnips",
                                "Onions",
                                "Beef broth (Whole30)",
                                "Tomato paste",
                                "Fresh thyme"
                            ],
                            instructions: [
                                "Season and sear roast",
                                "Place in slow cooker",
                                "Add vegetables and broth",
                                "Cook on low 6-8 hours",
                                "Shred and serve with vegetables"
                            ],
                            tags: ["whole30", "slow-cooker", "comfort-food"]
                        ),
                        snacks: [
                            Meal(
                                id: "whole30-s1",
                                name: "Guacamole with Vegetable Sticks",
                                description: "Fresh guacamole with raw vegetable crudités",
                                calories: 160,
                                protein: 3,
                                carbs: 12,
                                fat: 14,
                                fiber: 6,
                                prepTime: 10,
                                cookTime: 0,
                                ingredients: [
                                    "1 avocado",
                                    "Lime juice",
                                    "Cilantro",
                                    "Carrot sticks",
                                    "Celery sticks",
                                    "Bell pepper strips"
                                ],
                                instructions: [
                                    "Mash avocado with lime and cilantro",
                                    "Cut vegetables into sticks",
                                    "Serve together"
                                ],
                                tags: ["whole30", "vegetarian", "raw"]
                            )
                        ]
                    ),
                    generateWhole30Day("Tuesday", 2),
                    generateWhole30Day("Wednesday", 3),
                    generateWhole30Day("Thursday", 4),
                    generateWhole30Day("Friday", 5),
                    generateWhole30Day("Saturday", 6),
                    generateWhole30Day("Sunday", 7)
                ]
            ),
            generateWhole30Week(2),
            generateWhole30Week(3),
            generateWhole30Week(4)
        ]
    }

    // MARK: - Vegan Diet Plan
    func veganPlan() -> MealPlanType {
        MealPlanType(
            id: "vegan",
            name: "Vegan",
            description: "100% plant-based diet with no animal products for health and ethics",
            benefits: [
                "Lower carbon footprint",
                "Reduced risk of heart disease",
                "High fiber intake",
                "Weight management",
                "Improved gut health",
                "Ethical eating"
            ],
            restrictions: [
                "No meat or poultry",
                "No fish or seafood",
                "No dairy products",
                "No eggs",
                "No honey",
                "No animal-derived ingredients"
            ],
            monthlyPlans: generateVeganMonth()
        )
    }

    private func generateVeganMonth() -> [WeeklyMealPlan] {
        return [
            WeeklyMealPlan(
                id: "vegan-week-1",
                weekNumber: 1,
                days: [
                    DailyMealPlan(
                        id: "vegan-w1-monday",
                        dayName: "Monday",
                        breakfast: Meal(
                            id: "vegan-b1",
                            name: "Chocolate Protein Smoothie Bowl",
                            description: "Thick smoothie bowl topped with granola, berries, and seeds",
                            calories: 420,
                            protein: 18,
                            carbs: 62,
                            fat: 14,
                            fiber: 10,
                            prepTime: 10,
                            cookTime: 0,
                            ingredients: [
                                "1 frozen banana",
                                "1 cup plant milk",
                                "2 tbsp cocoa powder",
                                "1 scoop vegan protein powder",
                                "Granola",
                                "Mixed berries",
                                "Chia seeds"
                            ],
                            instructions: [
                                "Blend banana, milk, cocoa, and protein powder",
                                "Pour into bowl",
                                "Top with granola",
                                "Add berries and seeds",
                                "Drizzle with almond butter"
                            ],
                            tags: ["vegan", "high-protein", "no-cook"]
                        ),
                        lunch: Meal(
                            id: "vegan-l1",
                            name: "Chickpea Buddha Bowl",
                            description: "Roasted chickpeas over quinoa with tahini dressing",
                            calories: 520,
                            protein: 20,
                            carbs: 68,
                            fat: 20,
                            fiber: 14,
                            prepTime: 15,
                            cookTime: 30,
                            ingredients: [
                                "1 cup cooked quinoa",
                                "1 cup chickpeas",
                                "Kale",
                                "Roasted sweet potato",
                                "Red cabbage",
                                "Tahini dressing",
                                "Hemp seeds"
                            ],
                            instructions: [
                                "Roast chickpeas with spices",
                                "Cook quinoa",
                                "Massage kale",
                                "Roast sweet potato",
                                "Assemble bowl with all components",
                                "Drizzle with tahini"
                            ],
                            tags: ["vegan", "buddha-bowl", "protein-rich"]
                        ),
                        dinner: Meal(
                            id: "vegan-d1",
                            name: "Lentil Bolognese with Zucchini Noodles",
                            description: "Rich lentil sauce over spiralized zucchini noodles",
                            calories: 380,
                            protein: 18,
                            carbs: 48,
                            fat: 14,
                            fiber: 12,
                            prepTime: 20,
                            cookTime: 30,
                            ingredients: [
                                "1 cup red lentils",
                                "Crushed tomatoes",
                                "Onion",
                                "Garlic",
                                "Italian herbs",
                                "3 zucchini, spiralized",
                                "Nutritional yeast"
                            ],
                            instructions: [
                                "Sauté onion and garlic",
                                "Add lentils and tomatoes",
                                "Simmer until thick",
                                "Spiralize zucchini",
                                "Serve sauce over zoodles",
                                "Top with nutritional yeast"
                            ],
                            tags: ["vegan", "italian", "low-carb-option"]
                        ),
                        snacks: [
                            Meal(
                                id: "vegan-s1",
                                name: "Energy Balls",
                                description: "No-bake date and nut energy balls",
                                calories: 140,
                                protein: 4,
                                carbs: 18,
                                fat: 8,
                                fiber: 3,
                                prepTime: 15,
                                cookTime: 0,
                                ingredients: [
                                    "Medjool dates",
                                    "Almonds",
                                    "Coconut flakes",
                                    "Cocoa powder",
                                    "Vanilla extract"
                                ],
                                instructions: [
                                    "Process dates and nuts",
                                    "Add cocoa and vanilla",
                                    "Roll into balls",
                                    "Roll in coconut",
                                    "Refrigerate"
                                ],
                                tags: ["vegan", "no-bake", "portable"]
                            )
                        ]
                    ),
                    generateVeganDay("Tuesday", 2),
                    generateVeganDay("Wednesday", 3),
                    generateVeganDay("Thursday", 4),
                    generateVeganDay("Friday", 5),
                    generateVeganDay("Saturday", 6),
                    generateVeganDay("Sunday", 7)
                ]
            ),
            generateVeganWeek(2),
            generateVeganWeek(3),
            generateVeganWeek(4)
        ]
    }

    // MARK: - Helper Functions for Additional Days

    private func generateMeal(_ name: String, _ type: String) -> Meal {
        return Meal(
            id: "\(type)-\(UUID().uuidString.prefix(8))",
            name: name,
            description: type == "paleo" ? "Paleo Meal" : type == "whole30" ? "Whole30 Meal" : "Vegan Meal",
            calories: 400,
            protein: 25,
            carbs: 45,
            fat: 15,
            fiber: 8,
            prepTime: 15,
            cookTime: 20,
            ingredients: ["Various ingredients"],
            instructions: ["Prepare as directed"],
            tags: [type]
        )
    }

    private func generatePaleoDay(_ dayName: String, _ dayNum: Int) -> DailyMealPlan {
        return DailyMealPlan(
            id: "paleo-w1-\(dayName.lowercased())",
            dayName: dayName,
            breakfast: Meal(
                id: "paleo-b\(dayNum)",
                name: "Paleo Breakfast \(dayNum)",
                description: "Nutritious paleo breakfast option",
                calories: 400,
                protein: 25,
                carbs: 30,
                fat: 20,
                fiber: 6,
                prepTime: 10,
                cookTime: 15,
                ingredients: ["Eggs", "Vegetables", "Coconut oil", "Fresh herbs"],
                instructions: ["Prepare ingredients", "Cook as directed", "Season to taste"],
                tags: ["paleo", "breakfast"]
            ),
            lunch: generateMeal("Paleo Lunch \(dayNum)", "paleo"),
            dinner: generateMeal("Paleo Dinner \(dayNum)", "paleo"),
            snacks: [generateMeal("Paleo Snack \(dayNum)", "paleo")]
        )
    }

    private func generateWhole30Day(_ dayName: String, _ dayNum: Int) -> DailyMealPlan {
        return DailyMealPlan(
            id: "whole30-w1-\(dayName.lowercased())",
            dayName: dayName,
            breakfast: Meal(
                id: "whole30-b\(dayNum)",
                name: "Whole30 Breakfast \(dayNum)",
                description: "Compliant Whole30 breakfast",
                calories: 380,
                protein: 24,
                carbs: 25,
                fat: 22,
                fiber: 5,
                prepTime: 10,
                cookTime: 15,
                ingredients: ["Protein", "Vegetables", "Compliant fat", "Herbs"],
                instructions: ["Prepare ingredients", "Cook according to Whole30", "Season without sugar"],
                tags: ["whole30", "paleo", "breakfast"]
            ),
            lunch: generateMeal("Whole30 Lunch \(dayNum)", "whole30"),
            dinner: generateMeal("Whole30 Dinner \(dayNum)", "whole30"),
            snacks: [generateMeal("Whole30 Snack \(dayNum)", "whole30")]
        )
    }

    private func generateVeganDay(_ dayName: String, _ dayNum: Int) -> DailyMealPlan {
        return DailyMealPlan(
            id: "vegan-w1-\(dayName.lowercased())",
            dayName: dayName,
            breakfast: Meal(
                id: "vegan-b\(dayNum)",
                name: "Vegan Breakfast \(dayNum)",
                description: "Plant-based breakfast full of nutrients",
                calories: 400,
                protein: 15,
                carbs: 55,
                fat: 16,
                fiber: 8,
                prepTime: 10,
                cookTime: 15,
                ingredients: ["Plant milk", "Oats", "Fruits", "Nuts", "Seeds"],
                instructions: ["Prepare base", "Add toppings", "Season with spices"],
                tags: ["vegan", "plant-based", "breakfast"]
            ),
            lunch: generateMeal("Vegan Lunch \(dayNum)", "vegan"),
            dinner: generateMeal("Vegan Dinner \(dayNum)", "vegan"),
            snacks: [generateMeal("Vegan Snack \(dayNum)", "vegan")]
        )
    }

    private func generatePaleoWeek(_ weekNumber: Int) -> WeeklyMealPlan {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return WeeklyMealPlan(
            id: "paleo-week-\(weekNumber)",
            weekNumber: weekNumber,
            days: days.enumerated().map { index, day in
                generatePaleoDay(day, (weekNumber - 1) * 7 + index + 1)
            }
        )
    }

    private func generateWhole30Week(_ weekNumber: Int) -> WeeklyMealPlan {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return WeeklyMealPlan(
            id: "whole30-week-\(weekNumber)",
            weekNumber: weekNumber,
            days: days.enumerated().map { index, day in
                generateWhole30Day(day, (weekNumber - 1) * 7 + index + 1)
            }
        )
    }

    private func generateVeganWeek(_ weekNumber: Int) -> WeeklyMealPlan {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return WeeklyMealPlan(
            id: "vegan-week-\(weekNumber)",
            weekNumber: weekNumber,
            days: days.enumerated().map { index, day in
                generateVeganDay(day, (weekNumber - 1) * 7 + index + 1)
            }
        )
    }
}

// MARK: - Update MealPlanData to include new plans
extension MealPlanData {
    // Override the allMealPlans to include the new plans
    static var updatedAllMealPlans: [MealPlanType] {
        let data = MealPlanData.shared
        return [
            data.mediterraneanPlan(),
            data.ketoPlan(),
            data.intermittentFastingPlan(),
            data.familyFriendlyPlan(),
            data.vegetarianPlan(),
            data.paleoPlan(),      // New
            data.whole30Plan(),    // New
            data.veganPlan()       // New
        ]
    }
}