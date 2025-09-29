# NIH Supplement Database Integration Guide

## Overview
The NIH Dietary Supplement Label Database (DSLD) provides FREE access to 120,000+ supplement labels with complete ingredient and nutrient information.

## How It Works

### 1. Automatic Integration (Already Set Up!)
When a user scans a supplement barcode:

```
User scans barcode → Check local database (26 products)
                   ↓ (if not found)
                   → Query NIH DSLD API
                   → Query Open Food Facts
                   → Query USDA Database
                   → Return result or "Not Found"
```

### 2. The Lookup Flow

```kotlin
// When barcode is scanned in SupplementBarcodeScanner:

1. First checks local SupplementDatabase (instant, offline)
2. If not found, calls SupplementAPIService.lookupSupplement()
3. API tries multiple sources in order:
   - NIH DSLD (120,000+ supplements)
   - Open Food Facts (global database)
   - USDA FoodData Central (with our API key)
   - Nutritionix (if API key added)
4. Saves result to local database for future quick access
```

## NIH DSLD API Endpoints (FREE - No Key Required!)

### Search by Barcode/UPC
```
GET https://api.ods.od.nih.gov/dsld/v8/label?upc={barcode}
```

### Search by Name
```
GET https://api.ods.od.nih.gov/dsld/v8/browse?search={query}&limit=10
```

### Get Product Details
```
GET https://api.ods.od.nih.gov/dsld/v8/label/{dsld_id}
```

## Example Usage

### Direct API Call (for testing)
```bash
# Search for Centrum by barcode
curl "https://api.ods.od.nih.gov/dsld/v8/label?upc=062107073806"

# Search by name
curl "https://api.ods.od.nih.gov/dsld/v8/browse?search=centrum%20men&limit=5"

# Get specific product details
curl "https://api.ods.od.nih.gov/dsld/v8/label/77930"
```

### In the App (Automatic)
Just scan any supplement barcode! The app will:
1. Check local database
2. Query NIH if needed
3. Display results
4. Save for offline access

## What NIH Provides

### Product Information
- Product name & brand
- UPC/barcode
- Manufacturer details
- Serving size & servings per container
- Supplement facts panel

### Ingredients Data
- Complete ingredient list
- Amount per serving for each ingredient
- Units (mg, mcg, IU, etc.)
- Daily Value percentages

### Categories Covered
- Multivitamins
- Single vitamins (A, C, D, E, K, B-complex)
- Minerals (calcium, iron, magnesium, zinc)
- Omega-3/Fish oils
- Probiotics
- Protein powders
- Herbal supplements
- Specialty formulas

## Testing the Integration

### Test with Real Barcodes
Try scanning these actual supplement barcodes:

```
Centrum Men:           062107073806
One A Day Women's:     016500535669
Nature Made D3:        031604013721
GNC Mega Men:         048107084967
Vitafusion Gummies:   027917020587
NOW Foods Omega-3:    733739016713
Garden of Life:       658010114097
Rainbow Light:        021888109470
```

### Manual Search Test
```kotlin
// In any ViewModel or Screen:
val apiService = SupplementAPIService()

// Search by barcode
lifecycleScope.launch {
    val result = apiService.lookupSupplement("062107073806")
    if (result != null) {
        println("Found: ${result.name} by ${result.brand}")
        println("Ingredients: ${result.ingredients}")
        println("Source: ${result.source}")
    }
}

// Search by name
lifecycleScope.launch {
    val results = apiService.searchByName("vitamin d")
    results.forEach { supplement ->
        println("${supplement.name} - ${supplement.source}")
    }
}
```

## Advantages of NIH DSLD

✅ **FREE** - No API key required
✅ **Comprehensive** - 120,000+ products
✅ **Official** - U.S. government data
✅ **Detailed** - Complete ingredient lists
✅ **Reliable** - Regularly updated
✅ **No Rate Limits** - Reasonable usage allowed

## Fallback Options

If NIH doesn't have a product, the app automatically tries:
1. **Open Food Facts** - Community database
2. **USDA FoodData Central** - Some supplements
3. **Local Database** - 26 pre-loaded products

## Adding More Databases

To add Nutritionix (900,000+ products):
1. Sign up at https://www.nutritionix.com/business/api
2. Add to `ApiConfig.kt`:
```kotlin
const val NUTRITIONIX_APP_ID = "your_app_id"
const val NUTRITIONIX_APP_KEY = "your_api_key"
```

## Troubleshooting

### Supplement Not Found?
- Check barcode is correctly scanned
- Try searching by name instead
- Product may be too new/regional
- Add manually to local database

### Slow Response?
- NIH API is usually fast (<500ms)
- Network issues may cause delays
- Local cache speeds up repeated scans

### Wrong Product Data?
- Report to NIH via their website
- Override with local database entry
- Use manual entry as fallback

## Summary

The NIH integration provides:
- 🔍 120,000+ searchable supplements
- 💰 Completely FREE access
- 🚀 Automatic fallback to multiple APIs
- 💾 Local caching for offline use
- ✅ Zero configuration required

Just scan and go!