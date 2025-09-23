#!/bin/bash

echo "🔍 TestFlight Build Verification Script"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "HealthTracker.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Not in HealthTracker directory${NC}"
    exit 1
fi

echo "✅ Checking Info.plist keys..."

# Check for required Info.plist keys
PLIST_FILE="HealthTracker/Info.plist"

check_plist_key() {
    if grep -q "$1" "$PLIST_FILE"; then
        echo -e "${GREEN}✓${NC} $1 found"
    else
        echo -e "${RED}✗${NC} $1 MISSING - This will cause rejection!"
        return 1
    fi
}

# Check all required keys
check_plist_key "NSCameraUsageDescription"
check_plist_key "NSPhotoLibraryUsageDescription"
check_plist_key "NSHealthShareUsageDescription"
check_plist_key "NSHealthUpdateUsageDescription"
check_plist_key "NSMotionUsageDescription"
check_plist_key "ITSAppUsesNonExemptEncryption"
check_plist_key "CFBundleDisplayName"
check_plist_key "UILaunchStoryboardName"

echo ""
echo "✅ Checking for common issues..."

# Check for SwiftUI previews that might cause issues
if grep -r "#Preview" HealthTracker/Views --include="*.swift" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Found #Preview code - Make sure these are commented out${NC}"
fi

# Check for debug print statements
if grep -r "print(" HealthTracker --include="*.swift" | grep -v "//" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Found print statements - Consider removing for production${NC}"
fi

# Check if privacy policy exists
if [ -f "/Users/mocha/Development/iOS-Apps/privacy.html" ]; then
    echo -e "${GREEN}✓${NC} Privacy policy file found"
    echo -e "${YELLOW}📝 Remember to host this online and add URL to TestFlight${NC}"
else
    echo -e "${RED}✗${NC} Privacy policy file not found"
fi

# Check for launch screen
if [ -f "HealthTracker/SplashScreen.storyboard" ]; then
    echo -e "${GREEN}✓${NC} Launch screen found"
else
    echo -e "${RED}✗${NC} Launch screen missing"
fi

# Check for app icons
if [ -d "HealthTracker/Assets.xcassets/AppIcon.appiconset" ]; then
    ICON_COUNT=$(ls HealthTracker/Assets.xcassets/AppIcon.appiconset/*.png 2>/dev/null | wc -l)
    if [ $ICON_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓${NC} App icons found ($ICON_COUNT icons)"
    else
        echo -e "${RED}✗${NC} No app icons found"
    fi
else
    echo -e "${RED}✗${NC} AppIcon.appiconset not found"
fi

echo ""
echo "======================================="
echo "📋 TESTFLIGHT SUBMISSION CHECKLIST:"
echo "======================================="
echo ""
echo "1. ⬜ Build the app:"
echo "   xcodebuild -scheme HealthTracker -configuration Release -sdk iphoneos"
echo ""
echo "2. ⬜ Or use Xcode:"
echo "   - Open HealthTracker.xcodeproj"
echo "   - Select 'Any iOS Device' as target"
echo "   - Product > Archive"
echo ""
echo "3. ⬜ Host privacy.html online and get URL"
echo ""
echo "4. ⬜ In App Store Connect:"
echo "   - Add Privacy Policy URL"
echo "   - Add Test Information (see TESTFLIGHT_SUBMISSION.md)"
echo "   - Submit for Beta Review"
echo ""
echo "5. ⬜ Test on real device before submitting"
echo ""

# Quick test compile
echo "======================================="
echo "🔨 Quick compile test..."
echo "======================================="

if command -v xcodebuild &> /dev/null; then
    echo "Running quick build test (this may take a minute)..."
    xcodebuild -scheme HealthTracker -configuration Debug -sdk iphonesimulator -quiet build CODE_SIGNING_ALLOWED=NO > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Build test passed!${NC}"
        echo ""
        echo -e "${GREEN}🎉 Your app appears ready for TestFlight!${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Archive in Xcode (Product > Archive)"
        echo "2. Upload to App Store Connect"
        echo "3. Add test information and privacy URL"
        echo "4. Submit for Beta Review"
    else
        echo -e "${RED}❌ Build failed - fix errors before submitting${NC}"
        echo "Run 'xcodebuild' to see detailed errors"
    fi
else
    echo -e "${YELLOW}⚠️  xcodebuild not found - test in Xcode${NC}"
fi

echo ""
echo "📖 See TESTFLIGHT_SUBMISSION.md for detailed instructions"