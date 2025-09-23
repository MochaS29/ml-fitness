#!/usr/bin/env python3
"""
Spoonacular API Integration for Supplement Data
API Documentation: https://spoonacular.com/food-api/docs
"""

import requests
import json
import sqlite3
import time
import logging
from typing import Dict, List, Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SpoonacularAPI:
    """Spoonacular API client for supplement/product data."""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.spoonacular.com"
        self.session = requests.Session()

    def search_by_barcode(self, barcode: str) -> Optional[Dict]:
        """
        Search for a product by UPC/EAN barcode.
        Endpoint: GET /food/products/upc/{upc}
        """
        url = f"{self.base_url}/food/products/upc/{barcode}"
        params = {'apiKey': self.api_key}

        try:
            response = self.session.get(url, params=params)
            logger.info(f"Searching for barcode {barcode}: Status {response.status_code}")

            if response.status_code == 200:
                data = response.json()
                logger.info(f"Found: {data.get('title')}")
                return data
            elif response.status_code == 404:
                logger.warning(f"Product not found: {barcode}")
            else:
                logger.error(f"API error: {response.status_code}")

        except Exception as e:
            logger.error(f"Request failed: {e}")

        return None

    def search_products(self, query: str, limit: int = 10) -> Optional[List[Dict]]:
        """
        Search for products by name/query.
        Endpoint: GET /food/products/search
        """
        url = f"{self.base_url}/food/products/search"
        params = {
            'apiKey': self.api_key,
            'query': query,
            'number': limit,
            'addProductInformation': True
        }

        try:
            response = self.session.get(url, params=params)

            if response.status_code == 200:
                data = response.json()
                products = data.get('products', [])
                logger.info(f"Found {len(products)} products for '{query}'")
                return products

        except Exception as e:
            logger.error(f"Search failed: {e}")

        return None

    def get_product_info(self, product_id: int) -> Optional[Dict]:
        """
        Get detailed information about a specific product.
        Endpoint: GET /food/products/{id}
        """
        url = f"{self.base_url}/food/products/{product_id}"
        params = {'apiKey': self.api_key}

        try:
            response = self.session.get(url, params=params)

            if response.status_code == 200:
                return response.json()

        except Exception as e:
            logger.error(f"Failed to get product info: {e}")

        return None

    def parse_supplement_data(self, product_data: Dict) -> Dict:
        """Parse Spoonacular product data into our supplement format."""

        supplement = {
            'barcode': product_data.get('upc', ''),
            'name': product_data.get('title', 'Unknown'),
            'brand': product_data.get('brand', ''),
            'image_url': product_data.get('image', ''),
            'serving_size': None,
            'nutrients': []
        }

        # Parse nutrition data
        nutrition = product_data.get('nutrition', {})

        # Get serving size
        if 'weightPerServing' in product_data:
            weight = product_data['weightPerServing']
            supplement['serving_size'] = f"{weight.get('amount', 1)} {weight.get('unit', 'serving')}"

        # Parse nutrients
        nutrients_list = nutrition.get('nutrients', [])

        # Map Spoonacular nutrient names to standard names
        nutrient_mapping = {
            'Calories': ('Calories', 'kcal', 2000),
            'Protein': ('Protein', 'g', 50),
            'Total Fat': ('Total Fat', 'g', 65),
            'Carbohydrates': ('Carbohydrates', 'g', 300),
            'Sugar': ('Sugar', 'g', 50),
            'Sodium': ('Sodium', 'mg', 2300),
            'Fiber': ('Fiber', 'g', 25),
            'Vitamin A': ('Vitamin A', 'IU', 5000),
            'Vitamin C': ('Vitamin C', 'mg', 90),
            'Vitamin D': ('Vitamin D', 'IU', 400),
            'Vitamin E': ('Vitamin E', 'mg', 15),
            'Vitamin K': ('Vitamin K', 'mcg', 120),
            'Thiamin': ('Thiamine (B1)', 'mg', 1.2),
            'Riboflavin': ('Riboflavin (B2)', 'mg', 1.3),
            'Niacin': ('Niacin (B3)', 'mg', 16),
            'Vitamin B6': ('Vitamin B6', 'mg', 1.7),
            'Folate': ('Folate', 'mcg', 400),
            'Vitamin B12': ('Vitamin B12', 'mcg', 2.4),
            'Biotin': ('Biotin', 'mcg', 30),
            'Pantothenic Acid': ('Pantothenic Acid', 'mg', 5),
            'Calcium': ('Calcium', 'mg', 1000),
            'Iron': ('Iron', 'mg', 18),
            'Magnesium': ('Magnesium', 'mg', 400),
            'Zinc': ('Zinc', 'mg', 11),
            'Selenium': ('Selenium', 'mcg', 55),
            'Copper': ('Copper', 'mg', 0.9),
            'Manganese': ('Manganese', 'mg', 2.3),
            'Potassium': ('Potassium', 'mg', 3500),
        }

        for nutrient in nutrients_list:
            name = nutrient.get('name', '')
            amount = nutrient.get('amount', 0)
            unit = nutrient.get('unit', '')

            # Get daily value percentage
            percent_daily = nutrient.get('percentOfDailyNeeds', None)

            # Map to standard name if available
            if name in nutrient_mapping:
                standard_name, standard_unit, dv_amount = nutrient_mapping[name]

                supplement['nutrients'].append({
                    'name': standard_name,
                    'amount': amount,
                    'unit': unit or standard_unit,
                    'daily_value': percent_daily
                })

        return supplement

    def save_to_database(self, supplement_data: Dict):
        """Save supplement data to local SQLite database."""

        conn = sqlite3.connect('supplements.db')
        cursor = conn.cursor()

        try:
            # Insert or update supplement
            cursor.execute('''
                INSERT OR REPLACE INTO supplements
                (barcode, name, brand, serving_size, image_url, source)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                supplement_data['barcode'],
                supplement_data['name'],
                supplement_data.get('brand', ''),
                supplement_data.get('serving_size', ''),
                supplement_data.get('image_url', ''),
                'spoonacular'
            ))

            supplement_id = cursor.lastrowid

            # Insert nutrients
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
            logger.info(f"Saved to database: {supplement_data['name']}")

        except Exception as e:
            logger.error(f"Database error: {e}")
            conn.rollback()
        finally:
            conn.close()


def test_spoonacular_api():
    """Test Spoonacular API with real supplement barcodes."""

    api_key = "78925a5a97ef4f53a8fc692cad0b1618"
    api = SpoonacularAPI(api_key)

    # Test barcodes - mix of supplements and health products
    test_barcodes = [
        "031604026165",  # Nature Made CoQ10
        "016500537618",  # One A Day Men's
        "033984010406",  # NOW Vitamin D-3
        "305210046113",  # Centrum Adults
        "681131120104",  # Emergen-C
        "031604017019",  # Nature Made Vitamin D3 5000 IU
        "074312553646",  # Nature's Bounty Biotin
        "047469075774",  # Natrol Melatonin
    ]

    print("\n" + "="*60)
    print("TESTING SPOONACULAR API")
    print("="*60)

    found_count = 0
    for barcode in test_barcodes:
        print(f"\n🔍 Testing barcode: {barcode}")
        result = api.search_by_barcode(barcode)

        if result:
            found_count += 1
            print(f"✅ FOUND: {result.get('title')}")
            print(f"   Brand: {result.get('brand', 'N/A')}")
            print(f"   Category: {result.get('aisle', 'N/A')}")

            # Parse and save
            supplement = api.parse_supplement_data(result)
            api.save_to_database(supplement)

            # Show nutrients
            if supplement['nutrients']:
                print(f"   Nutrients: {len(supplement['nutrients'])} found")
                for nutrient in supplement['nutrients'][:5]:  # Show first 5
                    print(f"     - {nutrient['name']}: {nutrient['amount']}{nutrient['unit']}")
        else:
            print(f"❌ Not found")

        time.sleep(0.5)  # Rate limiting

    print(f"\n📊 Results: {found_count}/{len(test_barcodes)} products found")

    # Also test search functionality
    print("\n" + "="*60)
    print("TESTING PRODUCT SEARCH")
    print("="*60)

    search_terms = ["vitamin d", "omega 3", "probiotic", "multivitamin"]

    for term in search_terms:
        print(f"\n🔍 Searching for: {term}")
        results = api.search_products(term, limit=3)

        if results:
            print(f"✅ Found {len(results)} products:")
            for product in results:
                print(f"   - {product.get('title')}")

        time.sleep(0.5)

    print("\n✅ Spoonacular API integration complete!")
    print("📁 Data saved to supplements.db")


def get_api_limits():
    """Check Spoonacular API quota and limits."""

    api_key = "78925a5a97ef4f53a8fc692cad0b1618"

    # Check quota endpoint
    url = f"https://api.spoonacular.com/recipes/complexSearch"
    params = {
        'apiKey': api_key,
        'query': 'test',
        'number': 1
    }

    response = requests.get(url, params=params)

    # API quota is in response headers
    points_left = response.headers.get('X-API-Quota-Left')
    points_used = response.headers.get('X-API-Quota-Used')
    requests_left = response.headers.get('X-API-Quota-Request')

    print("\n📊 SPOONACULAR API QUOTA:")
    print(f"   Points remaining today: {points_left}")
    print(f"   Points used today: {points_used}")
    print(f"   Requests remaining today: {requests_left}")
    print("\n   Free tier: 150 points/day")
    print("   Each barcode lookup: 1 point")
    print("   Each search: 1 point + 0.01 per result")


if __name__ == "__main__":
    # Check API limits first
    get_api_limits()

    # Run tests
    test_spoonacular_api()