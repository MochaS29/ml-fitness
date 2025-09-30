# Production Branch Sync Plan
## iOS → Android Feature Parity

### Priority 1: Missing Core Features (HIGH)
These features exist in iOS production but not Android:

#### 1. Water Tracking
- **iOS**: `WaterTrackingView.swift`
- **Android Action**:
  - Create `WaterTrackingScreen.kt`
  - Implement `WaterViewModel`
  - Add water entry database entities
  - Add to navigation

#### 2. Supplement Tracking
- **iOS**: `EnhancedSupplementTrackingView.swift`
- **Android Status**: Partially implemented in feature branch
- **Android Action**:
  - Merge supplement features from feature branch
  - Complete `SupplementTrackingScreen.kt`
  - Ensure barcode scanner works for supplements

#### 3. Demo Data Generation
- **iOS**: Has sample data generator
- **Android Action**:
  - Port `SampleDataGenerator.kt`
  - Add demo mode toggle
  - Generate realistic test data

### Priority 2: UI/UX Features (MEDIUM)

#### 4. Dark Mode Support
- **iOS**: Full dark theme
- **Android Action**:
  - Implement Material You dark theme
  - Add theme toggle in settings
  - Test all screens in dark mode

#### 5. Notifications
- **iOS**: Reminder notifications
- **Android Action**:
  - Implement `NotificationService`
  - Add notification permissions
  - Create reminder scheduling

### Priority 3: Platform Integration (LOW)

#### 6. Health Platform Integration
- **iOS**: HealthKit integration
- **Android Action**:
  - Implement Google Fit integration
  - Add Health Connect API support
  - Sync steps, workouts, vitals

### Already Synced Features ✅
- Dashboard
- Food Diary
- Barcode Scanner (Food)
- Meal Planning
- Weight Tracking
- Exercise Tracking
- iPad/Tablet support

### Feature Branch Updates Ready to Merge
From `feature/comprehensive-meal-planning`:
- Enhanced barcode scanning (NIH database)
- Restaurant food service (800+ chains)
- Complete meal plan recipes
- Supplement barcode scanner
- API integrations (Nutritionix, USDA)

### Recommended Merge Strategy

1. **First**: Merge feature branch to dev
   ```bash
   git checkout dev
   git merge feature/comprehensive-meal-planning
   ```

2. **Second**: Implement missing Priority 1 features
   - Water tracking
   - Complete supplement tracking
   - Demo data

3. **Third**: Add UI/UX enhancements
   - Dark mode
   - Notifications

4. **Finally**: Platform integrations
   - Google Fit/Health Connect

### Version Alignment
- iOS Production: 1.5
- Android Production: 1.5 ✅ (Aligned!)

### Database Schema Sync
Ensure these entities exist in Android:
- [x] FoodEntry
- [x] ExerciseEntry
- [x] WeightEntry
- [ ] WaterEntry (missing)
- [x] SupplementEntry (in feature branch)
- [x] MealPlan
- [x] CustomFood
- [x] CustomRecipe

### API Keys Sync Status
- [x] USDA API Key
- [x] Spoonacular API Key
- [x] Nutritionix API Key (just added)
- [x] Open Food Facts (no key needed)

### Testing Checklist
- [ ] Test all features on Android 8+ devices
- [ ] Verify barcode scanning works
- [ ] Check meal plan display
- [ ] Confirm API fallbacks work offline
- [ ] Test dark mode (when implemented)
- [ ] Verify notifications (when implemented)

### Timeline Estimate
- Week 1: Merge feature branch, implement water tracking
- Week 2: Complete supplement tracking, add demo data
- Week 3: Dark mode and notifications
- Week 4: Google Fit integration, testing

### Next Immediate Steps
1. Create PR from feature branch to dev
2. Review and merge
3. Start water tracking implementation
4. Complete supplement tracking UI