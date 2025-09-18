# iOS Recipe Integration Guide

## Overview

This guide explains how to integrate and use the recipe system in the HealthTracker iOS app. The system uses Core Data for local storage with optional API synchronization for fetching new recipes.

## Setup Instructions

### 1. Core Data Configuration

#### Add Recipe Entity to Core Data Model

1. Open `HealthTracker.xcdatamodeld` in Xcode
2. Add new Entity: `RecipeEntity`
3. Add the following attributes:

| Attribute | Type | Properties |
|-----------|------|------------|
| id | String | Required, Indexed |
| name | String | Required |
| recipeDescription | String | Optional |
| imageUrl | String | Optional |
| category | String | Optional |
| cuisine | String | Optional |
| prepTime | Integer 16 | Default: 0 |
| cookTime | Integer 16 | Default: 0 |
| totalTime | Integer 16 | Default: 0 |
| servings | Integer 16 | Default: 4 |
| calories | Integer 16 | Default: 0 |
| protein | Double | Default: 0 |
| carbs | Double | Default: 0 |
| fat | Double | Default: 0 |
| fiber | Double | Default: 0 |
| dietaryTags | Transformable | Array |
| mealPlans | Transformable | Array |
| tags | Transformable | Array |
| ingredients | Binary Data | JSON |
| instructions | Binary Data | JSON |
| difficulty | String | Default: "medium" |
| rating | Double | Default: 0 |
| isFavorite | Boolean | Default: NO |
| userNotes | String | Optional |
| cookedCount | Integer 16 | Default: 0 |
| lastCookedDate | Date | Optional |
| isFromAPI | Boolean | Default: NO |
| lastUpdated | Date | Optional |

4. Set `id` as the unique constraint
5. Generate NSManagedObject subclass

### 2. Service Integration

The recipe system is managed through `RecipeDataService`:

```swift
import SwiftUI

struct RecipeListView: View {
    @StateObject private var recipeService = RecipeDataService.shared
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List(recipeService.recipes) { recipe in
                RecipeRowView(recipe: recipe)
            }
            .onAppear {
                // Load local recipes
                recipeService.loadLocalRecipes(
                    category: selectedCategory,
                    searchText: searchText
                )

                // Optional: Check for updates from API
                recipeService.checkForUpdates()
            }
        }
    }
}
```

### 3. Initial Recipe Data

#### Option A: Bundle Recipes with App

1. Create `InitialRecipes.json` in your project
2. Add to target's "Copy Bundle Resources"
3. Recipes will auto-load on first launch

#### Option B: Fetch from API

Configure API endpoint in Info.plist or UserDefaults:

```swift
// AppDelegate or SceneDelegate
UserDefaults.standard.set("https://your-api.com/api", forKey: "recipe_api_url")
UserDefaults.standard.set(true, forKey: "recipe_api_enabled")
```

## Usage Examples

### Loading Recipes

```swift
// Load all recipes
recipeService.loadLocalRecipes()

// Filter by category
recipeService.loadLocalRecipes(category: "breakfast")

// Filter by meal plan
recipeService.loadLocalRecipes(mealPlan: "mediterranean")

// Search recipes
recipeService.loadLocalRecipes(searchText: "salmon")

// Show only favorites
recipeService.loadLocalRecipes(favoritesOnly: true)

// Combine filters
recipeService.loadLocalRecipes(
    category: "dinner",
    mealPlan: "keto",
    searchText: "chicken",
    favoritesOnly: false
)
```

### User Interactions

```swift
// Toggle favorite
recipeService.toggleFavorite(for: recipeId)

// Add personal notes
recipeService.updateNotes(for: recipeId, notes: "Great recipe! Kids loved it.")

// Mark as cooked
recipeService.markAsCooked(recipeId: recipeId)

// Get single recipe
if let recipe = recipeService.recipes.first(where: { $0.id == recipeId }) {
    // Use recipe
}
```

### Fetching New Recipes (Optional)

```swift
// Fetch all new recipes
recipeService.fetchNewRecipesFromAPI()

// Fetch recipes for specific meal plan
recipeService.fetchNewRecipesFromAPI(mealPlan: "vegetarian")

// Check if should update (24+ hours since last sync)
recipeService.checkForUpdates()
```

### Recipe View Components

```swift
struct RecipeDetailView: View {
    let recipe: RecipeEntity
    @StateObject private var recipeService = RecipeDataService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe image
                if let imageUrl = recipe.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url)
                        .frame(height: 250)
                }

                // Recipe info
                Text(recipe.name ?? "")
                    .font(.largeTitle)

                HStack {
                    Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                    Label("\(recipe.calories) cal", systemImage: "flame")
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                }

                // Favorite button
                Button(action: {
                    recipeService.toggleFavorite(for: recipe.id!)
                }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(recipe.isFavorite ? .red : .gray)
                }

                // Ingredients
                if let ingredientsData = recipe.ingredients,
                   let ingredients = try? JSONDecoder().decode([IngredientData].self, from: ingredientsData) {
                    VStack(alignment: .leading) {
                        Text("Ingredients")
                            .font(.headline)
                        ForEach(ingredients, id: \.name) { ingredient in
                            Text("• \(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                        }
                    }
                }

                // Instructions
                if let instructionsData = recipe.instructions,
                   let instructions = try? JSONDecoder().decode([InstructionData].self, from: instructionsData) {
                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.headline)
                        ForEach(instructions, id: \.stepNumber) { instruction in
                            HStack(alignment: .top) {
                                Text("\(instruction.stepNumber).")
                                    .fontWeight(.bold)
                                Text(instruction.instruction)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
```

## Configuration Options

### API Configuration

```swift
// Enable/disable API
UserDefaults.standard.set(true, forKey: "recipe_api_enabled")

// Set API URL
UserDefaults.standard.set("https://api.example.com", forKey: "recipe_api_url")

// Force sync interval (hours)
UserDefaults.standard.set(24, forKey: "recipe_sync_interval")
```

### Offline Mode

To run completely offline:

```swift
// Disable API
UserDefaults.standard.set(false, forKey: "recipe_api_enabled")

// Load only bundled recipes
recipeService.loadLocalRecipes()
```

## Data Management

### Export Favorites

```swift
if let exportData = recipeService.exportFavorites() {
    // Save to file or share
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("favorite_recipes.json")
    try? exportData.write(to: url)
}
```

### Clear Cache

```swift
// Delete all recipes (useful for debugging)
recipeService.deleteAllRecipes()

// Re-initialize with bundled data
recipeService.setupInitialDataIfNeeded()
```

## Troubleshooting

### Recipes Not Loading

1. Check Core Data model configuration
2. Verify `RecipeEntity` attributes match
3. Check if `InitialRecipes.json` is in bundle
4. Verify JSON format is correct

### API Sync Issues

1. Check internet connection
2. Verify API URL is correct
3. Check API is running (`curl http://your-api/health`)
4. Review console logs for errors

### Performance Issues

1. Limit fetch requests with predicates
2. Use pagination for large datasets
3. Cache images separately
4. Optimize Core Data fetch requests

## Best Practices

1. **Always load from Core Data first** - Provides instant UI
2. **Sync in background** - Don't block UI for API calls
3. **Handle errors gracefully** - Continue with cached data
4. **Respect user preferences** - Keep favorites/notes local
5. **Test offline** - Ensure app works without internet

## Integration Checklist

- [ ] Add RecipeEntity to Core Data model
- [ ] Import RecipeDataService.swift
- [ ] Add RecipeData models
- [ ] Create InitialRecipes.json (optional)
- [ ] Configure API settings (optional)
- [ ] Implement recipe list view
- [ ] Implement recipe detail view
- [ ] Add favorite toggle functionality
- [ ] Test offline functionality
- [ ] Test API sync (if enabled)

## Related Files

- `Services/RecipeDataService.swift` - Main service class
- `Models/RecipeEntity.swift` - Core Data entity
- `Views/EnhancedMealPlanningView.swift` - Meal planning UI
- `Data/MealPlanData.swift` - Static meal plan data
- `Resources/InitialRecipes.json` - Bundled recipes (optional)