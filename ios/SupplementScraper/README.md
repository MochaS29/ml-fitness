# Supplement Data Collector

This tool collects supplement information from various public sources to build a comprehensive database for the Health Tracker app.

## Features

- **Legal Data Collection**: Uses only public APIs and respects robots.txt
- **Multiple Sources**:
  - Open Food Facts (free, community-driven)
  - USDA FoodData Central (free with API key)
  - NIH Dietary Supplements database
- **Rate Limiting**: Respects server resources with delays
- **Database Storage**: SQLite database for efficient storage
- **Export Options**: JSON and Swift code generation

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. (Optional) Get free API keys:
   - USDA FoodData Central: https://fdc.nal.usda.gov/api-key-signup
   - Set as environment variable: `export USDA_API_KEY=your_key_here`

## Usage

### Collect Data
```bash
python api_scraper.py
```

This will:
1. Build a database of common supplements
2. Fetch data from Open Food Facts for specific barcodes
3. Export to both JSON and Swift code

### Output Files
- `supplements.db` - SQLite database with all collected data
- `supplements_database.json` - JSON export for app integration
- `SupplementDatabase.swift` - Swift code with embedded data

## Data Sources

### Open Food Facts
- **URL**: https://world.openfoodfacts.org/
- **Coverage**: Growing database, community contributions
- **License**: Open Database License (ODbL)
- **Rate Limit**: Be respectful, ~1 request per second

### USDA FoodData Central
- **URL**: https://fdc.nal.usda.gov/
- **Coverage**: Comprehensive US food/supplement database
- **License**: Public domain
- **Rate Limit**: 3,600 requests/hour with API key

### NIH Office of Dietary Supplements
- **URL**: https://ods.od.nih.gov/
- **Coverage**: Educational fact sheets
- **License**: Public domain
- **Use**: Reference information for supplements

## Ethical Considerations

1. **Respect robots.txt**: Always check and comply
2. **Rate limiting**: Minimum 1-2 seconds between requests
3. **User-Agent**: Identify your bot clearly
4. **Terms of Service**: Read and comply with each site's ToS
5. **Caching**: Store data locally to minimize repeated requests

## Integration with iOS App

The generated `SupplementDatabase.swift` file can be directly included in the iOS app:

1. Copy `SupplementDatabase.swift` to your Xcode project
2. Access supplement data:
```swift
if let supplement = SupplementDatabase.shared.lookup(barcode: "733739001801") {
    print(supplement.name)
    print(supplement.nutrients)
}
```

## Adding New Sources

To add a new data source:

1. Create a new fetch method in `SupplementDataCollector`
2. Parse the response into the standard format
3. Add to `main()` function
4. Ensure compliance with the source's terms

## Common Supplement Barcodes for Testing

- Nature Made Vitamin D3: 030768011154
- Centrum Silver: 031604026165
- Garden of Life: 790011040194
- NOW Foods D-3: 733739001801
- One A Day Men's: 016500537618

## Legal Notice

This tool is for educational purposes. Always:
- Respect website terms of service
- Follow robots.txt guidelines
- Use rate limiting
- Give attribution where required
- Consider reaching out to websites before scraping

## Contributing

To add more supplements to the database:
1. Find the barcode (UPC/EAN)
2. Add to `test_barcodes` list in `api_scraper.py`
3. Run the script
4. Verify the data in the database