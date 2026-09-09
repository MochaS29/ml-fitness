# ML Fitness CLAUDE.md

## What this is
Fitness and calorie tracker for people who want simple food, meal-scan and activity logging on their phone. Marketed as MindLab Fitness (App Store name "Fitness & Calorie Tracker"). Two pure-native apps that share no code: SwiftUI in `ios/` (live on the App Store, v2.4.1 build 14) and Kotlin/Compose in `android/` (Play Internal Testing, v1.1.5 build 7). `shared/` holds cross-platform docs. No backend and no Supabase; Pro is a one-time IAP, and meal-scan calls the Vercel proxy at `mochasmindlab.com/api/v1/meal-scan`.

## Run it locally
From the repo root. No ports; both are on-device apps.
```sh
xcodebuild -project ios/HealthTracker.xcodeproj -scheme HealthTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
cd android && ./gradlew assembleDebug               # Android debug build
cd android && ./gradlew testProductionDebugUnitTest  # Android JVM unit tests
```
iOS needs the gitignored `ios/HealthTracker/Configuration/Secrets.plist`; Android release builds need the gitignored `local.properties`, `keystore.properties` and `release.keystore`.

## Ship it
Integration branch: `main`. There is no Vercel production branch; "production" means a store release.
Ship step: iOS via Xcode archive to App Store Connect; Android via `cd android && ./gradlew bundleRelease` to the Play Console. Versions are independent per platform.
Migrations: none. No Vercel deploys.

## Off limits
- Pricing, the paywall, the scan-vs-paywall ratio and the app name need Mocha, and only after a shipped version has had time to gather data.
- Store submission (App Store Connect and Play Console review) is Mocha's.
- Never commit `Secrets.plist`, `keystore.properties`, `release.keystore`, `local.properties`, binary media or build artifacts.

## Gotchas
- Parity rule: iOS is the source of truth and Android mirrors it exactly, enums, labels, copy and features. Read the iOS source before touching Android; change both platforms in the same PR where possible.
- 2026-09: Set the scheme's StoreKit configuration to None before archiving iOS; `MLFitnessPro.storekit` is for simulator IAP testing only.
- 2026-09: Android unit tests must name the flavour (`testProductionDebugUnitTest`); product IDs differ per store (`com.mochasmindlab.HealthTracker.pro` / `com.mochasmindlab.mlhealth.pro`).
- 2026-09: Linear project ML Fitness (HealthTracker), team MOC; launch issues MOC-5 to MOC-10 already exist, do not recreate them.

Full notes: docs/PROJECT-NOTES.md
