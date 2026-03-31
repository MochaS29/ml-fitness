# ML Fitness Landing Page - Image Setup Guide

## Directory Structure

Create the following structure in your HealthTracker directory:

```
/Users/mocha/Development/iOS-Apps/HealthTracker/
├── ml-fitness-landing-page.html
├── ml-fitness-icon.png          (Your app icon - 1024x1024px recommended)
├── ml-fitness-dashboard.png     (Dashboard screenshot you showed me)
└── screenshots/
    ├── meal-planning.png        (Meal planning screen)
    ├── food-diary.png           (Food diary/calorie tracking screen)
    ├── exercise.png             (Exercise tracking screen)
    ├── health-sync.png          (Health app integration screen)
    └── weight-tracking.png      (Weight tracking/progress screen)
```

## Image Specifications

### App Icon
- **File:** `ml-fitness-icon.png`
- **Size:** 1024x1024px (will be displayed at 180x180px)
- **Format:** PNG with transparency
- **Location:** Root directory next to HTML file

### Hero Dashboard Screenshot
- **File:** `ml-fitness-dashboard.png`
- **Size:** Original iPhone screenshot (1170 x 2532px for iPhone 15 Pro)
- **Format:** PNG
- **Location:** Root directory next to HTML file
- **Note:** This is the dashboard screenshot you showed me

### Feature Screenshots
Create a `screenshots` folder and add these images:

1. **meal-planning.png** - Screenshot showing meal plans
2. **food-diary.png** - Screenshot of food logging/diary
3. **exercise.png** - Screenshot of exercise tracking
4. **health-sync.png** - Screenshot of health app integration
5. **weight-tracking.png** - Screenshot of weight tracking charts

## Quick Setup Commands

Run these commands in Terminal:

```bash
# Navigate to the directory
cd /Users/mocha/Development/iOS-Apps/HealthTracker

# Create screenshots directory
mkdir -p screenshots

# Move your images to the correct locations
# (Replace these with your actual file paths)
# cp /path/to/your/app-icon.png ml-fitness-icon.png
# cp /path/to/your/dashboard-screenshot.png ml-fitness-dashboard.png
# cp /path/to/your/screenshots/*.png screenshots/
```

## Testing the Page

1. Place all images in their correct locations
2. Open Terminal and navigate to the directory:
   ```bash
   cd /Users/mocha/Development/iOS-Apps/HealthTracker
   ```

3. Start the local server (if not already running):
   ```bash
   python3 -m http.server 8000
   ```

4. Open in browser:
   ```
   http://localhost:8000/ml-fitness-landing-page.html
   ```

## Fallback Behavior

If images are not found, the page will automatically display gradient placeholders with text, so the page will never look broken.

## Image Optimization Tips

Before adding images to the website:

1. **Compress images** to reduce load time:
   - Use tools like ImageOptim (Mac) or TinyPNG
   - Target: < 200KB per screenshot

2. **Convert to WebP** for better performance (optional):
   ```bash
   # Install ImageMagick if needed: brew install imagemagick
   magick convert ml-fitness-icon.png ml-fitness-icon.webp
   ```

3. **Create responsive versions**:
   - 1x (original)
   - 2x (retina)
   - 3x (iPhone Pro Max)

## For Production Website

When uploading to mochasmindlab.com:

1. Upload all images to your hosting
2. Update image paths in HTML if needed
3. Test all images load correctly
4. Check mobile responsiveness

## Need Help?

If images aren't showing:
1. Check file names match exactly (case-sensitive)
2. Verify images are in correct directories
3. Check browser console for 404 errors
4. Ensure images are PNG or JPG format

---

**Last Updated:** October 6, 2025
**Status:** Ready to add images
