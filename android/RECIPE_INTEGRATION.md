# Android Recipe Integration Guide

## Overview

This guide explains how to integrate and use the recipe system in the MLHealthAndroid app. The system uses Room Database for local storage with optional API synchronization for fetching new recipes.

## Setup Instructions

### 1. Add Dependencies

Update `app/build.gradle.kts`:

```kotlin
dependencies {
    // Room Database
    implementation("androidx.room:room-runtime:2.6.0")
    implementation("androidx.room:room-ktx:2.6.0")
    kapt("androidx.room:room-compiler:2.6.0")

    // Gson for JSON parsing
    implementation("com.google.code.gson:gson:2.10.1")

    // Retrofit for API (optional)
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

### 2. Database Configuration

Update your database class to include Recipe:

```kotlin
@Database(
    entities = [
        RecipeEntity::class,
        // ... other entities
    ],
    version = 2, // Increment version
    exportSchema = false
)
@TypeConverters(RecipeTypeConverters::class)
abstract class MLFitnessDatabase : RoomDatabase() {
    abstract fun recipeDao(): RecipeDao
    // ... other DAOs

    companion object {
        @Volatile
        private var INSTANCE: MLFitnessDatabase? = null

        fun getDatabase(context: Context): MLFitnessDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    MLFitnessDatabase::class.java,
                    "mlfitness_database"
                )
                .addMigrations(MIGRATION_1_2) // Add migration
                .build()
                INSTANCE = instance
                instance
            }
        }

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create recipes table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS recipes (
                        id TEXT PRIMARY KEY NOT NULL,
                        name TEXT NOT NULL,
                        description TEXT NOT NULL,
                        imageUrl TEXT,
                        category TEXT NOT NULL,
                        cuisine TEXT,
                        prepTime INTEGER NOT NULL,
                        cookTime INTEGER NOT NULL,
                        totalTime INTEGER NOT NULL,
                        servings INTEGER NOT NULL,
                        calories INTEGER NOT NULL,
                        protein REAL NOT NULL,
                        carbs REAL NOT NULL,
                        fat REAL NOT NULL,
                        fiber REAL NOT NULL,
                        ingredients_json TEXT NOT NULL,
                        instructions_json TEXT NOT NULL,
                        dietaryTags TEXT,
                        mealPlans TEXT,
                        tags TEXT,
                        difficulty TEXT NOT NULL,
                        rating REAL NOT NULL,
                        isFavorite INTEGER NOT NULL DEFAULT 0,
                        userNotes TEXT,
                        cookedCount INTEGER NOT NULL DEFAULT 0,
                        lastCookedDate INTEGER,
                        isFromAPI INTEGER NOT NULL DEFAULT 0,
                        lastUpdated INTEGER NOT NULL
                    )
                """)
            }
        }
    }
}
```

### 3. Dependency Injection Setup

Using Hilt:

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object RecipeModule {

    @Provides
    @Singleton
    fun provideRecipeDao(database: MLFitnessDatabase): RecipeDao {
        return database.recipeDao()
    }

    @Provides
    @Singleton
    fun provideRecipeRepository(
        recipeDao: RecipeDao,
        @ApplicationContext context: Context
    ): RecipeRepository {
        return RecipeRepository(recipeDao, null) // API service optional
    }
}
```

### 4. Initial Recipe Data

Create `assets/initial_recipes.json`:

```json
[
  {
    "id": "recipe_001",
    "name": "Mediterranean Quinoa Bowl",
    "description": "Healthy and delicious quinoa bowl",
    "category": "lunch",
    "prepTime": 15,
    "cookTime": 20,
    "servings": 4,
    "nutrition": {
      "calories": 420,
      "protein": 18,
      "carbs": 58,
      "fat": 16,
      "fiber": 8
    },
    "ingredients": [
      {
        "name": "Quinoa",
        "amount": 1,
        "unit": "cup"
      }
    ],
    "instructions": [
      {
        "stepNumber": 1,
        "instruction": "Cook quinoa according to package"
      }
    ],
    "dietaryTags": ["vegetarian", "gluten-free"],
    "mealPlans": ["mediterranean"],
    "difficulty": "easy",
    "rating": 4.5
  }
]
```

## Usage Examples

### ViewModel Implementation

```kotlin
@HiltViewModel
class RecipeViewModel @Inject constructor(
    private val repository: RecipeRepository
) : ViewModel() {

    private val _recipes = MutableStateFlow<List<RecipeEntity>>(emptyList())
    val recipes: StateFlow<List<RecipeEntity>> = _recipes

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading

    init {
        loadRecipes()
    }

    fun loadRecipes(
        category: String? = null,
        mealPlan: String? = null,
        searchText: String? = null,
        favoritesOnly: Boolean = false
    ) {
        viewModelScope.launch {
            _recipes.value = repository.getLocalRecipes(
                category = category,
                mealPlan = mealPlan,
                searchText = searchText,
                favoritesOnly = favoritesOnly
            )
        }
    }

    fun toggleFavorite(recipeId: String) {
        viewModelScope.launch {
            repository.toggleFavorite(recipeId)
            loadRecipes() // Reload to update UI
        }
    }

    fun markAsCooked(recipeId: String) {
        viewModelScope.launch {
            repository.markAsCooked(recipeId)
        }
    }

    fun updateNotes(recipeId: String, notes: String) {
        viewModelScope.launch {
            repository.updateNotes(recipeId, notes)
        }
    }

    fun fetchNewRecipes(mealPlan: String? = null) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                repository.fetchAndSaveRecipesFromAPI(mealPlan)
                loadRecipes() // Reload after fetching
            } finally {
                _isLoading.value = false
            }
        }
    }
}
```

### Composable UI

```kotlin
@Composable
fun RecipeListScreen(
    viewModel: RecipeViewModel = hiltViewModel()
) {
    val recipes by viewModel.recipes.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    LaunchedEffect(Unit) {
        // Load bundled recipes on first launch
        viewModel.loadInitialRecipes()
    }

    Column {
        // Filter chips
        FilterSection(
            onCategorySelected = { category ->
                viewModel.loadRecipes(category = category)
            },
            onMealPlanSelected = { mealPlan ->
                viewModel.loadRecipes(mealPlan = mealPlan)
            }
        )

        // Recipe list
        LazyColumn {
            items(recipes) { recipe ->
                RecipeCard(
                    recipe = recipe,
                    onFavoriteClick = {
                        viewModel.toggleFavorite(recipe.id)
                    },
                    onClick = {
                        // Navigate to detail
                    }
                )
            }
        }

        // Loading indicator
        if (isLoading) {
            CircularProgressIndicator()
        }
    }
}

@Composable
fun RecipeCard(
    recipe: RecipeEntity,
    onFavoriteClick: () -> Unit,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Recipe image
            AsyncImage(
                model = recipe.imageUrl,
                contentDescription = recipe.name,
                modifier = Modifier.size(80.dp)
            )

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 16.dp)
            ) {
                Text(
                    text = recipe.name,
                    style = MaterialTheme.typography.headlineSmall
                )
                Text(
                    text = recipe.description,
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 2
                )
                Row {
                    Icon(
                        imageVector = Icons.Default.Timer,
                        contentDescription = "Time"
                    )
                    Text("${recipe.totalTime} min")
                    Spacer(modifier = Modifier.width(16.dp))
                    Icon(
                        imageVector = Icons.Default.LocalFireDepartment,
                        contentDescription = "Calories"
                    )
                    Text("${recipe.calories} cal")
                }
            }

            // Favorite button
            IconButton(onClick = onFavoriteClick) {
                Icon(
                    imageVector = if (recipe.isFavorite) {
                        Icons.Filled.Favorite
                    } else {
                        Icons.Outlined.FavoriteBorder
                    },
                    contentDescription = "Favorite",
                    tint = if (recipe.isFavorite) Color.Red else Color.Gray
                )
            }
        }
    }
}
```

### Recipe Detail Screen

```kotlin
@Composable
fun RecipeDetailScreen(
    recipeId: String,
    viewModel: RecipeViewModel = hiltViewModel()
) {
    var recipe by remember { mutableStateOf<RecipeEntity?>(null) }
    var showNotesDialog by remember { mutableStateOf(false) }

    LaunchedEffect(recipeId) {
        recipe = viewModel.getRecipe(recipeId)
    }

    recipe?.let { r ->
        LazyColumn(
            modifier = Modifier.fillMaxSize()
        ) {
            item {
                // Header image
                AsyncImage(
                    model = r.imageUrl,
                    contentDescription = r.name,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(250.dp)
                )
            }

            item {
                // Recipe info
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = r.name,
                        style = MaterialTheme.typography.headlineMedium
                    )

                    Row(
                        modifier = Modifier.padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Chip(onClick = {}) {
                            Text("${r.prepTime + r.cookTime} min")
                        }
                        Chip(onClick = {}) {
                            Text("${r.servings} servings")
                        }
                        Chip(onClick = {}) {
                            Text(r.difficulty)
                        }
                    }

                    // Action buttons
                    Row {
                        Button(
                            onClick = {
                                viewModel.toggleFavorite(r.id)
                            }
                        ) {
                            Icon(
                                imageVector = if (r.isFavorite) {
                                    Icons.Filled.Favorite
                                } else {
                                    Icons.Outlined.FavoriteBorder
                                },
                                contentDescription = "Favorite"
                            )
                            Text(if (r.isFavorite) "Favorited" else "Favorite")
                        }

                        Button(
                            onClick = {
                                viewModel.markAsCooked(r.id)
                            }
                        ) {
                            Text("Mark as Cooked")
                        }

                        Button(
                            onClick = { showNotesDialog = true }
                        ) {
                            Text("Add Notes")
                        }
                    }
                }
            }

            item {
                // Nutrition info
                NutritionCard(
                    calories = r.calories,
                    protein = r.protein,
                    carbs = r.carbs,
                    fat = r.fat,
                    fiber = r.fiber
                )
            }

            item {
                // Ingredients
                val ingredients = r.getIngredientsList()
                if (ingredients.isNotEmpty()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            "Ingredients",
                            style = MaterialTheme.typography.headlineSmall
                        )
                        ingredients.forEach { ingredient ->
                            Text(
                                "• ${ingredient.amount} ${ingredient.unit} ${ingredient.name}",
                                modifier = Modifier.padding(vertical = 4.dp)
                            )
                        }
                    }
                }
            }

            item {
                // Instructions
                val instructions = r.getInstructionsList()
                if (instructions.isNotEmpty()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            "Instructions",
                            style = MaterialTheme.typography.headlineSmall
                        )
                        instructions.forEach { instruction ->
                            Row(
                                modifier = Modifier.padding(vertical = 8.dp)
                            ) {
                                Text(
                                    "${instruction.stepNumber}.",
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.width(30.dp)
                                )
                                Text(instruction.instruction)
                            }
                        }
                    }
                }
            }
        }

        // Notes dialog
        if (showNotesDialog) {
            NotesDialog(
                currentNotes = r.userNotes ?: "",
                onSave = { notes ->
                    viewModel.updateNotes(r.id, notes)
                    showNotesDialog = false
                },
                onDismiss = { showNotesDialog = false }
            )
        }
    }
}
```

## API Configuration (Optional)

### Retrofit Setup

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://your-api.com/api/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideRecipeApiService(retrofit: Retrofit): RecipeApiService {
        return retrofit.create(RecipeApiService::class.java)
    }
}
```

### API Service Interface

```kotlin
interface RecipeApiService {
    @GET("recipes")
    suspend fun getRecipes(
        @Query("mealPlan") mealPlan: String? = null,
        @Query("category") category: String? = null,
        @Query("limit") limit: Int = 50
    ): RecipeApiResponse
}
```

## Offline Mode

To run completely offline:

```kotlin
class RecipeRepository(
    private val recipeDao: RecipeDao,
    private val apiService: RecipeApiService? = null // Pass null for offline
) {
    // Repository will work with local data only
}
```

## Performance Optimization

### 1. Paging

```kotlin
@Query("""
    SELECT * FROM recipes
    ORDER BY rating DESC
    LIMIT :limit OFFSET :offset
""")
suspend fun getRecipesPaged(limit: Int, offset: Int): List<RecipeEntity>
```

### 2. Image Caching

Use Coil with caching:

```kotlin
AsyncImage(
    model = ImageRequest.Builder(LocalContext.current)
        .data(recipe.imageUrl)
        .diskCachePolicy(CachePolicy.ENABLED)
        .memoryCachePolicy(CachePolicy.ENABLED)
        .build(),
    contentDescription = recipe.name
)
```

### 3. Background Sync

```kotlin
class RecipeSyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val repository = // Get repository
        repository.fetchAndSaveRecipesFromAPI()
        return Result.success()
    }
}

// Schedule periodic sync
val syncRequest = PeriodicWorkRequestBuilder<RecipeSyncWorker>(
    24, TimeUnit.HOURS
).build()

WorkManager.getInstance(context).enqueue(syncRequest)
```

## Troubleshooting

### Database Migration Issues

```kotlin
// If migration fails, use fallback
.fallbackToDestructiveMigration()
```

### JSON Parsing Errors

```kotlin
try {
    val ingredients = gson.fromJson(
        ingredientsJson,
        Array<Ingredient>::class.java
    ).toList()
} catch (e: JsonSyntaxException) {
    // Handle error
    emptyList()
}
```

## Testing

```kotlin
@Test
fun testRecipeDao() = runTest {
    val recipe = RecipeEntity(
        id = "test_001",
        name = "Test Recipe",
        // ... other fields
    )

    recipeDao.insertRecipe(recipe)
    val loaded = recipeDao.getRecipeById("test_001")

    assertEquals(recipe.name, loaded?.name)
}
```

## Integration Checklist

- [ ] Add Room dependencies to build.gradle
- [ ] Update database version and migration
- [ ] Copy RecipeEntity.kt to project
- [ ] Add RecipeDao to database
- [ ] Set up RecipeRepository
- [ ] Create RecipeViewModel
- [ ] Add initial_recipes.json to assets
- [ ] Implement recipe list screen
- [ ] Implement recipe detail screen
- [ ] Test offline functionality
- [ ] Test favorite/notes features
- [ ] Configure API (optional)

## Related Files

- `data/local/RecipeEntity.kt` - Room entity and DAO
- `data/MealPlanData.kt` - Static meal plan data
- `ui/screens/MealPlanScreen.kt` - Meal planning UI
- `assets/initial_recipes.json` - Bundled recipes