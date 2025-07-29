#!/usr/bin/env python3
"""
MindLabs Health App Icon Generator Script
This script helps generate app icon files for iOS

Requirements:
- Pillow (pip install Pillow)
- A 1024x1024 source image

Usage:
python generate_app_icon.py source_icon.png
"""

import sys
import os
from PIL import Image, ImageDraw, ImageFont
import json

def create_icon_set(source_image_path):
    """Generate all required iOS app icon sizes from a source image"""
    
    # iOS App Icon sizes (points @ scale = pixels)
    icon_sizes = [
        # iPhone App
        ("iphone", 20, 2, 40),    # 20pt @2x = 40px (Notification)
        ("iphone", 20, 3, 60),    # 20pt @3x = 60px (Notification)
        ("iphone", 29, 2, 58),    # 29pt @2x = 58px (Settings)
        ("iphone", 29, 3, 87),    # 29pt @3x = 87px (Settings)
        ("iphone", 40, 2, 80),    # 40pt @2x = 80px (Spotlight)
        ("iphone", 40, 3, 120),   # 40pt @3x = 120px (Spotlight)
        ("iphone", 60, 2, 120),   # 60pt @2x = 120px (App)
        ("iphone", 60, 3, 180),   # 60pt @3x = 180px (App)
        
        # iPad App
        ("ipad", 20, 1, 20),      # 20pt @1x = 20px (Notification)
        ("ipad", 20, 2, 40),      # 20pt @2x = 40px (Notification)
        ("ipad", 29, 1, 29),      # 29pt @1x = 29px (Settings)
        ("ipad", 29, 2, 58),      # 29pt @2x = 58px (Settings)
        ("ipad", 40, 1, 40),      # 40pt @1x = 40px (Spotlight)
        ("ipad", 40, 2, 80),      # 40pt @2x = 80px (Spotlight)
        ("ipad", 76, 1, 76),      # 76pt @1x = 76px (App)
        ("ipad", 76, 2, 152),     # 76pt @2x = 152px (App)
        ("ipad", 83.5, 2, 167),   # 83.5pt @2x = 167px (App)
        
        # App Store
        ("ios-marketing", 1024, 1, 1024),  # 1024pt @1x = 1024px
    ]
    
    # Load source image
    try:
        source = Image.open(source_image_path)
        if source.size != (1024, 1024):
            print(f"Warning: Source image is {source.size}, resizing to 1024x1024")
            source = source.resize((1024, 1024), Image.Resampling.LANCZOS)
    except Exception as e:
        print(f"Error loading source image: {e}")
        return
    
    # Create output directory
    output_dir = "AppIcon.appiconset"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Generate each icon size
    contents = {
        "images": [],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    for device, points, scale, pixels in icon_sizes:
        # Generate filename
        if device == "ios-marketing":
            filename = f"Icon-{pixels}.png"
        else:
            filename = f"Icon-{device}-{points}x{points}@{scale}x.png"
        
        # Resize and save
        icon = source.resize((pixels, pixels), Image.Resampling.LANCZOS)
        icon.save(os.path.join(output_dir, filename), "PNG")
        print(f"Generated {filename} ({pixels}x{pixels})")
        
        # Add to Contents.json
        if device == "ios-marketing":
            contents["images"].append({
                "filename": filename,
                "idiom": "ios-marketing",
                "scale": "1x",
                "size": f"{points}x{points}"
            })
        else:
            contents["images"].append({
                "filename": filename,
                "idiom": device,
                "scale": f"{scale}x",
                "size": f"{points}x{points}"
            })
    
    # Write Contents.json
    with open(os.path.join(output_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    
    print(f"\nApp icon set generated in {output_dir}/")
    print("Copy the entire AppIcon.appiconset folder to your Assets.xcassets")

def create_default_icon():
    """Create a default MindLabs Health icon programmatically"""
    
    # Create a 1024x1024 image
    size = 1024
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background (simulated with rectangles)
    for i in range(size):
        color_r = int(51 + (102 - 51) * (i / size))  # 0.2 to 0.4
        color_g = int(153 + (204 - 153) * (i / size))  # 0.6 to 0.8
        color_b = int(230 - (230 - 204) * (i / size))  # 0.9 to 0.8
        draw.rectangle([(0, i), (size, i+1)], fill=(color_r, color_g, color_b))
    
    # Draw white circle
    circle_margin = size // 8
    draw.ellipse(
        [(circle_margin, circle_margin), 
         (size - circle_margin, size - circle_margin)],
        fill='white'
    )
    
    # Draw "ML" text
    try:
        # Try to use a system font
        font_size = size // 3
        # This will use default font if system font not available
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    text = "ML"
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - size // 20  # Slight adjustment up
    
    # Draw text
    draw.text((x, y), text, fill=(51, 128, 204), font=font)
    
    # Add small health indicator circle
    indicator_size = size // 8
    indicator_x = size * 3 // 4
    indicator_y = size // 4
    draw.ellipse(
        [(indicator_x - indicator_size//2, indicator_y - indicator_size//2),
         (indicator_x + indicator_size//2, indicator_y + indicator_size//2)],
        fill=(76, 204, 128)
    )
    
    # Save the generated icon
    img.save("mindlabs_health_icon.png", "PNG")
    print("Generated default MindLabs Health icon: mindlabs_health_icon.png")
    return "mindlabs_health_icon.png"

if __name__ == "__main__":
    if len(sys.argv) > 1:
        source_path = sys.argv[1]
    else:
        print("No source image provided, generating default MindLabs Health icon...")
        source_path = create_default_icon()
    
    create_icon_set(source_path)