# Health Connect Rejection — Resubmission Kit

**Rejected:** Jul 2, 2026 — "Insufficient Information to Determine App Functionality for Health Connect."
**Root cause:** Not a code bug. All 4 permissions are genuinely used, but (a) the Play Console
declaration lacked per–data-type justification, (b) the in-app rationale copy mentions only steps +
weight — not ActiveCaloriesBurned — so the manifest and UI disagreed, and (c) no demonstration video /
Health-Connect-specific privacy policy for the reviewer to confirm functionality.

Permissions in `app/src/main/AndroidManifest.xml`:
`READ_STEPS`, `READ_WEIGHT`, `WRITE_WEIGHT`, `READ_ACTIVE_CALORIES_BURNED` — all wired in
`services/HealthConnectManager.kt` and consumed in `viewmodel/DashboardViewModel.kt`.

---

## STEP 1 — Per-permission justifications (paste into Play Console → App content → Health apps declaration)

For each data type, paste the matching block. These are written to match actual app behavior —
Google cross-checks the declaration against the running app, so do not embellish.

### Steps (Read)
```
ML Fitness is a calorie and nutrition tracker. It reads the user's daily step count from Health
Connect to display steps on the home dashboard, show day-over-day step trends, and estimate active
calories burned when no active-energy data is available. This lets users see their activity next to
their food intake and understand net calories (calories consumed minus calories burned) without
manually entering steps. Steps are read-only, shown in-app, and never shared with third parties.
```

### Active calories burned (Read)
```
ML Fitness reads active calories burned from Health Connect to show the user's energy expenditure on
the dashboard and to calculate net calories (food calories minus calories burned) — the core metric of
calorie tracking for weight management. When no active-calorie samples exist, the app falls back to a
step-derived estimate. This data is read-only, displayed to the user, and never shared with third
parties.
```

### Weight (Read)
```
ML Fitness reads the user's most recent body weight from Health Connect to display it on the dashboard
and weight-trend graph, and to personalize calorie-burn calculations. This keeps the user's weight
consistent with their other health apps without manual re-entry. Read-only display; not shared.
```

### Weight (Write)
```
When a user logs their body weight inside ML Fitness, the app writes that value to Health Connect so it
stays in sync across the user's other health and fitness apps. Only weight the user personally enters
in ML Fitness is written; no other data is created or modified.
```

---

## STEP 2 — Demonstration video (the piece the reviewer was missing)

The declaration form has a "video demonstrating your app's Health Connect functionality" field.
Record a 30–60s screen capture (upload unlisted to YouTube, paste the link):

1. Open ML Fitness → navigate to the **Health Connect** screen.
2. Tap **Grant Access** → show the Health Connect permission sheet listing steps, weight, active
   calories → grant all.
3. Return to the app → show the **dashboard** populating: today's **steps**, **active calories /
   calories-out**, and **latest weight** + trend.
4. Log a weight in-app → show it written back (open Health Connect app → weight now reflects it), to
   demonstrate WRITE_WEIGHT.

Narrate or caption each step so the reviewer sees each data type in use.

---

## STEP 3 — Privacy policy must name Health Connect (mochasmindlab.com/privacy.html)

Google requires the privacy policy to specifically address Health Connect. Confirm it states:
- The app accesses Health Connect data: **steps, active calories burned, and body weight** (read),
  and **body weight** (write).
- How each is used (dashboard display, net-calorie calculation, cross-app weight sync).
- That Health Connect data is **stored on-device only, not transmitted to any server, not shared or
  sold**, and how the user can revoke access (Health Connect app → permissions).
- If you use the Health Connect data solely on-device, say so explicitly — reviewers look for this.

---

## STEP 4 — In-app copy must match the manifest

`ui/screens/healthconnect/HealthConnectScreen.kt` currently tells users the app reads "steps and
weight" — it omits **active calories**. Either:
- **(Keep-all path — recommended):** update the copy to "read your steps, active calories, and weight
  … and write weight back." (Done in code if you chose this path.)
- **(Drop path):** remove `READ_ACTIVE_CALORIES_BURNED` from AndroidManifest.xml + the
  `ActiveCaloriesBurnedRecord` read in HealthConnectManager.kt + its use in DashboardViewModel
  (falls back to the existing step-derived estimate). Then the copy is already correct.

---

## STEP 5 — Resubmit

1. Upload a new build (only needed if you changed the manifest/code in Step 4).
2. Complete the Health apps declaration with the Step 1 justifications + Step 2 video link.
3. Confirm the privacy policy (Step 3) is live before submitting.
4. Submit for review. Health Connect re-reviews typically take a few days.

**Note:** This is the Health Connect *permissions* review — separate from the app-content update.
The fiber-goal changes (MOC-110) are still not live on Play; this rejection blocks the update that
carried them. Resolving this unblocks that release too.
```
