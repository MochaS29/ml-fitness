# Google Play Store Submission Materials

Adapted from `iOS-Apps/HealthTracker/APP_STORE_SUBMISSION.md` (the canonical product copy). Update both when copy changes.

## App Information

### App Title (50 characters max)
**MindLab Fitness — Calorie Tracker**

### Short Description (80 characters max)
**AI meal scanner + 53K food database. Track calories, macros & meal plans.**

### Full Description (4000 characters)

```
Track calories effortlessly. Snap a photo of your meal and AI identifies every food with calories, protein, carbs, and fat — instantly. Or search our database of 53,000+ foods. No tedious manual logging.

MindLab Fitness is the all-in-one nutrition and fitness tracker that respects your privacy and your wallet. Download free, unlock Pro for the full experience — no subscriptions, ever.

KEY FEATURES

AI MEAL SCANNER
- Snap a photo of any meal
- AI identifies foods and calculates nutrition instantly
- Adjust portions and save to your diary
- Powered by Claude AI for accurate results

SMART FOOD SEARCH
- 53,000+ foods from the USDA database
- Barcode scanner for packaged foods
- Recent foods for quick re-logging
- Add custom foods for anything not in the database

COMPLETE FOOD DIARY
- Track breakfast, lunch, dinner, and snacks
- Daily calorie, protein, carb, and fat totals
- Navigate between dates to review your history
- Logging streak counter to keep you motivated

8 MEAL PLANS WITH 400+ RECIPES
- Mediterranean, Keto, High Protein, Balanced, Low Carb, Paleo, Whole30, Vegan
- Full 4-week plans with real recipes and nutrition data
- Ingredients, instructions, and macro breakdowns

FITNESS & WEIGHT TRACKING
- Log any exercise or activity
- Automatic calorie burn estimates
- Daily weight logging with trend graphs
- Health Connect integration for steps and workouts

HYDRATION & REMINDERS
- Quick water logging with daily goal tracking
- Smart reminders for water, meals, and weigh-ins
- Customizable times for each reminder type

SMART DASHBOARD
- All your metrics at a glance — calories, macros, steps, water, weight
- Progress charts and weekly trends
- Achievements and logging streaks

WHY MINDLAB FITNESS

PRIVACY FIRST — All data stays on your device. No accounts, no cloud uploads, no tracking.

WORKS OFFLINE — Full functionality without internet (except AI meal scanning and online food search).

NO SUBSCRIPTIONS — Pay once for Pro, own it forever. Competitors charge $10-20 per month.

HEALTH CONNECT — Automatic step counting and weight sync via the official Android Health Connect platform.

Perfect for weight loss, muscle building, meal prep, managing health conditions, or simply eating better. Start your journey today.

Note: AI meal scanning and online food search require an internet connection. All other features work offline. Health Connect integration requires the Health Connect app from Google Play.
```

---

## Categorization

- **Category**: Health & Fitness
- **Tags** (Play Store, up to 5): `Calorie tracker`, `Nutrition`, `Meal planner`, `Weight loss`, `Fitness`
- **Content rating**: Everyone (PEGI 3 / IARC equivalent)

---

## What's New (Version 1.0 — initial release)

```
Welcome to MindLab Fitness — the no-subscription nutrition tracker.

• AI Meal Scanner — snap a photo, get instant nutrition
• 53,000+ food database with barcode scanning
• 8 meal plans, 400+ recipes
• Smart reminders for water, meals, and weigh-ins
• Health Connect integration for steps and weight
• Achievements and logging streaks

Free to download. Unlock Pro for the full experience — no subscriptions, ever.
```

---

## Pricing

### Business Model
**Free app** with one-time Pro in-app product (non-consumable, one-time purchase)

### In-App Product
- **Product ID**: `com.mochasmindlab.mlhealth.pro`
- **Type**: One-time (managed product)
- **Price**: $8.99 CAD (matched to iOS) — set per-region in Play Console for local equivalents

### Free Tier
- Manual food logging and search (53K+ database)
- Water tracking with reminders
- Weight tracking with trend chart
- Exercise logging
- Dashboard with calorie, macro, and step summaries
- One meal plan (Mediterranean) preview
- Reminders, achievements, logging streak
- Health Connect integration

### Pro Tier (one-time purchase)
- AI meal photo scanner
- Full meal plan library (all 8 plans, 400+ recipes)
- Advanced progress reports
- Future Pro features included at no additional cost

---

## Permissions Justification

| Permission | Why we need it |
|---|---|
| `INTERNET` | AI meal scanning (Claude API), USDA food search, Open Food Facts barcode lookup |
| `CAMERA` | Barcode scanning of packaged food, AI meal photo capture |
| `READ_EXTERNAL_STORAGE` | Pick existing meal photos from gallery for AI analysis (Android <= 28 only) |
| `POST_NOTIFICATIONS` | Smart reminders (water, meals, weigh-in) |
| `com.android.vending.BILLING` | Pro one-time purchase via Google Play Billing |
| `health.READ_STEPS` | Show steps on the dashboard via Health Connect |
| `health.READ_WEIGHT` | Show latest weight from Health Connect |
| `health.WRITE_WEIGHT` | Sync user-entered weight back to Health Connect |

---

## Required URLs

- **Support URL**: `https://mochasmindlab.com/support.html`
- **Privacy Policy URL**: `https://mochasmindlab.com/privacy.html`
- **Marketing URL** (optional): `https://mochasmindlab.com`

The privacy policy MUST disclose:
1. Use of Anthropic Claude API for meal scanning (food photos transmitted, not retained per provider)
2. Use of USDA FoodData Central + Open Food Facts for food/barcode search
3. Use of Health Connect (steps + weight read/write)
4. No collection of analytics or PII
5. All personal data stored locally on device (Room + DataStore)

---

## Data Safety Form Answers (Play Console)

### Data Collection
**Data collected by the app**: None  
**Data shared with third parties**: Photos (only for AI meal scan, transmitted to Anthropic, not retained)

### Data Types
- **Health and fitness**: weight, exercise, food intake, water intake — all stored ON-DEVICE only, not collected by us, not shared.
- **App activity**: none collected.
- **App info and performance**: none collected.

### Security Practices
- Data is encrypted in transit: **Yes** (HTTPS to Anthropic, USDA, Open Food Facts)
- Users can request data deletion: **Yes** — Settings → Clear Data wipes Room + DataStore on the device
- Committed to Play Families Policy: N/A (not targeted at children)

---

## Screenshots Required (Play Store)

### Phone (16:9 or 9:16, min 320px short side)
1. Dashboard — daily summary with calories, macros, steps, water
2. Food Diary — meal sections with entries and totals
3. AI Meal Scanner — photo analysis with detected foods
4. Food Search — search with 53K database
5. Meal Plans — recipe view with macros
6. Achievements — streak + categorized achievements

### 7-inch Tablet (recommended)
- Same six screenshots, scaled

### Feature Graphic (REQUIRED — 1024×500 px)
- Hero shot of phone showing dashboard, app name + tagline overlay
- Use the iOS feature graphic from `iOS-Apps/HealthTracker/MARKETING/` as starting point

### Promo Video (optional)
30-second YouTube link demoing AI scanner → food added to diary → meal plan view

---

## Internal Testing → Production Release Path

1. **Internal testing track** (closed): upload signed AAB, add 3-5 testers via email opt-in.
   - Verify: Health Connect prompt, Pro purchase flow (use a test account), notification permission prompt, AI scanner with valid `anthropic.api.key` set.
2. **Closed testing**: open to a wider group (~20 friends), 1-2 weeks for feedback.
3. **Open testing** (optional): public beta, gather Play Store reviews early.
4. **Production**: full release, staged rollout (start at 20% → 50% → 100% over a week).

---

## Pre-Launch Action Items

- [ ] Set production `anthropic.api.key` in `local.properties` for the release build
- [ ] Create the in-app product `com.mochasmindlab.mlhealth.pro` in Play Console → Monetize → In-app products
- [ ] Generate signing keystore (NOT checked into git): `keytool -genkey -v -keystore ml-fitness-release.keystore -alias ml-fitness -keyalg RSA -keysize 2048 -validity 10000`
- [ ] Configure `signingConfigs` in `app/build.gradle.kts` reading from `keystore.properties` (also gitignored)
- [ ] Add the Health Connect privacy-policy `<activity-alias>` to `AndroidManifest.xml` (currently a TODO comment) — required for Play submission with Health Connect permissions
- [ ] Update versionCode + versionName for the release build
- [ ] Test the release build on a physical device, NOT just emulator
- [ ] Run the full app on a Health Connect-enabled device
- [ ] Verify Pro purchase + restore + locked-content gating all work end-to-end
- [ ] Take 6 phone screenshots + 1 feature graphic at 1024×500
- [ ] Write the Privacy Policy update covering Anthropic + Health Connect + Play Billing

---

## Notes

- Bundle ID: `com.mochasmindlab.mlhealth` (NOT iOS `.HealthTracker`)
- iOS Pro product ID: `com.mochasmindlab.HealthTracker.pro`
- Android Pro product ID: `com.mochasmindlab.mlhealth.pro`
- These are intentionally separate — Apple and Google each manage their own SKUs.
- Maintain copy parity between this file and the iOS `APP_STORE_SUBMISSION.md` going forward.
