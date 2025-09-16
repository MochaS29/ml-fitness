package com.mochasmindlab.mlhealth.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.ui.theme.*
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle
import java.util.Locale

data class MealPlanDay(
    val date: LocalDate,
    val breakfast: Meal,
    val lunch: Meal,
    val dinner: Meal,
    val snacks: List<Meal>,
    val totalCalories: Int,
    val totalProtein: Int,
    val totalCarbs: Int,
    val totalFat: Int
)

data class Meal(
    val name: String,
    val calories: Int,
    val protein: Int,
    val carbs: Int,
    val fat: Int,
    val ingredients: List<String>,
    val prepTime: String,
    val recipe: String,
    val imageUrl: String? = null
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MealPlanScreen(navController: NavController) {
    var selectedDate by remember { mutableStateOf(LocalDate.now()) }
    var showMealDetail by remember { mutableStateOf<Meal?>(null) }
    
    val mealPlans = remember { generateWeeklyMealPlan() }
    val currentDayPlan = mealPlans.find { it.date == selectedDate } ?: mealPlans.first()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Meal Plan") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { /* Generate new plan */ }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Generate New Plan")
                    }
                    IconButton(onClick = { /* Settings */ }) {
                        Icon(Icons.Default.Settings, contentDescription = "Meal Plan Settings")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MindLabsPurple,
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White,
                    actionIconContentColor = Color.White
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Week selector
            item {
                LazyRow(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(mealPlans) { dayPlan ->
                        DaySelector(
                            date = dayPlan.date,
                            isSelected = dayPlan.date == selectedDate,
                            onClick = { selectedDate = dayPlan.date }
                        )
                    }
                }
            }
            
            // Daily nutrition summary
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = NutritionGreen.copy(alpha = 0.1f)
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            "Daily Nutrition",
                            fontWeight = FontWeight.Bold,
                            fontSize = 18.sp
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            NutritionStat("Calories", "${currentDayPlan.totalCalories}", EnergeticOrange)
                            NutritionStat("Protein", "${currentDayPlan.totalProtein}g", ExerciseGreen)
                            NutritionStat("Carbs", "${currentDayPlan.totalCarbs}g", HydrationBlue)
                            NutritionStat("Fat", "${currentDayPlan.totalFat}g", BalancedPurple)
                        }
                    }
                }
            }
            
            // Breakfast
            item {
                MealCard(
                    mealType = "Breakfast",
                    meal = currentDayPlan.breakfast,
                    icon = Icons.Default.WbSunny,
                    color = EnergeticOrange,
                    onClick = { showMealDetail = currentDayPlan.breakfast }
                )
            }
            
            // Lunch
            item {
                MealCard(
                    mealType = "Lunch",
                    meal = currentDayPlan.lunch,
                    icon = Icons.Default.LunchDining,
                    color = NutritionGreen,
                    onClick = { showMealDetail = currentDayPlan.lunch }
                )
            }
            
            // Dinner
            item {
                MealCard(
                    mealType = "Dinner",
                    meal = currentDayPlan.dinner,
                    icon = Icons.Default.DinnerDining,
                    color = MindfulTeal,
                    onClick = { showMealDetail = currentDayPlan.dinner }
                )
            }
            
            // Snacks
            if (currentDayPlan.snacks.isNotEmpty()) {
                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    ) {
                        Column(
                            modifier = Modifier.padding(16.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    Icons.Default.Cookie,
                                    contentDescription = "Snacks",
                                    tint = SupplementPurple,
                                    modifier = Modifier.size(24.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    "Snacks",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 18.sp
                                )
                            }
                            Spacer(modifier = Modifier.height(12.dp))
                            currentDayPlan.snacks.forEach { snack ->
                                SnackItem(
                                    snack = snack,
                                    onClick = { showMealDetail = snack }
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                            }
                        }
                    }
                }
            }
            
            // Shopping list button
            item {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .clickable { navController.navigate("grocery_list") },
                    colors = CardDefaults.cardColors(
                        containerColor = MindLabsPurple.copy(alpha = 0.1f)
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Default.ShoppingCart,
                                contentDescription = "Shopping List",
                                tint = MindLabsPurple
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Column {
                                Text(
                                    "Generate Shopping List",
                                    fontWeight = FontWeight.Medium
                                )
                                Text(
                                    "Get all ingredients for this week",
                                    fontSize = 12.sp,
                                    color = Color.Gray
                                )
                            }
                        }
                        Icon(
                            Icons.Default.ChevronRight,
                            contentDescription = null,
                            tint = Color.Gray
                        )
                    }
                }
            }
            
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }
    }
    
    // Meal detail bottom sheet
    showMealDetail?.let { meal ->
        MealDetailBottomSheet(
            meal = meal,
            onDismiss = { showMealDetail = null },
            onAddToDiary = {
                // Add to diary logic
                showMealDetail = null
            }
        )
    }
}

@Composable
private fun DaySelector(
    date: LocalDate,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .width(80.dp)
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) MindLabsPurple else Color.White
        )
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                date.dayOfWeek.getDisplayName(TextStyle.SHORT, Locale.getDefault()),
                fontSize = 12.sp,
                color = if (isSelected) Color.White else Color.Gray
            )
            Text(
                date.dayOfMonth.toString(),
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = if (isSelected) Color.White else Color.Black
            )
            Text(
                date.month.getDisplayName(TextStyle.SHORT, Locale.getDefault()),
                fontSize = 12.sp,
                color = if (isSelected) Color.White else Color.Gray
            )
        }
    }
}

@Composable
private fun NutritionStat(
    label: String,
    value: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            value,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            label,
            fontSize = 12.sp,
            color = Color.Gray
        )
    }
}

@Composable
private fun MealCard(
    mealType: String,
    meal: Meal,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(color.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    icon,
                    contentDescription = mealType,
                    tint = color,
                    modifier = Modifier.size(28.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    mealType,
                    fontSize = 12.sp,
                    color = Color.Gray
                )
                Text(
                    meal.name,
                    fontWeight = FontWeight.Medium,
                    fontSize = 16.sp
                )
                Row {
                    Text(
                        "${meal.calories} cal",
                        fontSize = 12.sp,
                        color = EnergeticOrange
                    )
                    Text(
                        " • ${meal.prepTime}",
                        fontSize = 12.sp,
                        color = Color.Gray
                    )
                }
            }
            
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = Color.Gray.copy(alpha = 0.5f)
            )
        }
    }
}

@Composable
private fun SnackItem(
    snack: Meal,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(SupplementPurple)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Text(
            snack.name,
            modifier = Modifier.weight(1f)
        )
        Text(
            "${snack.calories} cal",
            fontSize = 12.sp,
            color = Color.Gray
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MealDetailBottomSheet(
    meal: Meal,
    onDismiss: () -> Unit,
    onAddToDiary: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp)
        ) {
            // Header with back button
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(
                        onClick = onDismiss,
                        modifier = Modifier.size(40.dp)
                    ) {
                        Icon(
                            Icons.Default.Close,
                            contentDescription = "Close"
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        meal.name,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
            
            Divider()
            
            // Nutrition info
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                NutritionBadge("${meal.calories} cal", EnergeticOrange)
                NutritionBadge("${meal.protein}g protein", ExerciseGreen)
                NutritionBadge("${meal.carbs}g carbs", HydrationBlue)
                NutritionBadge("${meal.fat}g fat", BalancedPurple)
            }
            
            // Prep time
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Timer,
                    contentDescription = "Prep time",
                    tint = Color.Gray,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    "Prep time: ${meal.prepTime}",
                    color = Color.Gray
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Ingredients
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Gray.copy(alpha = 0.05f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        "Ingredients",
                        fontWeight = FontWeight.Medium,
                        fontSize = 16.sp
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    meal.ingredients.forEach { ingredient ->
                        Row(
                            modifier = Modifier.padding(vertical = 4.dp)
                        ) {
                            Text("• ", color = NutritionGreen)
                            Text(ingredient)
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Recipe
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Gray.copy(alpha = 0.05f)
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        "Recipe",
                        fontWeight = FontWeight.Medium,
                        fontSize = 16.sp
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        meal.recipe,
                        lineHeight = 20.sp
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Add to diary button
            Button(
                onClick = onAddToDiary,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MindLabsPurple
                )
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Add to Food Diary")
            }
        }
    }
}

@Composable
private fun NutritionBadge(
    text: String,
    color: Color
) {
    Text(
        text,
        fontSize = 12.sp,
        color = color,
        fontWeight = FontWeight.Medium
    )
}

private fun generateWeeklyMealPlan(): List<MealPlanDay> {
    val today = LocalDate.now()
    return (0..6).map { dayOffset ->
        val date = today.plusDays(dayOffset.toLong())
        MealPlanDay(
            date = date,
            breakfast = getBreakfastForDay(dayOffset),
            lunch = getLunchForDay(dayOffset),
            dinner = getDinnerForDay(dayOffset),
            snacks = getSnacksForDay(dayOffset),
            totalCalories = 2100,
            totalProtein = 120,
            totalCarbs = 250,
            totalFat = 70
        )
    }
}

private fun getBreakfastForDay(day: Int): Meal {
    val breakfasts = listOf(
        Meal(
            name = "Protein Oatmeal Bowl",
            calories = 420,
            protein = 25,
            carbs = 55,
            fat = 12,
            ingredients = listOf(
                "1 cup rolled oats",
                "1 scoop vanilla protein powder",
                "1 tbsp almond butter",
                "1/2 cup blueberries",
                "1 tbsp chia seeds",
                "1 cup almond milk"
            ),
            prepTime = "10 min",
            recipe = "1. Cook oats with almond milk for 5 minutes\n2. Stir in protein powder\n3. Top with almond butter, blueberries, and chia seeds"
        ),
        Meal(
            name = "Veggie Scramble & Toast",
            calories = 380,
            protein = 28,
            carbs = 35,
            fat = 15,
            ingredients = listOf(
                "3 eggs",
                "1/2 cup spinach",
                "1/4 cup mushrooms",
                "1/4 bell pepper",
                "2 slices whole grain bread",
                "1 tsp olive oil"
            ),
            prepTime = "15 min",
            recipe = "1. Heat oil in pan\n2. Sauté vegetables for 3 minutes\n3. Add beaten eggs and scramble\n4. Toast bread and serve"
        ),
        Meal(
            name = "Greek Yogurt Parfait",
            calories = 350,
            protein = 30,
            carbs = 40,
            fat = 10,
            ingredients = listOf(
                "1 cup Greek yogurt",
                "1/4 cup granola",
                "1/2 cup mixed berries",
                "1 tbsp honey",
                "2 tbsp sliced almonds"
            ),
            prepTime = "5 min",
            recipe = "1. Layer yogurt in a bowl\n2. Add granola and berries\n3. Drizzle with honey\n4. Top with almonds"
        ),
        Meal(
            name = "Avocado Toast with Eggs",
            calories = 400,
            protein = 20,
            carbs = 35,
            fat = 22,
            ingredients = listOf(
                "2 slices whole grain bread",
                "1 avocado",
                "2 eggs",
                "Cherry tomatoes",
                "Red pepper flakes",
                "Lemon juice"
            ),
            prepTime = "10 min",
            recipe = "1. Toast bread\n2. Mash avocado with lemon juice\n3. Poach or fry eggs\n4. Spread avocado on toast\n5. Top with eggs and tomatoes"
        ),
        Meal(
            name = "Protein Smoothie Bowl",
            calories = 380,
            protein = 25,
            carbs = 50,
            fat = 10,
            ingredients = listOf(
                "1 banana",
                "1/2 cup berries",
                "1 scoop protein powder",
                "1/2 cup spinach",
                "1 cup almond milk",
                "Toppings: granola, nuts, seeds"
            ),
            prepTime = "5 min",
            recipe = "1. Blend banana, berries, protein powder, spinach, and milk\n2. Pour into bowl\n3. Add toppings"
        ),
        Meal(
            name = "Quinoa Breakfast Bowl",
            calories = 390,
            protein = 18,
            carbs = 52,
            fat = 14,
            ingredients = listOf(
                "1 cup cooked quinoa",
                "1/4 cup nuts",
                "1 apple, diced",
                "Cinnamon",
                "1 tbsp maple syrup",
                "1/2 cup almond milk"
            ),
            prepTime = "20 min",
            recipe = "1. Cook quinoa\n2. Add almond milk and heat\n3. Mix in apple and cinnamon\n4. Top with nuts and maple syrup"
        ),
        Meal(
            name = "Breakfast Burrito",
            calories = 450,
            protein = 30,
            carbs = 45,
            fat = 18,
            ingredients = listOf(
                "1 whole wheat tortilla",
                "2 eggs",
                "1/4 cup black beans",
                "1/4 cup cheese",
                "Salsa",
                "1/4 avocado"
            ),
            prepTime = "15 min",
            recipe = "1. Scramble eggs\n2. Warm tortilla and beans\n3. Fill tortilla with eggs, beans, cheese\n4. Add salsa and avocado\n5. Roll and serve"
        )
    )
    return breakfasts[day % breakfasts.size]
}

private fun getLunchForDay(day: Int): Meal {
    val lunches = listOf(
        Meal(
            name = "Grilled Chicken Salad",
            calories = 480,
            protein = 40,
            carbs = 30,
            fat = 20,
            ingredients = listOf(
                "6 oz grilled chicken breast",
                "Mixed greens",
                "Cherry tomatoes",
                "Cucumber",
                "1/4 avocado",
                "Balsamic dressing"
            ),
            prepTime = "20 min",
            recipe = "1. Grill chicken breast\n2. Chop vegetables\n3. Mix greens and vegetables\n4. Slice chicken and add to salad\n5. Drizzle with dressing"
        ),
        Meal(
            name = "Turkey & Hummus Wrap",
            calories = 420,
            protein = 35,
            carbs = 40,
            fat = 15,
            ingredients = listOf(
                "Whole wheat wrap",
                "4 oz turkey breast",
                "2 tbsp hummus",
                "Lettuce, tomato",
                "Bell peppers",
                "Red onion"
            ),
            prepTime = "10 min",
            recipe = "1. Spread hummus on wrap\n2. Layer turkey and vegetables\n3. Roll tightly and cut in half"
        ),
        Meal(
            name = "Quinoa Buddha Bowl",
            calories = 450,
            protein = 20,
            carbs = 55,
            fat = 18,
            ingredients = listOf(
                "1 cup quinoa",
                "Roasted chickpeas",
                "Roasted vegetables",
                "Tahini dressing",
                "Pumpkin seeds",
                "Fresh herbs"
            ),
            prepTime = "25 min",
            recipe = "1. Cook quinoa\n2. Roast vegetables and chickpeas\n3. Arrange in bowl\n4. Drizzle with tahini\n5. Top with seeds and herbs"
        ),
        Meal(
            name = "Salmon Poke Bowl",
            calories = 500,
            protein = 35,
            carbs = 50,
            fat = 20,
            ingredients = listOf(
                "6 oz salmon",
                "1 cup brown rice",
                "Edamame",
                "Cucumber",
                "Avocado",
                "Soy sauce, sesame"
            ),
            prepTime = "15 min",
            recipe = "1. Cook rice\n2. Cube salmon\n3. Prepare vegetables\n4. Assemble bowl\n5. Drizzle with sauce"
        ),
        Meal(
            name = "Mediterranean Chicken Bowl",
            calories = 470,
            protein = 38,
            carbs = 42,
            fat = 18,
            ingredients = listOf(
                "Grilled chicken",
                "Couscous",
                "Cucumber, tomatoes",
                "Feta cheese",
                "Olives",
                "Tzatziki sauce"
            ),
            prepTime = "20 min",
            recipe = "1. Grill chicken\n2. Cook couscous\n3. Chop vegetables\n4. Assemble bowl\n5. Top with tzatziki"
        ),
        Meal(
            name = "Tuna & White Bean Salad",
            calories = 400,
            protein = 35,
            carbs = 35,
            fat = 15,
            ingredients = listOf(
                "2 cans tuna",
                "White beans",
                "Arugula",
                "Cherry tomatoes",
                "Red onion",
                "Lemon vinaigrette"
            ),
            prepTime = "10 min",
            recipe = "1. Drain tuna and beans\n2. Mix with arugula\n3. Add tomatoes and onion\n4. Toss with vinaigrette"
        ),
        Meal(
            name = "Veggie Stir-Fry Bowl",
            calories = 430,
            protein = 25,
            carbs = 50,
            fat = 16,
            ingredients = listOf(
                "Tofu or tempeh",
                "Mixed vegetables",
                "Brown rice",
                "Soy sauce",
                "Ginger, garlic",
                "Sesame oil"
            ),
            prepTime = "20 min",
            recipe = "1. Cook rice\n2. Stir-fry protein\n3. Add vegetables\n4. Season with sauce\n5. Serve over rice"
        )
    )
    return lunches[day % lunches.size]
}

private fun getDinnerForDay(day: Int): Meal {
    val dinners = listOf(
        Meal(
            name = "Baked Salmon & Vegetables",
            calories = 550,
            protein = 42,
            carbs = 35,
            fat = 25,
            ingredients = listOf(
                "8 oz salmon fillet",
                "Asparagus",
                "Sweet potato",
                "Lemon",
                "Olive oil",
                "Herbs and spices"
            ),
            prepTime = "30 min",
            recipe = "1. Preheat oven to 400°F\n2. Season salmon\n3. Arrange vegetables on sheet\n4. Bake for 20 minutes\n5. Serve with lemon"
        ),
        Meal(
            name = "Lean Beef Stir-Fry",
            calories = 520,
            protein = 40,
            carbs = 45,
            fat = 20,
            ingredients = listOf(
                "6 oz lean beef",
                "Broccoli, peppers",
                "Brown rice",
                "Soy sauce",
                "Ginger, garlic",
                "Sesame seeds"
            ),
            prepTime = "25 min",
            recipe = "1. Cook rice\n2. Slice beef thin\n3. Stir-fry beef\n4. Add vegetables\n5. Serve over rice"
        ),
        Meal(
            name = "Grilled Chicken & Quinoa",
            calories = 480,
            protein = 45,
            carbs = 40,
            fat = 15,
            ingredients = listOf(
                "8 oz chicken breast",
                "Quinoa",
                "Roasted vegetables",
                "Olive oil",
                "Herbs",
                "Lemon"
            ),
            prepTime = "30 min",
            recipe = "1. Marinate chicken\n2. Cook quinoa\n3. Grill chicken\n4. Roast vegetables\n5. Plate and serve"
        ),
        Meal(
            name = "Turkey Meatballs & Pasta",
            calories = 540,
            protein = 38,
            carbs = 55,
            fat = 18,
            ingredients = listOf(
                "Ground turkey",
                "Whole wheat pasta",
                "Marinara sauce",
                "Parmesan",
                "Basil",
                "Garlic"
            ),
            prepTime = "35 min",
            recipe = "1. Form meatballs\n2. Bake meatballs\n3. Cook pasta\n4. Heat sauce\n5. Combine and serve"
        ),
        Meal(
            name = "Shrimp & Vegetable Curry",
            calories = 470,
            protein = 35,
            carbs = 48,
            fat = 16,
            ingredients = listOf(
                "1 lb shrimp",
                "Coconut milk",
                "Curry paste",
                "Mixed vegetables",
                "Jasmine rice",
                "Cilantro"
            ),
            prepTime = "25 min",
            recipe = "1. Cook rice\n2. Sauté curry paste\n3. Add coconut milk\n4. Add vegetables\n5. Add shrimp, serve"
        ),
        Meal(
            name = "Stuffed Bell Peppers",
            calories = 450,
            protein = 30,
            carbs = 45,
            fat = 18,
            ingredients = listOf(
                "4 bell peppers",
                "Ground turkey",
                "Brown rice",
                "Onion, garlic",
                "Tomato sauce",
                "Cheese"
            ),
            prepTime = "40 min",
            recipe = "1. Hollow peppers\n2. Cook filling\n3. Stuff peppers\n4. Bake 30 minutes\n5. Top with cheese"
        ),
        Meal(
            name = "Tofu Buddha Bowl",
            calories = 460,
            protein = 25,
            carbs = 52,
            fat = 18,
            ingredients = listOf(
                "Baked tofu",
                "Brown rice",
                "Edamame",
                "Carrots, cabbage",
                "Peanut sauce",
                "Sesame seeds"
            ),
            prepTime = "30 min",
            recipe = "1. Bake tofu\n2. Cook rice\n3. Steam edamame\n4. Shred vegetables\n5. Assemble with sauce"
        )
    )
    return dinners[day % dinners.size]
}

private fun getSnacksForDay(day: Int): List<Meal> {
    val allSnacks = listOf(
        Meal(
            name = "Apple with Almond Butter",
            calories = 180,
            protein = 4,
            carbs = 25,
            fat = 8,
            ingredients = listOf("1 medium apple", "2 tbsp almond butter"),
            prepTime = "2 min",
            recipe = "Slice apple and serve with almond butter"
        ),
        Meal(
            name = "Greek Yogurt & Berries",
            calories = 150,
            protein = 15,
            carbs = 20,
            fat = 2,
            ingredients = listOf("1 cup Greek yogurt", "1/2 cup berries"),
            prepTime = "1 min",
            recipe = "Mix berries into yogurt"
        ),
        Meal(
            name = "Protein Shake",
            calories = 200,
            protein = 25,
            carbs = 15,
            fat = 5,
            ingredients = listOf("1 scoop protein powder", "1 cup almond milk", "Ice"),
            prepTime = "2 min",
            recipe = "Blend all ingredients"
        ),
        Meal(
            name = "Mixed Nuts",
            calories = 170,
            protein = 6,
            carbs = 8,
            fat = 15,
            ingredients = listOf("1/4 cup mixed nuts"),
            prepTime = "0 min",
            recipe = "Portion and enjoy"
        ),
        Meal(
            name = "Hummus & Veggies",
            calories = 120,
            protein = 5,
            carbs = 15,
            fat = 5,
            ingredients = listOf("1/4 cup hummus", "Carrot sticks", "Cucumber"),
            prepTime = "3 min",
            recipe = "Cut vegetables and serve with hummus"
        )
    )
    
    // Return 2 snacks for each day
    val startIndex = (day * 2) % allSnacks.size
    return listOf(
        allSnacks[startIndex],
        allSnacks[(startIndex + 1) % allSnacks.size]
    )
}