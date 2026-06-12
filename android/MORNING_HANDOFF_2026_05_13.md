# Morning Handoff — 2026-05-13

## TL;DR

- **v1.1.1 is committed and ready to ship locally** but the Android GitHub remote (`MochaS29/MLHealthAndroid`) was force-pushed to unrelated website content. **You need to fix that first** before any Android `main` push works. The new `secure-api-key` branch DID push to the messed-up remote, so the branch work is preserved.
- **Anthropic-proxy work is done on three branches** — iOS, Android, and the website. All three branches are pushed to GitHub. The Vercel preview should be live within minutes of you reading this.
- **You need to do four things before testing the proxy:** (1) set two Vercel env vars, (2) generate a shared secret, (3) drop it into iOS Secrets.plist and Android local.properties, (4) verify the ping endpoint.

---

## 🚨 BLOCKER 1 — Android `origin/main` is wrong

`origin/main` on `MochaS29/MLHealthAndroid` currently points at the website codebase (last commit *"Update app name from ML Health to ML Fitness on main website"*). Your local `main` has 14 commits ahead that include the entire Android app + the new v1.1.1 work I committed (commit `dd9b429`).

A force-push happened at some point and clobbered the remote.

**Options:**
- **A)** Force-push your local main to fix it: `git push --force-with-lease origin main` *(this will overwrite whatever website content the remote has — verify with `git log origin/main` first that you don't need it)*
- **B)** Create a new clean repo on GitHub and point `origin` there
- **C)** Investigate first — `gh repo view MochaS29/MLHealthAndroid` and check if maybe it's an accidental case of two repos overlapping

I did **not** force-push because it's destructive. Your call which option in the morning.

The `secure-api-key` branch DID push successfully, so the proxy work is safe regardless of how you resolve this.

---

## ✅ What got done overnight

### v1.1.1 Android (committed to local `main` as `dd9b429`)

All the work from yesterday is in one commit:
- Data-sync audit fixes (Profile/Goals/Dashboard/Weight/Water/Exercise all read from one source)
- Barcode-scanner crash fix (added `kotlin-parcelize`, `@Parcelize` on FoodItem)
- Dietary Preferences screen (mirrors iOS — 22 dietary prefs + 15 allergens)
- Exercise reminder time picker
- 6 new PreferencesManager setters + dietary preferences flow

### Anthropic API key security — three pair branches

| Repo | Branch | Status |
|---|---|---|
| `Web-Projects/mochamindlabs-website` | `secure-api-key` | Pushed. Vercel will auto-deploy a preview URL. |
| `iOS-Apps/HealthTracker` | `secure-api-key` | Pushed. Compiles cleanly. |
| `Android-Apps/MLHealthAndroid` | `secure-api-key` | Pushed. Compiles cleanly. |

What changed on each:
- **Website:** Added `api/v1/meal-scan.js` (proxy endpoint) and `api/v1/ping.js` (health check). Holds the Anthropic key server-side via Vercel env vars.
- **iOS:** `MealAnalysisService.swift` now calls the proxy instead of `api.anthropic.com`. Per-install UUID stored in UserDefaults.
- **Android:** Same — `MealAnalysisService.kt` calls the proxy. Per-install UUID stored in DataStore. Removed `ANTHROPIC_API_KEY` from BuildConfig entirely; added `APP_SHARED_SECRET` and `MEAL_SCAN_ENDPOINT`.

---

## 🟡 Things you need to do before testing the proxy

### 1. Generate a shared secret (1 min)

```bash
openssl rand -hex 32
```

Save the output — you'll paste it into three places below.

### 2. Set Vercel env vars (2 min)

Go to: Vercel dashboard → `mindlabs-website` project → Settings → Environment Variables

Add to **both Production and Preview** environments:

| Name | Value |
|---|---|
| `ANTHROPIC_API_KEY` | Your real `sk-ant-...` key (from `iOS-Apps/HealthTracker/HealthTracker/Configuration/Secrets.plist`) |
| `APP_SHARED_SECRET` | The hex string from step 1 |

Redeploy after saving (Vercel does this automatically when env vars change).

### 3. Verify the preview deployment (1 min)

Find the preview URL in Vercel dashboard → Deployments → most recent → "Visit". It'll look like:
```
https://mindlabs-website-git-secure-api-key-mochas29.vercel.app
```

Test the ping endpoint:
```bash
curl https://<your-preview-url>/api/v1/ping
```

Should return `{"ok":true,"service":"ml-fitness-proxy","ts":"..."}`.

### 4. Drop the shared secret into both apps

**iOS:** Edit `iOS-Apps/HealthTracker/HealthTracker/Configuration/Secrets.plist`:
```xml
<key>APP_SHARED_SECRET</key>
<string>PASTE_HEX_HERE</string>
```

Optionally also set:
```xml
<key>MEAL_SCAN_ENDPOINT</key>
<string>https://<preview-url>/api/v1/meal-scan</string>
```
(Leave it empty to use the default `https://mochasmindlab.com/api/v1/meal-scan`, but that won't work until you merge to main + redeploy.)

**Android:** Edit `Android-Apps/MLHealthAndroid/local.properties` — add:
```
app.shared.secret=PASTE_HEX_HERE
meal.scan.endpoint=https://<preview-url>/api/v1/meal-scan
```
*(Same caveat — preview URL until merge.)*

---

## 🧪 Test plan

Once env vars are set + shared secret is in both apps:

### Smoke test the proxy itself
```bash
# Should succeed with status 200
curl -X POST https://<preview-url>/api/v1/meal-scan \
  -H "Content-Type: application/json" \
  -H "X-App-Secret: $APP_SHARED_SECRET" \
  -H "X-Install-Id: test-curl-123" \
  -d '{"image":"<base64-of-any-jpeg>"}'

# Should return 401
curl -X POST https://<preview-url>/api/v1/meal-scan \
  -H "Content-Type: application/json" \
  -H "X-App-Secret: wrong" \
  -H "X-Install-Id: test-curl-123" \
  -d '{"image":"abc"}'

# Should return 400 (missing install-id)
curl -X POST https://<preview-url>/api/v1/meal-scan \
  -H "Content-Type: application/json" \
  -H "X-App-Secret: $APP_SHARED_SECRET" \
  -d '{"image":"abc"}'
```

### Test in apps
- **iOS:** Open HealthTracker on simulator → Meal Scanner → scan a food photo → should return nutrition results from Anthropic via the proxy.
- **Android:** Open MLHealthAndroid on emulator → Meal Scanner → same flow.

### Verify the key is actually gone from binaries
```bash
# Android — should output 0
unzip -p Android-Apps/MLHealthAndroid/app/build/outputs/apk/development/debug/app-development-debug.apk classes.dex | strings | grep -c "sk-ant"

# iOS — same idea, should output 0
strings ~/Library/Developer/Xcode/DerivedData/HealthTracker-*/Build/Products/Debug-iphonesimulator/HealthTracker.app/HealthTracker | grep -c "sk-ant"
```

Both should print `0`. If they print anything else, something didn't get removed.

---

## 🚢 Going live

Once both apps scan a meal successfully via the preview proxy:

1. **Merge `secure-api-key` to `main` on the website repo** → Vercel auto-deploys to `mochasmindlab.com/api/v1/*`
2. Update iOS Secrets.plist + Android local.properties to use the production URL (or leave them on default which is already prod)
3. Rebuild + verify both apps still work against the prod URL
4. **Rotate the Anthropic key**: generate a fresh one in console.anthropic.com, update Vercel env var, revoke the old one. (The old key was readable in Secrets.plist locally — not committed but worth rotating now that the proxy works.)
5. Merge `secure-api-key` to `main` on iOS + Android repos
6. Build + submit v2.4.1 (iOS) and v1.1.2 (Android) — both should bump version codes to indicate the security change in release notes ("Internal: improved API security")

---

## 📋 Open items

- [ ] Resolve Android `origin/main` mismatch (Blocker 1 above)
- [ ] iOS WIP work is stashed on iOS main — `git stash list` shows: *"WIP: iOS Diary/StepGoal work before secure-api-key branch (auto-stashed by Claude 2026-05-12)"*. Restore with `git stash pop` after you finish API key QA.
- [ ] Website repo has unrelated mindquest-pm-agent + deleted icon changes on local main — separate cleanup from this work, ignore for now.
- [ ] Anthropic spend cap — you confirmed this is set. Verify it's still active (console.anthropic.com → Settings → Limits).
- [ ] Memory file updated: `feedback_mlfitness_mirror_ios.md` added to MEMORY.md index. From here on I'll default to mirroring iOS for any UI/data question on Android.

---

## 📂 Files touched

**Android (`secure-api-key` branch):**
- `app/build.gradle.kts`
- `app/src/main/java/com/mochasmindlab/mlhealth/services/SecretsManager.kt`
- `app/src/main/java/com/mochasmindlab/mlhealth/services/MealAnalysisService.kt`
- `app/src/main/java/com/mochasmindlab/mlhealth/utils/PreferencesManager.kt`

**Android (`main` — v1.1.1 commit `dd9b429`):**
- 41 files (data-sync audit + dietary prefs + barcode parcelize)

**iOS (`secure-api-key` branch):**
- `HealthTracker/Configuration/SecretsManager.swift`
- `HealthTracker/Services/MealAnalysisService.swift`
- `HealthTracker/Configuration/Secrets.plist` (local-only, gitignored)

**Website (`secure-api-key` branch):**
- `api/v1/meal-scan.js` (new)
- `api/v1/ping.js` (new)
- `api/README.md` (new)

---

Ping me when you wake up — I'll help with the Android remote situation and walk through whatever test failures come up.
