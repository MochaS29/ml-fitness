#!/usr/bin/env python3
"""
Process Open Food Facts Parquet File for Supplements
Extracts supplement data and saves to SQLite for iOS app
"""

import pandas as pd
import sqlite3
import json
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)


def process_supplements_from_parquet(parquet_path: str):
    """Process Open Food Facts parquet file and extract supplements."""

    logger.info(f"Loading parquet file: {parquet_path}")

    # Columns we need for supplements
    columns_to_read = [
        'code',  # barcode
        'product_name_en', 'product_name',
        'brands',
        'categories_en', 'categories_tags',
        'serving_size',
        'ingredients_text_en', 'ingredients_text',
        'image_url',
        'countries_en',
        # Nutrients (per 100g)
        'energy_100g', 'energy-kcal_100g',
        'proteins_100g',
        'carbohydrates_100g',
        'sugars_100g',
        'fat_100g',
        'saturated-fat_100g',
        'fiber_100g',
        'sodium_100g',
        'salt_100g',
        # Vitamins
        'vitamin-a_100g',
        'vitamin-d_100g',
        'vitamin-e_100g',
        'vitamin-k_100g',
        'vitamin-c_100g',
        'vitamin-b1_100g', 'thiamin_100g',
        'vitamin-b2_100g', 'riboflavin_100g',
        'vitamin-b3_100g', 'niacin_100g',
        'vitamin-b6_100g',
        'vitamin-b9_100g', 'folates_100g',
        'vitamin-b12_100g',
        'biotin_100g',
        'pantothenic-acid_100g', 'vitamin-b5_100g',
        # Minerals
        'calcium_100g',
        'iron_100g',
        'magnesium_100g',
        'zinc_100g',
        'iodine_100g',
        'selenium_100g',
        'copper_100g',
        'manganese_100g',
        'phosphorus_100g',
        'potassium_100g',
        'chloride_100g',
        'chromium_100g',
        # Other nutrients
        'omega-3-fatty-acids_100g',
        'omega-6-fatty-acids_100g',
        'omega-9-fatty-acids_100g',
        'trans-fat_100g',
        'cholesterol_100g',
        'caffeine_100g',
        'taurine_100g',
        'alcohol_100g',
        'collagen_100g',
    ]

    # Read parquet file - only columns that exist
    logger.info("Reading parquet file...")
    df = pd.read_parquet(parquet_path)

    # Check which columns actually exist
    available_columns = [col for col in columns_to_read if col in df.columns]
    logger.info(f"Found {len(available_columns)} of {len(columns_to_read)} requested columns")

    # Read only available columns
    df = df[available_columns]

    logger.info(f"Total products in file: {len(df):,}")

    # Filter for supplements
    logger.info("Filtering for supplements...")

    # Create filter for supplements based on categories
    supplement_keywords = [
        'supplement', 'vitamin', 'mineral', 'multivitamin',
        'omega-3', 'omega-6', 'probiotic', 'protein powder',
        'collagen', 'biotin', 'calcium', 'iron', 'zinc',
        'magnesium', 'fish oil', 'cod liver', 'glucosamine',
        'chondroitin', 'coq10', 'coenzyme', 'melatonin',
        'ashwagandha', 'turmeric', 'curcumin', 'elderberry',
        'echinacea', 'ginseng', 'ginkgo', 'st john',
        'dietary supplement', 'nutritional supplement',
        'food supplement', 'herbal supplement'
    ]

    # Check both categories and product name
    categories_mask = pd.Series([False] * len(df))
    if 'categories_en' in df.columns:
        for keyword in supplement_keywords:
            categories_mask |= df['categories_en'].str.contains(keyword, case=False, na=False)

    if 'categories_tags' in df.columns:
        for keyword in supplement_keywords:
            categories_mask |= df['categories_tags'].str.contains(keyword, case=False, na=False)

    name_mask = pd.Series([False] * len(df))
    if 'product_name_en' in df.columns:
        for keyword in supplement_keywords:
            name_mask |= df['product_name_en'].str.contains(keyword, case=False, na=False)
    elif 'product_name' in df.columns:
        for keyword in supplement_keywords:
            name_mask |= df['product_name'].str.contains(keyword, case=False, na=False)

    # Combine filters
    supplements_df = df[categories_mask | name_mask].copy()

    logger.info(f"Found {len(supplements_df):,} supplement products")

    # Clean and prepare data
    logger.info("Cleaning supplement data...")

    # Get product name (prefer English)
    if 'product_name_en' in supplements_df.columns:
        supplements_df['name'] = supplements_df['product_name_en'].fillna(supplements_df.get('product_name', ''))
    else:
        supplements_df['name'] = supplements_df.get('product_name', '')

    # Get ingredients (prefer English)
    if 'ingredients_text_en' in supplements_df.columns:
        supplements_df['ingredients'] = supplements_df['ingredients_text_en'].fillna(supplements_df.get('ingredients_text', ''))
    else:
        supplements_df['ingredients'] = supplements_df.get('ingredients_text', '')

    # Rename columns for database
    column_mapping = {
        'code': 'barcode',
        'brands': 'brand',
        'categories_en': 'category',
        'image_url': 'image_url',
        'serving_size': 'serving_size',
        'countries_en': 'countries'
    }

    for old_col, new_col in column_mapping.items():
        if old_col in supplements_df.columns:
            supplements_df[new_col] = supplements_df[old_col]

    # Save to SQLite
    save_to_database(supplements_df)

    # Also save a sample to JSON for review
    save_sample_json(supplements_df)

    return supplements_df


def save_to_database(df):
    """Save supplements to SQLite database."""

    db_path = 'off_supplements.db'
    logger.info(f"Saving {len(df)} supplements to {db_path}")

    conn = sqlite3.connect(db_path)

    try:
        # Create main supplements table
        conn.execute('''
            CREATE TABLE IF NOT EXISTS supplements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                barcode TEXT UNIQUE,
                name TEXT,
                brand TEXT,
                category TEXT,
                serving_size TEXT,
                ingredients TEXT,
                image_url TEXT,
                countries TEXT,
                data_source TEXT DEFAULT 'Open Food Facts'
            )
        ''')

        # Create nutrients table
        conn.execute('''
            CREATE TABLE IF NOT EXISTS nutrients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                barcode TEXT,
                nutrient_name TEXT,
                amount_per_100g REAL,
                unit TEXT,
                FOREIGN KEY (barcode) REFERENCES supplements(barcode)
            )
        ''')

        # Insert supplements
        supplements_data = df[['barcode', 'name', 'brand', 'category',
                               'serving_size', 'ingredients', 'image_url', 'countries']].copy()
        supplements_data = supplements_data.dropna(subset=['barcode', 'name'])

        supplements_data.to_sql('supplements', conn, if_exists='replace', index=False)

        # Process and insert nutrients
        logger.info("Processing nutrients...")

        nutrient_columns = [col for col in df.columns if col.endswith('_100g')]
        nutrient_mapping = {
            'vitamin-a_100g': ('Vitamin A', 'µg'),
            'vitamin-d_100g': ('Vitamin D', 'µg'),
            'vitamin-e_100g': ('Vitamin E', 'mg'),
            'vitamin-k_100g': ('Vitamin K', 'µg'),
            'vitamin-c_100g': ('Vitamin C', 'mg'),
            'vitamin-b1_100g': ('Thiamine (B1)', 'mg'),
            'vitamin-b2_100g': ('Riboflavin (B2)', 'mg'),
            'vitamin-b3_100g': ('Niacin (B3)', 'mg'),
            'vitamin-b6_100g': ('Vitamin B6', 'mg'),
            'vitamin-b9_100g': ('Folate (B9)', 'µg'),
            'vitamin-b12_100g': ('Vitamin B12', 'µg'),
            'calcium_100g': ('Calcium', 'mg'),
            'iron_100g': ('Iron', 'mg'),
            'magnesium_100g': ('Magnesium', 'mg'),
            'zinc_100g': ('Zinc', 'mg'),
            'omega-3-fatty-acids_100g': ('Omega-3', 'mg'),
            'proteins_100g': ('Protein', 'g'),
            'carbohydrates_100g': ('Carbohydrates', 'g'),
            'fat_100g': ('Total Fat', 'g'),
            'fiber_100g': ('Fiber', 'g'),
            'sugars_100g': ('Sugar', 'g'),
            'sodium_100g': ('Sodium', 'mg'),
        }

        nutrients_data = []
        for idx, row in df.iterrows():
            barcode = row.get('barcode')
            if pd.isna(barcode):
                continue

            for nutrient_col in nutrient_columns:
                if nutrient_col in row and pd.notna(row[nutrient_col]):
                    if nutrient_col in nutrient_mapping:
                        name, unit = nutrient_mapping[nutrient_col]
                    else:
                        # Clean up column name
                        name = nutrient_col.replace('_100g', '').replace('-', ' ').title()
                        unit = 'mg'  # default unit

                    nutrients_data.append({
                        'barcode': barcode,
                        'nutrient_name': name,
                        'amount_per_100g': float(row[nutrient_col]),
                        'unit': unit
                    })

        if nutrients_data:
            nutrients_df = pd.DataFrame(nutrients_data)
            nutrients_df.to_sql('nutrients', conn, if_exists='replace', index=False)
            logger.info(f"Saved {len(nutrients_df)} nutrient entries")

        conn.commit()
        logger.info(f"Database saved successfully: {db_path}")

        # Print statistics
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(DISTINCT barcode) FROM supplements")
        unique_products = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM nutrients")
        total_nutrients = cursor.fetchone()[0]

        logger.info(f"Summary: {unique_products} unique products, {total_nutrients} nutrient entries")

    except Exception as e:
        logger.error(f"Database error: {e}")
    finally:
        conn.close()


def save_sample_json(df):
    """Save a sample of supplements to JSON for review."""

    # Get top 100 supplements with most nutrient data
    nutrient_cols = [col for col in df.columns if col.endswith('_100g')]
    df['nutrient_count'] = df[nutrient_cols].notna().sum(axis=1)

    top_supplements = df.nlargest(100, 'nutrient_count')

    # Convert to list of dicts
    supplements_list = []
    for idx, row in top_supplements.iterrows():
        supplement = {
            'barcode': row.get('barcode'),
            'name': row.get('name'),
            'brand': row.get('brand'),
            'category': row.get('category'),
            'nutrients': {}
        }

        # Add nutrients
        for col in nutrient_cols:
            if pd.notna(row[col]):
                nutrient_name = col.replace('_100g', '').replace('-', '_')
                supplement['nutrients'][nutrient_name] = float(row[col])

        supplements_list.append(supplement)

    # Save to JSON
    with open('off_supplements_sample.json', 'w') as f:
        json.dump(supplements_list, f, indent=2)

    logger.info("Sample saved to off_supplements_sample.json")


def analyze_database():
    """Analyze the created database."""

    db_path = 'off_supplements.db'

    if not Path(db_path).exists():
        logger.error(f"Database {db_path} not found")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print("\n" + "="*60)
    print("DATABASE ANALYSIS")
    print("="*60)

    # Product counts by brand
    cursor.execute("""
        SELECT brand, COUNT(*) as count
        FROM supplements
        WHERE brand IS NOT NULL
        GROUP BY brand
        ORDER BY count DESC
        LIMIT 20
    """)

    print("\n📊 Top 20 Brands:")
    for brand, count in cursor.fetchall():
        print(f"  {brand}: {count} products")

    # Most common nutrients
    cursor.execute("""
        SELECT nutrient_name, COUNT(DISTINCT barcode) as product_count
        FROM nutrients
        GROUP BY nutrient_name
        ORDER BY product_count DESC
        LIMIT 20
    """)

    print("\n💊 Most Common Nutrients:")
    for nutrient, count in cursor.fetchall():
        print(f"  {nutrient}: {count} products")

    # Sample products
    cursor.execute("""
        SELECT s.name, s.brand, COUNT(n.nutrient_name) as nutrient_count
        FROM supplements s
        LEFT JOIN nutrients n ON s.barcode = n.barcode
        WHERE s.name IS NOT NULL
        GROUP BY s.barcode
        ORDER BY nutrient_count DESC
        LIMIT 10
    """)

    print("\n🏆 Products with Most Nutrient Data:")
    for name, brand, count in cursor.fetchall():
        print(f"  {name} ({brand}): {count} nutrients")

    conn.close()


if __name__ == "__main__":
    parquet_file = "/Users/mocha/Downloads/food.parquet"

    if Path(parquet_file).exists():
        logger.info("Starting supplement extraction from Open Food Facts...")
        df = process_supplements_from_parquet(parquet_file)
        logger.info("Processing complete!")

        # Analyze the results
        analyze_database()
    else:
        logger.error(f"File not found: {parquet_file}")
        logger.info("Please ensure the parquet file is in /Users/mocha/Downloads/")