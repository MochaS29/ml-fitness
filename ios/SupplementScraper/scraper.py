#!/usr/bin/env python3
"""
Supplement Information Web Scraper
Scrapes supplement data from various sources to build a comprehensive database.
Follows ethical scraping practices with rate limiting and robots.txt compliance.
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import sqlite3
import re
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser
import hashlib
from datetime import datetime
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraper.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class SupplementScraper:
    """
    Ethical web scraper for supplement information.
    Respects robots.txt and implements rate limiting.
    """

    def __init__(self, database_path: str = "supplements.db"):
        self.database_path = database_path
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'HealthTracker-Supplement-Bot/1.0 (Educational Purpose; Contact: healthtracker@example.com)'
        })
        self.robots_cache = {}
        self.init_database()

    def init_database(self):
        """Initialize SQLite database for storing supplement data."""
        conn = sqlite3.connect(self.database_path)
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS supplements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                barcode TEXT UNIQUE,
                name TEXT NOT NULL,
                brand TEXT,
                serving_size TEXT,
                serving_unit TEXT,
                price REAL,
                image_url TEXT,
                product_url TEXT,
                ingredients TEXT,
                warnings TEXT,
                description TEXT,
                category TEXT,
                source TEXT,
                scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                data_hash TEXT
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
                FOREIGN KEY (supplement_id) REFERENCES supplements(id),
                UNIQUE(supplement_id, nutrient_name)
            )
        ''')

        conn.commit()
        conn.close()

    def check_robots_txt(self, url: str) -> bool:
        """Check if URL is allowed by robots.txt."""
        parsed_url = urlparse(url)
        robots_url = f"{parsed_url.scheme}://{parsed_url.netloc}/robots.txt"

        if robots_url not in self.robots_cache:
            rp = RobotFileParser()
            rp.set_url(robots_url)
            try:
                rp.read()
                self.robots_cache[robots_url] = rp
            except:
                # If robots.txt is not accessible, assume allowed
                return True

        rp = self.robots_cache.get(robots_url)
        if rp:
            return rp.can_fetch(self.session.headers['User-Agent'], url)
        return True

    def scrape_iherb(self, barcode: str) -> Optional[Dict]:
        """
        Scrape supplement data from iHerb (example implementation).
        Note: This is for educational purposes. Always check terms of service.
        """
        search_url = f"https://www.iherb.com/search?kw={barcode}"

        if not self.check_robots_txt(search_url):
            logger.warning(f"Robots.txt disallows scraping: {search_url}")
            return None

        time.sleep(2)  # Rate limiting - be respectful

        try:
            response = self.session.get(search_url, timeout=10)
            response.raise_for_status()
            soup = BeautifulSoup(response.content, 'html.parser')

            # This is a simplified example - actual selectors would need to be updated
            product_data = self._parse_iherb_page(soup, barcode)
            return product_data

        except Exception as e:
            logger.error(f"Error scraping iHerb for {barcode}: {e}")
            return None

    def scrape_vitacost(self, barcode: str) -> Optional[Dict]:
        """Scrape from Vitacost (example)."""
        # Similar implementation to iHerb
        pass

    def scrape_amazon(self, barcode: str) -> Optional[Dict]:
        """
        Scrape from Amazon.
        Note: Amazon has strict anti-scraping measures. Consider using their API instead.
        """
        # Amazon Product Advertising API would be better
        pass

    def _parse_iherb_page(self, soup: BeautifulSoup, barcode: str) -> Optional[Dict]:
        """Parse iHerb product page."""
        try:
            # Example selectors - these would need to be updated based on actual HTML
            product = {
                'barcode': barcode,
                'source': 'iherb'
            }

            # Product name
            name_elem = soup.find('h1', class_='product-title')
            if name_elem:
                product['name'] = name_elem.text.strip()

            # Brand
            brand_elem = soup.find('span', class_='brand-name')
            if brand_elem:
                product['brand'] = brand_elem.text.strip()

            # Price
            price_elem = soup.find('span', class_='price')
            if price_elem:
                price_text = price_elem.text.strip()
                price_match = re.search(r'[\d.]+', price_text)
                if price_match:
                    product['price'] = float(price_match.group())

            # Supplement facts
            facts_elem = soup.find('div', class_='supplement-facts')
            if facts_elem:
                nutrients = self._parse_supplement_facts(facts_elem)
                product['nutrients'] = nutrients

            # Ingredients
            ingredients_elem = soup.find('div', class_='ingredients')
            if ingredients_elem:
                product['ingredients'] = ingredients_elem.text.strip()

            return product if 'name' in product else None

        except Exception as e:
            logger.error(f"Error parsing iHerb page: {e}")
            return None

    def _parse_supplement_facts(self, facts_elem) -> List[Dict]:
        """Parse supplement facts table."""
        nutrients = []

        rows = facts_elem.find_all('tr')
        for row in rows:
            cols = row.find_all('td')
            if len(cols) >= 2:
                nutrient_name = cols[0].text.strip()
                amount_text = cols[1].text.strip()

                # Parse amount and unit
                amount_match = re.match(r'([\d.]+)\s*(\w+)', amount_text)
                if amount_match:
                    amount = float(amount_match.group(1))
                    unit = amount_match.group(2)

                    nutrient = {
                        'name': nutrient_name,
                        'amount': amount,
                        'unit': unit
                    }

                    # Check for daily value
                    if len(cols) >= 3:
                        dv_text = cols[2].text.strip()
                        dv_match = re.search(r'([\d.]+)%', dv_text)
                        if dv_match:
                            nutrient['daily_value'] = float(dv_match.group(1))

                    nutrients.append(nutrient)

        return nutrients

    def scrape_manufacturer_site(self, brand: str, product_url: str) -> Optional[Dict]:
        """
        Scrape directly from manufacturer websites.
        Examples: naturemade.com, centrum.com, gardenoflife.com
        """
        if not self.check_robots_txt(product_url):
            logger.warning(f"Robots.txt disallows scraping: {product_url}")
            return None

        time.sleep(2)  # Rate limiting

        try:
            response = self.session.get(product_url, timeout=10)
            response.raise_for_status()
            soup = BeautifulSoup(response.content, 'html.parser')

            # Brand-specific parsers
            if 'naturemade.com' in product_url:
                return self._parse_naturemade(soup)
            elif 'centrum.com' in product_url:
                return self._parse_centrum(soup)
            # Add more manufacturer parsers as needed

        except Exception as e:
            logger.error(f"Error scraping {product_url}: {e}")
            return None

    def save_to_database(self, product_data: Dict):
        """Save scraped product data to database."""
        conn = sqlite3.connect(self.database_path)
        cursor = conn.cursor()

        try:
            # Create data hash to check for duplicates
            data_str = json.dumps(product_data, sort_keys=True)
            data_hash = hashlib.md5(data_str.encode()).hexdigest()

            # Check if product already exists
            cursor.execute(
                "SELECT id, data_hash FROM supplements WHERE barcode = ?",
                (product_data.get('barcode'),)
            )
            existing = cursor.fetchone()

            if existing and existing[1] == data_hash:
                logger.info(f"Product {product_data.get('barcode')} already up to date")
                return

            # Insert or update supplement
            cursor.execute('''
                INSERT OR REPLACE INTO supplements
                (barcode, name, brand, serving_size, serving_unit, price,
                 image_url, product_url, ingredients, description, source, data_hash)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                product_data.get('barcode'),
                product_data.get('name'),
                product_data.get('brand'),
                product_data.get('serving_size'),
                product_data.get('serving_unit'),
                product_data.get('price'),
                product_data.get('image_url'),
                product_data.get('product_url'),
                product_data.get('ingredients'),
                product_data.get('description'),
                product_data.get('source'),
                data_hash
            ))

            supplement_id = cursor.lastrowid

            # Insert nutrients
            if 'nutrients' in product_data:
                for nutrient in product_data['nutrients']:
                    cursor.execute('''
                        INSERT OR REPLACE INTO nutrients
                        (supplement_id, nutrient_name, amount, unit, daily_value)
                        VALUES (?, ?, ?, ?, ?)
                    ''', (
                        supplement_id,
                        nutrient.get('name'),
                        nutrient.get('amount'),
                        nutrient.get('unit'),
                        nutrient.get('daily_value')
                    ))

            conn.commit()
            logger.info(f"Saved product: {product_data.get('name')} ({product_data.get('barcode')})")

        except Exception as e:
            logger.error(f"Database error: {e}")
            conn.rollback()
        finally:
            conn.close()

    def scrape_multiple_sources(self, barcode: str) -> Optional[Dict]:
        """Try multiple sources to find product information."""
        sources = [
            ('iherb', self.scrape_iherb),
            # ('vitacost', self.scrape_vitacost),
            # ('amazon', self.scrape_amazon),
        ]

        for source_name, scraper_func in sources:
            logger.info(f"Trying {source_name} for barcode {barcode}")
            result = scraper_func(barcode)
            if result:
                logger.info(f"Found product on {source_name}")
                return result

        logger.warning(f"Product not found for barcode: {barcode}")
        return None

    def export_to_json(self, output_file: str = "supplements_database.json"):
        """Export database to JSON for use in the app."""
        conn = sqlite3.connect(self.database_path)
        cursor = conn.cursor()

        cursor.execute('''
            SELECT s.*, GROUP_CONCAT(
                n.nutrient_name || ':' || n.amount || ':' || n.unit || ':' || COALESCE(n.daily_value, ''),
                '|'
            ) as nutrients_data
            FROM supplements s
            LEFT JOIN nutrients n ON s.id = n.supplement_id
            GROUP BY s.id
        ''')

        supplements = []
        for row in cursor.fetchall():
            supplement = {
                'barcode': row[1],
                'name': row[2],
                'brand': row[3],
                'serving_size': row[4],
                'serving_unit': row[5],
                'price': row[6],
                'image_url': row[7],
                'ingredients': row[9],
                'description': row[11],
                'nutrients': []
            }

            # Parse nutrients
            if row[-1]:  # nutrients_data
                for nutrient_str in row[-1].split('|'):
                    parts = nutrient_str.split(':')
                    if len(parts) >= 3:
                        nutrient = {
                            'name': parts[0],
                            'amount': float(parts[1]) if parts[1] else 0,
                            'unit': parts[2]
                        }
                        if len(parts) > 3 and parts[3]:
                            nutrient['daily_value'] = float(parts[3])
                        supplement['nutrients'].append(nutrient)

            supplements.append(supplement)

        with open(output_file, 'w') as f:
            json.dump(supplements, f, indent=2)

        conn.close()
        logger.info(f"Exported {len(supplements)} supplements to {output_file}")


def main():
    """Main function to run the scraper."""
    scraper = SupplementScraper()

    # Example: Scrape common supplement barcodes
    common_barcodes = [
        "030768011154",  # Nature Made Vitamin D3
        "031604026165",  # Centrum Silver
        "790011040194",  # Garden of Life Vitamin Code
        # Add more barcodes as needed
    ]

    for barcode in common_barcodes:
        logger.info(f"Processing barcode: {barcode}")
        product_data = scraper.scrape_multiple_sources(barcode)
        if product_data:
            scraper.save_to_database(product_data)
        time.sleep(5)  # Be respectful between requests

    # Export to JSON for app use
    scraper.export_to_json()


if __name__ == "__main__":
    main()