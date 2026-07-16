# ML Fitness — Optimized Play Store Listing (ASO)

> Drafted Jun 29, 2026. Replaces the listing copy in `PLAY_STORE_SUBMISSION.md`.
> **Why this differs:** Google indexes the **title + short description + full description**
> for search ranking (unlike Apple, which ignores the description). So every field here is
> written to (a) convert *and* (b) rank for high-intent search terms. The old title led with
> "MindLab Fitness" — a brand nobody searches — and exceeded Play's real **30-char** title limit.

---

## 1. App Title — **30 chars max** (highest ranking weight)

**RECOMMENDED:**
```
Calorie Counter: AI Scanner
```
(27 chars — leads with the #1 search term, names the differentiator)

**Alternatives (A/B candidates):**
```
AI Calorie Counter & Tracker      (28)
Calorie Counter & Food Scanner    (30)
```

> ⚠️ Changing the title triggers a brief Play re-index and resets some ranking signals.
> Worth it here because the current title buries every keyword behind the brand. Do it **once**,
> then leave it — don't churn the title.

---

## 2. Short Description — **80 chars max** (shown above the fold, indexed)

**RECOMMENDED:**
```
AI food scanner + calorie & macro tracker. Meal plans, no subscription.
```
(71 chars — intent keywords + the knockout "no subscription" hook)

**Alternative:**
```
Snap a photo to count calories. Macro tracker + meal plans. Pay once, no sub.
```
(76 chars)

---

## 3. Full Description — **4000 chars** (keyword-indexed; write for humans first)

```
Counting calories shouldn't be a chore. Snap a photo of your meal and our AI food scanner identifies every item with calories, protein, carbs, fiber, and fat, instantly. No tedious manual logging. Or search 53,000+ foods and scan barcodes when you want.

ML Fitness is the all-in-one calorie counter, macro tracker, and meal planner that respects your privacy and your wallet. Download free, unlock Pro once. No subscriptions.

AI MEAL SCANNER
- Snap a photo of any meal to count calories instantly
- AI calculates calories, protein, carbs, fat, and fiber
- Adjust portions and save straight to your food diary

FOOD SEARCH & BARCODE SCANNER
- 53,000+ foods from the USDA database, plus a barcode scanner
- Recent foods for one-tap re-logging
- Add custom foods for anything not in the database

FOOD DIARY & CALORIE COUNTER
- Track breakfast, lunch, dinner, and snacks
- Daily totals for calories, protein, carbs, fat, and fiber
- Set custom goals, including a high-fiber goal for heart health
- Tap the date to jump to any day with a calendar

IMPORT YOUR HISTORY
- Switching from another app? Bring your food, exercise, and weight history with you
- Import from a CSV export so you don't start over

MACRO TRACKER & GOALS
- Track protein, carbs, fat, and fiber against personal targets
- Adjustable goals for weight loss, muscle building, or a health condition

8 MEAL PLANS WITH 400+ RECIPES
- Mediterranean, Keto, High Protein, Balanced, Low Carb, Paleo, Whole30, and Vegan
- Full 4-week plans with recipes, ingredients, and macro breakdowns

FITNESS & WEIGHT TRACKING
- Log any exercise with automatic calorie-burn estimates
- Daily weight logging with trend graphs
- Health Connect for steps and workouts

HYDRATION & REMINDERS
- Water tracking with a daily goal
- Smart, customizable reminders for water, meals, and weigh-ins

WHY ML FITNESS
NO SUBSCRIPTIONS. Pay once for Pro and it's yours. Other calorie counters charge $10-20 a month. We don't.
PRIVACY FIRST. Your data stays on your device. No accounts, no tracking.
WORKS OFFLINE. Everything except AI scanning and online food search works without internet.

Perfect for weight loss, building muscle, meal prep, hitting a fiber goal, or simply eating better. Start counting calories the easy way today.
```

> **Keyword coverage** (woven naturally, not stuffed): *calorie counter, calorie tracker,
> food scanner, AI food scanner, macro tracker, food diary, barcode scanner, meal planner,
> meal plans, nutrition tracker, weight loss, fiber goal, food database.* First 3 lines are
> what shows before "read more" — they front-load the hook + top keywords.

---

## 4. What's New (v1.1.8 / build 10 — import release)

```
• Import your history: bring your food, exercise, and weight from another app via a CSV export, so you don't start over
• Tap the date in your diary to jump to any day with a calendar
• Fixes and polish

Free to download. Unlock Pro once. No subscriptions.
```

---

## 5. Play Store tags (up to 5)
`Calorie counter` · `Nutrition` · `Macro tracker` · `Meal planner` · `Weight loss`

---

## 6. Visual assets — the real conversion driver (action items, not copy)

These move installs more than text. Current `fastlane/metadata/.../images/` has only icon +
featureGraphic — **screenshots and a video are missing from the repo.**

1. **Screenshots (in this order, with a one-line caption overlay on each):**
   1. AI scanner flow — photo → calories + macros result *(lead with your wedge)*
   2. Nutrition dashboard — calories/macros/fiber rings
   3. Meal plans library — "8 plans, 400+ recipes"
   4. Food diary / barcode scan
   5. Progress + weight trend
   - Bare screenshots underperform; add a short caption banner to each.
2. **Feature graphic (1024×500):** one line — e.g. "Snap a photo. Count calories. No subscription."
3. **Promo video (15–30s):** Google shows it *before* screenshots and favors listings that have one.
   A screen recording of the scan flow is enough to start.

---

## 7. Ratings loop (ranking + conversion)
- Wire the **Play In-App Review API** to prompt after a positive moment (first successful scan,
  or a 3-day logging streak) — rating *volume and recency* both feed ranking.
- Confirm the store entry is tagged **Free + IAP**, not Paid.

---

## Rollout note
Title + short-description changes re-index the listing, so make them in one pass and let it settle
~1–2 weeks before judging. The full description and assets can be updated anytime with lower risk.
The fiber goal mentioned above is the feature shipped in MOC-110 (not yet live on Play — bundle the
listing update with that release).
```
