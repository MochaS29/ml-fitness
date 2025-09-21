#!/bin/bash

echo "🚀 HealthTracker TestFlight Setup Helper"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check Xcode
echo -e "${BLUE}Step 1: Checking Xcode Installation${NC}"
if xcodebuild -version > /dev/null 2>&1; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo -e "${GREEN}✓${NC} $XCODE_VERSION installed"
else
    echo -e "${RED}✗${NC} Xcode not found. Please install from App Store"
    exit 1
fi

# Step 2: Check if signed in to Xcode
echo ""
echo -e "${BLUE}Step 2: Checking Xcode Account${NC}"
echo -e "${YELLOW}Action Required:${NC}"
echo "1. Open Xcode"
echo "2. Go to: Xcode menu → Settings → Accounts"
echo "3. Add your Apple ID if not already added"
echo "4. Download certificates"
echo ""
read -p "Press Enter when you've completed this step..."

# Step 3: Update version and build number
echo ""
echo -e "${BLUE}Step 3: Version Information${NC}"
CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" HealthTracker/Info.plist 2>/dev/null || echo "1.0.0")
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" HealthTracker/Info.plist 2>/dev/null || echo "1")

echo "Current Version: $CURRENT_VERSION"
echo "Current Build: $CURRENT_BUILD"
echo ""
echo -e "${YELLOW}Would you like to update these?${NC}"
echo "1) Keep current"
echo "2) Update version"
echo "3) Update build number"
echo "4) Update both"
read -p "Choice (1-4): " UPDATE_CHOICE

case $UPDATE_CHOICE in
    2)
        read -p "New version (e.g., 1.0.1): " NEW_VERSION
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" HealthTracker/Info.plist
        echo -e "${GREEN}✓${NC} Version updated to $NEW_VERSION"
        ;;
    3)
        NEW_BUILD=$((CURRENT_BUILD + 1))
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" HealthTracker/Info.plist
        echo -e "${GREEN}✓${NC} Build number updated to $NEW_BUILD"
        ;;
    4)
        read -p "New version (e.g., 1.0.1): " NEW_VERSION
        NEW_BUILD=$((CURRENT_BUILD + 1))
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" HealthTracker/Info.plist
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" HealthTracker/Info.plist
        echo -e "${GREEN}✓${NC} Version updated to $NEW_VERSION"
        echo -e "${GREEN}✓${NC} Build number updated to $NEW_BUILD"
        ;;
esac

# Step 4: Open Xcode for archive
echo ""
echo -e "${BLUE}Step 4: Creating Archive${NC}"
echo -e "${YELLOW}Manual Steps Required:${NC}"
echo ""
echo "1. Opening Xcode now..."
open HealthTracker.xcodeproj

echo ""
echo "2. In Xcode, do the following:"
echo "   a) Select 'Any iOS Device (arm64)' from the device menu (top bar)"
echo "   b) Go to menu: Product → Archive"
echo "   c) Wait for archive to complete (2-5 minutes)"
echo ""
echo "3. When Organizer window opens:"
echo "   a) Select your archive"
echo "   b) Click 'Distribute App' button"
echo "   c) Choose 'App Store Connect'"
echo "   d) Click 'Next'"
echo "   e) Choose 'Upload'"
echo "   f) Keep all default options"
echo "   g) Click 'Next' through all screens"
echo "   h) Click 'Upload'"
echo ""
echo -e "${YELLOW}⏰ Upload takes 5-10 minutes${NC}"
echo ""
read -p "Press Enter when upload is complete..."

# Step 5: Configure in App Store Connect
echo ""
echo -e "${BLUE}Step 5: Configure TestFlight${NC}"
echo -e "${YELLOW}Go to App Store Connect:${NC}"
echo "https://appstoreconnect.apple.com"
echo ""
echo "1. Select your app 'HealthTracker'"
echo "2. Click on 'TestFlight' tab"
echo "3. Your build will appear (may take 10-30 min to process)"
echo "4. Once processed, click on the build number"
echo ""
echo -e "${GREEN}✓${NC} Setup script complete!"
echo ""
echo "=========================================="
echo -e "${BLUE}Quick Reference URLs:${NC}"
echo "App Store Connect: https://appstoreconnect.apple.com"
echo "Developer Portal: https://developer.apple.com"
echo "TestFlight Help: https://developer.apple.com/testflight/"
echo "=========================================="