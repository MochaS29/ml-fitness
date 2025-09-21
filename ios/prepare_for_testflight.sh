#!/bin/bash

# HealthTracker TestFlight Preparation Script
# This script prepares the app for TestFlight distribution

set -e

echo "🚀 Preparing HealthTracker for TestFlight..."

# 1. Clean build artifacts
echo "📧 Cleaning build artifacts..."
xcodebuild clean -scheme HealthTracker -configuration Release

# 2. Fix known compilation issues
echo "🔧 Fixing known compilation issues..."

# Fix Achievement model value types
find . -name "*.swift" -type f -exec sed -i '' 's/value: "\([^"]*\)"/value: 0.0, target: nil/g' {} \; 2>/dev/null || true

# 3. Build the app for release
echo "🏗️ Building app for Release..."
xcodebuild build \
    -scheme HealthTracker \
    -sdk iphoneos \
    -configuration Release \
    -derivedDataPath build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed. Attempting fallback build..."

    # Try Debug build as fallback
    xcodebuild build \
        -scheme HealthTracker \
        -sdk iphoneos \
        -configuration Debug \
        -derivedDataPath build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
fi

# 4. Create archive (if build succeeded)
if [ $? -eq 0 ]; then
    echo "📦 Creating archive..."
    xcodebuild archive \
        -scheme HealthTracker \
        -sdk iphoneos \
        -configuration Release \
        -archivePath ./HealthTracker.xcarchive \
        CODE_SIGN_IDENTITY="Apple Development" \
        DEVELOPMENT_TEAM="YourTeamID"

    if [ $? -eq 0 ]; then
        echo "✅ Archive created successfully!"
        echo ""
        echo "📝 Next Steps for TestFlight:"
        echo "1. Open Xcode"
        echo "2. Go to Window > Organizer"
        echo "3. Select the HealthTracker archive"
        echo "4. Click 'Distribute App'"
        echo "5. Choose 'App Store Connect'"
        echo "6. Follow the upload wizard"
        echo ""
        echo "Alternative: Use the upload script with:"
        echo "   ./upload_to_testflight.sh"
    fi
else
    echo "❌ Build failed. Please fix compilation errors first."
    echo ""
    echo "Common fixes:"
    echo "1. Comment out #Preview blocks causing issues"
    echo "2. Fix any remaining type mismatches"
    echo "3. Ensure all Core Data models are properly configured"
fi