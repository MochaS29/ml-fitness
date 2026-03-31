#!/usr/bin/env python3
"""
Build a local food SQLite database from USDA FoodData Central CSV exports.

Downloads and processes:
- Foundation Foods
- SR Legacy
- FNDDS (Survey Foods)
- Branded Foods (filtered to top ~100 brand owners)

Output: food_database.sqlite (~10-15 MB) with FTS5 full-text search index.

Usage:
    python3 build_food_database.py

The script will download USDA CSV files to a 'usda_data/' subdirectory,
then build the SQLite database in the current directory.
"""

import csv
import io
import os
import re
import sqlite3
import sys
import zipfile
from collections import defaultdict
from pathlib import Path
from typing import Optional

try:
    import requests
except ImportError:
    print("Installing requests...")
    os.system(f"{sys.executable} -m pip install requests")
    import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DATA_DIR = Path(__file__).parent / "usda_data"
OUTPUT_DB = Path(__file__).parent / "food_database.sqlite"

# USDA FoodData Central CSV download URLs
# https://fdc.nal.usda.gov/download-datasets/
USDA_DOWNLOADS = {
    "foundation": "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_foundation_food_csv_2025-12-18.zip",
    "sr_legacy": "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_2018-04.zip",
    "survey": "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_survey_food_csv_2024-10-31.zip",
    "branded": "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_branded_food_csv_2025-12-18.zip",
}

# Nutrient IDs from USDA (used in food_nutrient.csv)
NUTRIENT_IDS = {
    1008: "calories",       # Energy (kcal)
    1003: "protein",        # Protein (g)
    1005: "carbs",          # Carbohydrate, by difference (g)
    1004: "fat",            # Total lipid (fat) (g)
    1079: "fiber",          # Fiber, total dietary (g)
    2000: "sugar",          # Sugars, total including NLEA (g)
    1063: "sugar_alt",      # Sugars, total (g) — fallback
    1093: "sodium",         # Sodium, Na (mg)
    1253: "cholesterol",    # Cholesterol (mg)
    1258: "saturatedFat",   # Fatty acids, total saturated (g)
}

# Top brand owners to include from Branded Foods
# This keeps the database manageable while covering most popular items
TOP_BRAND_OWNERS = {
    # Fast Food / Restaurants
    "McDonald's Corporation", "McDonald's", "Starbucks", "Starbucks Coffee Company",
    "Subway", "Chick-fil-A, Inc.", "Chick-fil-A", "Taco Bell Corp.", "Taco Bell",
    "Wendy's International, Inc.", "Wendy's", "Burger King", "Domino's",
    "Pizza Hut", "KFC", "Chipotle Mexican Grill", "Panera Bread",
    "Dunkin' Donuts", "Dunkin'", "Popeyes Louisiana Kitchen",
    "Arby's Restaurant Group, Inc.", "Jack in the Box Inc.",
    "Papa John's International", "Little Caesars", "Sonic Drive-In",
    "Wingstop Restaurants Inc.", "Five Guys", "Panda Express",
    "Raising Cane's", "Whataburger",

    # Beverages
    "The Coca-Cola Company", "Coca-Cola", "PepsiCo, Inc.", "PepsiCo",
    "Red Bull", "Red Bull GmbH", "Monster Beverage Corporation", "Monster",
    "Gatorade", "Starbucks Corporation", "Nestle Waters",
    "Keurig Dr Pepper", "Dr Pepper", "Celsius Holdings, Inc.",
    "BODYARMOR", "Bai Brands LLC", "Vita Coco",

    # Dairy & Yogurt
    "Chobani, LLC", "Chobani", "Dannon", "The Dannon Company, Inc.",
    "Oikos", "Fage", "Siggi's", "Yoplait",
    "Organic Valley", "Horizon Organic", "Fairlife, LLC",
    "Tillamook County Creamery Association",

    # Cereal & Breakfast
    "General Mills, Inc.", "General Mills", "Kellogg Company", "Kellogg's",
    "Post Holdings, Inc.", "Post", "Quaker Oats Company", "Quaker",
    "Nature's Path Foods",

    # Snacks & Chips
    "Frito-Lay", "Frito-Lay, Inc.", "Lay's",
    "Doritos", "Cheetos", "KIND LLC", "KIND",
    "RXBAR", "Clif Bar & Company", "Clif", "LARABAR",
    "Nature Valley", "Wonderful Company", "Blue Diamond Growers",
    "Planters", "Skinny Pop",

    # Bread & Baked
    "Dave's Killer Bread", "Sara Lee", "Arnold", "Thomas'",
    "Pepperidge Farm", "Nature's Own", "Wonder",

    # Meat & Protein
    "Tyson Foods, Inc.", "Tyson", "Perdue Farms",
    "Hormel Foods Corporation", "Hormel", "Oscar Mayer",
    "Jennie-O Turkey Store", "Applegate",
    "Beyond Meat, Inc.", "Impossible Foods Inc.",

    # Frozen Foods
    "Nestlé", "Nestle", "Nestlé USA", "Amy's Kitchen",
    "Birds Eye", "Stouffer's", "Lean Cuisine",
    "Trader Joe's", "Trader Joe's Company, Inc.",
    "Annie's Homegrown",

    # Condiments & Sauces
    "The Kraft Heinz Company", "Kraft Heinz", "Kraft",
    "Heinz", "Hellmann's", "Hidden Valley",
    "Frank's RedHot", "Sriracha", "Huy Fong Foods",
    "Newman's Own",

    # Health & Nutrition
    "Orgain", "Garden of Life", "Premier Protein",
    "Optimum Nutrition", "Muscle Milk", "Ensure",
    "Soylent", "Huel",

    # Grocery
    "Campbell Soup Company", "Campbell's",
    "ConAgra Brands, Inc.", "Conagra",
    "Del Monte Foods, Inc.", "Dole Food Company",
    "Green Giant", "Barilla",
    "Mission Foods", "Old El Paso",
    "Ben & Jerry's", "Haagen-Dazs",
    "Oatly", "Silk", "Almond Breeze",

    # Canadian / International
    "President's Choice", "No Name", "Great Value",
    "Kirkland Signature",
}

# Normalize brand names for matching (lowercase, stripped)
TOP_BRANDS_LOWER = {b.lower().strip() for b in TOP_BRAND_OWNERS}

# Common food terms for the isCommon flag
COMMON_FOOD_TERMS = {
    "apple", "banana", "orange", "chicken breast", "rice", "eggs", "egg",
    "milk", "bread", "yogurt", "cheese", "salmon", "broccoli", "potato",
    "pasta", "oatmeal", "avocado", "spinach", "tomato", "coffee",
    "peanut butter", "almonds", "steak", "ground beef", "turkey",
    "tuna", "shrimp", "tofu", "beans", "lentils", "quinoa",
    "butter", "olive oil", "honey", "pizza", "hamburger", "french fries",
    "ice cream", "cookie", "chocolate", "cereal", "granola",
    "bacon", "sausage", "ham", "salad", "soup", "sandwich",
    "pancake", "waffle", "bagel", "muffin", "croissant",
    "orange juice", "latte", "cappuccino", "smoothie",
    "protein shake", "protein bar", "greek yogurt",
    "sweet potato", "corn", "carrot", "lettuce", "cucumber",
    "strawberries", "blueberries", "grapes", "watermelon", "mango",
    "pineapple", "peach", "pear", "cherry", "raspberry",
    "flat white", "espresso", "americano", "mocha",
}


def is_common_food(name: str) -> bool:
    """Check if a food name matches common food terms."""
    name_lower = name.lower()
    for term in COMMON_FOOD_TERMS:
        if term in name_lower:
            return True
    return False


def is_top_brand(brand_owner: str) -> bool:
    """Check if a brand owner is in our top brands list."""
    if not brand_owner:
        return False
    return brand_owner.lower().strip() in TOP_BRANDS_LOWER


def clean_food_name(name: str) -> str:
    """Clean up a USDA food description into a more readable name."""
    if not name:
        return name
    # Remove USDA style suffixes like ", NFS" or ", raw"
    # But keep useful descriptors
    name = name.strip()
    # Title case if all uppercase
    if name == name.upper() and len(name) > 3:
        name = name.title()
    return name


def download_and_extract(data_type: str, url: str) -> Path:
    """Download a USDA CSV zip file and extract it."""
    extract_dir = DATA_DIR / data_type
    if extract_dir.exists() and any(extract_dir.glob("*.csv")):
        print(f"  [{data_type}] Already downloaded, skipping.")
        return extract_dir

    zip_path = DATA_DIR / f"{data_type}.zip"

    if not zip_path.exists():
        print(f"  [{data_type}] Downloading from USDA...")
        try:
            resp = requests.get(url, stream=True, timeout=300)
            resp.raise_for_status()
            total = int(resp.headers.get("content-length", 0))
            downloaded = 0
            with open(zip_path, "wb") as f:
                for chunk in resp.iter_content(chunk_size=1024 * 1024):
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total > 0:
                        pct = downloaded * 100 // total
                        print(f"\r  [{data_type}] {pct}% ({downloaded // (1024*1024)} MB)", end="", flush=True)
            print()
        except Exception as e:
            print(f"\n  [{data_type}] Download failed: {e}")
            if zip_path.exists():
                zip_path.unlink()
            return extract_dir

    print(f"  [{data_type}] Extracting...")
    extract_dir.mkdir(parents=True, exist_ok=True)
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(extract_dir)
    except zipfile.BadZipFile:
        print(f"  [{data_type}] Bad zip file, re-downloading...")
        zip_path.unlink()
        return download_and_extract(data_type, url)

    return extract_dir


def find_csv(base_dir: Path, filename: str) -> Optional[Path]:
    """Find a CSV file recursively in extracted directory."""
    for path in base_dir.rglob(filename):
        return path
    return None


def load_nutrients(base_dir: Path) -> dict:
    """Load nutrient data from food_nutrient.csv. Returns {fdc_id: {nutrient_name: value}}."""
    csv_path = find_csv(base_dir, "food_nutrient.csv")
    if not csv_path:
        print(f"  Warning: food_nutrient.csv not found in {base_dir}")
        return {}

    nutrients = defaultdict(dict)
    with open(csv_path, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                nutrient_id = int(row.get("nutrient_id", 0))
                if nutrient_id in NUTRIENT_IDS:
                    fdc_id = int(row["fdc_id"])
                    value = float(row.get("amount", 0) or 0)
                    key = NUTRIENT_IDS[nutrient_id]
                    nutrients[fdc_id][key] = value
            except (ValueError, KeyError):
                continue

    return dict(nutrients)


def load_food_portions(base_dir: Path) -> dict:
    """Load serving size data from food_portion.csv. Returns {fdc_id: (size, unit)}."""
    csv_path = find_csv(base_dir, "food_portion.csv")
    if not csv_path:
        return {}

    portions = {}
    with open(csv_path, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                fdc_id = int(row["fdc_id"])
                if fdc_id in portions:
                    continue  # Keep first portion (usually the most standard)
                amount = row.get("amount", "1") or "1"
                unit = row.get("modifier", "") or row.get("measure_unit_id", "")
                gram_weight = float(row.get("gram_weight", 0) or 0)
                if gram_weight > 0:
                    portions[fdc_id] = (str(amount), f"{unit} ({int(gram_weight)}g)" if unit else f"{int(gram_weight)}g")
            except (ValueError, KeyError):
                continue

    return portions


def categorize_food(name: str, food_category: str = "") -> str:
    """Assign a FoodCategory based on food name and USDA category."""
    name_lower = name.lower()
    cat_lower = food_category.lower() if food_category else ""

    # Check category first
    if any(t in cat_lower for t in ["fruit", "berry", "citrus"]):
        return "Fruits"
    if any(t in cat_lower for t in ["vegetable", "legume"]):
        return "Vegetables"
    if any(t in cat_lower for t in ["grain", "cereal", "bread", "baked", "pasta"]):
        return "Grains & Cereals"
    if any(t in cat_lower for t in ["meat", "poultry", "fish", "seafood", "egg", "nut", "seed"]):
        return "Protein Foods"
    if any(t in cat_lower for t in ["dairy", "milk", "cheese", "yogurt", "cream"]):
        return "Dairy"
    if any(t in cat_lower for t in ["beverage", "drink", "water", "juice", "coffee", "tea"]):
        return "Beverages"
    if any(t in cat_lower for t in ["snack", "chip", "cracker", "pretzel", "popcorn"]):
        return "Snacks"
    if any(t in cat_lower for t in ["dessert", "candy", "chocolate", "cookie", "cake", "ice cream"]):
        return "Desserts"
    if any(t in cat_lower for t in ["fast food", "restaurant"]):
        return "Fast Food"
    if any(t in cat_lower for t in ["sauce", "condiment", "dressing", "spice", "seasoning"]):
        return "Condiments & Sauces"
    if any(t in cat_lower for t in ["oil", "fat", "butter", "margarine"]):
        return "Oils & Fats"

    # Fallback: check name
    if any(t in name_lower for t in ["apple", "banana", "orange", "berry", "fruit", "grape", "melon", "peach", "pear", "mango", "pineapple", "cherry", "plum", "lemon", "lime", "kiwi"]):
        return "Fruits"
    if any(t in name_lower for t in ["broccoli", "carrot", "spinach", "tomato", "potato", "lettuce", "cabbage", "celery", "pepper", "onion", "corn", "pea", "bean", "vegetable"]):
        return "Vegetables"
    if any(t in name_lower for t in ["rice", "bread", "pasta", "noodle", "oat", "cereal", "wheat", "flour", "tortilla", "bagel", "muffin", "pancake", "waffle"]):
        return "Grains & Cereals"
    if any(t in name_lower for t in ["chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp", "turkey", "egg", "tofu", "lamb", "steak"]):
        return "Protein Foods"
    if any(t in name_lower for t in ["milk", "cheese", "yogurt", "cream", "butter"]):
        return "Dairy"
    if any(t in name_lower for t in ["coffee", "tea", "juice", "soda", "water", "drink", "latte", "espresso", "smoothie", "shake"]):
        return "Beverages"
    if any(t in name_lower for t in ["pizza", "burger", "sandwich", "taco", "burrito", "fries", "hot dog", "wrap", "sub "]):
        return "Fast Food"
    if any(t in name_lower for t in ["cookie", "cake", "ice cream", "chocolate", "candy", "brownie", "pie", "donut", "pastry"]):
        return "Desserts"
    if any(t in name_lower for t in ["chip", "pretzel", "popcorn", "cracker", "granola bar", "protein bar", "trail mix", "nuts"]):
        return "Snacks"
    if any(t in name_lower for t in ["sauce", "ketchup", "mustard", "dressing", "mayo", "salsa", "syrup", "honey", "jam"]):
        return "Condiments & Sauces"
    if any(t in name_lower for t in ["oil", "lard", "shortening"]):
        return "Oils & Fats"

    return "Other"


def process_foundation_and_legacy(data_type: str, base_dir: Path) -> list:
    """Process Foundation Foods or SR Legacy data."""
    food_csv = find_csv(base_dir, "food.csv")
    if not food_csv:
        print(f"  [{data_type}] food.csv not found!")
        return []

    print(f"  [{data_type}] Loading nutrients...")
    nutrients = load_nutrients(base_dir)
    portions = load_food_portions(base_dir)

    # Load food categories
    category_map = {}
    cat_csv = find_csv(base_dir, "food_category.csv")
    if cat_csv:
        with open(cat_csv, "r", encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                try:
                    category_map[int(row["id"])] = row.get("description", "")
                except (ValueError, KeyError):
                    continue

    foods = []
    print(f"  [{data_type}] Processing foods...")
    with open(food_csv, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                fdc_id = int(row["fdc_id"])
                name = clean_food_name(row.get("description", ""))
                if not name:
                    continue

                nutr = nutrients.get(fdc_id, {})
                calories = nutr.get("calories", 0)

                # Skip entries with no calorie data (likely incomplete)
                if calories == 0 and not any(nutr.get(k, 0) > 0 for k in ["protein", "carbs", "fat"]):
                    continue

                cat_id = int(row.get("food_category_id", 0) or 0)
                food_category = category_map.get(cat_id, "")

                portion = portions.get(fdc_id, ("100", "g"))

                sugar = nutr.get("sugar", nutr.get("sugar_alt"))

                foods.append({
                    "fdcId": fdc_id,
                    "name": name,
                    "brand": None,
                    "category": categorize_food(name, food_category),
                    "servingSize": portion[0],
                    "servingUnit": portion[1],
                    "calories": calories,
                    "protein": nutr.get("protein", 0),
                    "carbs": nutr.get("carbs", 0),
                    "fat": nutr.get("fat", 0),
                    "fiber": nutr.get("fiber", 0),
                    "sugar": sugar,
                    "sodium": nutr.get("sodium", 0),
                    "cholesterol": nutr.get("cholesterol"),
                    "saturatedFat": nutr.get("saturatedFat"),
                    "dataType": data_type,
                    "isCommon": is_common_food(name),
                })
            except (ValueError, KeyError):
                continue

    print(f"  [{data_type}] Found {len(foods)} foods.")
    return foods


def process_survey(base_dir: Path) -> list:
    """Process FNDDS Survey Foods data."""
    return process_foundation_and_legacy("survey", base_dir)


def process_branded(base_dir: Path) -> list:
    """Process Branded Foods data, filtering to top brand owners."""
    food_csv = find_csv(base_dir, "branded_food.csv")
    main_food_csv = find_csv(base_dir, "food.csv")

    if not food_csv or not main_food_csv:
        print("  [branded] Required CSV files not found!")
        return []

    print("  [branded] Loading nutrients...")
    nutrients = load_nutrients(base_dir)

    # Load main food table for descriptions
    food_names = {}
    with open(main_food_csv, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            try:
                food_names[int(row["fdc_id"])] = row.get("description", "")
            except (ValueError, KeyError):
                continue

    # Process branded foods
    foods = []
    seen = set()  # For deduplication: (name_lower, brand_lower)
    skipped_brands = 0
    total_rows = 0

    print("  [branded] Processing branded foods (filtering to top brands)...")
    with open(food_csv, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            total_rows += 1
            try:
                brand_owner = (row.get("brand_owner", "") or "").strip()
                brand_name = (row.get("brand_name", "") or "").strip()

                # Filter to top brands
                if not is_top_brand(brand_owner) and not is_top_brand(brand_name):
                    skipped_brands += 1
                    continue

                fdc_id = int(row["fdc_id"])
                name = food_names.get(fdc_id, row.get("description", ""))
                name = clean_food_name(name)
                if not name:
                    continue

                brand = brand_name or brand_owner

                # Deduplicate: keep first occurrence per name+brand
                dedup_key = (name.lower(), brand.lower())
                if dedup_key in seen:
                    continue
                seen.add(dedup_key)

                nutr = nutrients.get(fdc_id, {})
                calories = nutr.get("calories", 0)

                serving_size = row.get("serving_size", "1") or "1"
                serving_unit = row.get("serving_size_unit", "g") or "g"
                household = row.get("household_serving_fulltext", "")

                # Use household serving if available (more user-friendly)
                if household:
                    serving_unit = f"{household} ({serving_size}{serving_unit})"
                    serving_size = "1"

                food_category = row.get("branded_food_category", "")
                sugar = nutr.get("sugar", nutr.get("sugar_alt"))

                foods.append({
                    "fdcId": fdc_id,
                    "name": name,
                    "brand": brand,
                    "category": categorize_food(name, food_category),
                    "servingSize": str(serving_size),
                    "servingUnit": serving_unit,
                    "calories": calories,
                    "protein": nutr.get("protein", 0),
                    "carbs": nutr.get("carbs", 0),
                    "fat": nutr.get("fat", 0),
                    "fiber": nutr.get("fiber", 0),
                    "sugar": sugar,
                    "sodium": nutr.get("sodium", 0),
                    "cholesterol": nutr.get("cholesterol"),
                    "saturatedFat": nutr.get("saturatedFat"),
                    "dataType": "branded",
                    "isCommon": is_common_food(name),
                })
            except (ValueError, KeyError):
                continue

    print(f"  [branded] Processed {total_rows} total rows, kept {len(foods)} from top brands (skipped {skipped_brands}).")
    return foods


def build_database(all_foods: list):
    """Build the SQLite database with FTS5 search index."""
    print(f"\nBuilding SQLite database with {len(all_foods)} foods...")

    if OUTPUT_DB.exists():
        OUTPUT_DB.unlink()

    conn = sqlite3.connect(str(OUTPUT_DB))
    cursor = conn.cursor()

    # Create main foods table
    cursor.execute("""
        CREATE TABLE foods (
            fdcId INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            brand TEXT,
            category TEXT NOT NULL DEFAULT 'Other',
            servingSize TEXT NOT NULL DEFAULT '1',
            servingUnit TEXT NOT NULL DEFAULT 'serving',
            calories REAL NOT NULL DEFAULT 0,
            protein REAL NOT NULL DEFAULT 0,
            carbs REAL NOT NULL DEFAULT 0,
            fat REAL NOT NULL DEFAULT 0,
            fiber REAL NOT NULL DEFAULT 0,
            sugar REAL,
            sodium REAL,
            cholesterol REAL,
            saturatedFat REAL,
            dataType TEXT NOT NULL,
            isCommon INTEGER NOT NULL DEFAULT 0
        )
    """)

    # Insert all foods
    insert_sql = """
        INSERT OR IGNORE INTO foods
        (fdcId, name, brand, category, servingSize, servingUnit,
         calories, protein, carbs, fat, fiber, sugar, sodium,
         cholesterol, saturatedFat, dataType, isCommon)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    rows = []
    for food in all_foods:
        rows.append((
            food["fdcId"],
            food["name"],
            food["brand"],
            food["category"],
            food["servingSize"],
            food["servingUnit"],
            food["calories"],
            food["protein"],
            food["carbs"],
            food["fat"],
            food["fiber"],
            food["sugar"],
            food["sodium"],
            food["cholesterol"],
            food["saturatedFat"],
            food["dataType"],
            1 if food["isCommon"] else 0,
        ))

    cursor.executemany(insert_sql, rows)
    inserted = cursor.rowcount
    print(f"  Inserted {inserted} rows into foods table.")

    # Create indexes for fast lookup
    cursor.execute("CREATE INDEX idx_foods_category ON foods(category)")
    cursor.execute("CREATE INDEX idx_foods_isCommon ON foods(isCommon)")
    cursor.execute("CREATE INDEX idx_foods_dataType ON foods(dataType)")
    cursor.execute("CREATE INDEX idx_foods_brand ON foods(brand)")

    # Create FTS5 full-text search index
    # FTS5 is built into iOS SQLite and handles word-boundary matching natively
    print("  Creating FTS5 full-text search index...")
    cursor.execute("""
        CREATE VIRTUAL TABLE foods_fts USING fts5(
            name,
            brand,
            content='foods',
            content_rowid='fdcId',
            tokenize='unicode61 remove_diacritics 2'
        )
    """)

    # Populate FTS index
    cursor.execute("""
        INSERT INTO foods_fts(rowid, name, brand)
        SELECT fdcId, name, COALESCE(brand, '') FROM foods
    """)

    # Create triggers to keep FTS in sync (for future inserts/updates)
    cursor.execute("""
        CREATE TRIGGER foods_ai AFTER INSERT ON foods BEGIN
            INSERT INTO foods_fts(rowid, name, brand)
            VALUES (new.fdcId, new.name, COALESCE(new.brand, ''));
        END
    """)
    cursor.execute("""
        CREATE TRIGGER foods_ad AFTER DELETE ON foods BEGIN
            INSERT INTO foods_fts(foods_fts, rowid, name, brand)
            VALUES ('delete', old.fdcId, old.name, COALESCE(old.brand, ''));
        END
    """)
    cursor.execute("""
        CREATE TRIGGER foods_au AFTER UPDATE ON foods BEGIN
            INSERT INTO foods_fts(foods_fts, rowid, name, brand)
            VALUES ('delete', old.fdcId, old.name, COALESCE(old.brand, ''));
            INSERT INTO foods_fts(rowid, name, brand)
            VALUES (new.fdcId, new.name, COALESCE(new.brand, ''));
        END
    """)

    conn.commit()

    # Print stats
    cursor.execute("SELECT COUNT(*) FROM foods")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM foods WHERE isCommon = 1")
    common = cursor.fetchone()[0]
    cursor.execute("SELECT dataType, COUNT(*) FROM foods GROUP BY dataType")
    by_type = cursor.fetchall()
    cursor.execute("SELECT COUNT(DISTINCT brand) FROM foods WHERE brand IS NOT NULL")
    brands = cursor.fetchone()[0]

    print(f"\n  Database stats:")
    print(f"    Total foods: {total}")
    print(f"    Common foods: {common}")
    print(f"    Unique brands: {brands}")
    for dt, count in by_type:
        print(f"    {dt}: {count}")

    # Test FTS search
    print("\n  Testing FTS5 search:")
    test_queries = ["latte", "flat white", "chicken breast", "starbucks", "coca cola"]
    for q in test_queries:
        # Use FTS5 prefix matching for partial words
        fts_query = " ".join(f'"{word}"*' for word in q.split())
        cursor.execute("""
            SELECT f.name, f.brand, f.calories
            FROM foods f
            JOIN foods_fts fts ON f.fdcId = fts.rowid
            WHERE foods_fts MATCH ?
            ORDER BY f.isCommon DESC, rank
            LIMIT 3
        """, (fts_query,))
        results = cursor.fetchall()
        if results:
            print(f'    "{q}" -> {results[0][0]}' + (f' ({results[0][1]})' if results[0][1] else '') + f' [{results[0][2]} cal]')
        else:
            print(f'    "{q}" -> No results')

    conn.close()

    size_mb = OUTPUT_DB.stat().st_size / (1024 * 1024)
    print(f"\n  Output: {OUTPUT_DB} ({size_mb:.1f} MB)")


def main():
    print("=" * 60)
    print("USDA FoodData Central -> SQLite Database Builder")
    print("=" * 60)

    DATA_DIR.mkdir(parents=True, exist_ok=True)

    all_foods = []

    # Step 1: Download and process each dataset
    print("\n1. Downloading USDA datasets...")
    for data_type, url in USDA_DOWNLOADS.items():
        base_dir = download_and_extract(data_type, url)

        print(f"\n2. Processing {data_type} foods...")
        if data_type == "branded":
            foods = process_branded(base_dir)
        else:
            foods = process_foundation_and_legacy(data_type, base_dir)

        all_foods.extend(foods)

    # Step 2: Global deduplication
    print(f"\n3. Deduplicating {len(all_foods)} total foods...")
    seen = {}
    unique_foods = []
    for food in all_foods:
        key = food["name"].lower()
        if food["brand"]:
            key += f"|{food['brand'].lower()}"
        if key not in seen:
            seen[key] = food
            unique_foods.append(food)
        else:
            # Prefer branded over generic, newer over older
            existing = seen[key]
            # Prefer entries with more complete nutrition data
            new_score = sum(1 for k in ["calories", "protein", "carbs", "fat", "fiber", "sugar", "sodium"] if food.get(k))
            old_score = sum(1 for k in ["calories", "protein", "carbs", "fat", "fiber", "sugar", "sodium"] if existing.get(k))
            if new_score > old_score:
                idx = unique_foods.index(existing)
                unique_foods[idx] = food
                seen[key] = food

    print(f"  After dedup: {len(unique_foods)} unique foods.")

    # Step 3: Build SQLite database
    build_database(unique_foods)

    print("\nDone! Copy food_database.sqlite to your Xcode project bundle.")


if __name__ == "__main__":
    main()
