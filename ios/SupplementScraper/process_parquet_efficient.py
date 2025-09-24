#!/usr/bin/env python3
"""
Efficiently Process Open Food Facts Parquet File for Supplements
Uses chunked reading to handle large files
"""

import pandas as pd
import pyarrow.parquet as pq
import sqlite3
import json
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)


def process_supplements_efficiently(parquet_path: str):
    """Process Open Food Facts parquet file efficiently using pyarrow."""
    
    logger.info(f"Opening parquet file: {parquet_path}")
    
    # Open parquet file with pyarrow for efficient reading
    parquet_file = pq.ParquetFile(parquet_path)
    
    # Get metadata
    metadata = parquet_file.metadata
    logger.info(f"File has {metadata.num_rows:,} rows and {metadata.num_columns} columns")
    
    # Columns we need for supplements (only read what we need)
    columns_needed = [
        'code',  # barcode
        'product_name',
        'brands',
        'categories', 'categories_tags',
        'serving_size',
        'ingredients_text',
        'image_url'
    ]
    
    # Check which columns actually exist
    schema = parquet_file.schema_arrow
    available_columns = [col for col in columns_needed if col in schema.names]
    logger.info(f"Found {len(available_columns)} of {len(columns_needed)} requested columns")
    
    # Initialize database
    db_path = 'off_supplements.db'
    conn = sqlite3.connect(db_path)
    
    # Create tables
    create_tables(conn)
    
    # Process in batches
    batch_size = 100000  # Process 100k rows at a time
    total_supplements = 0
    batch_num = 0
    
    logger.info("Processing file in batches...")
    
    for batch in parquet_file.iter_batches(batch_size=batch_size, columns=available_columns):
        batch_num += 1
        df = batch.to_pandas()
        
        logger.info(f"Processing batch {batch_num} ({len(df):,} rows)...")
        
        # Filter for supplements
        supplements = filter_supplements(df)
        
        if len(supplements) > 0:
            # Save to database
            save_batch_to_db(supplements, conn)
            total_supplements += len(supplements)
            logger.info(f"  Found {len(supplements)} supplements in this batch (total: {total_supplements})")
        
        # Stop after finding enough supplements
        if total_supplements >= 10000:
            logger.info(f"Reached {total_supplements} supplements. Stopping.")
            break
    
    conn.commit()
    conn.close()
    
    logger.info(f"\nProcessing complete! Found {total_supplements:,} total supplements")
    logger.info(f"Database saved to: {db_path}")
    
    return total_supplements


def filter_supplements(df):
    """Filter dataframe for supplement products."""

    supplement_keywords = [
        'supplement', 'vitamin', 'mineral', 'multivitamin',
        'omega-3', 'omega-6', 'probiotic', 'protein powder',
        'collagen', 'biotin', 'calcium', 'iron', 'zinc',
        'magnesium', 'fish oil', 'cod liver', 'glucosamine',
        'coq10', 'melatonin', 'dietary supplement'
    ]

    # Create filter mask
    mask = pd.Series([False] * len(df))

    # Check categories
    if 'categories' in df.columns:
        for keyword in supplement_keywords:
            mask |= df['categories'].str.contains(keyword, case=False, na=False)

    # Check categories_tags
    if 'categories_tags' in df.columns:
        for keyword in supplement_keywords:
            mask |= df['categories_tags'].str.contains(keyword, case=False, na=False)

    # Check product names
    if 'product_name' in df.columns:
        for keyword in supplement_keywords:
            mask |= df['product_name'].str.contains(keyword, case=False, na=False)

    return df[mask].copy()


def create_tables(conn):
    """Create database tables."""

    conn.execute('''
        CREATE TABLE IF NOT EXISTS supplements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode TEXT,
            name TEXT,
            brand TEXT,
            category TEXT,
            categories_tags TEXT,
            serving_size TEXT,
            ingredients TEXT,
            image_url TEXT,
            data_source TEXT DEFAULT 'Open Food Facts'
        )
    ''')
    
    conn.execute('CREATE INDEX IF NOT EXISTS idx_barcode ON supplements(barcode)')
    conn.execute('CREATE INDEX IF NOT EXISTS idx_name ON supplements(name)')


def save_batch_to_db(df, conn):
    """Save a batch of supplements to the database."""

    # Prepare data for insertion
    for idx, row in df.iterrows():
        try:
            # Get product name (handle numpy array with JSON format)
            import numpy as np
            name_field = row.get('product_name', '')
            name = ''

            # Handle numpy arrays
            if isinstance(name_field, (list, np.ndarray)) and len(name_field) > 0:
                # Extract text from language array
                for item in name_field:
                    if isinstance(item, dict) and 'text' in item:
                        name = item['text']
                        if item.get('lang') == 'en':
                            break  # Prefer English
            elif isinstance(name_field, str):
                name = name_field
            else:
                # Try converting to string
                try:
                    name_str = str(name_field)
                    if name_str and name_str != 'nan' and name_str != '[]':
                        name = name_str
                except:
                    pass

            if not name or name == 'nan' or name == '[]' or name == '':
                continue

            # Prepare data
            data = {
                'barcode': str(row.get('code', '')),
                'name': name,
                'brand': row.get('brands', ''),
                'category': row.get('categories', ''),
                'categories_tags': row.get('categories_tags', ''),
                'serving_size': row.get('serving_size', ''),
                'ingredients': row.get('ingredients_text', ''),
                'image_url': row.get('image_url', ''),
            }

            # Insert into database
            conn.execute('''
                INSERT INTO supplements
                (barcode, name, brand, category, categories_tags, serving_size, ingredients, image_url)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                data['barcode'], data['name'], data['brand'], data['category'],
                data['categories_tags'], data['serving_size'], data['ingredients'], data['image_url']
            ))

        except Exception as e:
            logger.debug(f"Error inserting row: {e}")
            continue


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
    
    # Total count
    cursor.execute("SELECT COUNT(*) FROM supplements")
    total = cursor.fetchone()[0]
    print(f"\n📊 Total supplements: {total:,}")
    
    # Top brands
    cursor.execute("""
        SELECT brand, COUNT(*) as count
        FROM supplements
        WHERE brand IS NOT NULL AND brand != ''
        GROUP BY brand
        ORDER BY count DESC
        LIMIT 10
    """)
    
    print("\n🏢 Top 10 Brands:")
    for brand, count in cursor.fetchall():
        print(f"  {brand}: {count} products")
    
    # Category distribution
    cursor.execute("""
        SELECT categories_tags, COUNT(*) as count
        FROM supplements
        WHERE categories_tags IS NOT NULL AND categories_tags != ''
        GROUP BY categories_tags
        ORDER BY count DESC
        LIMIT 5
    """)
    
    print("\n📂 Top 5 Categories:")
    for tags, count in cursor.fetchall():
        if tags:
            # Show first category tag
            first_tag = tags.split(',')[0] if ',' in tags else tags
            print(f"  {first_tag}: {count} products")
    
    # Sample products
    cursor.execute("""
        SELECT name, brand, barcode
        FROM supplements
        WHERE name IS NOT NULL
        ORDER BY RANDOM()
        LIMIT 5
    """)
    
    print("\n🎲 Random Sample Products:")
    for name, brand, barcode in cursor.fetchall():
        print(f"  {name[:50]} - {brand} ({barcode})")
    
    conn.close()


if __name__ == "__main__":
    parquet_file = "/Users/mocha/Downloads/food.parquet"
    
    if Path(parquet_file).exists():
        logger.info("Starting efficient supplement extraction...")
        total = process_supplements_efficiently(parquet_file)
        
        # Analyze the results
        analyze_database()
    else:
        logger.error(f"File not found: {parquet_file}")