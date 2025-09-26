# ML Health Android

A comprehensive Android health and fitness tracking app built with Kotlin, Jetpack Compose, and Room Database.

## Features

### 🍎 Nutrition Tracking
- Comprehensive food database
- Barcode scanning for quick entry
- Custom food creation
- Meal categorization (breakfast, lunch, dinner, snacks)
- Nutritional breakdown (calories, macros, vitamins, minerals)
- Food search and filtering

### 💪 Exercise & Fitness
- Exercise database with 70+ activities
- Custom workout creation
- Calorie burn calculation
- Duration and intensity tracking
- Exercise history and statistics
- Workout plans and routines

### 🥗 Enhanced Meal Planning & Recipes (NEW)
- **Dynamic Recipe System with 1000+ Recipes**
  - Local Room Database for offline access
  - Optional API sync for new recipes
  - 5 comprehensive meal plans (Mediterranean, Keto, Intermittent Fasting, Family-Friendly, Vegetarian)
  - Full monthly menus (4 weeks per plan)
  - Complete nutrition information
  - Step-by-step cooking instructions
- **Recipe Features**
  - Advanced search and filtering
  - Dietary tags (gluten-free, vegan, dairy-free, etc.)
  - Difficulty levels (easy, medium, hard)
  - Prep and cook time estimates
  - User favorites system
  - Personal notes on recipes
  - Cooking history tracking
- **Meal Planning Tools**
  - Weekly and monthly meal planners
  - Smart meal suggestions based on preferences
  - Automatic shopping list generation
  - Recipe scaling for different serving sizes
  - Meal prep optimization

### 📊 Analytics & Insights
- Daily nutrition summary dashboard
- Progress tracking with visual charts
- Goal achievement monitoring
- Weekly and monthly reports
- Trend analysis for health metrics
- Nutrient intake visualization

### 💊 Supplement Management
- Supplement tracking and reminders
- Dosage scheduling
- Vitamin/mineral intake monitoring
- Supplement regime management
- Interaction warnings

### 🎯 Goal Setting
- Custom nutrition goals
- Weight management targets
- Fitness objectives
- Water intake goals
- Intermittent fasting support

### 👤 User Profile
- Personal health metrics
- Activity level configuration
- Dietary preferences and restrictions
- Allergy management
- Recipe preferences

## Technical Architecture

### Tech Stack
- **Language**: Kotlin
- **UI**: Jetpack Compose
- **Database**: Room
- **Architecture**: MVVM with Clean Architecture
- **DI**: Hilt
- **Networking**: Retrofit (optional for API)
- **Image Loading**: Coil

### Data Storage
- **Room Database** for local persistence
- **SharedPreferences** for settings
- **Hybrid Recipe System**:
  - Local Room Database for instant access
  - Optional API backend for updates
  - Bundled recipes for offline use

### Recipe System Components
- `RecipeEntity.kt` - Room entity and data models
- `RecipeDao.kt` - Database access object
- `RecipeRepository.kt` - Repository pattern implementation
- `RecipeViewModel.kt` - ViewModel for UI state
- Optional API service for content updates

## Setup Instructions

### Requirements
- Android Studio Arctic Fox or later
- Kotlin 1.8+
- Minimum SDK: API 24 (Android 7.0)
- Target SDK: API 34 (Android 14)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd MLHealthAndroid
```

2. Open in Android Studio
3. Sync project with Gradle files
4. Run on emulator or physical device

### Database Setup
The app will automatically:
1. Create Room database on first launch
2. Load bundled recipes from assets/initial_recipes.json
3. Sync with API if configured

### Recipe API Configuration (Optional)

To enable dynamic recipe updates:

1. Add API URL to local.properties:
```properties
recipe.api.url=https://your-api-endpoint.com
recipe.api.enabled=true
```

2. Or configure in code:
```kotlin
class AppModule {
    @Provides
    fun provideRecipeApiService(): RecipeApiService? {
        return if (BuildConfig.RECIPE_API_ENABLED) {
            Retrofit.Builder()
                .baseUrl(BuildConfig.RECIPE_API_URL)
                .build()
                .create(RecipeApiService::class.java)
        } else null
    }
}
```

## Project Structure

```
MLHealthAndroid/
├── app/
│   ├── src/main/java/com/mlhealth/
│   │   ├── data/
│   │   │   ├── local/
│   │   │   │   ├── RecipeEntity.kt      # Room entities
│   │   │   │   ├── RecipeDao.kt         # DAOs
│   │   │   │   └── MLFitnessDatabase.kt # Database
│   │   │   ├── remote/
│   │   │   │   └── RecipeApiService.kt  # API service
│   │   │   └── repository/
│   │   │       └── RecipeRepository.kt  # Repository
│   │   ├── ui/
│   │   │   ├── screens/
│   │   │   │   ├── MealPlanScreen.kt
│   │   │   │   ├── RecipeListScreen.kt
│   │   │   │   └── RecipeDetailScreen.kt
│   │   │   ├── components/
│   │   │   └── theme/
│   │   ├── viewmodel/
│   │   │   └── RecipeViewModel.kt
│   │   └── di/
│   │       └── AppModule.kt
│   └── assets/
│       └── initial_recipes.json         # Bundled recipes
└── build.gradle.kts
```

## Key Features Implementation

### Recipe System
- Hybrid storage approach (Room + optional API)
- Offline-first architecture
- User data (favorites, notes) stored locally
- Background sync using WorkManager
- Efficient data caching

### Performance Optimizations
- Lazy loading with Paging 3
- Image caching with Coil
- Background processing for sync
- Efficient Room queries with Flow
- Compose performance optimizations

## Testing

Run tests:
```bash
./gradlew test                # Unit tests
./gradlew connectedAndroidTest # Instrumented tests
```

## Documentation

- [Recipe Integration Guide](RECIPE_INTEGRATION.md)
- [Recipe System Architecture](../../RECIPE_SYSTEM_ARCHITECTURE.md)
- [Backend API Documentation](../../Web-Projects/health-app-backend/README.md)

## Build & Release

### Debug Build
```bash
./gradlew assembleDebug
```

### Release Build
```bash
./gradlew assembleRelease
```

## Dependencies

Key dependencies:
```kotlin
// Room
implementation("androidx.room:room-runtime:2.6.0")
implementation("androidx.room:room-ktx:2.6.0")

// Compose
implementation("androidx.compose.ui:ui:1.5.4")
implementation("androidx.compose.material3:material3:1.1.2")

// Hilt
implementation("com.google.dagger:hilt-android:2.48")

// Networking (optional)
implementation("com.squareup.retrofit2:retrofit:2.9.0")

// Image Loading
implementation("io.coil-kt:coil-compose:2.4.0")
```

## Privacy & Data

- All personal data stored locally on device
- Optional API sync (user controlled)
- Recipe content cached locally
- No tracking or analytics
- Camera permission only for barcode scanning

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## License

© 2024 ML Health. All rights reserved.

## Support

For issues or questions, please create an issue in the repository.

## Upcoming Features

- [ ] Wearable device integration
- [ ] Social recipe sharing
- [ ] Restaurant menu integration
- [ ] AI-powered meal recommendations
- [ ] Family meal planning
- [ ] Budget tracking
- [ ] Grocery list sharing
- [ ] Meal prep scheduling