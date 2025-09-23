# Legal Guide to Obtaining Supplement Data

## 🟢 100% Legal Data Sources (Ranked by Ease of Use)

### 1. **Open Food Facts** ⭐⭐⭐⭐⭐ (BEST FREE OPTION)
- **Cost**: FREE
- **Coverage**: Growing (community-driven)
- **API**: No key required
- **Rate Limit**: ~1 request/second
- **Implementation**: Already in your app!

```python
# Example usage
import requests
barcode = "031604026165"
url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
response = requests.get(url)
```

**Bonus**: You can download their ENTIRE database:
- CSV: https://world.openfoodfacts.org/category/dietary-supplements.csv
- Full dump: 30GB+ but has everything

### 2. **USDA FoodData Central** ⭐⭐⭐⭐
- **Cost**: FREE
- **Coverage**: Excellent for US products
- **API Key**: Free at https://fdc.nal.usda.gov/api-key-signup.html
- **Rate Limit**: 3,600/hour with key
- **Best For**: Verified nutritional data

```python
# Get your free key, then:
api_key = "YOUR_FREE_KEY"
url = f"https://api.nal.usda.gov/fdc/v1/foods/search?query=vitamin&api_key={api_key}"
```

### 3. **NIH Dietary Supplement Label Database** ⭐⭐⭐⭐
- **Cost**: FREE
- **Coverage**: Comprehensive for US supplements
- **Source**: https://dsld.od.nih.gov/
- **Data**: Actual label information
- **Download**: Full database available as CSV

### 4. **Nutritionix API** ⭐⭐⭐⭐⭐ (BEST PAID OPTION)
- **Cost**: $99/month (10K calls)
- **Coverage**: EXCELLENT - most supplements
- **Quality**: Professional grade
- **Support**: Barcode lookup, nutrients, images
- **Sign Up**: https://www.nutritionix.com/business/api

If budget allows, this is the gold standard.

### 5. **Affiliate/Partner APIs** ⭐⭐⭐
Free with affiliate account:
- **Amazon Product API**: Need affiliate account (free)
- **iHerb Partner API**: Full catalog access
- **Walmart Open API**: Free with registration
- **Vitamin Shoppe**: Partner program available

## 📊 Data Collection Strategy

### Phase 1: Immediate (Today)
1. ✅ Use Open Food Facts API (already implemented)
2. ✅ Use your 55-product local database
3. ✅ Add manual entry for unknowns

### Phase 2: This Week
1. Sign up for free USDA API key
2. Download Open Food Facts supplement CSV
3. Import into your SQLite database

### Phase 3: This Month
1. Implement user submissions for unknown products
2. Add OCR for supplement labels (Vision framework)
3. Consider affiliate program for one retailer

### Phase 4: Growth (If Needed)
1. Subscribe to Nutritionix ($99/month) when you have users
2. Partner with a supplement retailer
3. Build community features

## 🚀 Quick Implementation

### Download Open Food Facts Supplements (Legal & Free)
```bash
# Download all supplements (about 50MB)
curl -o supplements.csv "https://world.openfoodfacts.org/category/dietary-supplements.csv"

# Import to SQLite
sqlite3 supplements.db <<EOF
.mode csv
.import supplements.csv off_supplements
EOF
```

### Get USDA API Key (Free)
1. Go to: https://fdc.nal.usda.gov/api-key-signup.html
2. Fill form (takes 2 minutes)
3. Get key instantly via email
4. Add to your app's environment variables

### OCR Implementation (Extract from photos)
```swift
// Use Vision framework to extract text from supplement labels
import Vision

func extractSupplementInfo(from image: UIImage) {
    let request = VNRecognizeTextRequest { request, error in
        // Extract supplement facts from label
    }
    request.recognitionLevel = .accurate
}
```

## ❌ What NOT to Do

### Illegal/Unethical:
- Scraping Amazon, iHerb, Vitacost without permission
- Using automated bots on retail sites
- Bypassing rate limits
- Ignoring robots.txt
- Violating Terms of Service

### Will Get You Banned:
- Mass scraping retail websites
- Using fake user agents
- Rotating proxies to bypass blocks
- Stealing copyrighted data

## ✅ Recommended Implementation Order

1. **Today**: Use existing Open Food Facts + local database
2. **Tomorrow**: Get USDA API key (free, 5 minutes)
3. **This Week**: Download OFF supplement CSV
4. **Next Week**: Add user submission feature
5. **When You Have 100+ Users**: Consider Nutritionix API
6. **At Scale**: Partner with retailer for data feed

## 💡 Pro Tips

1. **Cache Everything**: Store API responses locally
2. **Fallback Chain**: OFF → USDA → Local → Manual
3. **User Contributions**: Build like Wikipedia
4. **OCR Labels**: Let users photo scan labels
5. **Partnerships**: Reach out to brands directly

## 📞 Direct Contact Options

Many brands will give you data if you ask:
- **Nature Made**: customerservice@naturemade.com
- **NOW Foods**: webmaster@nowfoods.com
- **Garden of Life**: Via website contact form
- **GNC**: Partner program available

Email template:
```
Subject: Data Partnership for Health Tracking App

Hi [Brand],

I'm developing a health tracking app that helps users manage their supplements.
We'd like to include accurate information about your products.

Would you be open to providing:
- Product catalog in CSV/JSON format
- Nutritional information
- Product images

We'll include attribution and could potentially drive sales to your products.

Best regards,
[Your name]
```

## 🎯 Final Recommendation

**For your app right now:**
1. Stick with Open Food Facts (free, legal, working)
2. Add USDA as backup (free, comprehensive)
3. Keep your 55-product database as fallback
4. Add user submission for missing items
5. Consider Nutritionix only if you get serious traction

This approach is 100% legal, cost-effective, and scalable!