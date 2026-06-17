# ML Fitness

One product, two **native** apps: a fitness & calorie tracker with an AI meal scanner and planner.
Marketed as **ML Fitness** (App Store name "Fitness & Calorie Tracker", home-screen "MindLab Fitness").
Free + a one-time **Pro IAP** ($8.99 CAD).

- **iOS** — SwiftUI (iOS 17+), live on the App Store
- **Android** — Kotlin / Jetpack Compose, Play Internal Testing (Production promotion pending)

## Layout

```
ios/        SwiftUI app — Xcode project HealthTracker.xcodeproj
android/    Kotlin / Jetpack Compose app (Gradle)
shared/     cross-platform docs: parity checklist, meal-scan proxy API contract
```

## Parity rule (most important)

**Android mirrors iOS exactly** — enums, category labels, screens, copy. iOS is the source of truth.
Read the corresponding iOS source before porting/fixing on Android; never invent new categories. Change
shared behavior on both platforms in the same commit where possible.

## Build

**iOS** (from repo root):
```sh
xcodebuild -project ios/HealthTracker.xcodeproj -scheme HealthTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
```
Before archiving for the App Store, set the scheme's StoreKit config to **None** (use
`MLFitnessPro.storekit` only for simulator IAP testing). `ios/HealthTracker/Configuration/Secrets.plist`
is gitignored and required to build.

**Android** (from repo root):
```sh
cd android && ./gradlew assembleDebug      # debug build
cd android && ./gradlew bundleRelease      # Play Store AAB
```
`android/local.properties`, `keystore.properties`, `release.keystore` are gitignored and required for
release builds — never commit them.

## Meal scanner backend

Both apps call the Vercel proxy `https://mochasmindlab.com/api/v1/meal-scan` — the Anthropic key lives
only in the proxy's env vars, never in app binaries. Auth headers: `X-App-Secret`, `X-Install-Id`,
`X-Platform`. Contract in [`shared/meal-scan-proxy.md`](shared/meal-scan-proxy.md).

## Releases

Per-platform and independent: iOS ships via Xcode archive → App Store Connect; Android via
`bundleRelease` → Play Console. There is no git `production` branch — "production" is a store release.

## Working in this repo

See [`CLAUDE.md`](CLAUDE.md) for the full brief. Follows the shared
[MindLab Best Practices](https://github.com/MochaS29/best-practices) (read on session init), with the
native-only deviations documented there.
