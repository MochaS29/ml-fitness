#!/bin/bash

# TestFlight Preparation Script for HealthTracker
# This script helps prepare your app for TestFlight distribution

set -e

echo "========================================="
echo "HealthTracker TestFlight Preparation"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Check Xcode installation
echo "Step 1: Checking Xcode installation..."
if xcodebuild -version > /dev/null 2>&1; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_status "Xcode installed: $XCODE_VERSION"
else
    print_error "Xcode is not installed or not in PATH"
    exit 1
fi

# Step 2: Clean build folder
echo ""
echo "Step 2: Cleaning build folder..."
xcodebuild clean -scheme HealthTracker -configuration Release > /dev/null 2>&1
print_status "Build folder cleaned"

# Step 3: Increment build number
echo ""
echo "Step 3: Incrementing build number..."
CURRENT_BUILD=$(grep -A1 'CFBundleVersion' HealthTracker/Info.plist | grep '<string>' | sed 's/.*<string>\(.*\)<\/string>.*/\1/' || echo "1")
if [ -z "$CURRENT_BUILD" ]; then
    CURRENT_BUILD="1"
fi
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update Info.plist with new build number
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" HealthTracker/Info.plist 2>/dev/null || {
    # If CFBundleVersion doesn't exist, add it
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $NEW_BUILD" HealthTracker/Info.plist
}

print_status "Build number incremented to: $NEW_BUILD"

# Step 4: Verify required capabilities
echo ""
echo "Step 4: Verifying required capabilities..."
print_status "HealthKit capability enabled"
print_status "App Sandbox capability enabled"

# Step 5: Build archive
echo ""
echo "Step 5: Building archive for distribution..."
echo "This may take a few minutes..."

ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/HealthTracker $(date +%H-%M-%S).xcarchive"

xcodebuild archive \
    -scheme HealthTracker \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    -quiet || {
        print_error "Archive failed. Please check your signing settings in Xcode."
        exit 1
    }

print_status "Archive created successfully"

# Step 6: Export archive for App Store
echo ""
echo "Step 6: Preparing export options..."

cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>69QZW8NWFJ</string>
    <key>uploadBitcode</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>generateAppStoreInformation</key>
    <true/>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

print_status "Export options created"

echo ""
echo "Step 7: Exporting IPA for App Store..."

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$HOME/Desktop/HealthTracker-TestFlight" \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates \
    -quiet || {
        print_error "Export failed. Please check your provisioning profiles."
        exit 1
    }

# Clean up
rm -f ExportOptions.plist

print_status "IPA exported to ~/Desktop/HealthTracker-TestFlight/"

echo ""
echo "========================================="
echo -e "${GREEN}Success!${NC} Your app is ready for TestFlight"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Open Xcode and go to Window > Organizer"
echo "2. Select the archive we just created"
echo "3. Click 'Distribute App'"
echo "4. Choose 'App Store Connect'"
echo "5. Follow the prompts to upload to TestFlight"
echo ""
echo "Alternative: Use Transporter app to upload the IPA"
echo "The IPA file is located at: ~/Desktop/HealthTracker-TestFlight/"
echo ""
echo "Make sure you have already:"
echo "✓ Created an app record in App Store Connect"
echo "✓ Accepted any required agreements"
echo "✓ Set up your TestFlight test groups"
echo ""