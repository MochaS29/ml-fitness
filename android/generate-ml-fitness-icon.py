#!/usr/bin/env python3
"""
Generate ML Fitness app icon for Android
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size):
    """Create a professional ML Fitness app icon"""
    # Create a new image with a gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (deep teal to vibrant purple)
    for y in range(size):
        # Gradient from teal (#00ACC1) to purple (#8E24AA)
        ratio = y / size
        r = int(0 * (1 - ratio) + 142 * ratio)
        g = int(172 * (1 - ratio) + 36 * ratio)
        b = int(193 * (1 - ratio) + 170 * ratio)
        draw.rectangle([(0, y), (size, y + 1)], fill=(r, g, b, 255))
    
    # Add rounded corners
    # Create mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = size // 8
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    
    # Apply mask
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0), mask)
    img = output
    draw = ImageDraw.Draw(img)
    
    # Add a semi-transparent white circle for logo background
    circle_margin = size // 6
    circle_size = size - (2 * circle_margin)
    
    # Create subtle white overlay circle
    overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.ellipse(
        [(circle_margin, circle_margin), 
         (circle_margin + circle_size, circle_margin + circle_size)],
        fill=(255, 255, 255, 200)
    )
    img = Image.alpha_composite(img, overlay)
    draw = ImageDraw.Draw(img)
    
    # Draw "ML" text - larger and bolder
    try:
        # Try to use a bold font
        font_size = int(size * 0.35)
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = ImageFont.load_default()
    
    text = "ML"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2 - size // 10
    
    # Add shadow for depth
    shadow_offset = max(2, size // 100)
    draw.text((text_x + shadow_offset, text_y + shadow_offset), text, 
              font=font, fill=(0, 0, 0, 80))
    
    # Main text in dark purple
    draw.text((text_x, text_y), text, font=font, fill=(76, 27, 97, 255))
    
    # Add "FITNESS" text below in smaller size
    try:
        small_font_size = int(size * 0.1)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", small_font_size)
    except:
        small_font = ImageFont.load_default()
    
    fitness_text = "FITNESS"
    bbox = draw.textbbox((0, 0), fitness_text, font=small_font)
    fitness_width = bbox[2] - bbox[0]
    fitness_x = (size - fitness_width) // 2
    fitness_y = text_y + text_height + size // 30
    
    # Fitness text in teal
    draw.text((fitness_x, fitness_y), fitness_text, font=small_font, fill=(0, 131, 143, 255))
    
    return img

def main():
    """Generate all required icon sizes for Android"""
    base_dir = "/Users/mocha/Development/Android-Apps/MLHealthAndroid/app/src/main/res"
    
    # Icon sizes for Android
    icon_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    # Create icons for each resolution
    for folder, size in icon_sizes.items():
        folder_path = os.path.join(base_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # Create main icon
        icon = create_app_icon(size)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        print(f"Created {icon_path}")
        
        # Create round icon (same for now)
        round_icon_path = os.path.join(folder_path, 'ic_launcher_round.png')
        icon.save(round_icon_path, 'PNG')
        print(f"Created {round_icon_path}")
    
    # Create high-res playstore icon
    playstore_icon = create_app_icon(512)
    playstore_path = os.path.join(base_dir, '..', '..', 'ic_launcher-playstore.png')
    playstore_icon.save(playstore_path, 'PNG')
    print(f"Created {playstore_path}")
    
    print("\n✅ All ML Fitness icons generated successfully!")
    print("📱 Please rebuild and reinstall the app to see the new icon.")

if __name__ == "__main__":
    main()
