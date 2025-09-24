#!/usr/bin/env python3
"""
Open Food Facts Parquet File Handler
Efficient way to work with Open Food Facts data
"""

import pandas as pd
import pyarrow.parquet as pq
import sqlite3
import logging
from typing import List, Dict
import requests
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class OpenFoodFactsParquet:
    """Handle Open Food Facts Parquet files efficiently."""

    def __init__(self):
        self.parquet_url = "https://static.openfoodfacts.org/data/openfoodfacts-products.parquet"
        self.local_parquet = "openfoodfacts-products.parquet"

    def download_parquet(self, supplements_only: bool = True):
        """
        Download Open Food Facts Parquet file.
        Note: Full file is ~2-3GB
        """
        if supplements_only:
            # Download smaller supplements subset
            url = "https://static.openfoodfacts.org/data/delta/supplements.parquet"
            filename = "supplements.parquet"
        else:
            url = self.parquet_url
            filename = self.local_parquet

        if os.path.exists(filename):
            logger.info(f"File {filename} already exists")
            return filename

        logger.info(f"Downloading {url}...")
        logger.info("This may take a few minutes...")

        response = requests.get(url, stream=True)
        total_size = int(response.headers.get('content-length', 0))

        with open(filename, 'wb') as file:
            downloaded = 0
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\rProgress: {percent:.1f}%", end='')

        print("\n✅ Download complete!")
        return filename

    def read_supplements_efficiently(self, parquet_file: str = None) -> pd.DataFrame:
        """
        Read only supplement data from Parquet file.
        Much more efficient than loading entire dataset.
        """
        if not parquet_file:
            parquet_file = self.local_parquet

        if not os.path.exists(parquet_file):
            logger.error(f"File {parquet_file} not found. Download it first.")
            return pd.DataFrame()

        logger.info("Reading supplements from Parquet file...")

        # Define columns we actually need (saves memory)
        columns = [
            'code',  # barcode
            'product_name',
            'brands',
            'categories_en',
            'serving_size',
            'ingredients_text',
            'image_url',
            # Nutrient columns
            'energy_100g',
            'proteins_100g',
            'carbohydrates_100g',
            'sugars_100g',
            'fat_100g',
            'saturated-fat_100g',
            'fiber_100g',
            'sodium_100g',
            'vitamin-a_100g',
            'vitamin-c_100g',
            'vitamin-d_100g',
            'vitamin-e_100g',
            'vitamin-k_100g',
            'vitamin-b1_100g',
            'vitamin-b2_100g',
            'vitamin-b3_100g',
            'vitamin-b6_100g',
            'vitamin-b9_100g',
            'vitamin-b12_100g',
            'calcium_100g',
            'iron_100g',
            'magnesium_100g',
            'zinc_100g',
            'iodine_100g',
            'omega-3-fatty-acids_100g',
            'omega-6-fatty-acids_100g'
        ]

        # Read Parquet with filters (pushdown predicate)
        # This reads ONLY supplements, not the entire file!
        filters = [
            ('categories_en', 'contains', 'supplement'),
        ]

        try:
            # Use pyarrow for efficient filtering
            parquet_file = pq.ParquetFile(parquet_file)

            # Read only needed columns with filter
            df = parquet_file.read(
                columns=[col for col in columns if col in parquet_file.schema.names]
            ).to_pandas()

            # Additional filtering in pandas
            supplement_keywords = [
                'supplement', 'vitamin', 'mineral', 'multivitamin',
                'omega', 'probiotic', 'protein powder', 'collagen'
            ]

            # Filter for supplements
            mask = df['categories_en'].str.contains(
                '|'.join(supplement_keywords),
                case=False,
                na=False
            ) | df['product_name'].str.contains(
                '|'.join(supplement_keywords),
                case=False,
                na=False
            )

            supplements_df = df[mask].copy()

            logger.info(f"Found {len(supplements_df)} supplements")
            return supplements_df

        except Exception as e:
            logger.error(f"Error reading Parquet: {e}")
            return pd.DataFrame()

    def search_by_barcode(self, barcode: str, df: pd.DataFrame = None) -> Dict:
        """Search for a product by barcode in the dataframe."""
        if df is None or df.empty:
            return None

        result = df[df['code'] == barcode]

        if not result.empty:
            product = result.iloc[0]
            return self._parse_product(product)

        return None

    def search_by_name(self, query: str, df: pd.DataFrame = None, limit: int = 10) -> List[Dict]:
        """Search products by name."""
        if df is None or df.empty:
            return []

        # Case-insensitive search
        mask = df['product_name'].str.contains(query, case=False, na=False)
        results = df[mask].head(limit)

        return [self._parse_product(row) for _, row in results.iterrows()]

    def _parse_product(self, product) -> Dict:
        """Parse a product row into our standard format."""
        nutrients = []

        # Map Open Food Facts nutrients to standard names
        nutrient_map = {
            'vitamin-a_100g': ('Vitamin A', 'µg'),
            'vitamin-c_100g': ('Vitamin C', 'mg'),
            'vitamin-d_100g': ('Vitamin D', 'µg'),
            'vitamin-e_100g': ('Vitamin E', 'mg'),
            'vitamin-k_100g': ('Vitamin K', 'µg'),
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
        }

        for col, (name, unit) in nutrient_map.items():
            if col in product and pd.notna(product[col]):
                nutrients.append({
                    'name': name,
                    'amount': float(product[col]),
                    'unit': unit
                })

        return {
            'barcode': str(product.get('code', '')),
            'name': product.get('product_name', ''),
            'brand': product.get('brands', ''),
            'category': product.get('categories_en', ''),
            'serving_size': product.get('serving_size', ''),
            'ingredients': product.get('ingredients_text', ''),
            'image_url': product.get('image_url', ''),
            'nutrients': nutrients
        }

    def save_to_sqlite(self, df: pd.DataFrame, db_path: str = 'supplements.db'):
        """Save supplements to SQLite database."""
        if df.empty:
            logger.warning("No data to save")
            return

        conn = sqlite3.connect(db_path)

        try:
            # Save main product info
            products = df[['code', 'product_name', 'brands', 'categories_en',
                          'serving_size', 'ingredients_text', 'image_url']].copy()
            products.columns = ['barcode', 'name', 'brand', 'category',
                               'serving_size', 'ingredients', 'image_url']

            products.to_sql('off_supplements', conn, if_exists='replace', index=False)

            logger.info(f"Saved {len(products)} supplements to {db_path}")

        except Exception as e:
            logger.error(f"Error saving to database: {e}")
        finally:
            conn.close()


def demo_parquet_usage():
    """Demonstrate efficient Parquet file usage."""

    print("\n" + "="*60)
    print("OPEN FOOD FACTS PARQUET DEMO")
    print("="*60)

    handler = OpenFoodFactsParquet()

    print("\n📊 PARQUET vs JSON vs CSV:")
    print("-"*40)
    print("Format    | Size  | Speed | Memory")
    print("----------|-------|-------|-------")
    print("Parquet   | 2-3GB | Fast  | Low")
    print("JSON      | 30GB  | Slow  | High")
    print("CSV       | 9GB   | Medium| Medium")

    print("\n✅ ADVANTAGES OF PARQUET:")
    print("  • 90% smaller than JSON")
    print("  • Read only columns you need")
    print("  • Filter data while reading")
    print("  • Works with pandas/polars")
    print("  • Preserves data types")

    print("\n📥 TO DOWNLOAD SUPPLEMENTS:")
    print("  1. Small test file (~50MB):")
    print("     handler.download_parquet(supplements_only=True)")
    print("\n  2. Full database (~2-3GB):")
    print("     handler.download_parquet(supplements_only=False)")

    print("\n🔍 USAGE EXAMPLE:")
    print("""
    # Load supplements efficiently
    df = handler.read_supplements_efficiently()

    # Search by barcode
    product = handler.search_by_barcode('031604026165', df)

    # Search by name
    results = handler.search_by_name('vitamin d', df)

    # Save to SQLite for app use
    handler.save_to_sqlite(df)
    """)

    print("\n💡 RECOMMENDATION:")
    print("  For your app: Use Parquet for bulk data processing")
    print("  Then convert to SQLite for mobile app use")


if __name__ == "__main__":
    demo_parquet_usage()

    # Uncomment to actually download and process:
    # handler = OpenFoodFactsParquet()
    # handler.download_parquet(supplements_only=True)
    # df = handler.read_supplements_efficiently()
    # handler.save_to_sqlite(df)