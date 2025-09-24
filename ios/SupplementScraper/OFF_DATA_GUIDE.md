# Open Food Facts Data Format Guide

## 🎯 Quick Answer: Use PARQUET Files!

### Why Parquet Over JSON?

| Format | File Size | Load Time | Memory Usage | Best For |
|--------|-----------|-----------|--------------|----------|
| **Parquet** | 2-3 GB | Fast | Low | ✅ Production use |
| JSON | 30 GB | Very Slow | Huge | ❌ Too large |
| CSV | 9 GB | Medium | Medium | 🔶 Okay alternative |

## 📊 Parquet Advantages

1. **90% smaller than JSON** (2GB vs 30GB)
2. **Columnar format** - only load columns you need
3. **Fast filtering** - can filter while reading
4. **Type safe** - preserves data types
5. **Memory efficient** - doesn't load entire file

## 🚀 How to Use Open Food Facts Data

### Option 1: Direct API (For Individual Lookups)
```python
# Best for: Real-time barcode scanning
import requests

barcode = "031604026165"
url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
response = requests.get(url)
product = response.json()
```

### Option 2: Download Parquet (For Bulk Processing)
```bash
# Download supplements subset (~500MB)
wget https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz

# Or full Parquet file (~2-3GB)
wget https://static.openfoodfacts.org/data/openfoodfacts-products.parquet
```

### Option 3: Use Their MongoDB Dump
```bash
# Full database (~40GB compressed)
wget https://static.openfoodfacts.org/data/openfoodfacts-mongodbdump.tar.gz
```

## 📱 For Your iOS App

### Recommended Architecture:

```
1. Server-Side Processing:
   - Download Parquet file monthly
   - Filter for supplements only
   - Convert to SQLite database
   - Upload to your server

2. iOS App:
   - Download SQLite database (~50MB)
   - Use for offline lookups
   - Fall back to API for missing items

3. Data Flow:
   Parquet (2GB) → Filter → SQLite (50MB) → iOS App
```

## 🔍 Working with Parquet Files

### Using Python (pandas/pyarrow):
```python
import pyarrow.parquet as pq

# Read only supplements
parquet_file = pq.ParquetFile('openfoodfacts-products.parquet')

# Read specific columns only (memory efficient)
columns = ['code', 'product_name', 'brands', 'vitamin-d_100g']
df = parquet_file.read(columns=columns).to_pandas()

# Filter for supplements
supplements = df[df['categories_en'].str.contains('supplement', na=False)]
```

### Using DuckDB (SQL on Parquet):
```sql
-- Query Parquet files directly with SQL!
SELECT code, product_name, brands, "vitamin-d_100g"
FROM 'openfoodfacts-products.parquet'
WHERE categories_en LIKE '%supplement%'
LIMIT 1000;
```

## 📈 Data Statistics

- **Total OFF products**: ~2.5 million
- **Supplements**: ~50,000-100,000
- **Update frequency**: Daily
- **Coverage**: Global

## 🛠 Implementation Plan

### Phase 1: Quick Start (Today)
- Use the API for barcode lookups
- Already implemented in your app ✅

### Phase 2: Offline Support (This Week)
1. Download categories CSV:
   ```bash
   curl -o supplements.csv "https://world.openfoodfacts.org/category/dietary-supplements.csv"
   ```
2. Import to SQLite
3. Bundle with app

### Phase 3: Complete Database (Future)
1. Set up monthly Parquet download
2. Process on server
3. Provide SQLite download for app
4. Auto-update mechanism

## 💾 Storage Requirements

### For Processing (Server):
- Parquet file: 2-3GB
- Processing RAM: 4-8GB
- Output SQLite: ~50MB

### For iOS App:
- SQLite database: ~50MB
- Cached images: ~100MB
- Total: ~150MB

## 🔑 Key Takeaways

1. **DON'T use JSON** - too large (30GB)
2. **DO use Parquet** - efficient (2-3GB)
3. **Process server-side** - filter to supplements only
4. **Distribute as SQLite** - perfect for mobile
5. **Cache locally** - for offline support

## 📚 Resources

- **Parquet Downloads**: https://world.openfoodfacts.org/data
- **API Docs**: https://openfoodfacts.github.io/openfoodfacts-server/api/
- **Categories**: https://world.openfoodfacts.org/categories
- **Supplements CSV**: https://world.openfoodfacts.org/category/dietary-supplements.csv

## 🎯 Your Action Items

1. ✅ Keep using API for now (already working)
2. 📥 Download supplements CSV for testing
3. 🔄 Set up monthly Parquet processing (later)
4. 📱 Bundle SQLite with app updates