Detailed notes for this repo. CLAUDE.md is the short brief; this is the long memory.

# ML Fitness project notes

## What the product is

One product, two native apps. Marketed as MindLab Fitness (App Store name and home-screen name both "MindLab Fitness"; "ML Fitness" is the legacy name). Free tier plus a one-time Pro IAP ($8.99 CAD). There is no backend of our own, no Supabase, no Stripe and no web app; the only server-side piece is the meal-scan proxy described below.

Product IDs differ per store (each platform manages its own SKU):

- iOS: `com.mochasmindlab.HealthTracker.pro`
- Android: `com.mochasmindlab.mlhealth.pro`

## Repo layout

```
ios/        SwiftUI app (iOS 17+), Xcode project HealthTracker.xcodeproj. Live on the App Store
android/    Kotlin / Jetpack Compose app, Gradle. Live on Google Play, production track
shared/     Cross-platform docs: parity checklist, meal-scan proxy API contract
```

The layout is a flat `ios/ + android/ + shared/`, not `apps/ + platforms/`. Reason: two pure-native apps that share no code and no backend, so this layout is intentional. There is no `platforms/` directory because there is no Supabase, web or infra here.

## The parity rule (most important)

Android mirrors iOS exactly: enums, category labels, screens, copy and features. iOS is the source of truth. When porting or fixing on Android, read the corresponding iOS source first; never invent new categories or labels. When changing shared behaviour, change both platforms in the same commit or PR whenever possible. The parity checklist lives in `shared/`.

## Build and test

### iOS (from repo root)

```sh
xcodebuild -project ios/HealthTracker.xcodeproj -scheme HealthTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
```

- Before archiving for the App Store, set the scheme's StoreKit configuration to None. Use `MLFitnessPro.storekit` only for simulator IAP testing.
- `ios/HealthTracker/Configuration/Secrets.plist` is gitignored and required to build (it holds the app secret for the meal-scan proxy).

### Android (from repo root)

```sh
cd android && ./gradlew assembleDebug               # debug build
cd android && ./gradlew testProductionDebugUnitTest  # JVM unit tests (product flavour is required)
cd android && ./gradlew bundleRelease               # Play Store AAB (signs with release.keystore)
```

- `android/local.properties`, `android/keystore.properties` and `android/release.keystore` are gitignored and required for release builds. Never commit them.

## Meal Scanner backend

Both apps call the Vercel proxy `https://mochasmindlab.com/api/v1/meal-scan`. The Anthropic key lives only in the proxy's env vars, never in the app binaries. Auth headers: `X-App-Secret`, `X-Install-Id`, `X-Platform` (`ios` / `android`). Contract details are in `shared/meal-scan-proxy.md`.

Local testing and payments: not applicable in the usual sense. The app is native-only; Pro is an App Store / Play IAP, and meal-scan calls the existing Vercel proxy with the key kept server-side.

## Branching and release mechanics

- `main` is the integration branch (the develop-equivalent). There is no Vercel `production` branch; "production" here means a store release (App Store / Play), gated by store review, not a git branch.
- Releases are always per-platform. Versions are independent: iOS uses `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `ios/HealthTracker.xcodeproj`; Android uses `versionName` / `versionCode` in `android/app/build.gradle.kts`. **Those two files are the only place a shipped version number is written down**, do not restate it in README.md, CLAUDE.md or here, because that is exactly how this repo came to claim Android was still in Internal Testing at v1.1.5 while the Play listing was public at 1.1.8.
- iOS ships via Xcode archive to App Store Connect; Android ships via `bundleRelease` to the Play Console.
- Store metadata, screenshots and review submissions are separate per store.

## Task tracking

Linear team Mochas Mind Lab (`MOC`), project ML Fitness (HealthTracker). The build-6/7 launch work is tracked as MOC-5 to MOC-10; do not recreate it.

## Conventions

- Commits: include both `Co-Authored-By: MochaS29 <mocha.shmigelsky@gmail.com>` and the Claude co-author trailer.
- Do not commit binary media (screenshots, videos) or build artifacts, even when asked to "push everything".

## Gotchas (dated)

Dates are when the note was recorded, not necessarily when the issue first appeared. The pre-rewrite CLAUDE.md carried these undated; they were dated 2026-09 when moved here.

- 2026-09: Before archiving iOS for the App Store, set the scheme's StoreKit configuration to None. `MLFitnessPro.storekit` is for simulator IAP testing only.
- 2026-09: The Android unit-test task must name the product flavour: `testProductionDebugUnitTest`.
- 2026-09: Android release builds need the three gitignored files (`local.properties`, `keystore.properties`, `release.keystore`); iOS needs the gitignored `Secrets.plist` to build at all.
- 2026-09: Parity: never invent categories or labels on Android; read the iOS source first.
- 2026-09: The Linear launch issues MOC-5 to MOC-10 already exist; do not recreate them.

## History note

This repo was assembled in June 2026 from two archived repos with full history preserved: `MochaS29/HealthTracker-iOS` became `ios/` and `MochaS29/MLHealthAndroid` became `android/`. Pre-merge history and old branches remain readable in the archived repos.
