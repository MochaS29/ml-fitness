# Recipe Import from URLs

## Overview

HealthTracker now supports importing recipes directly from popular cooking websites. Simply paste a recipe URL and the app will automatically extract all the recipe information including ingredients, instructions, nutrition facts, and more.

## Supported Websites

The following websites are currently supported:

- AllRecipes
- Food Network
- Bon Appétit
- Serious Eats
- Epicurious
- Simply Recipes
- Cooking Light
- MyRecipes
- Food52
- The Kitchn
- Minimalist Baker
- Budget Bytes
- Skinnytaste
- Pinch of Yum
- Love & Lemons

Additional websites that use Schema.org Recipe markup are also supported automatically.

## How to Import Recipes

1. **From My Recipe Book**
   - Navigate to the "My Recipe Book" section
   - Tap the link icon (🔗) in the navigation bar
   - Paste the recipe URL
   - Tap "Import Recipe"

2. **What Gets Imported**
   - Recipe name
   - Prep and cook times
   - Number of servings
   - Complete ingredient list
   - Step-by-step instructions
   - Nutritional information (if available)
   - Recipe image
   - Source attribution
   - Tags/keywords

## Technical Implementation

### Recipe Parser Architecture

The import service uses a modular parser architecture:

```swift
protocol RecipeParserProtocol {
    func parseRecipe(from url: URL) async throws -> ParsedRecipe
}
```

### Parser Types

1. **Schema.org Parser** (Default)
   - Extracts JSON-LD structured data
   - Supports Recipe schema markup
   - Handles most modern recipe websites

2. **Site-Specific Parsers**
   - Custom parsers for specific websites
   - Handle unique HTML structures
   - Optimize extraction for known formats

### Data Extraction Process

1. **URL Validation**
   - Checks if URL is valid
   - Verifies domain support

2. **Content Fetching**
   - Downloads HTML content
   - Handles redirects and cookies

3. **Recipe Extraction**
   - Searches for JSON-LD data
   - Falls back to microdata parsing
   - Extracts all recipe fields

4. **Data Processing**
   - Parses ingredient strings
   - Converts time formats (ISO 8601)
   - Estimates nutrition if missing
   - Downloads recipe images

5. **Storage**
   - Saves to Core Data
   - Maintains source attribution
   - Marks as imported (not user-created)

## Parsing Features

### Ingredient Parsing
- Extracts amount, unit, and name
- Handles various formats:
  - "2 cups flour"
  - "1/2 teaspoon salt"
  - "3 large eggs"
  - "Salt to taste"

### Time Parsing
- Converts ISO 8601 durations (PT30M → 30 minutes)
- Handles various formats:
  - "30 minutes"
  - "1 hour 15 minutes"
  - "PT1H15M"

### Nutrition Extraction
- Supports multiple formats:
  - Schema.org NutritionInformation
  - Plain text ("250 calories")
  - Nutrition labels

### Category Detection
- Analyzes recipe name and tags
- Auto-categorizes:
  - Breakfast (pancakes, omelet)
  - Lunch (sandwich, salad)
  - Dinner (main dishes)
  - Dessert (cake, cookies)
  - Snacks (appetizers)

## Error Handling

The service handles various error scenarios:

- **Invalid URL**: Clear error message
- **Unsupported Website**: Warning with option to try anyway
- **Network Errors**: Retry mechanism
- **Parsing Failures**: Graceful degradation
- **Missing Data**: Uses sensible defaults

## User Experience

### Import Flow
1. User pastes URL
2. Real-time validation feedback
3. One-tap import
4. Progress indicator during import
5. Success screen with recipe preview
6. Option to view or edit imported recipe

### Success Feedback
- Visual confirmation
- Recipe preview
- Key stats (time, servings, calories)
- Quick actions (View, Done)

## Privacy & Attribution

- Original source URL is preserved
- No modification of copyright content
- Images are cached locally
- Full attribution maintained

## Future Enhancements

1. **Browser Extension**
   - Import while browsing
   - One-click import button

2. **Batch Import**
   - Import multiple recipes
   - Recipe collection import

3. **Smart Parsing**
   - ML-based ingredient parsing
   - Automatic unit conversion
   - Nutrition estimation

4. **Social Features**
   - Share imported recipes
   - Public recipe collections

5. **Enhanced Support**
   - More international sites
   - Video recipe extraction
   - PDF recipe import