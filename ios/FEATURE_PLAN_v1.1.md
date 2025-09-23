# Feature Development Plan v1.1.0

## 🎯 Target Features for Next Release

### 1. 💧 Water Hydration Reminders
**Priority: HIGH** - Great for user engagement

#### Requirements:
- [ ] Local notifications (no server needed)
- [ ] Customizable reminder intervals
- [ ] Smart scheduling (not during sleep hours)
- [ ] Quick log from notification
- [ ] Daily goal tracking

#### Technical Components:
```swift
1. NotificationManager (already exists - needs extension)
2. WaterReminderSettings view
3. UserDefaults for preferences
4. Local notification scheduling
```

#### User Flow:
1. User enables water reminders in Settings
2. Sets frequency (every 1, 2, 3 hours)
3. Sets active hours (e.g., 8 AM - 8 PM)
4. Receives notifications
5. Can log water directly from notification

---

### 2. 📷 Barcode Scanner - Supplements
**Priority: HIGH** - Already has UI, needs implementation

#### Current State:
- ✅ UI exists (camera icon in ManualSupplementEntryView)
- ✅ Supplement database ready
- ❌ Scanner not implemented

#### Requirements:
- [ ] Camera permission handling
- [ ] AVFoundation barcode scanning
- [ ] API integration for barcode lookup
- [ ] Fallback to manual entry
- [ ] Success/error feedback

#### API Options:
1. **OpenFoodFacts API** (Free, good supplement data)
2. **Nutritionix API** (Free tier available)
3. **USDA API** (Free, limited supplement data)
4. **Barcode Lookup API** (Freemium)

---

### 3. 📷 Barcode Scanner - Food Items
**Priority: MEDIUM** - Expands food database significantly

#### Current State:
- ❌ No UI for barcode in food search
- ✅ Food database structure ready
- ✅ UnifiedFoodSearchSheet can be extended

#### Requirements:
- [ ] Add scanner button to food search
- [ ] Share scanner code with supplements
- [ ] Map barcode data to FoodItem model
- [ ] Handle missing nutrition data
- [ ] Save scanned items to custom foods

---

## 📱 Implementation Plan

### Phase 1: Water Reminders (Week 1)
```
Day 1-2: Notification permissions & settings UI
Day 3-4: Scheduling logic & intervals
Day 5-6: Quick actions from notifications
Day 7: Testing & polish
```

### Phase 2: Barcode Infrastructure (Week 2)
```
Day 1-2: Camera permissions & AVFoundation setup
Day 3-4: Barcode detection & parsing
Day 5-6: Create reusable BarcodeScannerView
Day 7: Error handling & feedback
```

### Phase 3: API Integration (Week 3)
```
Day 1-2: OpenFoodFacts API client
Day 3-4: Supplement barcode lookup
Day 5-6: Food barcode lookup
Day 7: Offline fallback & caching
```

---

## 🏗️ Technical Architecture

### New Files to Create:
```
Services/
  ├── WaterReminderService.swift
  ├── BarcodeService.swift
  └── OpenFoodFactsAPI.swift

Views/
  ├── Settings/
  │   └── WaterReminderSettingsView.swift
  ├── Components/
  │   └── BarcodeScannerView.swift
  └── Sheets/
      └── BarcodeResultView.swift

Models/
  └── BarcodeProduct.swift
```

### Modified Files:
```
- NotificationManager.swift (add water reminders)
- SettingsView.swift (add water settings link)
- ManualSupplementEntryView.swift (integrate scanner)
- UnifiedFoodSearchSheet.swift (add scanner button)
```

---

## 🔑 Key Decisions Needed

### 1. Notification Strategy
- **Option A**: Fixed intervals (every 2 hours)
- **Option B**: Smart reminders (based on intake pattern)
- **Option C**: Both with user choice
- **Recommendation**: Start with A, add B later

### 2. Barcode API
- **Option A**: OpenFoodFacts (free, community-driven)
- **Option B**: Nutritionix (better data, has limits)
- **Option C**: Multiple APIs with fallback
- **Recommendation**: OpenFoodFacts primary, manual fallback

### 3. Scanner UX
- **Option A**: Full-screen scanner modal
- **Option B**: Embedded scanner in search view
- **Option C**: Floating scanner button
- **Recommendation**: Full-screen for better UX

---

## 📊 Success Metrics

### Water Reminders:
- Users enable the feature
- Daily water goal completion increases
- Notification interaction rate > 30%

### Barcode Scanning:
- 50%+ success rate on first scan
- Reduces manual entry time by 75%
- Users scan 5+ items per week

---

## 🚀 Quick Start Commands

### Start Water Reminders Feature:
```bash
# Create water reminder service
touch HealthTracker/Services/WaterReminderService.swift

# Create settings view
touch HealthTracker/Views/Settings/WaterReminderSettingsView.swift
```

### Start Barcode Scanner:
```bash
# Create barcode scanner view
touch HealthTracker/Views/Components/BarcodeScannerView.swift

# Create API service
touch HealthTracker/Services/OpenFoodFactsAPI.swift
```

---

## 🎯 Version Planning

### v1.1.0 (Next Release)
- ✅ Water reminders
- ✅ Basic barcode scanning
- ✅ OpenFoodFacts integration

### v1.2.0 (Future)
- Enhanced water tracking widgets
- Barcode history
- Multiple API sources
- Nutrition label OCR

---

## 📝 Notes

1. **Privacy**: Update Info.plist with notification permissions
2. **Testing**: Need real device for camera testing
3. **Offline**: Consider caching scanned products
4. **Analytics**: Track scan success rates

---

**Ready to start?** Let's begin with water reminders! 💧