# ML Fitness iOS - Release Notes 📱

## Version 2.3.1 - Polish Release ✨
**Submitted for Review:** April 28, 2026
**Build:** 2.3.1 (12)
**Status:** Pending Apple review

A focused polish release on top of 2.3.0. Smarter defaults, more user-editable goals, real trend data, edit-from-diary, favourites everywhere, and a pile of dark-mode and accuracy fixes.

---

### 🎯 Editable Goals (more of them, more places they show up)
- **NEW**: Editable Exercise minutes goal (was hardcoded 30 min)
- **NEW**: Editable Protein grams goal (was hardcoded 50 g)
- All six goals — Steps, Calories, Water, Exercise, Protein, Target Weight — are now set from More → Set Goals
- Every goal is reflected directly on the Dashboard:
  - Water card: "of N glasses goal" (was just %)
  - Exercise card: "of N min goal" (was "0 sessions")
  - Calorie donut center: "X / of N cal" (was just calories)
- Health-score formula now respects your real exercise goal

### 🍽️ Diary Improvements
- **NEW**: Tap any food entry to edit servings (Stepper, 0.25 increments) and reassign meal type — macros rescale live
- **NEW**: Add to Diary auto-selects the right meal by time of day (breakfast morning, lunch midday, dinner evening, snack otherwise)
- **FIXED**: Top-bar Eaten/Protein totals stay in sync when food is added from any source (Quick Add, Meal Scanner, edit sheet) — no more mismatch with meal section sums

### ⭐ Favourites Everywhere
- **NEW**: Star button on barcode-scanned products
- **NEW**: Star button in the diary edit sheet
- All favouriting flows through the same FavouriteFoodsManager; favourites pin to the top of food search

### 🔍 Smarter Search
- **NEW**: "Your Foods" section shows up at the top of search results — items you've previously logged that match your query, ranked above generic database results, with macros from your prior entries
- One-tap re-logging of foods you eat regularly

### 📊 Real Adaptive Trends (no more placeholders)
- Steps, Calories, Water, Exercise, and Weight cards now show real % change computed from your actual data
- **Adaptive window** that scales with how long you've used the app:
  - Less than 4 weeks of data → week vs prior week
  - 4 weeks to 1 year → 30 days vs prior 30 days
  - 1 year+ → year vs prior year
- "Trends shown vs last week/month/year" caption tells you which window is active

### 🎨 Dashboard Reorganized
- Nutrition Distribution card moved up directly under the goal section
- **NEW**: Calories Eaten / Goal / Left counter at the top of the Nutrition Distribution card (turns red and reads "Over" when you exceed your goal)
- Four metric blocks (Steps, Weight, Exercise, Water) now sit below the nutrition card

### 💧 Water Tracking
- **FIXED**: Changing your water goal now propagates to the Water Intake page (was hardcoded to 8 glasses)
- **UNIFIED**: All "Log Water" entry points (Diary +, Dashboard FAB, Add to Diary) now open the same rich Water Intake page with droplet quick-add and reminder controls

### 📅 Meal Plan
- **FIXED**: Selected meal plan and current week now persist between launches (was resetting to "No Meal Plan Selected" each time)

### 🌙 Dark Mode
- **FIXED**: Weight Tracking page now renders correctly in dark mode (cards were white-on-dark and unreadable)
- The four core neutral colors (`softCream`, `lightGray`, `deepCharcoal`, `cardBackground`) are now adaptive across the app — fixes other views using `.cardStyle()` too

### ⚖️ Weight Trend
- **FIXED**: Default time range changed from Week to Month so chart shows data immediately
- **FIXED**: Week / Month filters now use rolling 7-day / 30-day windows instead of "since the start of this calendar week/month" — no more empty trend on Monday mornings
- **NEW**: Added Year option to time range picker (rolling 365-day window) — better for tracking long-term, sustainable weight loss

### 📷 Meal Scanner
- **FIXED**: "Add to Food Diary" button no longer cut off behind the home indicator on iPhones with safe-area home bars

### 🔒 Privacy
- Privacy policy expanded with detailed disclosures about our use of Apple HealthKit, the AI meal scanner, and on-device data storage.

### 🎉 Celebrations
- **FIXED**: Logging celebration only fires once per day, even across app relaunches (was re-firing every time you reopened the app and logged another meal)
- Dedupe set now persists to UserDefaults scoped to today's date — naturally rolls over at midnight
- New `loggedToday` master key collapses all food-logging celebrations into one fire per day
- Weight-loss celebrations still fire once per day, every day there's a new loss

---

### 🔧 Technical Notes
- New UserDefaults keys: `dailyExerciseGoal` (Int min), `proteinGoal` (Int g), `selectedMealPlanId`, `selectedMealPlanWeek`, `celebratedToday_keys`, `celebratedToday_date`
- `MealType.defaultForCurrentTime()` helper for time-of-day meal selection
- `FoodProduct.toFoodItem()` lets barcode results flow through the favourites system
- `DashboardViewModel.recomputeTrends()` runs on init and every CoreData save
- `DiaryView` now listens for `.NSManagedObjectContextDidSave` to refresh the daily summary
- `AchievementDetector` persists daily celebration dedupe set to UserDefaults

---

## Version 1.5.0 - Major Release 🎉
**Release Date:** [Your Release Date]
**Build:** 1.5.0 (150)

---

## 🚀 What's New

### 💧 Water Tracking - Stay Hydrated!
- **NEW**: Complete water tracking system to monitor your daily hydration
- Quick-add buttons for common amounts (glass, bottle, custom)
- Beautiful animated progress circles showing daily goals
- Smart reminders to drink water throughout the day
- Weekly hydration trends and statistics
- Customizable daily water goals in oz/ml/cups/L

### 🎨 Dark Mode - Easy on the Eyes
- **NEW**: Full dark mode support across the entire app
- Automatic switching based on system preferences
- OLED-optimized true blacks for battery saving
- Carefully designed contrast for comfortable night usage
- All charts and graphs optimized for dark theme

### 🧪 Demo Mode - Try Before You Track
- **NEW**: Generate 30 days of sample data to explore all features
- Realistic demo data for calories, exercise, weight, and water
- Perfect for new users to understand the app's capabilities
- One-tap activation from Settings
- Easy to clear when ready to track real data

### ⚙️ Enhanced Settings
- **NEW**: Comprehensive settings screen with organized sections
- Granular notification controls for different reminder types
- Privacy controls and data management options
- Quick access to all app preferences
- Account and profile management in one place

### 📊 Feature Parity with Android
- Complete synchronization of features between iOS and Android versions
- Consistent UI/UX across both platforms
- Shared codebase improvements for better reliability

---

## 🔧 Improvements

### Performance Enhancements
- **30% faster** app launch time
- **Improved** barcode scanning speed and accuracy
- **Optimized** database queries for smoother scrolling
- **Reduced** memory usage by 25%
- **Better** background task handling

### User Interface Updates
- **Refined** navigation with better tab bar icons
- **Updated** color scheme with Mocha Brown branding
- **Improved** form inputs with better validation
- **Enhanced** charts with smoother animations
- **Clearer** success/error messaging

### Barcode Scanner Upgrades
- **Expanded** database to 900,000+ products
- **Added** NIH Supplement Database integration (120,000+ supplements)
- **Improved** multi-barcode format support
- **Better** low-light scanning performance
- **Faster** product lookup with smart caching

### Data & Sync
- **Enhanced** data export capabilities
- **Improved** offline mode functionality
- **Better** conflict resolution for data sync
- **Automatic** backup to iCloud
- **Smarter** data compression for less storage usage

---

## 🐛 Bug Fixes

### Critical Fixes
- ✅ Fixed crash when scanning certain barcodes
- ✅ Fixed data loss issue when app was force-closed during entry
- ✅ Fixed incorrect calorie calculations for custom recipes
- ✅ Fixed sync conflicts causing duplicate entries

### General Fixes
- ✅ Fixed weight chart not displaying correct units
- ✅ Fixed meal plan recipes not loading properly
- ✅ Fixed notification scheduling issues
- ✅ Fixed iPad layout issues in landscape mode
- ✅ Fixed keyboard covering input fields on smaller devices
- ✅ Fixed food search returning irrelevant results
- ✅ Fixed exercise timer continuing in background
- ✅ Fixed photo uploads failing for progress pictures
- ✅ Fixed decimal input issues in various fields
- ✅ Fixed timezone issues affecting daily totals

---

## 📱 Device Compatibility

### Supported Devices
- iPhone 8 and later
- iPad (6th generation) and later
- iPad Air (3rd generation) and later
- iPad Pro (all models)
- iPod touch (7th generation)

### OS Requirements
- **Minimum**: iOS 14.0
- **Recommended**: iOS 16.0 or later
- **Optimized for**: iOS 17.0+

---

## 🌟 Coming Soon (Next Release)

### Version 1.6.0 Preview
- 🏃 Apple Watch companion app
- 🤖 AI-powered meal suggestions
- 📸 Food recognition from photos
- 🏆 Social challenges with friends
- 📈 Advanced analytics dashboard
- 🌐 Multi-language support (Spanish, French, German)
- 💪 Workout plan generator
- 🥗 Grocery list from meal plans
- 📱 Widget support for home screen
- 🔄 Google Fit and Fitbit sync

---

## 📝 App Store Release Notes (Short Version)

```
ML Fitness 1.5.0 - Your Complete Health Companion!

NEW FEATURES:
• Water Tracking - Monitor hydration with beautiful progress animations
• Dark Mode - Full support for comfortable night usage
• Demo Mode - Explore the app with sample data
• Enhanced Settings - Better control over your app experience

IMPROVEMENTS:
• 30% faster app launch
• Expanded food database to 900,000+ items
• Better barcode scanning in low light
• Smoother animations and transitions

BUG FIXES:
• Fixed crash issues with barcode scanner
• Resolved data sync conflicts
• Fixed iPad landscape layouts
• Many more stability improvements

We love your feedback! Please rate and review.
```

---

## 📋 User-Facing Changelog

### For Social Media
```
🎉 ML Fitness v1.5 is HERE!

✨ NEW:
• 💧 Water tracking with smart reminders
• 🌙 Dark mode for night owls
• 🧪 Demo mode to explore features
• ⚙️ Revamped settings

🚀 FASTER:
• 30% quicker app launch
• Instant barcode scanning
• Smoother everything!

📱 Update now!
```

### For Email Newsletter
```
Subject: ML Fitness 1.5 is here - Water tracking, Dark mode & more!

Dear ML Fitness Community,

We're thrilled to announce version 1.5 with your most requested features:

🆕 Water Tracking
Never forget to stay hydrated! Track your daily water intake with our beautiful new interface, set custom goals, and receive smart reminders.

🆕 Dark Mode
Perfect for evening meal logging. Our new dark theme is easy on the eyes and saves battery on OLED devices.

🆕 Demo Mode
New to ML Fitness? Try our demo mode with 30 days of sample data to explore all features risk-free.

Plus: 30% faster performance, expanded food database, and dozens of bug fixes.

Update now through the App Store and let us know what you think!

Best regards,
The ML Fitness Team
```

---

## 🔐 Privacy Updates

### Data Collection
- No new data collection in this version
- Continued commitment to privacy-first approach
- All data remains on-device unless explicitly shared
- No third-party analytics or tracking

### Permissions
- Camera: Required for barcode scanning only
- Notifications: Optional, for reminders only
- Photos: Optional, for progress pictures only
- Health: Optional, for Apple Health sync

---

## 🙏 Acknowledgments

### Special Thanks
- Beta testers who provided invaluable feedback
- Our community for feature requests and bug reports
- Open source contributors for libraries used
- The r/fitness and r/loseit communities for inspiration

### Open Source Libraries
- Charts library for beautiful data visualization
- MLKit for barcode scanning
- Alamofire for networking
- SwiftLint for code quality

---

## 📞 Support

### Need Help?
- **Email**: support@mlfitnessapp.com
- **Website**: www.mlfitnessapp.com/help
- **Twitter/X**: @MLFitnessApp
- **In-App**: Settings > Help & Support

### Known Issues
- Rare sync delay with very large food databases
- Minor UI glitches on iOS 14.0 (recommend updating to iOS 16+)
- Apple Health sync occasionally requires re-authorization

### Report Bugs
Please report any issues through:
1. In-app feedback (Settings > Send Feedback)
2. Email with "Bug Report" in subject
3. Include device model and iOS version

---

## 📊 Version History

### Previous Releases
- **1.4.0** - Added meal planning and recipe features
- **1.3.0** - Introduced barcode scanner
- **1.2.0** - Added exercise tracking
- **1.1.0** - Weight tracking and progress charts
- **1.0.0** - Initial release with food diary

### Update Statistics
- **Total Updates**: 5 major, 12 minor
- **Bugs Fixed**: 150+
- **Features Added**: 25+
- **User Requests Implemented**: 40+

---

## 💡 Pro Tips for New Features

### Water Tracking
- Set reminders every 2 hours for optimal hydration
- Log water immediately after drinking for accuracy
- Use the quick-add buttons for common amounts

### Dark Mode
- Let it follow system settings for automatic switching
- Manually toggle in Settings if preferred
- Great for bedtime meal logging

### Demo Mode
- Perfect for showing the app to friends
- Use it to test features before committing
- Clear demo data anytime from Settings

---

*Thank you for making ML Fitness part of your health journey! 💪*

*Version 1.5.0 - Released [Date]*
*© 2024 Mocha's Mind Lab - All Rights Reserved*