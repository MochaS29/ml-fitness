# MindLab Fitness — Android

Android port of the iOS app **MindLab Fitness** (App Store: *Fitness & Calorie Tracker — AI Meal Scanner & Planner*). The iOS app is the source of truth for feature behavior; this port aims for feature parity.

- iOS source repo: https://github.com/MochaS29/HealthTracker-iOS
- Android repo: https://github.com/MochaS29/MLHealthAndroid
- Application ID: `com.mochasmindlab.mlhealth`

## Status

Active port, resumed April 2026. The app builds and runs but several core features are stubs. See the matrix below.

| Feature | Status | Notes |
|---|---|---|
| Onboarding | Implemented | DataStore-backed completion flag |
| User profile | Implemented | BMR/TDEE calculation, DataStore prefs |
| Water tracking | Implemented | Animated wave UI; reminders pending |
| Weight tracking | Implemented | Room-backed, BMI display |
| Barcode scanner (food) | Implemented | OFF → USDA → Spoonacular fallback chain |
| Dashboard | Partial | Calories/macros/water from DB; step count + week/month aggregation pending |
| Food diary | Partial | Food entries load; exercise + supplement entries not yet wired |
| Food search UI | Partial | Tabs render; search/recent/favorites/custom-foods all stubbed |
| Food database (53K USDA) | Not started | iOS ships an FTS5 SQLite asset that needs to be bundled here |
| Meal scanner (Claude AI) | Not started | iOS uses `claude-sonnet-4-6` via Anthropic API |
| Meal plans + recipes | Stub | iOS ships 8 plans / 400 recipes as JSON; Android shows "coming soon" |
| Reminders / notifications | Not started | WorkManager dependency present, no scheduling logic |
| Achievements / streaks | Stub | Routes to `ComingSoonScreen` |
| Google Play Billing / paywall | Not started | iOS uses StoreKit 2 for Pro IAP |
| Health Connect | Not started | iOS uses HealthKit for steps + weight |
| Add custom food, progress charts | Stub | Routes to `ComingSoonScreen` |
| Settings — dark mode, clear data | Partial | UI present; persistence/clear not implemented |

## Tech Stack

- **Language**: Kotlin 1.9.20
- **UI**: Jetpack Compose (Compose UI 1.5.4, Material3 1.1.2, compiler ext 1.5.4)
- **Build**: Android Gradle Plugin 8.12.3, Gradle 8.13
- **Architecture**: MVVM, Hilt DI
- **Persistence**: Room 2.6.0, DataStore Preferences 1.0.0
- **Networking**: Ktor client 1.6.7, OkHttp 4.11.0
- **Camera / barcode**: CameraX 1.1.0-beta01, ML Kit barcode-scanning 17.0.2
- **Background work**: WorkManager 2.7.1

`minSdk` 26, `compileSdk`/`targetSdk` 34. Three product flavors: `development`, `staging`, `production`. ProGuard enabled in release.

## Project Layout

```
app/src/main/java/com/mochasmindlab/mlhealth/
├── data/
│   ├── database/        Room database, DAOs (Food, Exercise, Water, Weight, Supplement, Goals, etc.)
│   ├── entities/        Room entities (CoreEntities.kt, SupplementRegime.kt)
│   ├── models/          Domain models
│   ├── preferences/     PreferencesManager (DataStore)
│   └── repository/      Per-feature repositories
├── di/                  Hilt modules (DatabaseModule.kt)
├── services/            Network/API services (FoodBarcodeService, RestaurantFoodService, SupplementAPIService)
├── ui/
│   ├── navigation/      MLFitnessNavigation (active nav host)
│   ├── screens/         Feature screens (Compose)
│   └── theme/
├── utils/               DemoDataGenerator, SampleDataGenerator, DateConverter, UnitConversions
└── viewmodel/           Per-screen ViewModels
docs/
├── BARCODE_SCANNER_UI_SPECS.md      Shared iOS/Android design spec
├── NIH_SUPPLEMENT_DATABASE_GUIDE.md
└── ios-android-file-mapping.json    iOS→Android file cross-reference
```

The Compose nav host at `ui/navigation/MLFitnessNavigation.kt` is the active one. A second nav file (`navigation/MLHealthNavHost.kt`) exists but is partially wired and slated for removal.

## Build

```bash
./gradlew assembleDevelopmentDebug      # default dev build
./gradlew assembleProductionRelease     # signed release
./gradlew test                           # unit tests
./gradlew connectedAndroidTest           # instrumented tests
```

## Configuration

API keys live in `local.properties` (gitignored from new entries — but the file is checked in for `sdk.dir`). The `app/build.gradle.kts` reads them into BuildConfig fields, accessed at runtime via `SecretsManager`.

To enable the AI meal scanner (gap #3 / Phase 2.C):

1. Open `local.properties` at the project root.
2. Add this line (uncomment if it's already there as a comment):
   ```
   anthropic.api.key=sk-ant-api03-...your-real-key...
   ```
3. Rebuild — `./gradlew :app:assembleDevelopmentDebug` — the key gets baked into `BuildConfig.ANTHROPIC_API_KEY`.
4. Run the app, open the meal scanner from the bottom-bar FAB or the AddMenu, take a photo. `MealAnalysisService` will POST to `https://api.anthropic.com/v1/messages` with `claude-sonnet-4-6` and vision.
5. Without a key, `SecretsManager.anthropicAPIKey` returns `null` and `MealAnalysisService` short-circuits with an `apiKeyMissing` error — the scanner UI shows a friendly "API key not configured" message rather than crashing.

The other API keys (USDA, Spoonacular, Nutritionix, Open Food Facts) are currently hardcoded in `config/ApiConfig.kt` — security debt to clean up later (move to BuildConfig + local.properties).

Open Food Facts requires no key.

## iOS Reference

When porting a feature, check these in order:
1. `docs/ios-android-file-mapping.json` — file-path mapping for Swift ↔ Kotlin equivalents
2. The iOS source at `/Users/mocha/Development/iOS-Apps/HealthTracker/` (or the public repo)
3. The shared design specs in `docs/`

The iOS app has zero third-party library dependencies — every external integration is a raw HTTPS call. That makes the network/service layers a near-direct port; the differences are framework-level (HealthKit → Health Connect, StoreKit 2 → Play Billing, UNUserNotificationCenter → WorkManager + NotificationManagerCompat).

## License

© 2026 Mocha's MindLab Inc. All rights reserved.
