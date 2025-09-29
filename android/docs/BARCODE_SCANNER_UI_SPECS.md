# Barcode Scanner UI Specifications
## Shared Design for iOS and Android

### Overview
This document defines the shared UI design for barcode scanning features across both iOS (SwiftUI) and Android (Jetpack Compose) versions of ML Fitness app.

## UI Components

### 1. Scanner Screen Layout

#### Top Section - Header
- **Background**: Semi-transparent dark overlay (Black @ 80% opacity)
- **Height**: 60dp/pt
- **Content**:
  - Back/Close button (left) - X icon, white, 24dp/pt
  - Title "Scan Barcode" (center) - White, 18sp/pt, Medium weight
  - Flash toggle button (right) - Lightning icon, white, 24dp/pt

#### Middle Section - Camera View
- **Full screen camera preview**
- **Scan Area Overlay**:
  - Rounded rectangle frame in center
  - Size: 280x140dp/pt
  - Corner radius: 12dp/pt
  - Border: 2dp/pt white with subtle glow effect
  - Semi-transparent dark overlay outside scan area (Black @ 60% opacity)

#### Scan Line Animation
- **Horizontal line** moving up and down within scan area
- Color: Primary color (Mocha Brown #6B4423)
- Height: 2dp/pt
- Animation: 2-second loop, ease-in-out
- Opacity pulse: 0.6 to 1.0

#### Bottom Section - Actions
- **Background**: White with top rounded corners (24dp/pt radius)
- **Height**: 180dp/pt
- **Content**:

##### Status Text
- Position: Top, centered
- Default: "Point camera at barcode"
- Scanning: "Scanning..."
- Found: "Product found!"
- Not found: "Product not found"
- Font size: 16sp/pt
- Color: Gray for default, Primary for scanning, Green for found, Orange for not found

##### Primary Button
- **Manual Entry Button**
  - Text: "Enter Manually"
  - Background: Primary color (Mocha Brown)
  - Text color: White
  - Height: 48dp/pt
  - Width: Fill parent with 24dp/pt padding
  - Corner radius: 24dp/pt
  - Position: 16dp/pt from bottom

##### Secondary Actions (when product found)
- **Product Card**:
  - Background: Light gray (#F5F5F5)
  - Corner radius: 12dp/pt
  - Padding: 16dp/pt
  - Content:
    - Product name (16sp/pt, Bold)
    - Brand name (14sp/pt, Gray)
    - Nutrition preview (12sp/pt): "Cal: 150 | P: 10g | C: 20g | F: 5g"

### 2. Permission Request Screen

#### Layout
- **Icon**: Camera icon, 64dp/pt, Primary color
- **Title**: "Camera Permission Required"
  - Font: 20sp/pt, Bold
- **Description**: "ML Fitness needs camera access to scan barcodes and quickly log your food."
  - Font: 14sp/pt, Gray
  - Multi-line, centered
- **Grant Button**:
  - Text: "Grant Camera Access"
  - Same style as primary button
- **Skip Button**:
  - Text: "Enter Manually Instead"
  - Text button style, Primary color

### 3. Loading States

#### Scanning Animation
- Circular progress indicator over camera view
- Size: 48dp/pt
- Color: Primary with white background circle
- Position: Center of scan area

#### API Call Loading
- Small inline progress indicator (20dp/pt)
- Next to "Looking up product..." text
- In bottom section

### 4. Error States

#### No Camera Available
- Icon: Camera-off icon
- Message: "Camera not available"
- Action: "Enter Manually" button only

#### API Error
- Toast/Snackbar notification
- Message: "Unable to fetch product details. Try again."
- Action: "Retry" button

### 5. Success State

#### Product Found Animation
- Scan area border flashes green
- Haptic feedback (single impact)
- Bottom sheet expands with product details

#### Auto-dismiss
- After 3 seconds if no user interaction
- Navigate to food entry screen with product pre-filled

## Color Palette

### Primary Colors
- **Mocha Brown**: #6B4423 (Primary actions, scan line)
- **Light Mocha**: #8B5A3C (Secondary elements)
- **Cream**: #FFF8E7 (Background accents)

### Status Colors
- **Success Green**: #4CAF50
- **Warning Orange**: #FF9800
- **Error Red**: #F44336
- **Info Blue**: #2196F3

### Neutral Colors
- **Dark Gray**: #333333 (Primary text)
- **Medium Gray**: #666666 (Secondary text)
- **Light Gray**: #F5F5F5 (Backgrounds)
- **Border Gray**: #E0E0E0

## Typography

### iOS (SF Pro)
- **Title**: SF Pro Display, 18pt, Semibold
- **Body**: SF Pro Text, 14pt, Regular
- **Caption**: SF Pro Text, 12pt, Regular
- **Button**: SF Pro Text, 16pt, Semibold

### Android (Roboto)
- **Title**: Roboto, 18sp, Medium (500)
- **Body**: Roboto, 14sp, Regular (400)
- **Caption**: Roboto, 12sp, Regular (400)
- **Button**: Roboto, 16sp, Medium (500)

## Animations

### Scan Line
```
Duration: 2000ms
Easing: EaseInOut
Path: Top of scan area → Bottom → Top (loop)
```

### Product Found
```
1. Scan border flash (green, 300ms)
2. Haptic feedback
3. Bottom sheet expand (400ms, ease-out)
```

### Camera Permission
```
Fade in: 300ms
Scale: 0.95 → 1.0
```

## Spacing Guidelines

### Padding
- Screen edges: 16dp/pt
- Between elements: 12dp/pt
- Inside cards: 16dp/pt
- Button padding: 16dp/pt horizontal, 12dp/pt vertical

### Margins
- Top safe area: Status bar height + 8dp/pt
- Bottom safe area: Navigation bar height + 8dp/pt
- Between sections: 24dp/pt

## Platform-Specific Implementations

### iOS (SwiftUI)
```swift
// Use AVCaptureSession for camera
// Use Vision framework for barcode detection
// SwiftUI animations with .animation() modifier
// Haptic: UIImpactFeedbackGenerator
```

### Android (Compose)
```swift
// Use CameraX for camera
// Use ML Kit for barcode detection
// Compose animations with animateFloatAsState
// Haptic: HapticFeedbackConstants
```

## Accessibility

### VoiceOver/TalkBack
- Scanner view: "Camera viewfinder. Point at barcode to scan"
- Manual entry: "Enter barcode manually, button"
- Flash toggle: "Toggle flash, button, {on/off}"

### Dynamic Type/Font Scaling
- Support system font size preferences
- Minimum font size: 12sp/pt
- Maximum font size: 24sp/pt

### Color Contrast
- All text meets WCAG AA standards
- Minimum contrast ratio: 4.5:1 for normal text
- Minimum contrast ratio: 3:1 for large text

## Testing Checklist

- [ ] Camera preview displays correctly
- [ ] Scan area overlay is centered
- [ ] Scan line animates smoothly
- [ ] Barcode detection works for all supported formats
- [ ] Manual entry button is always accessible
- [ ] Permission request shows when needed
- [ ] Flash toggle works
- [ ] Product details display correctly
- [ ] Error states handle gracefully
- [ ] Success state provides feedback
- [ ] Accessibility features work
- [ ] Dark mode support (if applicable)

## Supported Barcode Formats

Both platforms should support:
- UPC-A (12 digits)
- UPC-E (8 digits)
- EAN-13 (13 digits)
- EAN-8 (8 digits)
- Code 128
- Code 39
- ITF

## Implementation Notes

1. **Performance**: Keep camera resolution at 1920x1080 or lower for smooth scanning
2. **Battery**: Stop camera when app goes to background
3. **Privacy**: Don't store scanned barcodes without user consent
4. **Network**: Cache successful lookups for offline access
5. **Fallback**: Always provide manual entry option

## Version History

- v1.0 (2024-01): Initial specification
- v1.1 (2024-01): Added supplement scanner variations