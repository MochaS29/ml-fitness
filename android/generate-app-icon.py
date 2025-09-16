#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import subprocess

def create_icon_with_text(size, text="MLF"):
    """Create an app icon with MLFitness text"""
    # Create a new image with a gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (purple to teal)
    for y in range(size):
        # Gradient from purple (118, 75, 162) to teal (64, 151, 147)
        r = int(118 + (64 - 118) * y / size)
        g = int(75 + (151 - 75) * y / size)
        b = int(162 + (147 - 162) * y / size)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))
    
    # Add rounded corners
    corner_radius = size // 8
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    
    # Apply mask for rounded corners
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0))
    output.putalpha(mask)
    
    # Add text
    draw = ImageDraw.Draw(output)
    
    # Try to use a bold font, fallback to default if not available
    try:
        # Try to find a suitable font
        font_size = int(size * 0.35)
        font = None
        
        # Try different font paths
        font_paths = [
            "/System/Library/Fonts/Helvetica.ttc",
            "/System/Library/Fonts/Avenir.ttc",
            "/Library/Fonts/Arial.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
        ]
        
        for font_path in font_paths:
            if os.path.exists(font_path):
                try:
                    font = ImageFont.truetype(font_path, font_size)
                    break
                except:
                    continue
        
        if font is None:
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    # Draw text with shadow for depth
    shadow_offset = max(1, size // 100)
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw shadow
    draw.text((x + shadow_offset, y + shadow_offset), text, 
              fill=(0, 0, 0, 100), font=font)
    # Draw main text
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    return output

def generate_android_icons():
    """Generate Android app icons for all densities"""
    base_dir = "/Users/mocha/Development/Android-Apps/MLHealthAndroid/app/src/main/res"
    
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, size in sizes.items():
        folder_path = os.path.join(base_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # Create regular icon
        icon = create_icon_with_text(size)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        print(f"Created {icon_path}")
        
        # Create round icon (same for now)
        round_icon_path = os.path.join(folder_path, 'ic_launcher_round.png')
        icon.save(round_icon_path, 'PNG')
        print(f"Created {round_icon_path}")

def main():
    # Check if PIL is installed
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("Installing Pillow...")
        subprocess.run(["pip3", "install", "Pillow"], check=True)
        from PIL import Image, ImageDraw, ImageFont
    
    print("Generating MindLabs Fitness app icons...")
    generate_android_icons()
    print("✅ App icons generated successfully!")

if __name__ == "__main__":
    main()