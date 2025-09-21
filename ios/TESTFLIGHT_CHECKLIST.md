# TestFlight Upload Checklist

## Before You Start
- [ ] Apple Developer Account active ($99/year)
- [ ] Xcode signed in with Apple ID
- [ ] App Store Connect account created

## In Xcode
- [ ] Open project: `open HealthTracker.xcodeproj`
- [ ] Select "Any iOS Device (arm64)" from device menu
- [ ] Product → Archive
- [ ] Wait for archive to complete
- [ ] Click "Distribute App"
- [ ] Choose "App Store Connect"
- [ ] Choose "Upload"
- [ ] Click through with defaults
- [ ] Upload complete

## In App Store Connect
- [ ] Go to https://appstoreconnect.apple.com
- [ ] Select your app
- [ ] Go to TestFlight tab
- [ ] Wait for build to process (10-30 min)
- [ ] Add test information
- [ ] Create tester group
- [ ] Add tester emails
- [ ] Save changes

## Common Issues & Solutions

### "No account for team"
**Solution**: Add Apple ID in Xcode → Settings → Accounts

### "No eligible devices"
**Solution**: Select "Any iOS Device" not a simulator

### "Missing compliance"
**Solution**: In App Store Connect, answer "No" to encryption questions

### Build not showing
**Solution**: Wait 30 minutes, check email for processing errors

### HealthKit not working
**Solution**: Already configured in Info.plist ✅

## Your App Details
- **Bundle ID**: com.mindlabs.fitness
- **Team ID**: 69QZW8NWFJ
- **App Name**: HealthTracker

## Quick Links
- [App Store Connect](https://appstoreconnect.apple.com)
- [Developer Portal](https://developer.apple.com)
- [TestFlight for Testers](https://testflight.apple.com)

## Tester Instructions
Send this to your testers:

1. Download TestFlight from App Store
2. Open invitation email on iPhone
3. Tap "View in TestFlight"
4. Tap "Install"
5. Test the app
6. Send feedback via TestFlight "Send Beta Feedback"