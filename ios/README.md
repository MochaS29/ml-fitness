# MindLabs Health

Your Personal Nutrition & Wellness Companion - A comprehensive iOS health and nutrition tracking app built with SwiftUI and Core Data.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![iOS](https://img.shields.io/badge/iOS-15.0%2B-green)
![Swift](https://img.shields.io/badge/Swift-5.7%2B-orange)
![License](https://img.shields.io/badge/license-Proprietary-red)

© 2024 Mocha's Mind Lab. All rights reserved.

## Features

### 🍎 Food Tracking
- Built-in database with 90+ common foods
- Smart search functionality
- Nutritional information display (calories, protein, carbs, fats)
- Custom food creation
- Barcode scanner (requires camera permissions)
- USDA database integration (desktop only)

### 💪 Exercise Tracking
- 70+ built-in exercises across categories:
  - Cardio (running, cycling, swimming)
  - Strength training
  - Flexibility (yoga, stretching)
  - Sports activities
- Automatic calorie calculation
- Duration tracking
- Exercise history

### 📊 Dashboard & Analytics
- Daily nutrition summary
- Progress tracking against goals
- Visual charts and metrics
- Multiple dashboard themes
- RDA (Recommended Daily Allowance) tracking

### 🥗 Enhanced Meal Planning & Recipes (NEW)
- **Dynamic Recipe System with 1000+ Recipes**
  - Local Core Data storage for offline access
  - Optional API sync for new recipes
  - 5 comprehensive meal plans (Mediterranean, Keto, Intermittent Fasting, Family-Friendly, Vegetarian)
  - Full monthly menus (4 weeks per plan)
  - Complete nutrition information
  - Step-by-step instructions
- **Recipe Features**
  - Advanced search and filtering
  - Dietary tags (gluten-free, vegan, etc.)
  - Difficulty levels and time estimates
  - User favorites and personal notes
  - Cooking history tracking
  - Ingredient substitutions
- **Meal Planning Tools**
  - Weekly meal planner
  - Smart meal suggestions
  - Automatic shopping list generation
  - Recipe scaling for servings
  - Prep time optimization

### 🎯 Goals & Tracking
- Custom nutrition goals
- Weight tracking
- Water intake monitoring
- Intermittent fasting support
- Achievement system

### 👤 User Profiles
- Personal health metrics
- Activity level settings
- Dietary preferences
- Allergy management
- Recipe preferences and restrictions

### 💊 Supplement Tracking (NEW)
- **Comprehensive Supplement Database**
  - Top multivitamins for men and women
  - Canadian brands (Jamieson, Webber Naturals, etc.)
  - Your personal supplements pre-loaded
- **Barcode Scanning**
  - Quick entry via barcode/DPN scanning
  - Canadian Drug Product Numbers (DPN) support
- **Smart Selection Lists**
  - Searchable supplement database
  - Recent and favorite supplements
  - Custom supplement creation
- **Tracking Features**
  - Daily supplement logging
  - Nutrient totals calculation
  - RDA percentage tracking
  - Interaction warnings

## Technical Architecture

### Data Storage
- **Core Data** for local persistence
- **CloudKit** for backup and sync (optional)
- **Hybrid Recipe System**:
  - Local Core Data for instant access
  - Optional API backend for updates
  - Bundled recipes for offline use

### Recipe System Components
- `RecipeDataService.swift` - Main service layer
- `RecipeEntity` - Core Data model
- `EnhancedMealPlanningView.swift` - UI components
- Optional backend API for content updates

## Setup Instructions

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Installation

1. Clone the repository
2. Open `HealthTracker.xcodeproj` in Xcode
3. Build and run on simulator or device

### Core Data Setup
The app will automatically:
1. Create the Core Data stack on first launch
2. Load bundled recipes (if included)
3. Sync with API if configured

### Recipe API Configuration (Optional)

To enable dynamic recipe updates:

1. Set API endpoint in Info.plist:
```xml
<key>RecipeAPIURL</key>
<string>https://your-api-endpoint.com</string>
```

2. Or configure programmatically:
```swift
UserDefaults.standard.set("https://api.example.com", forKey: "recipe_api_url")
UserDefaults.standard.set(true, forKey: "recipe_api_enabled")
```

## Project Structure

```
HealthTracker/
├── Models/
│   ├── HealthTracker.xcdatamodeld  # Core Data models
│   ├── RecipeEntity.swift          # Recipe data model
│   ├── FoodDatabase.swift          # Food database
│   └── ExerciseDatabase.swift      # Exercise database
├── Views/
│   ├── Dashboard/                  # Dashboard views
│   ├── Food/                       # Food tracking views
│   ├── Exercise/                   # Exercise tracking views
│   ├── MealPlanning/              # Meal planning views
│   │   ├── MealPlanningView.swift
│   │   └── EnhancedMealPlanningView.swift
│   └── Profile/                    # User profile views
├── Services/
│   ├── RecipeDataService.swift    # Recipe management
│   ├── HealthKitManager.swift     # HealthKit integration
│   └── NotificationManager.swift  # Notifications
├── Data/
│   ├── MealPlanData.swift         # Static meal plans
│   └── InitialRecipes.json        # Bundled recipes (optional)
└── Resources/
    └── Assets.xcassets             # Images and colors
```

## Key Features Implementation

### Recipe System
- Hybrid storage approach (Core Data + optional API)
- Offline-first architecture
- User data (favorites, notes) stored locally
- Background sync for new content

### Performance Optimizations
- Lazy loading for large datasets
- Image caching
- Background processing for sync
- Efficient Core Data queries

## Testing

Run the test suite:
```bash
cmd+U in Xcode
```

## Documentation

- [Recipe Integration Guide](RECIPE_INTEGRATION.md)
- [Recipe System Architecture](../../RECIPE_SYSTEM_ARCHITECTURE.md)
- [API Documentation](../../Web-Projects/health-app-backend/README.md)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Privacy & Data

- All personal data stored locally on device
- Optional CloudKit sync (user controlled)
- Recipe content can be fetched from API
- No tracking or analytics
- Camera access only for barcode scanning

## License

© 2024 MindLabs. All rights reserved.

## Support

For issues or questions, please create an issue in the repository.

## Upcoming Features

- [ ] Social recipe sharing
- [ ] Meal prep planning
- [ ] Grocery delivery integration
- [ ] Restaurant menu analysis
- [ ] AI-powered meal suggestions
- [ ] Family meal planning
- [ ] Budget tracking for meals