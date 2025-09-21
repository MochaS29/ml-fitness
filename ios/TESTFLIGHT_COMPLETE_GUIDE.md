# TestFlight Complete Setup Guide for HealthTracker

## Prerequisites

### 1. Apple Developer Account
- Go to https://developer.apple.com
- Sign in with your Apple ID
- Enroll in the Apple Developer Program ($99/year)

### 2. App Store Connect Setup
1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click the "+" button and select "New App"
4. Fill in:
   - Platform: iOS
   - Name: HealthTracker
   - Primary Language: English
   - Bundle ID: com.yourcompany.healthtracker
   - SKU: healthtracker001

## Step-by-Step TestFlight Setup

### Step 1: Configure Xcode Project

1. **Open project in Xcode:**
   ```bash
   cd /Users/mocha/Development/iOS-Apps/HealthTracker
   open HealthTracker.xcodeproj
   ```

2. **Configure signing:**
   - Select the HealthTracker target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team from the dropdown
   - Bundle Identifier: com.yourcompany.healthtracker

3. **Set version numbers:**
   - Version: 1.0.0
   - Build: 1

### Step 2: Fix Remaining Build Issues

Run the preparation script:
```bash
./prepare_for_testflight.sh
```

If build fails, manually fix:

1. **Comment out problematic previews:**
   ```bash
   ./fix_previews.sh
   ```

2. **Fix Achievement model issues:**
   - Ensure all Achievement initializations include `value: Double?` and `target: Double?`

3. **Clean and rebuild:**
   ```bash
   xcodebuild clean build -scheme HealthTracker -sdk iphoneos -configuration Release
   ```

### Step 3: Create Archive

#### Option A: Using Xcode GUI

1. In Xcode, select "Any iOS Device" as the destination
2. Go to Product menu > Archive
3. Wait for archive to complete

#### Option B: Using Command Line

```bash
xcodebuild archive \
  -scheme HealthTracker \
  -sdk iphoneos \
  -configuration Release \
  -archivePath ~/Desktop/HealthTracker.xcarchive \
  DEVELOPMENT_TEAM="YourTeamID"
```

### Step 4: Upload to App Store Connect

#### Option A: Using Xcode Organizer

1. Go to Window > Organizer in Xcode
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Select "Upload"
6. Follow the prompts:
   - Choose automatic signing
   - Let Xcode manage certificates
   - Review and upload

#### Option B: Using Transporter App

1. Download Transporter from Mac App Store
2. Export IPA from Xcode Organizer:
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Export"
   - Save IPA file
3. Open Transporter
4. Sign in with Apple ID
5. Drag IPA file to Transporter
6. Click "Deliver"

### Step 5: Configure TestFlight

1. **Go to App Store Connect:**
   https://appstoreconnect.apple.com

2. **Select your app**

3. **Go to TestFlight tab**

4. **Configure Test Information:**
   - Beta App Description: "HealthTracker helps you monitor nutrition, exercise, and wellness goals"
   - Email: your-email@example.com
   - Beta App Review Notes: "Test account: demo@example.com / password123"

5. **Add Internal Testers:**
   - Click "Internal Testing"
   - Create new group or use existing
   - Add testers by email

6. **Add External Testers:**
   - Click "External Testing"
   - Create new group
   - Add up to 10,000 testers
   - Submit for Beta Review (takes 24-48 hours)

### Step 6: Manage Builds

1. **Build Processing:**
   - New builds appear in "iOS Builds" section
   - Processing takes 10-30 minutes
   - You'll receive email when ready

2. **Enable Testing:**
   - Once processed, click on the build
   - Add to test groups
   - Testers receive invitation email

3. **TestFlight Public Link (Optional):**
   - Go to External Testing
   - Click "Public Link"
   - Enable and share link

## Quick Commands Reference

### Build and Archive
```bash
# Clean build
xcodebuild clean -scheme HealthTracker

# Build for device
xcodebuild build -scheme HealthTracker -sdk iphoneos -configuration Release

# Create archive
xcodebuild archive -scheme HealthTracker -archivePath ~/Desktop/HealthTracker.xcarchive
```

### Using Fastlane (Alternative)
```bash
# Install fastlane
sudo gem install fastlane

# Initialize fastlane
fastlane init

# Create beta build
fastlane beta
```

## Troubleshooting

### Build Failures
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Reset package caches: File > Packages > Reset Package Caches in Xcode
- Check code signing: Ensure valid certificates and provisioning profiles

### Upload Issues
- Check internet connection
- Verify Apple ID has proper permissions
- Ensure app version/build number is unique
- Check for export compliance

### TestFlight Not Showing Build
- Wait 10-30 minutes for processing
- Check email for any issues
- Verify build was uploaded successfully
- Check for missing compliance information

## Important Notes

1. **HealthKit Requirements:**
   - Must provide clear privacy policy
   - Explain health data usage in app description
   - May require additional review

2. **App Review Guidelines:**
   - Ensure no placeholder content
   - Fix all crashes before submission
   - Provide demo account if needed

3. **Version Management:**
   - Increment build number for each upload
   - Version format: Major.Minor.Patch (1.0.0)
   - Build number must always increase

## Support Resources

- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## Next Steps After TestFlight

1. Collect feedback from testers
2. Fix reported issues
3. Update build and re-upload
4. Prepare for App Store submission
5. Create App Store screenshots and description
6. Submit for App Review

---

Last Updated: [Current Date]
Status: Ready for TestFlight preparation