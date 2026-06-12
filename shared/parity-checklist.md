# iOS ↔ Android Parity Checklist

iOS is the source of truth; Android mirrors it exactly. Use this checklist when porting an iOS change to Android (or auditing drift).

For every feature change, confirm on both platforms:

- [ ] **Enums & categories** — identical cases, raw values, and ordering (food categories, supplement categories, exercise types, etc.)
- [ ] **Labels & copy** — screen titles, button text, empty states, units (metric/imperial handling)
- [ ] **Screens & navigation** — same screens exist, same flow between them
- [ ] **Goals & calculations** — nutrition goal math, step→calorie burn (weight-adjusted fallback), streaks
- [ ] **Meal Scanner** — same proxy contract (`shared/meal-scan-proxy.md`), same result parsing/display
- [ ] **Pro gating** — the same features sit behind the Pro IAP on both platforms
- [ ] **Health integration** — HealthKit (iOS) ↔ Health Connect (Android) read/write the equivalent data types

Known intentional differences (do not "fix"):
- Version numbers/build counters are independent per platform.
- Watch app is iOS-only.
- Platform-native UI idioms (navigation patterns, pickers) may differ in implementation while matching in structure and content.

Last full parity audit: v1.1.3 iOS-parity catch-up, Jun 2026 (see `android/OVERNIGHT_PARITY_REPORT.md`).
