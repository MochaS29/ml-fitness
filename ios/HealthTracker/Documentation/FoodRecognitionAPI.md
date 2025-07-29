# Food Recognition API Integration

## Overview

The HealthTracker app includes an enhanced food recognition service that can analyze dish photos and provide nutritional information. The service is designed to work with multiple food recognition APIs and includes fallback mechanisms for offline use.

## Architecture

### Service Layer

**FoodRecognitionService.swift**
- Singleton service that handles all food recognition operations
- Protocol-based design for easy testing and API switching
- Async/await support for modern Swift concurrency
- Built-in error handling and retry logic

### Configuration

**APIConfiguration.swift**
- Centralized API configuration
- Support for multiple food APIs:
  - Food Recognition API (primary)
  - Nutritionix API (nutrition database)
  - USDA FoodData Central (comprehensive food database)
- Environment-based API key management

## Features

### 1. Dish Analysis
- Analyzes photos using computer vision
- Identifies multiple food items in a single image
- Provides confidence scores for each identified item
- Estimates portion sizes based on visual analysis
- Returns comprehensive nutritional information

### 2. Portion Adjustment
- Interactive UI for adjusting portion sizes
- Real-time nutrition calculation updates
- Slider-based interface (10g to 500g range)
- Preserves confidence scores and food categories

### 3. Mock Data Support
- Built-in mock data for development and testing
- Realistic food items with accurate nutrition data
- Simulates API responses with proper delays
- Categorized foods (proteins, grains, vegetables)

### 4. Error Handling
- Graceful degradation to mock data when offline
- User-friendly error messages
- Automatic retry for transient failures
- Image validation before processing

## API Integration

### Setup

1. **Environment Variables**
   ```bash
   export FOOD_API_KEY="your-api-key-here"
   export NUTRITIONIX_APP_ID="your-app-id"
   export NUTRITIONIX_APP_KEY="your-app-key"
   export USDA_API_KEY="your-usda-key"
   ```

2. **Enable Mock Mode** (for development)
   ```bash
   export USE_MOCK_DATA=true
   ```

### API Endpoints

The service is configured to work with these endpoints:

**Food Recognition API**
- `/analyze` - Analyze dish photos
- `/search` - Search food database
- `/nutrients` - Get detailed nutrition info
- `/barcode` - Scan product barcodes

**Parameters**
- `confidenceThreshold`: 0.7 (default)
- `maxResults`: 10
- `includeNutrition`: true
- `includeBoundingBox`: true

### Response Format

```swift
struct FoodScanResult {
    let id: UUID
    let timestamp: Date
    let identifiedFoods: [IdentifiedFood]
    let totalNutrition: NutritionInfo
}

struct IdentifiedFood {
    let name: String
    let confidence: Double
    let estimatedWeight: Double // grams
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let category: FoodCategory
}
```

## Usage

### Basic Usage

```swift
// Analyze a dish photo
let foodService = FoodRecognitionService.shared
let results = try await foodService.analyzeDish(from: capturedImage)

// Search for foods
let searchResults = try await foodService.searchFood(query: "chicken breast")
```

### Error Handling

```swift
do {
    let results = try await foodService.analyzeDish(from: image)
    // Process results
} catch FoodRecognitionError.invalidImage {
    // Handle invalid image
} catch FoodRecognitionError.apiError {
    // Handle API error
} catch {
    // Handle other errors
}
```

## Testing

The service includes comprehensive mock data for testing:

- Main dishes (chicken, salmon, beef)
- Side dishes (rice, quinoa, sweet potato)
- Vegetables (broccoli, salad, mixed vegetables)

Mock mode automatically activates when:
- API keys are not configured
- Network is unavailable
- `USE_MOCK_DATA` environment variable is set

## Future Enhancements

1. **Barcode Scanning**
   - Integration with barcode scanning APIs
   - Product database lookup
   - Automatic nutrition import

2. **Machine Learning**
   - On-device food recognition using Core ML
   - Custom model training based on user corrections
   - Improved portion size estimation

3. **Multi-Language Support**
   - Food name translation
   - Localized nutrition databases
   - Regional food recognition

4. **Batch Processing**
   - Analyze multiple photos at once
   - Meal combination suggestions
   - Daily nutrition summaries

## Security

- API keys stored in environment variables
- HTTPS-only communication
- Image data never stored permanently
- User privacy protection