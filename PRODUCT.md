# MindLab Fitness — product brief

**Read this before working on the repo, writing copy, or making a product call.**
It is the context that is not recoverable from the code: why the app exists, how
it is positioned, what has already been tried in marketing, and which decisions
are settled.

Written for agents (Vex, Claude, anything else) and for humans joining cold.
Last updated 18 September 2026.

- Engineering conventions, build and ship steps: `CLAUDE.md`
- Deeper history and per-area notes: `docs/PROJECT-NOTES.md`

---

## 1. Why this app exists

Mocha Shmigelsky built it because she wanted **MyFitnessPal without the
subscription**.

That is the whole origin. Calorie tracking is a habit you keep for years, and the
category has spent the last two years moving the useful parts behind a recurring
bill. MyFitnessPal Premium is **$19.99/month or $79.99/year**, and in **May 2026
it moved photo meal scanning into Premium** — the single feature that removes the
tedious part of logging food. Cronometer puts AI photo logging in Gold.
FatSecret puts Smart Food Scan in Premium. Every major tracker rents it.

MindLab Fitness charges **$8.99 CAD once**. Over five years that is $8.99 against
roughly $400 for MyFitnessPal Premium billed annually.

The second conviction is **privacy by structure, not by policy**. Health data is
among the most sensitive data a person generates. It is stored on the device.
There is no account, no cloud database of food logs, nothing to breach and
nothing to sell. That is a constraint the product is built around, not a feature
bolted on: if we do not hold the data, we cannot lose it or monetise it later.

Both convictions are load-bearing. Anything that reintroduces a subscription or
moves health data to a server contradicts the reason the app exists. Do not
propose either without an explicit conversation.

---

## 2. What the app actually does

Native on both platforms. iOS is the source of truth; Android mirrors it exactly.

**The wedge — AI meal scanner.** Photograph a meal, Claude Vision identifies the
foods and returns calories, protein, carbs and fat with a confidence score.
Adjust portions, save to the diary. No searching a database for "chicken thigh,
roasted, skin removed" and guessing portions.

**Food logging**
- 53,000-food offline database (USDA, SQLite FTS5) with USDA API fallback
- Barcode scanner via Open Food Facts; decoding runs on-device (Google ML Kit),
  only the numeric barcode is sent
- Breakfast / lunch / dinner / snacks diary with daily macro totals
- Copy from a previous day, by meal type, including supplements

**Meal planning**
- 8 diets x 50 real recipes = 400 recipes, full 4-week plans
- Mediterranean, Keto, Vegetarian, Vegan, Paleo, Whole30, Intermittent Fasting,
  Family Friendly
- Ingredients, instructions, macros, grocery list generation

**Tracking**
- Exercise logging with calorie burn estimates (MET-based)
- Built-in step counter
- Weight, body measurements (waist, hips, chest, biceps, thighs) and progress charts
- Supplement tracking with a vitamin and mineral database and RDA analysis
- Hydration tracking
- Apple Health / Google Fit integration, including Apple Watch data
- Smart reminders: water, steps, meals, exercise, weight, each toggleable
- Nutrition analytics: today / week / month, macro bars, full nutrient table
- CSV import, including MyFitnessPal export history

**Units.** Weights are always **stored in pounds** on both platforms. The user
picks lbs or kg for display only (iOS: More → Units; Android: Settings → Units).
Conversion happens at exactly two boundaries, display and typed input, so
switching never rewrites history.

---

## 3. Pricing and what is gated

| | |
|---|---|
| Download | Free |
| Pro unlock | **$8.99 CAD one-time**, non-consumable IAP |
| Subscription | **None. Ever.** |
| Trial | 7-day free Pro trial, started from the paywall |
| Free AI scans | 3, then the paywall |
| Free meal plans | Mediterranean plan plus 8 built-in recipes |
| Pro | All 400 recipes, unlimited scanning, all gated features |

Pro is bought per platform; Apple and Google do not share purchases.

**Economics that constrain marketing.** A free app with a one-time $8.99 unlock
cannot sustain a high cost per install. Paid acquisition around **$2.50 CPI is
the sustainable zone**; $7+ is only justifiable as ranking velocity, and $16 is
not justifiable at all. Any growth proposal has to respect that ceiling.

---

## 4. Competitors

Publisher list pricing, checked September 2026, changes without notice. MyFitnessPal,
Cronometer and FatSecret were checked directly; the Lose It! lifetime figure is
second-hand and worth re-checking before it goes in public copy.

| App | Recurring | One-time | Photo meal scan |
|---|---|---|---|
| MyFitnessPal Premium | $19.99/mo or $79.99/yr | none | Paid tier only |
| MyFitnessPal Premium+ | $24.99/mo or $99.99/yr | none | Paid tier only |
| Cronometer Gold | ~$10/mo or $50-60/yr | none | Paid tier only |
| FatSecret Premium | $14.99/mo or $59.99/yr | none | Paid tier only |
| Lose It! | subscription | ~$299.99 lifetime | Paid tier |
| Noom, YAZIO, MacroFactor, Cal AI | subscription | none | varies |
| **MindLab Fitness** | **none** | **$8.99 CAD** | **included** |

**How to talk about them honestly.** Cronometer and FatSecret have genuinely good
free tiers for basic logging, and the marketing says so. Recommending them where
they win is what makes the comparison content credible enough to rank, and it is
also true. The claim is narrow and defensible: nobody else includes photo meal
scanning in a one-time purchase.

Never put competitor trademarks in the Apple keyword field — Apple prohibits it
and it risks rejection. Comparison belongs on the website, where it is legal and
already working.

---

## 5. Companion and sibling products

**Mindful Meal Plans** — the true companion app. AI meal planning, fridge and
pantry scanning, household grocery lists. Same customer, adjacent job: MindLab
Fitness answers "what did I eat", Mindful Meal Plans answers "what should I
cook". Lives at **mindfulmealplan.com**, its own repo (`Web-Apps/meal-plans-pivot`)
and its own App Store listing. The two sites link to each other; keep that mutual.

**Mocha's Mind Labs Inc.** is the umbrella. Each product has its own domain:

| Product | Domain | What it is |
|---|---|---|
| MindLab Fitness | mochasmindlab.com | this app |
| Mindful Meal Plans | mindfulmealplan.com | AI meal planning |
| Happy Grants | happygrants.com | grant discovery and AI co-writing, Canadian non-profits **and SMEs** |
| Certalot | certalot.com | food export compliance |
| Mocha Shmigelsky | mochashmigelsky.com | AI enablement consulting |

`mochasmindlab.com` is **the MindLab Fitness site**, not a company homepage. It
also hosts the **live meal-scan proxy** at `/api/v1/meal-scan` — that path is
production infrastructure for shipped apps, so treat any change to it as a release.

---

## 6. Positioning and terminology

**Names.** App Store and home screen: **MindLab Fitness**. Developer: Mocha's
MindLab Inc. "ML Fitness" is the legacy name, kept only as a schema
`alternateName` so the old spelling stays searchable. Do not reintroduce
"Fitness & Calorie Tracker", the previous App Store title.

**The naming decision, and why it matters.** Under a generic "calorie app"
positioning there were essentially **no sales**. Calorie counter is a red ocean
owned by MyFitnessPal and Lose It!; competing on the commodity keyword buried the
listing and converted nothing. The fix was to stop fighting for the generic
ranking and win specific, less contested terms instead. **The AI meal scanner is
the wedge. Lead with it.**

**iOS and Android listings differ on purpose. Do not sync them.**
- Apple does not index the description and weights title and subtitle heavily, so
  iOS leans on brand plus scanner: *MindLab Fitness* / *AI Meal Scanner & Calorie Log*
- Google indexes title, short and long description, so Play leads with the search
  term: *Calorie Counter: AI Scanner*

**Apple keyword field.** Name, subtitle and keywords are indexed as one pool. A
word already in the name or subtitle is wasted in the keyword field. Current name
and subtitle already cover: MindLab, Fitness, AI, Meal, Scanner, Calorie, Log.

**Term bank** (Apple Search Ads keywords, Google asset copy, Play ASO):
- Core: calorie counter, calorie tracker, food tracker, **food diary**, food
  journal, meal diary, macro tracker, macro counter, nutrition tracker
- Differentiator, low volume and high intent: ai calorie counter, ai food scanner,
  food scanner, meal scanner, scan food calories, photo calorie counter, calorie ai
- Diet terms: keto meal plan, vegan meal plan, intermittent fasting

**Messages that have carried the product:**
- "Snap a photo. Get instant calories."
- "Stop guessing. Start knowing."
- "No subscription. Ever." / "$8.99 once, not $80 a year."
- "Your data never leaves your device."
- "Free to download. $8.99 one-time Pro unlock."
- "Built in Vancouver, British Columbia."

---

## 7. What marketing has already been tried

**Apple Search Ads** (from 19 June 2026, Canada, ~$7/day). The expensive lesson,
so it is not repeated:

- Exact-match keywords served **zero impressions for two weeks** at every bid up
  to $4.00. The problem was never price, it was volume: exact match in a
  Canada-only storefront has almost no search traffic. **Broad match is what
  works here.**
- Apple's own keyword recommendations were junk — snapchat, tiktok, netflix,
  roblox. Do not bulk-add them.
- Winners by cost per install: **`food diary` (broad)** is the star at 6.49%
  tap-through, then `food tracker` and `macro tracker`. `calorie tracker free`
  was a pure leak: a third of the budget, zero installs.
- Negatives that had to be added: dynacare, goodlife, planet fitness, anytime
  fitness, snap.
- Blended CPI ran $7+, above the $2.58 sustainable zone, so ASA is worth treating
  as ranking velocity and keyword learning rather than a growth engine.

**Website and SEO** (September 2026). `mochasmindlab.com` was rebuilt as the app's
landing page. It had one page indexed of nine because the canonical tag pointed at
a 404 and four hostnames served identical content. Fixed, plus structured data, a
comparison page targeting "calorie counter without a subscription", and a
persistent download CTA.

**Not yet done:** AlternativeTo listing, App Store featuring nomination, Product
Hunt, Canadian tech press. Draft copy for the first two is in
`work-plans/ml-fitness-listings-2026-09.md` with assets alongside it.

---

## 8. Settled decisions — do not relitigate without asking

1. **No subscription.** This is the product.
2. **Health data stays on device.** No account, no server-side log.
3. **Pounds are the canonical stored unit** on both platforms. Display converts.
4. **iOS is the source of truth**; Android mirrors it exactly, including enums,
   labels and copy. Read the iOS file first.
5. **iOS and Play listings stay different.** See section 6.
6. **Let a release breathe.** After a version ships, give it 2 to 4 weeks of live
   traffic before proposing pricing, paywall or naming changes. Pricing and the
   scan limit have been through many rounds already; churn without install data
   muddies the signal. During that window, work on things outside the binary:
   listing copy, screenshots, marketing, installs.
7. **Ask for real numbers first.** Do not recommend app-side changes blind; pull
   installs and Pro sales from App Store Connect.
8. **No fabricated social proof.** Three invented testimonials were removed from
   the website in September 2026. Fake testimonials breach the Competition Act in
   Canada. There is currently **one real App Store review** and **three ratings**;
   quote only what can be sourced, and do not publish an aggregate rating off a
   sample of three.

---

## 9. Where things live

| | |
|---|---|
| Repo | `MochaS29/ml-fitness` — `ios/`, `android/`, `shared/` |
| Bundle ID (iOS) | `com.mindlabs.healthtracker` — Apple ID `6752837101` |
| Package (Android) | `com.mochasmindlab.mlhealth` |
| App Store | apps.apple.com/ca/app/mindlab-fitness/id6752837101 |
| Google Play | play.google.com/store/apps/details?id=com.mochasmindlab.mlhealth |
| Website | mochasmindlab.com |
| Meal-scan proxy | `mochasmindlab.com/api/v1/meal-scan` — key lives only in Vercel env |
| Linear | team Mochas Mind Lab (`MOC`), project **ML Fitness (HealthTracker)** |
| Listing copy and assets | `work-plans/ml-fitness-listings-2026-09.md` |
