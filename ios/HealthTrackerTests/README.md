# HealthTracker Test Suite

## Overview

This test suite provides comprehensive coverage for the HealthTracker iOS app, ensuring reliability and quality for launch readiness.

## Test Categories

### 1. Unit Tests
- **Models**: NutritionInfo, FoodScanResult, Core Data entities
- **Services**: FoodRecognitionService, API integrations
- **ViewModels**: HybridDashboardViewModel, data calculations
- **Helpers**: Validation functions, formatters

### 2. UI Tests
- **Dashboard**: Navigation, metric displays, time range selection
- **Food Tracking**: Manual entry, search, image scanning
- **Exercise Tracking**: Search, categories, custom exercises
- **User Flows**: Complete workflows from start to finish

### 3. Integration Tests
- **API Configuration**: Spoonacular, USDA, Nutritionix setup
- **Error Handling**: Network failures, invalid data
- **Mock Data**: Fallback behavior when APIs unavailable

### 4. Performance Tests
- **Database**: Large dataset queries, bulk operations
- **Image Processing**: Analysis speed for food recognition
- **Dashboard Loading**: Initial load and refresh times
- **Memory Usage**: No leaks during extended use

### 5. Core Data Tests
- **CRUD Operations**: Create, read, update, delete
- **Relationships**: Food entries, exercise entries
- **Migration**: Database schema updates
- **Concurrency**: Thread-safe operations

## Running Tests

### All Tests
```bash
xcodebuild test -scheme HealthTracker -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Unit Tests Only
```bash
xcodebuild test -scheme HealthTracker -only-testing:HealthTrackerTests
```

### UI Tests Only
```bash
xcodebuild test -scheme HealthTracker -only-testing:HealthTrackerUITests
```

### Performance Tests
```bash
xcodebuild test -scheme HealthTracker -only-testing:HealthTrackerTests/PerformanceTests
```

## Test Coverage

Target coverage: 80%+

### Current Coverage Areas
- ✅ Core Data models and operations
- ✅ Food recognition service
- ✅ Dashboard view model
- ✅ API configurations
- ✅ Main user workflows
- ✅ Error handling
- ✅ Performance benchmarks

### Pending Coverage
- ⏳ Supplement tracking (not yet implemented)
- ⏳ Onboarding flow (not yet implemented)
- ⏳ Barcode scanner (not yet implemented)

## CI/CD Integration

The test suite is designed for easy integration with CI/CD pipelines:

1. **Pre-commit**: Run unit tests
2. **Pull Request**: Run full test suite
3. **Release**: Run all tests + performance benchmarks

## Test Data

Mock data is provided via `TestConfiguration.swift` and `TestHelpers.swift`:
- Sample users (regular, pregnant, various ages)
- Food items with complete nutrition data
- Exercise templates for all categories
- API response mocks

## Best Practices

1. **Isolation**: Each test is independent
2. **Repeatability**: Tests produce consistent results
3. **Speed**: Unit tests complete in <0.1s each
4. **Clarity**: Descriptive test names explain intent
5. **Maintenance**: Regular updates with new features

## Troubleshooting

### Common Issues

1. **"No such module 'HealthTracker'"**
   - Build the main app target first
   - Check scheme includes test targets

2. **UI Tests Timing Out**
   - Increase timeout in `waitForExistence()`
   - Check simulator performance

3. **Core Data Tests Failing**
   - Ensure in-memory store is used
   - Clear persistent stores between tests

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure >80% code coverage
3. Update this README
4. Run full suite before committing