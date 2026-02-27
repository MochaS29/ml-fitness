# ML Fitness — Fix-It & Relaunch Plan

**Created:** February 18, 2026
**Status:** Planning
**Goal:** Relaunch as a free app with Pro IAP, fix content gaps, improve discoverability

---

## Table of Contents
1. [Priority 1: Fix Food Search (CRITICAL)](#priority-1-fix-food-search)
2. [Priority 2: Freemium Conversion (StoreKit)](#priority-2-freemium-conversion)
3. [Priority 3: App Store Optimization (ASO)](#priority-3-app-store-optimization)
4. [Priority 4: Meal Plan Content Gap](#priority-4-meal-plan-content-gap)
5. [Priority 5: Profile Picture / Avatar](#priority-5-profile-picture--avatar)
6. [Priority 6: App Store Listing Refresh](#priority-6-app-store-listing-refresh)
7. [Priority 7: Name Change Evaluation](#priority-7-name-change-evaluation)
8. [Priority 8: Marketing & Promotion](#priority-8-marketing--promotion)
9. [Future Considerations](#future-considerations)

---

## Priority 1: Fix Food Search

**Problem:** The core food logging experience is broken. This is the #1 thing users do in a calorie tracker and it doesn't work.

### Current State (Screenshots Confirmed)

**Diary Search (UnifiedFoodSearchSheet.swift):**
- Searching "Latte" → ZERO results, only "Create Latte" option
- Does NOT call USDA API — only searches local 124-item FoodDatabase
- Local DB has no coffee drinks, lattes, fast food, or most common foods
- Users see an empty "Search Results" section for nearly everything

**Autocomplete Search (AutocompleteFoodSearchView.swift):**
- Searching "Coffee Cake" → only 2 results ("Cake, fruit cake" + "Coffee, brewed")
- Searching "Flat White" → returns "Emu, flat fillet, raw" (absurd)
- Results capped at `.prefix(10)` per source
- Uses substring `.contains()` matching — "flat" matches "flat fillet"

**Root Cause:**
1. UnifiedFoodSearchSheet only queries local 124-item database — NO external API
2. AutocompleteFoodSearchView calls USDA but caps at 10 results per source
3. Search matching uses naive `.contains()` — no word boundary awareness
4. Foods added to diary are NOT saved to local DB for faster future searches

### Required Fixes

- [ ] **Wire USDA API into UnifiedFoodSearchSheet**
  - Add async USDA search with debounce (0.3-0.5s)
  - Show local results immediately, USDA results as they load
  - Add loading indicator during API fetch

- [ ] **Increase search result limits**
  - Change `.prefix(10)` to `.prefix(25)` minimum in AutocompleteFoodSearchView
  - Change `.prefix(20)` to `.prefix(50)` in UnifiedFoodSearchSheet
  - Show scrollable list, not truncated results

- [ ] **Fix search matching algorithm**
  - Replace `.contains()` with word-boundary-aware matching
  - "Flat White" should NOT match "Emu, flat fillet, raw"
  - Prioritize: exact match > starts with > word match > substring
  - Weight results by relevance, not just alphabetical

- [ ] **Auto-cache foods to local database**
  - When user adds a food from USDA to their diary, save it to local FoodDatabase
  - Next time they search, it appears instantly (no API call needed)
  - Store in CoreData as a "cached food" entity
  - Show "Recent Foods" section at top of search (already partially exists)

- [ ] **Expand local FoodDatabase**
  - Current: 124 items (mostly raw ingredients like "Chicken breast, raw")
  - Missing: coffee drinks, fast food, snacks, brand items, common meals
  - Add at minimum 200-300 common foods people actually search for
  - Categories to add: coffee/tea drinks, fast food chains, common snacks, prepared meals, beverages

- [ ] **Unify the two search experiences**
  - Users shouldn't encounter two different search UIs with different capabilities
  - Both should search: recent foods → local DB → USDA API
  - Same result limits, same matching logic

- [ ] **Fix USDA API key storage**
  - Currently hardcoded in USDAFoodService.swift (line 10)
  - Move to environment variable or secure keychain
  - Use DEMO_KEY as fallback

### Files to Modify
- `Views/UnifiedFoodSearchSheet.swift` — add USDA API call, increase limits
- `Views/AutocompleteFoodSearchView.swift` — increase `.prefix()` limits, fix matching
- `Models/FoodDatabase.swift` — expand to 300+ common foods, improve search algo
- `Services/USDAFoodService.swift` — move hardcoded API key
- `Services/UnifiedDataManager.swift` — add food caching on diary add

---

## Priority 2: Freemium Conversion

**Problem:** App is $6.99 upfront. Every competitor on the search page shows "Get" (free). Users scroll past without downloading. Zero sales to date.

**Solution:** Free download with one-time $6.99 "ML Fitness Pro" in-app purchase.

### Implementation Tasks

- [ ] **Create StoreManager service** (StoreKit 2)
  - Non-consumable IAP: "ML Fitness Pro" — $6.99 one-time
  - Purchase state persisted via StoreKit 2 transaction listener
  - Restore purchases support
  - Receipt validation

- [ ] **Create PaywallView**
  - Shows when user hits a gated feature
  - Lists what Pro unlocks (with preview screenshots)
  - "Restore Purchases" button
  - Clean, non-aggressive design (no dark patterns)

- [ ] **Create ProFeatureGate utility**
  - Simple `isPro` check used throughout app
  - Wraps StoreKit 2 purchase status

- [ ] **Gate Pro features:**
  | Feature | Free | Pro |
  |---------|------|-----|
  | Manual food logging + search | Yes | Yes |
  | Water tracking + reminders | Yes | Yes |
  | Weight tracking | Yes | Yes |
  | Basic exercise logging | Yes | Yes |
  | Basic dashboard (calories, steps, weight) | Yes | Yes |
  | Goal setting | Yes | Yes |
  | 1 meal plan preview (today only, Mediterranean) | Yes | Yes |
  | AI photo food scanner | No | Yes |
  | Barcode scanning | No | Yes |
  | Full meal plan library (all plans, all weeks) | No | Yes |
  | Recipe import from URLs | No | Yes |
  | Supplement tracking | No | Yes |
  | Advanced analytics / AI insights | No | Yes |
  | Intermittent fasting timer | No | Yes |
  | HealthKit sync | No | Yes |
  | Grocery list generation | No | Yes |

- [ ] **Add "Restore Purchases" to Settings**

- [ ] **Add IAP entitlement** to HealthTracker.entitlements

- [ ] **Create IAP product in App Store Connect**

### Files to Create/Modify
- NEW: `Services/StoreManager.swift`
- NEW: `Views/PaywallView.swift`
- NEW: `Utils/ProFeatureGate.swift`
- MODIFY: `DishScannerView.swift` — add Pro gate
- MODIFY: `BarcodeScannerView.swift` — add Pro gate
- MODIFY: `EnhancedMealPlanningView.swift` — limit free tier
- MODIFY: `ImportRecipeView.swift` — add Pro gate
- MODIFY: `EnhancedSupplementTrackingView.swift` — add Pro gate
- MODIFY: `DashboardView.swift` — limit AI insights on free tier
- MODIFY: `HealthTracker.entitlements` — add IAP entitlement
- MODIFY: `HealthTrackerApp.swift` — initialize StoreManager

---

## Priority 3: App Store Optimization (ASO)

**Problem:** App doesn't appear in searches for "fitness tracker", "calorie counter", "macro tracker", etc. Current name "ML Fitness" and subtitle "Complete Wellness Companion" contain zero searchable terms.

### Changes in App Store Connect

- [ ] **Update App Name** (30 chars max):
  - Current: `ML Fitness`
  - Proposed: `ML Fitness: Calorie Tracker` (27 chars)
  - (Or new name if renaming — see Priority 6)

- [ ] **Update Subtitle** (30 chars max):
  - Current: `Complete Wellness Companion`
  - Proposed: `Food Diary & Calorie Counter` (28 chars)

- [ ] **Update Keywords** (100 chars, comma-separated, no spaces after commas):
  ```
  fitness,tracker,calorie,counter,macro,meal,plan,food,diary,nutrition,diet,barcode,scanner,fasting,health
  ```

- [ ] **Update Description** — lead with value props:
  - "Track calories and macros. Scan food with AI. Plan your meals. No subscription — ever."
  - Highlight: 8 meal plan types, AI food scanning, barcode scanner, 124+ food database
  - Mention: privacy-first, on-device storage, no ads

- [ ] **Update Category** — Primary: Health & Fitness, Secondary: Food & Drink

---

## Priority 4: Meal Plan Content Gap

**Problem:** User-facing meal plans are severely under-populated. The app advertises meal planning but delivers very little content.

### Current Reality
| Plan | Week 1 | Week 2 | Week 3 | Week 4 |
|------|--------|--------|--------|--------|
| Mediterranean | 7 real days | EMPTY | EMPTY | EMPTY |
| Keto | Mon only | — | — | — |
| IF (16:8) | Mon only | — | — | — |
| Family Friendly | Mon only | — | — | — |
| Vegetarian | Mon only | — | — | — |
| Paleo* | Mon real, Tue-Sun generic placeholders | Generic | Generic | Generic |
| Whole30* | Mon real, Tue-Sun generic placeholders | Generic | Generic | Generic |
| Vegan* | Mon real, Tue-Sun generic placeholders | Generic | Generic | Generic |

*Paleo, Whole30, Vegan exist in `MealPlanDataExtensions.swift` but may not surface via `allMealPlans` (uses original 5 only). `updatedAllMealPlans` static var exists but needs to be wired into views.

### Additional Issue
- `generateWeek2Days()`, `generateWeek3Days()`, `generateWeek4Days()` all return `[]` (empty arrays)
- Generic placeholder meals show "Paleo Lunch 2" with "Various ingredients" — unusable

### Solution Options

**Option A: Populate locally (no backend needed)**
- Write full 4-week meal plans for all 8 diet types
- That's 8 plans x 4 weeks x 7 days x 4 meals = **896 unique meals**
- Massive content task but zero ongoing cost
- Could use AI assistance to generate nutritionally-accurate meal data
- Pro: works offline, no API dependency
- Con: static content, can't easily update

**Option B: Connect to Mindful Meal Plans backend**
- Pull meal plan data from existing backend
- Pro: dynamic content, easy to update, shared across platforms
- Con: requires network, API maintenance, backend hosting costs

**Option C: Hybrid approach (RECOMMENDED)**
- Populate 4 weeks of real content per plan locally (minimum viable)
- Add backend integration later for seasonal/rotating content
- Free tier gets Week 1 of Mediterranean only
- Pro tier gets all plans, all weeks

### Implementation Tasks
- [ ] Verify `updatedAllMealPlans` is used in `EnhancedMealPlanningView` (likely using `allMealPlans` which misses Paleo/Whole30/Vegan)
- [ ] Populate full 4-week Mediterranean plan (weeks 2-4 currently empty)
- [ ] Populate full Week 1 for Keto (only Monday exists)
- [ ] Populate full Week 1 for IF (only Monday exists)
- [ ] Populate full Week 1 for Family Friendly (only Monday exists)
- [ ] Populate full Week 1 for Vegetarian (only Monday exists)
- [ ] Replace generic placeholder meals in Paleo/Whole30/Vegan with real recipes
- [ ] Populate weeks 2-4 for all plans (can be phased)
- [ ] Wire `updatedAllMealPlans` into views so all 8 plans surface
- [ ] Add meal plan count to App Store description once populated

---

## Priority 5: Profile Picture / Avatar

**Problem:** No way to add a profile photo or avatar. ProfileView shows a header but no image picker.

### Implementation Tasks
- [ ] **Add avatar to UserProfile model**
  - Store as `Data?` (JPEG) in UserDefaults or Core Data
  - Support camera and photo library
  - Add circular crop/resize

- [ ] **Create AvatarPickerView**
  - Camera option
  - Photo library option
  - Default avatar options (SF Symbols or bundled illustrations)
  - Remove photo option

- [ ] **Update ProfileHeaderView**
  - Show avatar image or default placeholder
  - Tap to change

- [ ] **Update ProfileView / EditProfileView**
  - Integrate avatar picker

- [ ] **Update DashboardView greeting**
  - Show avatar next to "Hello, [Name]!"

### Files to Create/Modify
- MODIFY: `Models/UserProfile.swift` — add avatar data field
- MODIFY: `ViewModels/UserProfileManager.swift` — save/load avatar
- NEW or MODIFY: `Views/ProfileView.swift` — add avatar picker
- MODIFY: `Views/DashboardView.swift` — show avatar in greeting

---

## Priority 6: App Store Listing Refresh

**Problem:** Screenshots show raw app UI without marketing messaging. Competitors use bold text overlays, outcome-focused copy, and social proof.

### Tasks
- [ ] **Redesign screenshots** (6.7" and 6.5" required, 6.1" optional)
  - Screenshot 1: Dashboard — "Track Your Nutrition with AI"
  - Screenshot 2: Food scanner — "Scan Any Meal, Get Instant Macros"
  - Screenshot 3: Meal plans — "8 Diet Plans, 4 Weeks Each"
  - Screenshot 4: Barcode scanner — "Scan Barcodes, Log in Seconds"
  - Screenshot 5: Progress/analytics — "See Your Progress Over Time"
  - Screenshot 6: Fasting timer — "Built-In Intermittent Fasting Timer"
  - Use bold text overlays on each screenshot
  - Consistent color scheme matching app brand
  - Consider tools: Figma, RocketSim, or Screenshots Pro

- [ ] **Update app preview video** (optional but high-impact)
  - 15-30 second walkthrough of key features
  - Focus on speed of food logging

- [ ] **Write compelling "What's New" text** for the update
  - "Now FREE to download! Unlock Pro for the full experience."

---

## Priority 7: Name Change Evaluation

**Problem:** "ML Fitness" competes with established "ML.Fitness Workout For Women" (50 ratings) and "ML Sports and Fitness" in search. The "ML" prefix has no meaning to users and creates brand confusion.

### Considerations

**Pros of renaming:**
- Escape the crowded "ML" space
- Include searchable terms in the name itself
- Fresh start with no negative baggage
- Better brand identity

**Cons of renaming:**
- Lose current #5 ranking for "ML fitness"
- Need new app icon, branding
- App Store treats it as same app (just a metadata update) — no listing reset
- Any existing users would see the name change

### Name Candidates (must be ≤30 chars with subtitle keyword)
| Full App Store Name | Core Name | Subtitle |
|---|---|---|
| `NourishTrack: Calorie Counter` | NourishTrack | Food Diary & Macro Tracker |
| `FuelLog: Calorie & Meal Plan` | FuelLog | AI Food Scanner & Diet Tracker |
| `MindLab Fitness: Calorie Track` | MindLab Fitness | Food Diary & Meal Planner |
| `CalScan: AI Calorie Tracker` | CalScan | Macro Counter & Meal Planner |
| `BiteFit: Calorie & Food Diary` | BiteFit | Meal Plan & Macro Tracker |

### Recommendation
Renaming is worth doing IF we pick a name that includes a high-volume search term. "ML Fitness" gets zero organic discovery from people searching "calorie tracker" or "food diary." A name like "NourishTrack" or "CalScan" immediately communicates the app's purpose AND contains searchable terms.

### Decision: [ ] PENDING — needs user input

---

## Priority 8: Marketing & Promotion

### TikTok / Reels Strategy (Free, Highest ROI)
- [ ] Post 1-2x daily, screen recordings of the app
- [ ] Content ideas:
  - "I built a fitness app and here's what it does"
  - Screen record: scan a meal → instant macros
  - "This app has 8 meal plans built in"
  - "POV: you're tired of paying $100/yr for MyFitnessPal"
  - Dev journey / indie dev content
  - Side-by-side comparison with competitors
- [ ] Use trending sounds and fitness hashtags
- [ ] Pin best-performing video to profile

### Reddit (Free, High Intent)
- [ ] Post in r/fitness, r/loseit, r/mealprep, r/macros (genuine, not spammy)
- [ ] Share indie dev journey in r/iOSProgramming, r/SwiftUI, r/indiedev
- [ ] Answer "what calorie tracker do you use?" threads

### Meta Ads (Paid — HOLD until freemium is live)
- [ ] Wait until app is free to download
- [ ] Start with $5-10/day budget targeting fitness-interested 25-45 year olds
- [ ] Use video creative showing the food scanning feature
- [ ] Track cost-per-install and optimize

### ProductHunt Launch
- [ ] Submit when freemium update goes live
- [ ] "AI-powered calorie tracker with no subscription"

---

## Future Considerations (Not Now)

These are opportunities to revisit once the app has traction:

- [ ] **Spoonacular Video-to-Recipe** — extractFromVideo API (50 pts/call, $0.25 overage on Cook plan). Add when users request it and revenue justifies $29/mo API plan.
- [ ] **Spoonacular Nutrition by Photo** — new dedicated endpoint. Test if it returns better data than current `/food/images/analyze`.
- [ ] **Subscription model** — consider adding $2.99/mo or $19.99/yr tier alongside one-time purchase if retention data supports it.
- [ ] **Backend / Cloud Sync** — Firebase or CloudKit for cross-device sync, would justify subscription.
- [ ] **Social features** — community meal sharing, recipe sharing.
- [ ] **Apple Watch complications** — quick-log from watch face.
- [ ] **Widgets** — home screen calorie/macro summary widget.
- [ ] **Android port** — MLHealthAndroid project exists but is empty.

---

## Execution Order

| Phase | What | Effort | Impact |
|-------|------|--------|--------|
| **Phase A** | Fix food search (USDA in diary, result limits, matching, caching) | ~2-3 days | Fixes the core user experience — without this, the app is unusable |
| **Phase B** | StoreKit 2 + Paywall + Pro gating | ~2-3 days | Removes #1 barrier to downloads |
| **Phase C** | ASO (name/subtitle/keywords/description) | ~1 hour in App Store Connect | Makes app discoverable |
| **Phase D** | Profile avatar feature | ~1 day | Fixes visible missing feature |
| **Phase E** | Meal plan content (Week 1 all plans) | ~2-3 days | Fills the biggest content gap |
| **Phase F** | Screenshot redesign | ~1 day | Improves conversion rate |
| **Phase G** | Submit update to App Store | ~1 hour + 24-48hr review | Everything goes live |
| **Phase H** | Marketing push (TikTok, Reddit, ProductHunt) | Ongoing | Drives downloads |
| **Phase I** | Meal plan content (Weeks 2-4 all plans) | ~1-2 weeks | Completes the meal plan library |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `Configuration/APIConfiguration.swift` | All API endpoints and keys |
| `Services/FoodRecognitionService.swift` | Spoonacular + Vision food scanning |
| `Services/RecipeImportService.swift` | URL-based recipe import |
| `Data/MealPlanData.swift` | Meal plan content (5 plans, mostly stubs) |
| `Data/MealPlanDataExtensions.swift` | 3 additional plans (Paleo, Whole30, Vegan) |
| `Views/EnhancedMealPlanningView.swift` | Meal planning UI |
| `Views/ProfileView.swift` | User profile (no avatar) |
| `Views/DashboardView.swift` | Main dashboard |
| `Models/UserProfile.swift` | User profile model |
| `HealthTracker.entitlements` | App capabilities |
| `HealthTrackerApp.swift` | App entry point |
