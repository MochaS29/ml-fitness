#!/usr/bin/env python3
"""
Generate Minimal ML Fitness app icon
Design: Teal-to-Purple gradient with a white stylized 'Pulse M'
"""

from PIL import Image, ImageDraw
import os

def create_gradient(width, height):
    """Create the signature Teal-to-Purple gradient"""
    base = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    
    for y in range(height):
        # Gradient from Teal (#00ACC1 / 0, 172, 193) to Purple (#8E24AA / 142, 36, 170)
        ratio = y / height
        r = int(0 * (1 - ratio) + 142 * ratio)
        g = int(172 * (1 - ratio) + 36 * ratio)
        b = int(193 * (1 - ratio) + 170 * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
    return base

def draw_pulse_m(draw, size, color=(255, 255, 255, 255)):
    """Draw a stylized M shaped like a heart pulse"""
    # Coordinates based on percentage of size
    w = size
    h = size
    
    # Thickness
    stroke_width = int(size * 0.08)
    
    # Points for the Pulse M
    # Left lead-in
    p1 = (w * 0.15, h * 0.6)
    p2 = (w * 0.25, h * 0.6)
    
    # First peak (Left of M)
    p3 = (w * 0.35, h * 0.25)
    
    # Middle valley (Middle of M)
    p4 = (w * 0.5, h * 0.75)
    
    # Second peak (Right of M)
    p5 = (w * 0.65, h * 0.25)
    
    # Right return
    p6 = (w * 0.75, h * 0.6)
    p7 = (w * 0.85, h * 0.6)

    # Join points
    points = [p1, p2, p3, p4, p5, p6, p7]
    
    # Draw line with rounded joints if possible, else standard
    draw.line(points, fill=color, width=stroke_width, joint='curve')
    
    # Add round caps manually for nicer look
    r = stroke_width / 2
    for point in [p1, p7]:
        draw.ellipse([point[0]-r, point[1]-r, point[0]+r, point[1]+r], fill=color)

def create_icon(size, rounded=False):
    """Generate the icon"""
    # 1. Background
    img = create_gradient(size, size)
    
    # 2. Draw Symbol
    draw = ImageDraw.Draw(img)
    draw_pulse_m(draw, size)
    
    # 3. Optional Rounding
    if rounded:
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        # Circular mask for "round" icons
        mask_draw.ellipse((0, 0, size, size), fill=255)
        
        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask)
        return output
        
    return img

def main():
    base_dir = "/Users/mocha/Development/Android-Apps/MLHealthAndroid/app/src/main/res"
    
    # Standard Android mipmap sizes
    icon_configs = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    print("🎨 Generating Minimal Pulse-M Icons...")
    
    for folder, size in icon_configs.items():
        folder_path = os.path.join(base_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # 1. Square/Adaptive Background (ic_launcher.png)
        # Usually Android wants a full square which it masks, but for simple consistency
        # we'll generate the square gradient.
        icon = create_icon(size, rounded=False)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        print(f"   -> {folder}/ic_launcher.png")
        
        # 2. Round Icon (ic_launcher_round.png)
        round_icon = create_icon(size, rounded=True)
        round_path = os.path.join(folder_path, 'ic_launcher_round.png')
        round_icon.save(round_path, 'PNG')
        print(f"   -> {folder}/ic_launcher_round.png")

    # Play Store High-Res
    playstore_size = 512
    playstore_icon = create_icon(playstore_size, rounded=False)
    playstore_path = os.path.join(base_dir, '..', '..', 'ic_launcher-playstore.png')
    playstore_icon.save(playstore_path, 'PNG')
    print(f"   -> ic_launcher-playstore.png ({playstore_size}x{playstore_size})")
    
    print("\n✅ Done! Clean and simple.")

if __name__ == "__main__":
    main()
