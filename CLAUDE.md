# ML Fitness Monorepo

One product, two native apps. Marketed as **ML Fitness** (App Store name: "Fitness & Calorie Tracker", home-screen name "MindLab Fitness"). Free + one-time Pro IAP ($8.99 CAD), product ID `com.mochasmindlab.HealthTracker.pro`.

```
ios/        SwiftUI app (iOS 17+), Xcode project HealthTracker.xcodeproj — live on App Store (v2.4.1 / build 14)
android/    Kotlin / Jetpack Compose app, Gradle — Play Internal Testing (v1.1.3 / build 5), Production pending
shared/     Cross-platform docs: parity checklist, meal-scan proxy API contract
```

## The parity rule (most important)

**Android mirrors iOS exactly** — enums, category labels, screens, copy. iOS is the source of truth. When porting or fixing on Android, read the corresponding iOS source first; never invent new categories or labels. When changing shared behavior, change both platforms in the same commit/PR whenever possible.

## Build & test

### iOS (from repo root)
```sh
xcodebuild -project ios/HealthTracker.xcodeproj -scheme HealthTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
```
- **Before archiving for App Store**: set the scheme's StoreKit configuration to **None**. Use `MLFitnessPro.storekit` only for simulator IAP testing.
- `ios/HealthTracker/Configuration/Secrets.plist` is gitignored and required to build (holds the app secret for the meal-scan proxy).

### Android (from repo root)
```sh
cd android && ./gradlew assembleDebug      # debug build
cd android && ./gradlew bundleRelease      # Play Store AAB (signs with release.keystore)
```
- `android/local.properties`, `android/keystore.properties`, `android/release.keystore` are gitignored and required for release builds — never commit them.

## Meal Scanner backend

Both apps call the Vercel proxy `https://mochasmindlab.com/api/v1/meal-scan` (Anthropic key lives only in proxy env vars, never in app binaries). Auth headers: `X-App-Secret`, `X-Install-Id`, `X-Platform` (`ios` / `android`). Contract details in `shared/meal-scan-proxy.md`.

## Release mechanics (always per-platform)

- Versions are independent: iOS `MARKETING_VERSION`/build number; Android `versionName`/`versionCode` in `android/app/build.gradle.kts`.
- iOS ships via Xcode archive → App Store Connect; Android via `bundleRelease` → Play Console.
- Store metadata, screenshots, and review submissions are separate per store.

## Conventions

- Commits: include both `Co-Authored-By: MochaS29 <mocha.shmigelsky@gmail.com>` and the Claude co-author trailer.
- Don't commit binary media (screenshots, videos) or build artifacts even when asked to "push everything".

## History note

This repo was assembled (Jun 2026) from two archived repos with full history preserved: `MochaS29/HealthTracker-iOS` → `ios/`, `MochaS29/MLHealthAndroid` → `android/`. Pre-merge history and old branches remain readable in the archived repos.
