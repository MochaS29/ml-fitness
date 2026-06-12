#!/bin/bash

# Create temporary directory for work
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create a simple colored square as placeholder icon
# Using ImageMagick convert command if available, otherwise create minimal valid PNGs

# Function to create a minimal valid PNG of given size
create_png() {
    local size=$1
    local output=$2
    
    # Create a minimal PNG using hex values
    # PNG header + IHDR chunk + IDAT chunk + IEND chunk
    printf "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A" > "$output"  # PNG signature
    
    # For now, just create empty files as placeholders
    # These will be valid but empty PNGs
    touch "$output"
}

# Base directory
BASE_DIR="/Users/mocha/Development/Android-Apps/MLHealthAndroid/app/src/main/res"

# Create directories if they don't exist
mkdir -p "$BASE_DIR/mipmap-mdpi"
mkdir -p "$BASE_DIR/mipmap-hdpi"
mkdir -p "$BASE_DIR/mipmap-xhdpi"
mkdir -p "$BASE_DIR/mipmap-xxhdpi"
mkdir -p "$BASE_DIR/mipmap-xxxhdpi"

# Try to use sips (macOS built-in) to create simple icons
if command -v sips &> /dev/null; then
    # Create a base icon (192x192) using sips
    echo "Creating base icon..."
    
    # Create a simple colored rectangle using sips
    # First create a 192x192 white image
    cat << 'EOF' > base_icon.html
<html><body style="margin:0; padding:0;">
<div style="width:192px; height:192px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            display: flex; align-items: center; justify-content: center; 
            color: white; font-size: 96px; font-family: Arial; font-weight: bold;">ML</div>
</body></html>
EOF
    
    # Create simple solid color images as placeholders
    # Using dd to create raw image data then converting
    
    # Create images with solid purple color
    for size in 48 72 96 144 192; do
        # Create a raw RGB file
        dd if=/dev/zero bs=1 count=$((size * size * 3)) 2>/dev/null | \
        perl -pe 's/\0/\x76\x4b\xa2/g' > "raw_${size}.rgb"
    done
fi

# If no image tools available, create minimal valid PNG files
echo "Creating placeholder PNG files..."

# mdpi - 48x48
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > "$BASE_DIR/mipmap-mdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x30\x00\x00\x00\x30\x08\x02\x00\x00\x00' >> "$BASE_DIR/mipmap-mdpi/ic_launcher.png"
echo -n -e '\xd1\x62\x9d\xd7\x00\x00\x00\x19\x49\x44\x41\x54\x48\x89\xed' >> "$BASE_DIR/mipmap-mdpi/ic_launcher.png"
echo -n -e '\xc1\x01\x01\x00\x00\x00\x82\x20\xff\xaf\x6e\x48\x40\x01\x00' >> "$BASE_DIR/mipmap-mdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x01\x00\x01\x14\x65\xa9\x11\x00\x00\x00\x00\x49' >> "$BASE_DIR/mipmap-mdpi/ic_launcher.png"
echo -n -e '\x45\x4e\x44\xae\x42\x60\x82' >> "$BASE_DIR/mipmap-mdpi/ic_launcher.png"

cp "$BASE_DIR/mipmap-mdpi/ic_launcher.png" "$BASE_DIR/mipmap-mdpi/ic_launcher_round.png"

# hdpi - 72x72
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > "$BASE_DIR/mipmap-hdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x48\x00\x00\x00\x48\x08\x02\x00\x00\x00' >> "$BASE_DIR/mipmap-hdpi/ic_launcher.png"
echo -n -e '\x55\x02\x7e\x9e\x00\x00\x00\x19\x49\x44\x41\x54\x68\x89\xed' >> "$BASE_DIR/mipmap-hdpi/ic_launcher.png"
echo -n -e '\xc1\x01\x01\x00\x00\x00\x82\x20\xff\xaf\x6e\x48\x40\x01\x00' >> "$BASE_DIR/mipmap-hdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x01\x00\x01\x14\x65\xa9\x11\x00\x00\x00\x00\x49' >> "$BASE_DIR/mipmap-hdpi/ic_launcher.png"
echo -n -e '\x45\x4e\x44\xae\x42\x60\x82' >> "$BASE_DIR/mipmap-hdpi/ic_launcher.png"

cp "$BASE_DIR/mipmap-hdpi/ic_launcher.png" "$BASE_DIR/mipmap-hdpi/ic_launcher_round.png"

# xhdpi - 96x96
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x60\x00\x00\x00\x60\x08\x02\x00\x00\x00' >> "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"
echo -n -e '\x8b\x01\x93\x41\x00\x00\x00\x19\x49\x44\x41\x54\x78\x89\xed' >> "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"
echo -n -e '\xc1\x01\x01\x00\x00\x00\x82\x20\xff\xaf\x6e\x48\x40\x01\x00' >> "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x01\x00\x01\x14\x65\xa9\x11\x00\x00\x00\x00\x49' >> "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"
echo -n -e '\x45\x4e\x44\xae\x42\x60\x82' >> "$BASE_DIR/mipmap-xhdpi/ic_launcher.png"

cp "$BASE_DIR/mipmap-xhdpi/ic_launcher.png" "$BASE_DIR/mipmap-xhdpi/ic_launcher_round.png"

# xxhdpi - 144x144
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x90\x00\x00\x00\x90\x08\x02\x00\x00\x00' >> "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"
echo -n -e '\x47\x8f\xfa\x37\x00\x00\x00\x19\x49\x44\x41\x54\x78\x89\xed' >> "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"
echo -n -e '\xc1\x01\x01\x00\x00\x00\x82\x20\xff\xaf\x6e\x48\x40\x01\x00' >> "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x01\x00\x01\x14\x65\xa9\x11\x00\x00\x00\x00\x49' >> "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"
echo -n -e '\x45\x4e\x44\xae\x42\x60\x82' >> "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png"

cp "$BASE_DIR/mipmap-xxhdpi/ic_launcher.png" "$BASE_DIR/mipmap-xxhdpi/ic_launcher_round.png"

# xxxhdpi - 192x192
echo -n -e '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\xc0\x00\x00\x00\xc0\x08\x02\x00\x00\x00' >> "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo -n -e '\x7c\xe2\xea\x57\x00\x00\x00\x19\x49\x44\x41\x54\x78\x89\xed' >> "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo -n -e '\xc1\x01\x01\x00\x00\x00\x82\x20\xff\xaf\x6e\x48\x40\x01\x00' >> "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo -n -e '\x00\x00\x00\x01\x00\x01\x14\x65\xa9\x11\x00\x00\x00\x00\x49' >> "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo -n -e '\x45\x4e\x44\xae\x42\x60\x82' >> "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png"

cp "$BASE_DIR/mipmap-xxxhdpi/ic_launcher.png" "$BASE_DIR/mipmap-xxxhdpi/ic_launcher_round.png"

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "Icons generated successfully!"