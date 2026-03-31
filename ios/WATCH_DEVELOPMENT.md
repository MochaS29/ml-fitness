# Apple Watch & Fossil Watch Development Guide

## Apple Watch Implementation

### Current Status
- **Branch**: develop
- **Target iOS Version**: 16.0+
- **Watch OS Version**: 9.0+
- **Framework**: WatchKit / SwiftUI

### Implementation Plan

#### Phase 1: Basic Setup (Current)
1. Create Watch App target in Xcode
2. Set up Watch Connectivity framework
3. Configure app groups for data sharing
4. Implement basic UI screens

#### Phase 2: Core Features
- Water tracking quick entry
- View today's calories/macros
- Quick food logging
- Exercise timer
- Daily progress rings

#### Phase 3: Advanced Features
- Complications for watch faces
- Background refresh
- HealthKit integration
- Notifications

### Watch App Architecture

```
HealthTracker Watch App/
├── WatchApp.swift           # Main app entry
├── Models/
│   └── WatchDataModel.swift # Simplified data models
├── Views/
│   ├── ContentView.swift    # Main navigation
│   ├── WaterView.swift       # Water tracking
│   ├── QuickLogView.swift   # Quick food entry
│   ├── ProgressView.swift   # Daily progress
│   └── ExerciseView.swift   # Exercise tracking
├── Services/
│   └── PhoneConnectivity.swift # Watch Connectivity
└── Assets.xcassets/         # Watch-specific assets
```

## Fossil Watch Development

### Current Status (2024)
- **Official Support**: Discontinued - Fossil exited smartwatch market in early 2024
- **Last Update**: Gen 6 watches last updated in 2023
- **Platform**: Wear OS 3.5 (outdated)

### Available Options

#### 1. Community SDK (Fossil HR SDK)
- **Repository**: github.com/dakhnod/Fossil-HR-SDK
- **Requirements**:
  - jerryscript v2.1.0
  - Linux/Unix environment
- **Capabilities**: Native app development for Fossil HR watches
- **Limitations**: No official support, community-maintained

#### 2. Gadgetbridge Integration
- Third-party app manager
- Can upload/delete apps on Fossil watches
- No official API

### Recommendation
**Focus on Apple Watch development** for the following reasons:
1. Active platform with ongoing support
2. Large user base among iOS users
3. Rich SDK and documentation
4. Regular OS updates and new features
5. Better integration with iOS apps

Fossil watch development is not recommended due to:
- No official support or updates
- Limited development tools
- Uncertain future of existing devices
- Small and declining user base

## Next Steps

1. ✅ Research completed - Fossil not viable
2. 🔄 Create Apple Watch app target
3. ⏳ Implement Watch Connectivity
4. ⏳ Design minimal viable Watch UI
5. ⏳ Test on simulator and device

## Commands for Watch App Creation

```bash
# The Watch app will be created via Xcode UI
# File > New > Target > watchOS > Watch App

# After creation, test with:
xcrun simctl list devices | grep "Apple Watch"
xcrun xcodebuild -scheme "HealthTracker Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' build
```

## Data Synchronization Strategy

### Using Watch Connectivity
```swift
// Phone app sends data to watch
WCSession.default.transferUserInfo([
    "dailyCalories": 1850,
    "waterIntake": 64,
    "macros": ["protein": 120, "carbs": 200, "fat": 65]
])

// Watch app receives and displays
func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
    // Update watch UI
}
```

### Using App Groups (Alternative)
- Share Core Data or UserDefaults
- Requires app group capability
- More suitable for background updates

## Testing Checklist

- [ ] Watch app launches independently
- [ ] Phone connectivity established
- [ ] Data syncs correctly
- [ ] Complications work
- [ ] Notifications received
- [ ] Background refresh functions
- [ ] Battery usage acceptable