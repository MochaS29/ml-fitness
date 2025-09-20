# TestFlight Distribution Guide for HealthTracker

## Prerequisites

Before you can upload to TestFlight, ensure you have:

1. **Apple Developer Account** ($99/year)
   - Sign up at [developer.apple.com](https://developer.apple.com)

2. **App Store Connect Access**
   - Log in at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

3. **Xcode Configured**
   - Your Apple ID added to Xcode (Xcode > Settings > Accounts)
   - Valid signing certificate and provisioning profile

## Step 1: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click the **"+"** button and select **"New App"**
3. Fill in the required information:
   - **Platforms**: iOS
   - **Name**: HealthTracker (or your preferred name)
   - **Primary Language**: English
   - **Bundle ID**: Select `com.mindlabs.fitness`
   - **SKU**: Something unique like `HEALTHTRACKER2024`

## Step 2: Configure App Information

In App Store Connect, for your new app:

1. **App Information**:
   - Add app category: Health & Fitness
   - Set content rights if needed

2. **TestFlight Tab**:
   - Set up test information
   - Add a description of what to test
   - Create internal/external testing groups

3. **App Privacy**:
   - Answer privacy questions about data collection
   - Important for HealthKit apps:
     - Health data collection: Yes
     - Data linked to user: Health & Fitness data
     - Data used for tracking: No (unless you add analytics)

## Step 3: Prepare Build for Upload

### Option A: Using the Script (Recommended)

Run the provided script:

```bash
cd /Users/mocha/Development/iOS-Apps/HealthTracker
./prepare-for-testflight.sh
```

### Option B: Manual Process in Xcode

1. **Update Version and Build Number**:
   - Open project in Xcode
   - Select HealthTracker target
   - General tab > Identity section
   - Version: 1.0.0 (or your version)
   - Build: Increment for each upload

2. **Select Generic iOS Device**:
   - In Xcode toolbar, change from simulator to "Any iOS Device (arm64)"

3. **Create Archive**:
   - Menu: Product > Archive
   - Wait for build to complete

4. **Upload to App Store Connect**:
   - Window > Organizer opens automatically
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Follow the prompts

## Step 4: Configure TestFlight

After upload (processing takes 10-30 minutes):

1. **Internal Testing**:
   - Automatically available to your team
   - No review required
   - Add testers by email

2. **External Testing**:
   - Requires brief review (usually 24-48 hours)
   - Can have up to 10,000 testers
   - Create groups for different test focuses

3. **Add Test Information**:
   ```
   What to Test:
   - Food tracking and meal planning
   - Exercise logging
   - Supplement tracking
   - Weight tracking
   - HealthKit integration
   - Recipe browser and meal plans

   Test Account (if needed):
   - No account required
   ```

## Step 5: Invite Testers

### For Internal Testing:
1. Go to TestFlight tab
2. Select "Internal Group"
3. Add testers by email
4. They'll receive TestFlight invitation immediately

### For External Testing:
1. Create a new group or use existing
2. Add tester emails
3. Submit for review (first time only)
4. Once approved, invitations sent

## Important Considerations

### HealthKit Requirements:
- ✅ Privacy policy URL required
- ✅ Clear usage descriptions in Info.plist
- ✅ Only request necessary health data types
- ✅ Handle authorization properly

### TestFlight Limits:
- Build expires after 90 days
- Maximum 100 internal testers
- Maximum 10,000 external testers
- New builds can be added without re-review

### Common Issues and Solutions:

1. **"Missing Compliance" Error**:
   - In App Store Connect, answer export compliance questions
   - For HealthTracker: Usually "No" to encryption questions

2. **Archive Not Showing in Organizer**:
   - Ensure you're building for "Any iOS Device"
   - Check that scheme is set to Release configuration

3. **Upload Fails**:
   - Check internet connection
   - Verify App Store Connect agreements are signed
   - Ensure bundle ID matches App Store Connect

4. **HealthKit Not Working**:
   - Verify entitlements are properly configured
   - Check Info.plist has usage descriptions
   - Ensure capabilities are enabled in Xcode

## Testing Checklist for Testers

Share this with your testers:

- [ ] Install TestFlight app from App Store
- [ ] Accept email invitation
- [ ] Install HealthTracker from TestFlight
- [ ] Grant HealthKit permissions when prompted
- [ ] Test all major features:
  - [ ] Add foods to diary
  - [ ] Log exercises
  - [ ] Track supplements
  - [ ] Record weight
  - [ ] Browse recipes
  - [ ] View progress charts
- [ ] Report crashes through TestFlight
- [ ] Send feedback via TestFlight "Send Feedback" button

## Monitoring and Feedback

1. **View Crash Reports**:
   - App Store Connect > TestFlight > Crashes

2. **Read Tester Feedback**:
   - App Store Connect > TestFlight > Feedback

3. **Track Installation**:
   - See who installed and when
   - Monitor session counts

## Next Build Updates

For subsequent builds:

1. Increment build number
2. Archive and upload
3. New build automatically available to internal testers
4. External testers get it after you enable it (no re-review needed)

## Support

If you encounter issues:

1. Check Xcode's error messages
2. Verify all certificates are valid (Xcode > Settings > Accounts)
3. Ensure you've accepted all App Store Connect agreements
4. Check Apple Developer Forums for specific error codes

---

## Quick Commands Reference

```bash
# Build and archive from command line
xcodebuild -scheme HealthTracker -configuration Release archive

# View current version and build
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" HealthTracker/Info.plist
/usr/libexec/PlistBuddy -c "Print CFBundleVersion" HealthTracker/Info.plist

# Increment build number
agvtool next-version -all
```

Good luck with your TestFlight testing! 🚀