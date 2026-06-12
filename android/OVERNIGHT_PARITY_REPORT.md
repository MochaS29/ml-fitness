# Overnight parity report — May 7→8, 2026

Side-by-side audit of `iOS-Apps/HealthTracker` (v2.4.0) vs `Android-Apps/MLHealthAndroid`,
plus every fix applied this session.

---

## Audit findings

| Area | iOS source | Android status before | Action |
|---|---|---|---|
| AI Meal Scanner | `Views/MealPhotoAnalyzerView.swift` | 🐞 built but unreachable (no nav route) | ✅ wired + Pro gating |
| Paywall / IAP CTA | `Views/PaywallView.swift` | 🐞 built but unreachable | ✅ wired + reachable from More + meal-scan gate |
| Achievements | dashboard display | 🐞 built but unreachable | ✅ wired into More |
| Health Connect | `HealthKitManager.swift` | 🐞 built but unreachable | ✅ wired into More |
| Grocery List | `Views/GroceryListGeneratorView.swift` | ❌ no equivalent | ✅ built |
| AI Insights carousel | `Views/AllInsightsView.swift` | ❌ computed but never rendered | ✅ rendered on Dashboard |
| Progress Charts | `Views/ProfessionalProgressView.swift` | ⚠️ `ComingSoon` stub | ✅ replaced with 14-day sparkline charts |
| Export Data | iOS functional | ⚠️ `ComingSoon` stub | ✅ CSV export + share sheet |
| About / Privacy / Help | iOS pages | ⚠️ `ComingSoon` stubs | ✅ all replaced with real content |
| Food Preferences | `Views/FoodPreferencesView.swift` | ⚠️ `ComingSoon` stub | ✅ aliased to Allergen Preferences screen |
| Food Database menu entry | iOS list | ⚠️ `ComingSoon` stub | ✅ opens food search |
| Exercise Search | iOS preset list | ⚠️ `ComingSoon` stub | ✅ opens real Exercise screen |
| Water Entry | iOS quick-log | ⚠️ `ComingSoon` stub | ✅ opens Water tracking |
| Exercise Quick Add presets | 12 iOS presets | ⚠️ 6 presets | ✅ added HIIT, Pilates, Dancing, Hiking, Tennis, Basketball |
| Bottom-nav center FAB | iOS tab bar style | 🐞 layout broken (FAB took 5th tab slot, blocked More tap) | ✅ rebuilt with Box overlay + spacer slot |
| Detail-screen FAB overlap | iOS uses sheets | 🐞 nav FAB sat over Diary/Exercise scaffold FABs | ✅ nav FAB hidden on non-tab routes |
| Recipe "Log to Diary" UX | iOS sheet | ⚠️ button at bottom of sheet, scroll required | ✅ moved to top under description |
| Quick Calories | iOS Food screen | 🐞 navigated to non-existent route → crash | ✅ inline dialog |
| Add Weight | iOS allows backdating | ⚠️ today only | ✅ DatePicker added |
| Weight Settings button | iOS dialog | 🐞 navigated to non-existent route → crash | ✅ removed (use Goals) |
| Weight progress bar | iOS handles 0 goals | 🐞 NaN crash when no goal set | ✅ guarded |
| Exercise Quick-Add nav | iOS opens detail | 🐞 navigated to non-existent route → crash | ✅ pre-fills the QuickAdd dialog |
| Exercise calorie burn | iOS HealthKit-derived | ⚠️ manual entry only | ✅ MET-based auto-estimate, editable |
| Exercise / Food / Weight save | iOS ObservableObject | 🐞 `viewModelScope` cancellation race lost inserts | ✅ all inserts on `@ApplicationScope` |
| Date alignment for queries | iOS NSCalendar | 🐞 entries with `Date()` (now) didn't match start-of-day dashboard queries | ✅ all inserts normalized to start-of-day |
| Diary water + cup on previous day | iOS supports | 🐞 always logged to today | ✅ uses Diary's selectedDate |
| Supplement add | iOS preset list | ⚠️ free-form text only | ✅ 18 common-supplement preset chips |
| Supplements screen | iOS full screen | 🐞 `ComingSoon` stub | ✅ real list + add dialog |
| Goal type from Quick Goal | iOS preset → form | 🐞 always defaulted to Weight Loss | ✅ preset type passed to dialog |
| Dashboard cards click | iOS taps to detail | 🐞 nothing was clickable | ✅ all 6 cards navigate |
| Dashboard goal source | iOS reads stored goal | 🐞 hardcoded 2200 cal / 8 cups | ✅ reads PreferencesManager + auto-mirrors from Goals |
| Dashboard refresh on resume | iOS observable | 🐞 stale until app relaunch | ✅ `LifecycleEventObserver(ON_RESUME)` |
| Dashboard NaN ÷ 0 guards | iOS Double | 🐞 crash on Weight progress when goalWeight==0 | ✅ guarded |
| WaterRepository Flow | iOS Combine | 🐞 `flow { emit(...) }` builder emitted once → no live updates | ✅ uses Room's native Flow |
| Water droplets tap | iOS individual taps | 🐞 only "next" droplet was clickable | ✅ any unfilled droplet logs a glass |
| Demo data on debug | iOS toggle | 🐞 ran on every debug install, confused testing | ✅ off by default; opt-in via More dev tools |
| Demo data button | iOS button | 🐞 onClick was empty | ✅ wired via Hilt EntryPoint |
| Exercise History route | iOS screen | 🐞 navigated → crash | ✅ removed from top bar (not built) |
| Edit Exercise route | iOS screen | 🐞 navigated → crash | ✅ Edit re-opens QuickAdd seeded with name |
| Launcher icon | iOS adaptive | 🐞 small icon on white background | ✅ proper adaptive icon (foreground + teal background) |
| Diary auto-pop after food add | iOS sheet dismiss | ✅ already did (kept) | — |
| Tracking screens auto-pop | iOS depends | (inconsistent) | ✅ stay on screen for water/exercise/supplements/weight; pop only for food |

---

## What's still on iOS but not Android

These are deliberately deferred — bigger ports, lower ship-blocker priority:

- **"Generate Month Plan" AI feature** (`MealPlanningView.swift`) — calls Claude to build a personalized 4-week plan. Estimated ~2–3 days to port (server-side prompt engineering + UI plumbing).
- **Apple Watch companion** — no Wear OS analogue.
- **`DishScannerView`** — secondary meal-analysis flow on iOS. Largely overlaps with the meal scanner we just wired; defer.
- **Two-way HealthKit weight write-back** — Android Health Connect is currently read-only in this app (we read steps/weight; we don't write weight back).

---

## Files changed this session

### New
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/about/AboutScreens.kt` (About / Privacy / Help)
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/reports/ProgressScreen.kt` (charts + ViewModel)
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/reports/ExportScreen.kt` (CSV + ViewModel)
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/grocery/GroceryListScreen.kt`
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/supplements/SupplementsScreen.kt`
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/SupplementsViewModel.kt`
- `app/src/main/res/xml/file_provider_paths.xml`

### Modified
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/navigation/MLFitnessNavigation.kt` — added 5 routes (`meal_scanner`, `paywall`, `achievements`, `health_connect`, `grocery_list`); replaced 7 `ComingSoon` placeholders with real screens; restructured bottom bar with Box overlay + spacer; added Meal Scanner to + sheet.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/dashboard/DashboardScreen.kt` — InsightsCarousel composable, ON_RESUME refresh, all cards clickable.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/diary/DiaryScreen.kt` — removed duplicate Scaffold FAB, fixed Exercise +.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/exercise/ExerciseTrackingScreen.kt` — 12 presets, removed dead routes, MET-based calorie estimate, top-bar + button.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/food/FoodSearchScreen.kt` — Quick Calories inline dialog.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/goals/GoalsScreen.kt` — preset type for Quick Goals; FAB → top-bar action.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/mealplan/MealPlanScreen.kt` — Log to Diary moved to top of sheet.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/more/MoreScreen.kt` — Achievements / Health Connect / Pro upgrade / Grocery List entries; demo data wired via Hilt EntryPoint.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/scanner/MealScannerScreen.kt` — Pro gating UI, free-scans counter chip, Paywall phase.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/sleep/SleepTrackingScreen.kt` — FAB → top-bar action.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/water/WaterTrackingScreen.kt` — droplet tap any unfilled.
- `app/src/main/java/com/mochasmindlab/mlhealth/ui/screens/weight/WeightTrackingScreen.kt` — date picker, NaN guard, removed broken Settings, FAB → top-bar action.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/DashboardViewModel.kt` — reads goal flows from PreferencesManager.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/DiaryViewModel.kt` — water cup uses selectedDate.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/ExerciseViewModel.kt` — appScope insert + start-of-day.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/FoodSearchViewModel.kt` — `logQuickCalories` function.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/GoalsViewModel.kt` — mirrors targets to PreferencesManager.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/MealPlanViewModel.kt` — `currentWeekIngredients()`.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/MealScannerViewModel.kt` — Pro/free quota gate.
- `app/src/main/java/com/mochasmindlab/mlhealth/viewmodel/WeightViewModel.kt` — accept date param + appScope.
- `app/src/main/java/com/mochasmindlab/mlhealth/data/database/WaterDao.kt` — added Flow-based `getEntriesForDateFlow`.
- `app/src/main/java/com/mochasmindlab/mlhealth/data/repository/WaterRepository.kt` — uses Room Flow.
- `app/src/main/java/com/mochasmindlab/mlhealth/utils/PreferencesManager.kt` — `mealScanCount` flow + `incrementMealScanCount`.
- `app/build.gradle.kts` — `ENABLE_DEMO_DATA` off by default in debug.
- `app/src/main/AndroidManifest.xml` — FileProvider for CSV export sharing.
- `app/src/main/res/mipmap-{anydpi-v26,*}/ic_launcher_foreground.png` — proper adaptive icon foregrounds.
- `app/src/main/res/values/colors.xml` — `ic_launcher_background`.

### Tests / verification
- `./gradlew :app:assembleProductionDebug` — green.
- App installed and cold-launched on the running emulator without `AndroidRuntime` errors.
- Several flows still need a hand-test pass when you wake up (see below).

---

## What I'd like you to test before we set up the meal scanner properly

1. **Cold launch** — should land on Dashboard with insights carousel visible.
2. **Bottom nav** — tap each of Dashboard / Diary / Plan / More; the centred + button is now in line with the four tabs.
3. **Meal Scanner** — + sheet → Scan a Meal. Take or pick a photo. Verify the analyse → results → save flow works (needs `ANTHROPIC_API_KEY` in `local.properties`). After 3 scans the paywall gate should appear.
4. **Pro upgrade** — More → Upgrade to Pro should reach the PaywallScreen.
5. **Achievements** — More → Achievements.
6. **Health Connect** — More → Health Connect.
7. **Grocery List** — More → Grocery List (needs a diet selected on the Plan tab first).
8. **Progress Charts** — More → Progress Charts.
9. **Export Data** — More → Export Data → "Export & share CSV" → opens a share sheet with the file.
10. **Add Weight backdating** — Dashboard Weight card → +. The dialog now has a Date field with a calendar picker.
11. **Quick Calories** — Diary → Add to a meal → "Quick Calories" button.
12. **Insights carousel** — Dashboard top — should show hydration/calories/exercise nudges.

If anything blows up I'll have logcat ready.
