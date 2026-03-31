# ML Fitness Apple Watch App

## Overview
The ML Fitness Apple Watch app is a companion app that provides quick access to health tracking features directly from your wrist. Built with SwiftUI and Watch Connectivity framework, it seamlessly syncs with the iPhone app.

## Current Features

### ✅ Implemented (v1.6.0)
- **Dashboard View**: Real-time display of daily progress
  - Calorie intake vs goal
  - Water consumption tracking
  - Macro nutrients (Protein, Carbs, Fat)
- **Water Tracking**: Quick water entry with preset amounts
- **Quick Food Logging**: Fast food entry for common meals
- **Exercise Tracking**: Built-in workout timer with calorie estimation
- **Watch Connectivity**: Two-way sync between iPhone and Watch

## Architecture

### File Structure
```
HealthTracker Watch App/
├── HealthTrackerWatchApp.swift     # Main app entry point
├── Info.plist                       # Configuration
├── Views/
│   ├── ContentView.swift           # Main navigation
│   ├── WaterTrackingView.swift     # Water logging
│   ├── QuickLogView.swift          # Food quick entry
│   └── ExerciseView.swift          # Workout tracking
└── Services/
    └── WatchConnectivityManager.swift # iPhone sync

HealthTracker (iPhone)/
└── Services/
    └── PhoneConnectivityManager.swift # Watch sync
```

### Data Flow
1. **iPhone → Watch**: Daily summaries, goals, current progress
2. **Watch → iPhone**: Water entries, food logs, exercise data
3. **Sync Methods**: Message passing, User Info, Application Context

## Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ (iPhone app)
- watchOS 9.0+ (Watch app)
- Apple Developer Account

### Adding Watch Target to Xcode

1. **Open Project**
   ```bash
   open HealthTracker.xcodeproj
   ```

2. **Add Watch Target**
   - Select project in navigator
   - Click "+" at bottom of targets
   - Choose: watchOS → App
   - Configure:
     - Name: HealthTracker Watch App
     - Bundle ID: com.mochasmindlab.HealthTracker.watchkitapp
     - Interface: SwiftUI

3. **Configure Capabilities**

   **iPhone App:**
   - Add "App Groups": `group.com.mochasmindlab.healthtracker`
   - Add "Background Modes": Background fetch, Remote notifications

   **Watch App:**
   - Add "App Groups": Same as iPhone
   - Add "HealthKit" (if needed)

4. **Add Files to Target**
   - Right-click Watch App folder
   - "Add Files to 'HealthTracker Watch App'"
   - Select all Watch app files
   - Uncheck "Copy items if needed"
   - Add to Watch target only

## Development Guide

### Testing

#### Simulator
```bash
# List available Watch simulators
xcrun simctl list devices | grep "Apple Watch"

# Build for Watch simulator
xcodebuild -scheme "HealthTracker Watch App" \
           -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
           build
```

#### Physical Device
1. Pair Apple Watch with iPhone
2. Enable Developer Mode on both devices
3. Select paired watch as destination in Xcode
4. Build and run

### Adding New Features

#### Example: Adding a New View
```swift
// 1. Create new view file
struct NewFeatureView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        // Your UI here
    }
}

// 2. Add to ContentView navigation
TabView {
    // ... existing views
    NewFeatureView()
        .tag(4)
}

// 3. Add connectivity methods if needed
extension WatchConnectivityManager {
    func sendNewFeatureData(_ data: [String: Any]) {
        // Implementation
    }
}
```

### Watch Connectivity Best Practices

1. **Always check reachability**
   ```swift
   guard session.isReachable else { return }
   ```

2. **Use appropriate transfer method**
   - `sendMessage`: Immediate, requires reachability
   - `transferUserInfo`: Background, guaranteed delivery
   - `updateApplicationContext`: Latest state only

3. **Handle all delegate methods**
   ```swift
   func session(_ session: WCSession, didReceiveMessage message: [String : Any])
   func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any])
   func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any])
   ```

## Troubleshooting

### Common Issues

#### Watch app not installing
- Ensure both devices unlocked
- Check Watch app on iPhone
- Verify provisioning profiles

#### Data not syncing
- Check App Group configuration
- Verify WCSession activation
- Review console logs
- Ensure both apps running

#### Build errors
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all
```

## Testing Checklist

- [ ] Watch app launches independently
- [ ] Dashboard shows current data
- [ ] Water entry syncs to iPhone
- [ ] Food logging works
- [ ] Exercise tracking saves
- [ ] Background sync functions
- [ ] Complications update (future)

## Future Enhancements

### v1.7.0 Planned
- [ ] Watch face complications
- [ ] Background refresh
- [ ] Standalone mode (offline)
- [ ] Heart rate integration
- [ ] Sleep tracking
- [ ] Notifications

### v1.8.0 Ideas
- [ ] Voice input for food
- [ ] Barcode scanning
- [ ] Social features
- [ ] Achievement badges
- [ ] Custom workouts

## Performance Optimization

### Battery Usage
- Limit background refreshes
- Use efficient data transfer
- Minimize animation complexity
- Cache frequently used data

### Memory Management
- Clear old data regularly
- Use lightweight models
- Optimize image sizes
- Limit concurrent operations

## Deployment

### App Store Submission
1. Both apps submit together
2. Match version numbers
3. Include Watch screenshots
4. Update release notes

### Screenshots Required
- Series 3 (38mm, 42mm)
- Series 9 (41mm, 45mm)
- Ultra (49mm)

## API Reference

### WatchConnectivityManager (Watch Side)

```swift
class WatchConnectivityManager: NSObject, ObservableObject {
    // Published properties
    @Published var currentCalories: Double
    @Published var currentWater: Double
    @Published var currentProtein: Int

    // Methods
    func sendWaterEntry(amount: Double)
    func sendQuickFoodEntry(name: String, calories: Int)
    func sendExerciseData(_ data: [String: Any])
    func requestDataRefresh()
}
```

### PhoneConnectivityManager (iPhone Side)

```swift
class PhoneConnectivityManager: NSObject, ObservableObject {
    // Singleton
    static let shared = PhoneConnectivityManager()

    // Methods
    func sendDailyUpdate()
    func handleWaterEntry(amount: Double, timestamp: TimeInterval)
    func handleQuickFoodEntry(name: String, calories: Int, timestamp: TimeInterval)
    func handleExerciseEntry(_ data: [String: Any])
}
```

## Resources

- [Apple Watch Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos/overview)
- [WatchKit Documentation](https://developer.apple.com/documentation/watchkit)
- [Watch Connectivity Framework](https://developer.apple.com/documentation/watchconnectivity)
- [SwiftUI for watchOS](https://developer.apple.com/documentation/swiftui)

## Support

For issues or questions:
- Create an issue in the repository
- Email: support@mlfitnessapp.com
- Documentation: `/WATCH_XCODE_SETUP.md`

---

**Last Updated**: October 2025
**Version**: 1.6.0
**Status**: Ready for Xcode integration