#!/usr/bin/env python3
"""
Enhanced Supplement Data Collector
Uses APIs and public databases to collect supplement information legally.
"""

import requests
import json
import sqlite3
import time
from typing import Dict, List, Optional
import logging
from datetime import datetime
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SupplementDataCollector:
    """Collects supplement data from various public APIs and databases."""

    def __init__(self):
        self.session = requests.Session()
        self.init_database()

    def init_database(self):
        """Initialize database for supplement data."""
        conn = sqlite3.connect('supplements.db')
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS supplements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                barcode TEXT UNIQUE,
                name TEXT NOT NULL,
                brand TEXT,
                category TEXT,
                serving_size TEXT,
                serving_unit TEXT,
                ingredients TEXT,
                warnings TEXT,
                image_url TEXT,
                source TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS nutrients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                supplement_id INTEGER,
                nutrient_name TEXT,
                amount REAL,
                unit TEXT,
                daily_value REAL,
                FOREIGN KEY (supplement_id) REFERENCES supplements(id)
            )
        ''')

        conn.commit()
        conn.close()

    def fetch_from_open_food_facts(self, barcode: str) -> Optional[Dict]:
        """
        Fetch supplement data from Open Food Facts API.
        This is completely free and legal to use.
        """
        url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"

        try:
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data.get('status') == 1 and data.get('product'):
                product = data['product']
                return self.parse_off_product(product, barcode)

        except Exception as e:
            logger.error(f"Error fetching from Open Food Facts: {e}")

        return None

    def parse_off_product(self, product: Dict, barcode: str) -> Dict:
        """Parse Open Food Facts product data."""
        supplement = {
            'barcode': barcode,
            'name': product.get('product_name', ''),
            'brand': product.get('brands', ''),
            'category': product.get('categories', ''),
            'serving_size': product.get('serving_size', ''),
            'ingredients': product.get('ingredients_text', ''),
            'image_url': product.get('image_url', ''),
            'source': 'open_food_facts',
            'nutrients': []
        }

        # Parse nutrients
        nutriments = product.get('nutriments', {})
        nutrient_map = {
            'vitamin-a_100g': ('Vitamin A', 'µg', 900),  # Daily value in micrograms
            'vitamin-c_100g': ('Vitamin C', 'mg', 90),
            'vitamin-d_100g': ('Vitamin D', 'µg', 20),
            'vitamin-e_100g': ('Vitamin E', 'mg', 15),
            'vitamin-k_100g': ('Vitamin K', 'µg', 120),
            'vitamin-b1_100g': ('Thiamine (B1)', 'mg', 1.2),
            'vitamin-b2_100g': ('Riboflavin (B2)', 'mg', 1.3),
            'vitamin-b3_100g': ('Niacin (B3)', 'mg', 16),
            'vitamin-b6_100g': ('Vitamin B6', 'mg', 1.7),
            'vitamin-b9_100g': ('Folate (B9)', 'µg', 400),
            'vitamin-b12_100g': ('Vitamin B12', 'µg', 2.4),
            'calcium_100g': ('Calcium', 'mg', 1300),
            'iron_100g': ('Iron', 'mg', 18),
            'magnesium_100g': ('Magnesium', 'mg', 420),
            'zinc_100g': ('Zinc', 'mg', 11),
            'potassium_100g': ('Potassium', 'mg', 3400),
            'omega-3-fatty-acids_100g': ('Omega-3', 'mg', 1600),
        }

        for key, (name, unit, dv) in nutrient_map.items():
            if key in nutriments:
                amount = nutriments[key]
                supplement['nutrients'].append({
                    'name': name,
                    'amount': amount,
                    'unit': unit,
                    'daily_value': (amount / dv * 100) if dv else None
                })

        return supplement

    def fetch_from_usda(self, search_term: str) -> Optional[Dict]:
        """
        Fetch from USDA FoodData Central API.
        Free API but requires registration for API key.
        """
        api_key = os.getenv('USDA_API_KEY', 'DEMO_KEY')  # Get your free key from https://fdc.nal.usda.gov/api-key-signup

        search_url = f"https://api.nal.usda.gov/fdc/v1/foods/search"
        params = {
            'query': search_term,
            'dataType': 'Branded',
            'pageSize': 10,
            'api_key': api_key
        }

        try:
            response = self.session.get(search_url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data.get('foods'):
                return self.parse_usda_food(data['foods'][0])

        except Exception as e:
            logger.error(f"Error fetching from USDA: {e}")

        return None

    def fetch_from_nih_dietary_supplements(self, ingredient: str) -> Optional[Dict]:
        """
        Fetch from NIH Office of Dietary Supplements.
        Educational data about supplements.
        """
        # NIH provides fact sheets but not a direct API
        # This would scrape their public fact sheets
        base_url = "https://ods.od.nih.gov/factsheets/"

        # Map common ingredients to NIH fact sheet names
        ingredient_map = {
            'vitamin d': 'VitaminD',
            'vitamin c': 'VitaminC',
            'omega-3': 'Omega3FattyAcids',
            'calcium': 'Calcium',
            'iron': 'Iron',
            'magnesium': 'Magnesium',
            'zinc': 'Zinc',
            'probiotics': 'Probiotics'
        }

        sheet_name = ingredient_map.get(ingredient.lower())
        if sheet_name:
            return {
                'source': 'NIH',
                'fact_sheet_url': f"{base_url}{sheet_name}-HealthProfessional/"
            }

        return None

    def build_common_supplements_database(self):
        """Build a database of common supplements with their typical compositions."""
        common_supplements = [
            {
                'name': 'Multivitamin',
                'brand': 'Generic',
                'category': 'Multivitamin',
                'nutrients': [
                    {'name': 'Vitamin A', 'amount': 900, 'unit': 'µg', 'daily_value': 100},
                    {'name': 'Vitamin C', 'amount': 90, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Vitamin D', 'amount': 20, 'unit': 'µg', 'daily_value': 100},
                    {'name': 'Vitamin E', 'amount': 15, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Thiamine', 'amount': 1.2, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Riboflavin', 'amount': 1.3, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Niacin', 'amount': 16, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Vitamin B6', 'amount': 1.7, 'unit': 'mg', 'daily_value': 100},
                    {'name': 'Folate', 'amount': 400, 'unit': 'µg', 'daily_value': 100},
                    {'name': 'Vitamin B12', 'amount': 2.4, 'unit': 'µg', 'daily_value': 100},
                ]
            },
            {
                'name': 'Vitamin D3',
                'brand': 'Generic',
                'category': 'Single Vitamin',
                'serving_size': '1',
                'serving_unit': 'softgel',
                'nutrients': [
                    {'name': 'Vitamin D3', 'amount': 50, 'unit': 'µg', 'daily_value': 250}
                ]
            },
            {
                'name': 'Omega-3 Fish Oil',
                'brand': 'Generic',
                'category': 'Fatty Acids',
                'serving_size': '2',
                'serving_unit': 'softgels',
                'nutrients': [
                    {'name': 'EPA', 'amount': 360, 'unit': 'mg', 'daily_value': None},
                    {'name': 'DHA', 'amount': 240, 'unit': 'mg', 'daily_value': None},
                    {'name': 'Total Omega-3', 'amount': 600, 'unit': 'mg', 'daily_value': None}
                ]
            },
            {
                'name': 'Probiotic',
                'brand': 'Generic',
                'category': 'Probiotic',
                'serving_size': '1',
                'serving_unit': 'capsule',
                'nutrients': [
                    {'name': 'Probiotic Blend', 'amount': 10, 'unit': 'billion CFU', 'daily_value': None}
                ]
            },
            {
                'name': 'Calcium + Vitamin D',
                'brand': 'Generic',
                'category': 'Mineral',
                'nutrients': [
                    {'name': 'Calcium', 'amount': 600, 'unit': 'mg', 'daily_value': 46},
                    {'name': 'Vitamin D3', 'amount': 10, 'unit': 'µg', 'daily_value': 50}
                ]
            },
            {
                'name': 'Magnesium Glycinate',
                'brand': 'Generic',
                'category': 'Mineral',
                'nutrients': [
                    {'name': 'Magnesium', 'amount': 200, 'unit': 'mg', 'daily_value': 48}
                ]
            },
            {
                'name': 'B-Complex',
                'brand': 'Generic',
                'category': 'B Vitamins',
                'nutrients': [
                    {'name': 'Thiamine (B1)', 'amount': 50, 'unit': 'mg', 'daily_value': 4167},
                    {'name': 'Riboflavin (B2)', 'amount': 50, 'unit': 'mg', 'daily_value': 3846},
                    {'name': 'Niacin (B3)', 'amount': 50, 'unit': 'mg', 'daily_value': 313},
                    {'name': 'Vitamin B6', 'amount': 50, 'unit': 'mg', 'daily_value': 2941},
                    {'name': 'Folate', 'amount': 400, 'unit': 'µg', 'daily_value': 100},
                    {'name': 'Vitamin B12', 'amount': 50, 'unit': 'µg', 'daily_value': 2083},
                    {'name': 'Biotin', 'amount': 300, 'unit': 'µg', 'daily_value': 1000},
                    {'name': 'Pantothenic Acid', 'amount': 50, 'unit': 'mg', 'daily_value': 1000}
                ]
            }
        ]

        conn = sqlite3.connect('supplements.db')
        cursor = conn.cursor()

        for supplement in common_supplements:
            # Create a fake barcode for generic supplements
            barcode = f"GENERIC_{supplement['name'].replace(' ', '_').upper()}"

            cursor.execute('''
                INSERT OR IGNORE INTO supplements
                (barcode, name, brand, category, serving_size, serving_unit, source)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                barcode,
                supplement['name'],
                supplement.get('brand', 'Generic'),
                supplement.get('category', ''),
                supplement.get('serving_size', '1'),
                supplement.get('serving_unit', 'serving'),
                'manual_database'
            ))

            supplement_id = cursor.lastrowid or cursor.execute(
                "SELECT id FROM supplements WHERE barcode = ?", (barcode,)
            ).fetchone()[0]

            for nutrient in supplement.get('nutrients', []):
                cursor.execute('''
                    INSERT OR REPLACE INTO nutrients
                    (supplement_id, nutrient_name, amount, unit, daily_value)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    supplement_id,
                    nutrient['name'],
                    nutrient['amount'],
                    nutrient['unit'],
                    nutrient.get('daily_value')
                ))

        conn.commit()
        conn.close()

        logger.info(f"Added {len(common_supplements)} common supplements to database")

    def save_supplement(self, supplement_data: Dict):
        """Save supplement data to database."""
        conn = sqlite3.connect('supplements.db')
        cursor = conn.cursor()

        try:
            cursor.execute('''
                INSERT OR REPLACE INTO supplements
                (barcode, name, brand, category, serving_size, serving_unit,
                 ingredients, image_url, source)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                supplement_data.get('barcode'),
                supplement_data.get('name'),
                supplement_data.get('brand'),
                supplement_data.get('category'),
                supplement_data.get('serving_size'),
                supplement_data.get('serving_unit', 'serving'),
                supplement_data.get('ingredients'),
                supplement_data.get('image_url'),
                supplement_data.get('source')
            ))

            supplement_id = cursor.lastrowid

            for nutrient in supplement_data.get('nutrients', []):
                cursor.execute('''
                    INSERT OR REPLACE INTO nutrients
                    (supplement_id, nutrient_name, amount, unit, daily_value)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    supplement_id,
                    nutrient['name'],
                    nutrient['amount'],
                    nutrient['unit'],
                    nutrient.get('daily_value')
                ))

            conn.commit()
            logger.info(f"Saved: {supplement_data.get('name')} ({supplement_data.get('barcode')})")

        except Exception as e:
            logger.error(f"Database error: {e}")
            conn.rollback()
        finally:
            conn.close()

    def export_to_swift(self, output_file: str = "SupplementDatabase.swift"):
        """Export database to Swift code for embedding in the app."""
        conn = sqlite3.connect('supplements.db')
        cursor = conn.cursor()

        cursor.execute('''
            SELECT s.*, GROUP_CONCAT(
                n.nutrient_name || '|' || n.amount || '|' || n.unit || '|' || COALESCE(n.daily_value, ''),
                ';'
            ) as nutrients_data
            FROM supplements s
            LEFT JOIN nutrients n ON s.id = n.supplement_id
            GROUP BY s.id
        ''')

        swift_code = '''// Auto-generated Supplement Database
// Generated: {timestamp}

import Foundation

struct PreloadedSupplement {{
    let barcode: String
    let name: String
    let brand: String?
    let servingSize: String?
    let servingUnit: String?
    let ingredients: String?
    let nutrients: [PreloadedNutrient]
}}

struct PreloadedNutrient {{
    let name: String
    let amount: Double
    let unit: String
    let dailyValue: Double?
}}

class SupplementDatabase {{
    static let shared = SupplementDatabase()

    private let supplements: [String: PreloadedSupplement] = [
'''.format(timestamp=datetime.now().isoformat())

        for row in cursor.fetchall():
            barcode = row[1]
            name = row[2].replace('"', '\\"') if row[2] else ""
            brand = '"{}"'.format(row[3].replace('"', '\\"')) if row[3] else "nil"
            serving_size = '"{}"'.format(row[5]) if row[5] else "nil"
            serving_unit = '"{}"'.format(row[6]) if row[6] else "nil"
            ingredients = '"{}"'.format(row[7].replace('"', '\\"')) if row[7] else "nil"

            nutrients_swift = "["
            if row[-1]:  # nutrients_data
                nutrient_entries = []
                for nutrient_str in row[-1].split(';'):
                    parts = nutrient_str.split('|')
                    if len(parts) >= 3:
                        n_name = parts[0].replace('"', '\\"')
                        n_amount = parts[1]
                        n_unit = parts[2]
                        n_dv = parts[3] if len(parts) > 3 and parts[3] else "nil"

                        nutrient_entries.append(f'''
            PreloadedNutrient(
                name: "{n_name}",
                amount: {n_amount},
                unit: "{n_unit}",
                dailyValue: {n_dv}
            )''')

                nutrients_swift += ','.join(nutrient_entries)
            nutrients_swift += "\n        ]"

            swift_code += f'''
        "{barcode}": PreloadedSupplement(
            barcode: "{barcode}",
            name: "{name}",
            brand: {brand},
            servingSize: {serving_size},
            servingUnit: {serving_unit},
            ingredients: {ingredients},
            nutrients: {nutrients_swift}
        ),
'''

        swift_code += '''
    ]

    func lookup(barcode: String) -> PreloadedSupplement? {
        return supplements[barcode]
    }

    func search(query: String) -> [PreloadedSupplement] {
        let lowercasedQuery = query.lowercased()
        return supplements.values.filter { supplement in
            supplement.name.lowercased().contains(lowercasedQuery) ||
            (supplement.brand?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
'''

        with open(output_file, 'w') as f:
            f.write(swift_code)

        conn.close()
        logger.info(f"Exported to {output_file}")


def main():
    collector = SupplementDataCollector()

    # Build common supplements database
    collector.build_common_supplements_database()

    # Test with some real barcodes
    test_barcodes = [
        "733739001801",  # NOW Foods Vitamin D-3
        "021078025733",  # Centrum Adults
        "790011180036",  # Garden of Life
    ]

    for barcode in test_barcodes:
        logger.info(f"Fetching data for {barcode}")
        data = collector.fetch_from_open_food_facts(barcode)
        if data:
            collector.save_supplement(data)
        time.sleep(1)  # Rate limiting

    # Export to Swift
    collector.export_to_swift()


if __name__ == "__main__":
    main()