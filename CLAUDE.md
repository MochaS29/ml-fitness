# ML Fitness Monorepo

## Best practices (read on init)

This project follows the shared **MindLab Best Practices**. On starting a session, read them:

1. Read the local copy at `~/Development/best-practices/` — start with `README.md`, then `standards/`.
2. If that path doesn't exist, pull it first:
   `git clone https://github.com/MochaS29/best-practices ~/Development/best-practices`
   (or run `~/Development/best-practices/scripts/sync-best-practices.sh` to refresh it).

These standards govern monorepo layout (`apps/` + `platforms/`), Linear task tracking with image capture, local Supabase Docker testing with seed data, `develop`/`production` branching + Vercel deploys, documentation, the agent workflow (`/cpg`, `/pup`, `/verify-ui` + guardrail hooks), payments, stack gotchas, and the terminal status line.

Project-specific instructions below **override** the shared standards where they conflict; note any deliberate deviation with a one-line reason.

### Deliberate deviations from the standards

- **Layout (std 01):** uses flat `ios/ + android/ + shared/`, not `apps/ + platforms/`. Reason: two pure-native apps that share no code and no backend; std 01's own note grandfathers this layout as a reference "in this style." No `platforms/` because there is no Supabase/web/infra here.
- **Local testing & payments (std 03, 08):** N/A. No Supabase and no Stripe — the app is native-only; Pro is an App Store / Play **IAP**, and meal-scan calls the existing Vercel proxy (key server-side per std 09).
- **Branching (std 04):** uses `main` as the develop-equivalent (allowed by std 04's note). There is no Vercel `production` branch — "production" here means a store release (App Store / Play), gated by their review, not a git branch.
- **Task tracking (std 02):** Linear is not yet wired for this repo; release-ops history lives in commits + Claude memory for now.
- **Status line (std 06):** a custom global status line is configured in `~/.claude/settings.json`, not the shared `best-practices/templates/statusline.sh`.

One product, two native apps. Marketed as **ML Fitness** (App Store name: "Fitness & Calorie Tracker", home-screen name "MindLab Fitness"). Free + one-time Pro IAP ($8.99 CAD). Product IDs differ per store (each platform manages its own SKU): iOS `com.mochasmindlab.HealthTracker.pro`, Android `com.mochasmindlab.mlhealth.pro`.

```
ios/        SwiftUI app (iOS 17+), Xcode project HealthTracker.xcodeproj — live on App Store (v2.4.1 / build 14)
android/    Kotlin / Jetpack Compose app, Gradle — Play Internal Testing (v1.1.5 / build 7), Production promotion pending
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
