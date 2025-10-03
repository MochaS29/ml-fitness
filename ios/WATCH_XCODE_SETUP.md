# Apple Watch App - Xcode Setup Instructions

## Step 1: Add Watch App Target

1. Open `HealthTracker.xcodeproj` in Xcode
2. Select the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Choose **watchOS** → **App** (not "App for Existing iOS App")
5. Configure the Watch App:
   - **Product Name**: HealthTracker Watch App
   - **Team**: Your development team
   - **Organization Identifier**: com.mochasmindlab
   - **Bundle Identifier**: com.mochasmindlab.HealthTracker.watchkitapp
   - **Language**: Swift
   - **User Interface**: SwiftUI
   - **Include Notification Scene**: No (for now)
   - **Include Complication**: No (for now)
6. Click **Finish**

## Step 2: Configure Watch App Files

1. **Delete the default files** created by Xcode in the Watch App folder:
   - Delete the default `ContentView.swift`
   - Delete the default `HealthTracker_Watch_AppApp.swift`

2. **Add existing files** to the Watch App target:
   - Right-click the Watch App folder in Xcode
   - Choose "Add Files to 'HealthTracker Watch App'"
   - Navigate to the `HealthTracker Watch App` folder we created
   - Select all files and folders
   - Make sure "Copy items if needed" is UNCHECKED (files are already there)
   - Make sure "Add to targets" has only "HealthTracker Watch App" selected
   - Click **Add**

## Step 3: Configure Capabilities

### For the iPhone App:
1. Select the main HealthTracker target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**:
   - Create group: `group.com.mochasmindlab.healthtracker`
5. Add **Background Modes**:
   - Check "Background fetch"
   - Check "Remote notifications"

### For the Watch App:
1. Select the Watch App target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**:
   - Use same group: `group.com.mochasmindlab.healthtracker`
5. Add **HealthKit** (if not already added)

## Step 4: Update Info.plist

### Watch App Info.plist
Add the following keys:
```xml
<key>WKCompanionAppBundleIdentifier</key>
<string>com.mochasmindlab.HealthTracker</string>

<key>CFBundleDisplayName</key>
<string>ML Fitness</string>
```

## Step 5: Initialize Watch Connectivity in iPhone App

In `HealthTrackerApp.swift`, add:

```swift
import WatchConnectivity

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var phoneConnectivity = PhoneConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Initialize Watch Connectivity
                    _ = PhoneConnectivityManager.shared
                }
        }
    }
}
```

## Step 6: Update ContentView to Send Updates

In relevant views (e.g., after adding food or water), call:
```swift
PhoneConnectivityManager.shared.sendDailyUpdate()
```

## Step 7: Build Settings

### Watch App Build Settings:
1. Select the Watch App target
2. Go to **Build Settings**
3. Search for "iOS Deployment Target"
4. Set **watchOS Deployment Target** to **9.0** or higher
5. Ensure **Swift Language Version** matches the iPhone app

## Step 8: Test the Watch App

### Simulator Testing:
1. Select scheme: **HealthTracker Watch App**
2. Choose a Watch simulator (e.g., Apple Watch Series 9 - 45mm)
3. Build and Run (⌘R)

### Physical Device Testing:
1. Pair your Apple Watch with your iPhone
2. Open **Watch** app on iPhone
3. Enable **Developer Mode** on both devices
4. Select your paired watch as the destination
5. Build and Run

## Step 9: Verify Connectivity

### Test Checklist:
- [ ] Watch app launches independently
- [ ] Phone app detects watch
- [ ] Data syncs from phone to watch on launch
- [ ] Water entries from watch appear on phone
- [ ] Quick food logs from watch sync to phone
- [ ] Exercise tracking saves to phone
- [ ] Background updates work

## Common Issues & Solutions

### Issue: Watch app not installing
**Solution**: Make sure both devices are unlocked and the Watch app on iPhone shows your app

### Issue: Data not syncing
**Solution**:
1. Check both apps have the same App Group
2. Verify WCSession is activated in both apps
3. Check console logs for connectivity errors

### Issue: "No paired Apple Watch" error
**Solution**:
1. Use Simulator instead
2. Or pair a physical watch via Xcode Devices window

## Next Steps

After successful setup:
1. Test all features thoroughly
2. Add complications (optional)
3. Implement notifications
4. Add background refresh
5. Submit to App Store with iPhone app

## Build Script for CI/CD

```bash
# Build Watch App
xcodebuild -scheme "HealthTracker Watch App" \
           -configuration Release \
           -sdk watchos \
           -derivedDataPath build \
           archive -archivePath build/HealthTrackerWatch.xcarchive

# Build iPhone App with Watch App
xcodebuild -scheme "HealthTracker" \
           -configuration Release \
           -sdk iphoneos \
           -derivedDataPath build \
           archive -archivePath build/HealthTracker.xcarchive
```

## Deployment Notes

When submitting to App Store:
1. Both apps are submitted together
2. Watch app version should match iPhone app version
3. Include Watch screenshots in App Store Connect
4. Mention Apple Watch support in release notes

---

**Important**: After adding the Watch target in Xcode, you may need to:
1. Clean build folder (Shift+⌘+K)
2. Delete derived data
3. Restart Xcode if you encounter indexing issues