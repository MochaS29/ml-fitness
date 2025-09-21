#!/bin/bash

# Export HealthTracker for TestFlight
# This creates an unsigned IPA that can be signed in Xcode

echo "📱 Exporting HealthTracker for TestFlight..."

# Create export directory
EXPORT_DIR=~/Desktop/HealthTracker_Export
mkdir -p "$EXPORT_DIR"

# Check if app was built
if [ -d "build/Build/Products/Release-iphoneos/HealthTracker.app" ]; then
    echo "✅ Found built app"

    # Create Payload directory
    mkdir -p "$EXPORT_DIR/Payload"

    # Copy app to Payload
    cp -R build/Build/Products/Release-iphoneos/HealthTracker.app "$EXPORT_DIR/Payload/"

    # Create IPA
    cd "$EXPORT_DIR"
    zip -r HealthTracker.ipa Payload

    # Clean up
    rm -rf Payload

    echo "✅ IPA created at: $EXPORT_DIR/HealthTracker.ipa"
    echo ""
    echo "📝 Next Steps:"
    echo "1. Open Xcode"
    echo "2. Go to Window > Organizer"
    echo "3. Click 'Import' and select the IPA"
    echo "4. Or use Transporter app to upload directly"
    echo ""
    echo "Alternative: Open project in Xcode and:"
    echo "1. Select 'Any iOS Device' as destination"
    echo "2. Product > Archive"
    echo "3. Follow the upload wizard"
else
    echo "❌ App not built. Run ./prepare_for_testflight.sh first"
fi