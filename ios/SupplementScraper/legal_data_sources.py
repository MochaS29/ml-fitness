#!/usr/bin/env python3
"""
Legal Methods to Obtain Supplement Data
All methods here are 100% legal and ethical
"""

import requests
import json
import csv
import time
from typing import Dict, List, Optional
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class LegalSupplementDataCollector:
    """Collects supplement data through legal channels only."""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'HealthTracker/1.0 (Educational; Contact: healthtracker@example.com)'
        })

    # ============================================================
    # METHOD 1: FREE PUBLIC APIs
    # ============================================================

    def get_from_open_food_facts(self, barcode: str) -> Optional[Dict]:
        """
        Open Food Facts - 100% Free and Legal
        No API key required, community-driven database
        Rate limit: Be respectful, ~1 request/second
        """
        url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"

        try:
            response = self.session.get(url)
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 1:
                    product = data['product']
                    logger.info(f"Found on Open Food Facts: {product.get('product_name')}")
                    return product
        except Exception as e:
            logger.error(f"Error: {e}")

        return None

    def get_from_usda_fooddata(self, search_term: str, api_key: str = None) -> Optional[Dict]:
        """
        USDA FoodData Central - Free Government Database
        Get free API key at: https://fdc.nal.usda.gov/api-key-signup.html
        Rate limit: 3,600 requests/hour with key, 30/hour without
        """
        if not api_key:
            api_key = "DEMO_KEY"  # Limited to 30 requests/hour
            logger.warning("Using DEMO_KEY - limited to 30 requests/hour. Get free key at link above.")

        url = "https://api.nal.usda.gov/fdc/v1/foods/search"
        params = {
            'query': search_term,
            'dataType': 'Branded',  # For commercial products
            'pageSize': 5,
            'api_key': api_key
        }

        try:
            response = self.session.get(url, params=params)
            if response.status_code == 200:
                data = response.json()
                if data.get('foods'):
                    logger.info(f"Found {len(data['foods'])} results on USDA")
                    return data['foods']
        except Exception as e:
            logger.error(f"Error: {e}")

        return None

    def get_from_nih_labels_database(self, search_term: str) -> Optional[Dict]:
        """
        NIH Dietary Supplement Label Database - Free Government Resource
        API Documentation: https://dsld.od.nih.gov/dsld/api.jsp
        No API key required
        """
        url = "https://api.ods.od.nih.gov/dsld/v8/label"
        params = {
            'search': search_term,
            'limit': 10
        }

        try:
            # Note: This is a simplified example - check actual API docs
            response = self.session.get(url, params=params)
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            logger.error(f"NIH API error: {e}")

        return None

    # ============================================================
    # METHOD 2: OFFICIAL MANUFACTURER DATA
    # ============================================================

    def get_manufacturer_catalog(self, brand: str) -> Optional[str]:
        """
        Many manufacturers provide official product catalogs
        These are meant for retailers and consumers
        """
        manufacturer_catalogs = {
            'Nature Made': 'https://www.naturemade.com/products',
            'NOW Foods': 'https://www.nowfoods.com/products/supplements',
            'Garden of Life': 'https://www.gardenoflife.com/products',
            'Centrum': 'https://www.centrum.com/products/',
            'One A Day': 'https://www.oneaday.com/vitamins/',
            'GNC': 'https://www.gnc.com/api/products',  # Some have actual APIs
            'Thorne': 'https://www.thorne.com/products',
            'Pure Encapsulations': 'https://www.pureencapsulations.com/products',
            'Nordic Naturals': 'https://www.nordicnaturals.com/products/',
            'Life Extension': 'https://www.lifeextension.com/api/products'
        }

        if brand in manufacturer_catalogs:
            catalog_url = manufacturer_catalogs[brand]
            logger.info(f"Manufacturer catalog available at: {catalog_url}")
            logger.info("Many manufacturers offer:")
            logger.info("  - Downloadable product sheets (PDF/CSV)")
            logger.info("  - Partner/retailer APIs")
            logger.info("  - Bulk data exports")
            logger.info("Contact them directly for data partnership!")
            return catalog_url

        return None

    # ============================================================
    # METHOD 3: COMMERCIAL APIs (PAID BUT LEGAL)
    # ============================================================

    def get_nutritionix_data(self, barcode: str, app_id: str, api_key: str) -> Optional[Dict]:
        """
        Nutritionix API - Best supplement coverage
        Pricing: $99/month for 10K calls
        Sign up: https://www.nutritionix.com/business/api
        """
        url = f"https://trackapi.nutritionix.com/v2/item"
        headers = {
            'x-app-id': app_id,
            'x-app-key': api_key
        }
        params = {'upc': barcode}

        try:
            response = self.session.get(url, headers=headers, params=params)
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            logger.error(f"Nutritionix error: {e}")

        return None

    def get_spoonacular_data(self, barcode: str, api_key: str) -> Optional[Dict]:
        """
        Spoonacular API - Food and supplement data
        Pricing: Free tier (150 calls/day), paid plans available
        Sign up: https://spoonacular.com/food-api
        """
        url = f"https://api.spoonacular.com/food/products/upc/{barcode}"
        params = {'apiKey': api_key}

        try:
            response = self.session.get(url, params=params)
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            logger.error(f"Spoonacular error: {e}")

        return None

    # ============================================================
    # METHOD 4: BULK DATA DOWNLOADS (COMPLETELY LEGAL)
    # ============================================================

    def download_open_food_facts_dump(self):
        """
        Download entire Open Food Facts database
        Updated daily, completely free
        """
        logger.info("Open Food Facts provides full database dumps:")
        logger.info("  CSV Export (supplements only):")
        logger.info("  https://world.openfoodfacts.org/data/en.openfoodfacts.org.products.csv")
        logger.info("  MongoDB dump (full database):")
        logger.info("  https://world.openfoodfacts.org/data/openfoodfacts-mongodbdump.tar.gz")
        logger.info("  Filter for supplements using category field")

        # Example: Download supplements CSV
        supplements_csv_url = "https://world.openfoodfacts.org/category/dietary-supplements.csv"
        logger.info(f"Downloading supplements CSV from: {supplements_csv_url}")
        # Actual download code would go here

        return supplements_csv_url

    def download_fda_data(self):
        """
        FDA provides various datasets about supplements
        """
        logger.info("FDA Data Sources:")
        logger.info("  1. FDA Adverse Event Reporting:")
        logger.info("     https://www.fda.gov/food/compliance-enforcement-food/cfsan-adverse-event-reporting-system-caers")
        logger.info("  2. FDA Registered Facilities:")
        logger.info("     https://www.fda.gov/food/registration-food-facilities-and-other-submissions")
        logger.info("  3. FDA Import Alerts (supplements):")
        logger.info("     https://www.accessdata.fda.gov/cms_ia/industry_70.html")

        return "FDA datasets available for download"

    # ============================================================
    # METHOD 5: WEB SCRAPING (ONLY WHERE EXPLICITLY ALLOWED)
    # ============================================================

    def check_scraping_permission(self, website: str) -> bool:
        """
        Some websites explicitly allow scraping
        Always check robots.txt and terms of service
        """
        allowed_sites = {
            'wikipedia.org': 'Allows respectful scraping with attribution',
            'examine.com': 'Research database - check their API',
            'supplementdb.com': 'Open database project',
            'labdoor.com': 'Supplement testing - has API for partners'
        }

        for domain, info in allowed_sites.items():
            if domain in website:
                logger.info(f"✅ {domain}: {info}")
                return True

        logger.warning(f"⚠️ Check {website}/robots.txt and terms before scraping")
        return False

    # ============================================================
    # METHOD 6: PARTNER & AFFILIATE PROGRAMS
    # ============================================================

    def get_affiliate_api_access(self):
        """
        Many companies provide API access to affiliates/partners
        """
        affiliate_programs = {
            'Amazon Associates': {
                'api': 'Product Advertising API',
                'url': 'https://webservices.amazon.com/paapi5/documentation/',
                'access': 'Free with affiliate account',
                'limits': '8,640 requests/day for new accounts'
            },
            'iHerb Affiliate': {
                'api': 'Product Feed API',
                'url': 'https://www.iherb.com/info/affiliate',
                'access': 'Free for approved affiliates',
                'data': 'Full product catalog with prices'
            },
            'Vitacost Affiliate': {
                'api': 'Product Data Feed',
                'url': 'https://www.vitacost.com/affiliate',
                'access': 'CSV/XML feeds for affiliates'
            },
            'GNC Partner Program': {
                'api': 'GNC API',
                'url': 'https://www.gnc.com/partners',
                'access': 'For approved partners'
            },
            'Walmart Affiliate': {
                'api': 'Walmart Open API',
                'url': 'https://developer.walmart.com',
                'access': 'Free with registration'
            }
        }

        for program, details in affiliate_programs.items():
            logger.info(f"\n{program}:")
            for key, value in details.items():
                logger.info(f"  {key}: {value}")

        return affiliate_programs

    # ============================================================
    # METHOD 7: COMMUNITY & CROWDSOURCING
    # ============================================================

    def setup_crowdsourcing(self):
        """
        Build your own database through user contributions
        """
        logger.info("Crowdsourcing Strategy:")
        logger.info("  1. Let users submit unknown supplements")
        logger.info("  2. Verify with multiple submissions")
        logger.info("  3. Reward contributors with app features")
        logger.info("  4. Use OCR on supplement labels")
        logger.info("  5. Build community like MyFitnessPal did")

        example_schema = {
            'user_submission': {
                'barcode': 'string',
                'product_name': 'string',
                'brand': 'string',
                'photo_of_label': 'image',
                'nutrients': 'extracted_via_OCR',
                'verified_by': 'number_of_users',
                'trust_score': 'calculated'
            }
        }

        return example_schema


def demonstrate_legal_methods():
    """Demonstrate all legal data collection methods."""
    collector = LegalSupplementDataCollector()

    print("\n" + "="*60)
    print("LEGAL METHODS TO OBTAIN SUPPLEMENT DATA")
    print("="*60)

    # 1. Free APIs
    print("\n1️⃣ FREE PUBLIC APIs")
    print("-"*40)

    # Test Open Food Facts
    test_barcode = "031604026165"  # Centrum Silver
    print(f"\nTesting Open Food Facts with barcode: {test_barcode}")
    result = collector.get_from_open_food_facts(test_barcode)
    if result:
        print(f"  ✅ Found: {result.get('product_name')}")
        print(f"     Brand: {result.get('brands')}")
    else:
        print("  ❌ Not found (contribute data at openfoodfacts.org)")

    # Test USDA
    print(f"\nTesting USDA FoodData Central:")
    usda_result = collector.get_from_usda_fooddata("vitamin d")
    if usda_result:
        print(f"  ✅ Found {len(usda_result)} vitamin D products")

    # 2. Manufacturer Catalogs
    print("\n2️⃣ MANUFACTURER CATALOGS")
    print("-"*40)
    collector.get_manufacturer_catalog("Nature Made")

    # 3. Bulk Downloads
    print("\n3️⃣ BULK DATA DOWNLOADS")
    print("-"*40)
    collector.download_open_food_facts_dump()

    # 4. Partner Programs
    print("\n4️⃣ PARTNER & AFFILIATE APIs")
    print("-"*40)
    collector.get_affiliate_api_access()

    # 5. Legal Scraping
    print("\n5️⃣ WEBSITES THAT ALLOW SCRAPING")
    print("-"*40)
    collector.check_scraping_permission("wikipedia.org")

    print("\n" + "="*60)
    print("RECOMMENDED APPROACH FOR YOUR APP:")
    print("="*60)
    print("""
    1. START with Open Food Facts (free, immediate)
    2. ADD USDA database (free, government data)
    3. IMPLEMENT user submissions for missing items
    4. CONSIDER Nutritionix API if you need extensive coverage ($99/month)
    5. PARTNER with one retailer for their product feed
    6. BUILD community features for crowdsourcing
    """)


if __name__ == "__main__":
    demonstrate_legal_methods()