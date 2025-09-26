package com.mochasmindlab.mlhealth.ui.screens.food

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
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
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.mochasmindlab.mlhealth.data.models.FoodItem
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.ui.theme.*
import com.mochasmindlab.mlhealth.viewmodel.FoodSearchViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FoodSearchScreen(
    navController: NavController,
    mealType: MealType,
    viewModel: FoodSearchViewModel = hiltViewModel()
) {
    var searchQuery by remember { mutableStateOf("") }
    var showBarcodeScanner by remember { mutableStateOf(false) }
    var selectedTab by remember { mutableStateOf(0) }
    val searchResults by viewModel.searchResults.collectAsState()
    val recentFoods by viewModel.recentFoods.collectAsState()
    val favoriteFoods by viewModel.favoriteFoods.collectAsState()
    val customFoods by viewModel.customFoods.collectAsState()
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Add ${mealType.displayName}",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                },
                actions = {
                    IconButton(onClick = { showBarcodeScanner = true }) {
                        Icon(Icons.Default.QrCodeScanner, contentDescription = "Scan Barcode")
                    }
                    IconButton(onClick = { navController.navigate("add_custom_food") }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Custom Food")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Search Bar
            OutlinedTextField(
                value = searchQuery,
                onValueChange = {
                    searchQuery = it
                    if (it.length >= 2) {
                        scope.launch {
                            viewModel.searchFoods(it)
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                placeholder = { Text("Search foods...") },
                leadingIcon = {
                    Icon(Icons.Default.Search, contentDescription = "Search")
                },
                trailingIcon = {
                    if (searchQuery.isNotEmpty()) {
                        IconButton(onClick = { searchQuery = "" }) {
                            Icon(Icons.Default.Clear, contentDescription = "Clear")
                        }
                    }
                },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MochaBrown,
                    unfocusedBorderColor = Color.Gray.copy(alpha = 0.3f)
                )
            )

            // Tab Row
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MochaBrown
            ) {
                Tab(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    text = { Text("All") }
                )
                Tab(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    text = { Text("Recent") }
                )
                Tab(
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 },
                    text = { Text("Favorites") }
                )
                Tab(
                    selected = selectedTab == 3,
                    onClick = { selectedTab = 3 },
                    text = { Text("My Foods") }
                )
            }

            // Content based on selected tab
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                when (selectedTab) {
                    0 -> {
                        // All Foods / Search Results
                        if (searchQuery.isEmpty()) {
                            item {
                                QuickAddSection(
                                    onQuickCaloriesClick = {
                                        navController.navigate("quick_calories_entry")
                                    }
                                )
                            }

                            item {
                                Text(
                                    "Common Foods",
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = MochaBrown,
                                    modifier = Modifier.padding(vertical = 8.dp)
                                )
                            }

                            items(commonFoods) { food ->
                                FoodItemCard(
                                    food = food,
                                    onClick = {
                                        navController.navigate("food_detail/${food.id}/$mealType")
                                    }
                                )
                            }
                        } else {
                            items(searchResults) { food ->
                                FoodItemCard(
                                    food = food,
                                    onClick = {
                                        navController.navigate("food_detail/${food.id}/$mealType")
                                    }
                                )
                            }
                        }
                    }
                    1 -> {
                        // Recent Foods
                        items(recentFoods) { food ->
                            FoodItemCard(
                                food = food,
                                onClick = {
                                    navController.navigate("food_detail/${food.id}/$mealType")
                                }
                            )
                        }
                    }
                    2 -> {
                        // Favorite Foods
                        items(favoriteFoods) { food ->
                            FoodItemCard(
                                food = food,
                                onClick = {
                                    navController.navigate("food_detail/${food.id}/$mealType")
                                },
                                showFavoriteIcon = true
                            )
                        }
                    }
                    3 -> {
                        // Custom Foods
                        item {
                            Card(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { navController.navigate("add_custom_food") },
                                colors = CardDefaults.cardColors(
                                    containerColor = MochaBrown.copy(alpha = 0.1f)
                                )
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(16.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        Icons.Default.Add,
                                        contentDescription = "Add",
                                        tint = MochaBrown,
                                        modifier = Modifier.size(24.dp)
                                    )
                                    Spacer(modifier = Modifier.width(12.dp))
                                    Text(
                                        "Create Custom Food",
                                        fontSize = 16.sp,
                                        color = MochaBrown
                                    )
                                }
                            }
                        }

                        items(customFoods) { food ->
                            FoodItemCard(
                                food = food,
                                onClick = {
                                    navController.navigate("food_detail/${food.id}/$mealType")
                                },
                                isCustom = true
                            )
                        }
                    }
                }
            }
        }
    }

    if (showBarcodeScanner) {
        // Navigate to barcode scanner
        LaunchedEffect(Unit) {
            navController.navigate("barcode_scanner/$mealType")
            showBarcodeScanner = false
        }
    }
}

@Composable
fun QuickAddSection(
    onQuickCaloriesClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                "Quick Add",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = MochaBrown
            )
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                QuickAddButton(
                    text = "Quick Calories",
                    icon = Icons.Default.Speed,
                    onClick = onQuickCaloriesClick,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
fun QuickAddButton(
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    OutlinedCard(
        modifier = modifier.clickable { onClick() }
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                icon,
                contentDescription = text,
                tint = MochaBrown
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun FoodItemCard(
    food: FoodItem,
    onClick: () -> Unit,
    showFavoriteIcon: Boolean = false,
    isCustom: Boolean = false
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Food Icon
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(MochaBrown.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    food.emoji ?: "🍽️",
                    fontSize = 20.sp
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Food Info
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        food.name,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium
                    )
                    if (isCustom) {
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            "• Custom",
                            fontSize = 12.sp,
                            color = MochaBrown
                        )
                    }
                }
                Text(
                    "${food.brand ?: "Generic"} • ${food.servingSize} ${food.servingUnit}",
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    "${food.calories} cal",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Macros
            Column(
                horizontalAlignment = Alignment.End
            ) {
                MacroText("P", food.protein, ProteinBlue)
                MacroText("C", food.carbs, CarbsGreen)
                MacroText("F", food.fat, FatYellow)
            }

            if (showFavoriteIcon) {
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    Icons.Default.Favorite,
                    contentDescription = "Favorite",
                    tint = ErrorRed,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
fun MacroText(
    label: String,
    value: Float,
    color: Color
) {
    Text(
        "$label: ${value.toInt()}g",
        fontSize = 11.sp,
        color = color,
        fontWeight = FontWeight.Medium
    )
}

// Sample common foods data
val commonFoods = listOf(
    FoodItem(
        id = 1,
        name = "Banana",
        brand = "Generic",
        calories = 105,
        protein = 1.3f,
        carbs = 27f,
        fat = 0.4f,
        servingSize = "1",
        servingUnit = "medium",
        emoji = "🍌"
    ),
    FoodItem(
        id = 2,
        name = "Apple",
        brand = "Generic",
        calories = 95,
        protein = 0.5f,
        carbs = 25f,
        fat = 0.3f,
        servingSize = "1",
        servingUnit = "medium",
        emoji = "🍎"
    ),
    FoodItem(
        id = 3,
        name = "Chicken Breast",
        brand = "Generic",
        calories = 165,
        protein = 31f,
        carbs = 0f,
        fat = 3.6f,
        servingSize = "100",
        servingUnit = "g",
        emoji = "🍗"
    ),
    FoodItem(
        id = 4,
        name = "Brown Rice",
        brand = "Generic",
        calories = 218,
        protein = 4.5f,
        carbs = 45.8f,
        fat = 1.6f,
        servingSize = "1",
        servingUnit = "cup cooked",
        emoji = "🍚"
    ),
    FoodItem(
        id = 5,
        name = "Greek Yogurt",
        brand = "Generic",
        calories = 100,
        protein = 17f,
        carbs = 6f,
        fat = 0.7f,
        servingSize = "170",
        servingUnit = "g",
        emoji = "🥛"
    )
)