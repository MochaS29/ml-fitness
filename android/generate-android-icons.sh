#!/bin/bash

# Generate Android app icons with ML Health branding
# Uses ImageMagick to create icons in different sizes

# Define colors - matching iOS app
BACKGROUND="#00D4AA"  # Mindful Teal
TEXT_COLOR="#FFFFFF"   # White

# Create base icon with "ML" text
create_icon() {
    SIZE=$1
    OUTPUT=$2
    
    # Calculate font size (roughly 40% of icon size)
    FONT_SIZE=$(echo "$SIZE * 0.4" | bc | cut -d. -f1)
    
    # Create icon using ImageMagick convert command
    convert -size ${SIZE}x${SIZE} xc:"$BACKGROUND" \
            -gravity center \
            -font Helvetica-Bold \
            -pointsize $FONT_SIZE \
            -fill "$TEXT_COLOR" \
            -annotate +0+0 "ML" \
            "$OUTPUT"
}

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Creating placeholder icons..."
    
    # Create placeholder icons using base64 encoded PNG
    # This is a minimal 48x48 teal square with ML text
    PLACEHOLDER_ICON="iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAAKjSURBVGiB7ZpLSFRRGMd/Z8bRyUfqaKOFqZGVFUUPKqIHRRsXLVq0aBFBi6BFQYsgWrQIIqJFiyAiokWLFi1atGjRokWLFi0qKHpQGGVlZWVlZeXY4sx0z3fPvXfunTszOf3hg5n7ne/8/985557vfBcmMYlJTGLiQZQqsDYLKFW8KFV8KGQCCkBBQaEQhQwUMlHoAvYCR4Em4BXwA/gJvAZ2AwuBTEBBRkFGRuv5P6CQiUIeCp8R6ALWAs+B78Bv4AuwDyhApBdnSiQjcqF8ktXNXeCU9hKFVBQyUMgF0oBOhCjUobAemIGQjMJyFLYg0IPQhbCaWfkahP8BKUAKsBW4BnzVvj8HzgJVKNQiJCCkI+Qi9AB7ECpQkFHoQqEFISHSYK2QhMIG4JLW63PgOlALZCLEkx0Fo9BDeNrMa0x9Bq4AS1GQHV0wD3gGjAAvgOko5NgzdhIK04C3wChwHkjyxdhqFhEeOs9Q8NkxliTgMPAdGEEo88VY/VBhJuGF5zYKeU6MvQRWEh5SJSj8w3UiqShsAj4Q7olCv/MZaBHwDRgDqvw2tg6FRuAnMIxQ4LOxMRSytQXtJ0Ilgs/aiBSFDcAjrednwGqfx38JKAUGA3r/VoQsZOQRudcQvyJRFEJai/+nUP5vNB5RKKxCuKltP9sXCxUKp4FB4AFCeRytFyGLwJq0xVASCpmAjLAzjua0OG21IqxBoRGhBWEPMXyWR8hFYREKZQipxtGR0f4ngKeBM9o2SQjpiKSGmK+5bJSxCuEnxhBOdGpQOKPNRKBQNQFsJCJrxnLihJ8Yy3EY1oxdQgZoP3NUY6MZJVK1XkaIYBW1T6FAEv0flGBrBVs3nP0AAAAASUVORK5CYII="
    
    # mdpi - 48x48
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-mdpi/ic_launcher.png
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-mdpi/ic_launcher_round.png
    
    # hdpi - 72x72
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-hdpi/ic_launcher.png
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-hdpi/ic_launcher_round.png
    
    # xhdpi - 96x96
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xhdpi/ic_launcher.png
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xhdpi/ic_launcher_round.png
    
    # xxhdpi - 144x144
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png
    
    # xxxhdpi - 192x192
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
    echo "$PLACEHOLDER_ICON" | base64 -d > app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png
    
    echo "Placeholder icons created successfully!"
else
    echo "Creating app icons with ImageMagick..."
    
    # Create icons for different densities
    create_icon 48 "app/src/main/res/mipmap-mdpi/ic_launcher.png"
    create_icon 48 "app/src/main/res/mipmap-mdpi/ic_launcher_round.png"
    
    create_icon 72 "app/src/main/res/mipmap-hdpi/ic_launcher.png"
    create_icon 72 "app/src/main/res/mipmap-hdpi/ic_launcher_round.png"
    
    create_icon 96 "app/src/main/res/mipmap-xhdpi/ic_launcher.png"
    create_icon 96 "app/src/main/res/mipmap-xhdpi/ic_launcher_round.png"
    
    create_icon 144 "app/src/main/res/mipmap-xxhdpi/ic_launcher.png"
    create_icon 144 "app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png"
    
    create_icon 192 "app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
    create_icon 192 "app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png"
    
    echo "Icons created successfully with ImageMagick!"
fi

echo "Android app icons have been generated in app/src/main/res/mipmap-* directories"