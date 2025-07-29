# MindLabs Health

A comprehensive iOS health and nutrition tracking app built with SwiftUI and Core Data.

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

### 🥗 Meal Planning
- Weekly meal planner
- Recipe management
- Smart meal suggestions
- Grocery list generation
- Recipe import from web URLs

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
- Professional mode for trainers/nutritionists

## Requirements

- iOS 18.5+
- Xcode 16.1+
- Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/HealthTracker.git
cd HealthTracker
```

2. Open in Xcode:
```bash
open HealthTracker.xcodeproj
```

3. Select your development team in Signing & Capabilities
4. Build and run on your device or simulator

## Configuration

### Running on Physical Device

The app is configured to run on personal development teams. To run on your iPhone:

1. Enable Developer Mode on your iPhone (Settings → Privacy & Security → Developer Mode)
2. Connect your iPhone via USB
3. Select your device in Xcode
4. Trust the developer certificate on your iPhone after first install

### Bundle Identifier

Current bundle ID: `com.mokah.healthtracker2025`

## Architecture

- **SwiftUI** for the user interface
- **Core Data** for local data persistence
- **MVVM** architecture pattern
- **Combine** for reactive programming

## Project Structure

```
HealthTracker/
├── Models/           # Data models and Core Data entities
├── Views/            # SwiftUI views
├── ViewModels/       # View models and business logic
├── Services/         # API and external services
├── Utils/            # Helper functions and utilities
├── Styles/           # UI styling and themes
└── Resources/        # Assets and databases
```

## Known Limitations

- USDA database import only works when running from Xcode (not on device)
- Barcode scanner requires camera permissions
- Push notifications and iCloud sync require paid Apple Developer account

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Mocha's Mindful Tech design philosophy
- Uses USDA FoodData Central database
- Inspired by modern health tracking needs

---

Made with ❤️ by Mocha Shmigelsky