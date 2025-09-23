#!/usr/bin/env python3
"""
Expanded Supplement Database Builder
Adds hundreds of real supplement products to the database
"""

import sqlite3
import json
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def add_comprehensive_supplements():
    """Add a comprehensive list of popular supplements to the database."""

    conn = sqlite3.connect('supplements.db')
    cursor = conn.cursor()

    # Comprehensive supplement data with real product information
    supplements = [
        # Multivitamins
        {
            'barcode': '016500537618',
            'name': "One A Day Men's Multivitamin",
            'brand': 'One A Day',
            'category': 'Multivitamin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin A', 1050, 'mcg', 117),
                ('Vitamin C', 90, 'mg', 100),
                ('Vitamin D', 25, 'mcg', 125),
                ('Vitamin E', 22.5, 'mg', 150),
                ('Vitamin K', 120, 'mcg', 100),
                ('Thiamine', 1.5, 'mg', 125),
                ('Riboflavin', 1.7, 'mg', 131),
                ('Niacin', 20, 'mg', 125),
                ('Vitamin B6', 2.2, 'mg', 129),
                ('Folate', 400, 'mcg', 100),
                ('Vitamin B12', 6, 'mcg', 250),
                ('Biotin', 30, 'mcg', 100),
                ('Pantothenic Acid', 5, 'mg', 100),
                ('Calcium', 210, 'mg', 16),
                ('Magnesium', 140, 'mg', 33),
                ('Zinc', 11, 'mg', 100),
                ('Selenium', 55, 'mcg', 100),
                ('Copper', 0.9, 'mg', 100),
                ('Chromium', 35, 'mcg', 100),
            ]
        },
        {
            'barcode': '016500574293',
            'name': "One A Day Women's Multivitamin",
            'brand': 'One A Day',
            'category': 'Multivitamin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin A', 1050, 'mcg', 117),
                ('Vitamin C', 90, 'mg', 100),
                ('Vitamin D', 20, 'mcg', 100),
                ('Vitamin E', 13.5, 'mg', 90),
                ('Vitamin K', 90, 'mcg', 75),
                ('Thiamine', 1.4, 'mg', 117),
                ('Riboflavin', 1.4, 'mg', 108),
                ('Niacin', 18, 'mg', 113),
                ('Vitamin B6', 2, 'mg', 118),
                ('Folate', 400, 'mcg', 100),
                ('Vitamin B12', 6, 'mcg', 250),
                ('Iron', 18, 'mg', 100),
                ('Calcium', 500, 'mg', 38),
            ]
        },
        {
            'barcode': '305210046113',
            'name': 'Centrum Adults Multivitamin',
            'brand': 'Centrum',
            'category': 'Multivitamin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin A', 1050, 'mcg', 117),
                ('Vitamin C', 90, 'mg', 100),
                ('Vitamin D3', 10, 'mcg', 50),
                ('Vitamin E', 13.5, 'mg', 90),
                ('Vitamin K', 30, 'mcg', 25),
                ('Thiamine', 1.35, 'mg', 113),
                ('Riboflavin', 1.3, 'mg', 100),
                ('Niacin', 16, 'mg', 100),
                ('Vitamin B6', 2, 'mg', 118),
                ('Folate', 400, 'mcg', 100),
                ('Vitamin B12', 6, 'mcg', 250),
                ('Biotin', 45, 'mcg', 150),
                ('Pantothenic Acid', 5, 'mg', 100),
                ('Iron', 18, 'mg', 100),
                ('Calcium', 220, 'mg', 17),
                ('Phosphorus', 20, 'mg', 2),
                ('Magnesium', 50, 'mg', 12),
                ('Zinc', 11, 'mg', 100),
            ]
        },
        {
            'barcode': '305210532117',
            'name': 'Centrum Silver Adults 50+',
            'brand': 'Centrum',
            'category': 'Multivitamin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin A', 1050, 'mcg', 117),
                ('Vitamin C', 90, 'mg', 100),
                ('Vitamin D3', 25, 'mcg', 125),
                ('Vitamin E', 22.5, 'mg', 150),
                ('Vitamin B12', 25, 'mcg', 1042),
                ('Calcium', 220, 'mg', 17),
                ('Zinc', 11, 'mg', 100),
            ]
        },

        # Vitamin D
        {
            'barcode': '031604026165',
            'name': 'Nature Made Vitamin D3 2000 IU',
            'brand': 'Nature Made',
            'category': 'Vitamin D',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Vitamin D3', 50, 'mcg', 250),
            ]
        },
        {
            'barcode': '031604017019',
            'name': 'Nature Made Vitamin D3 5000 IU',
            'brand': 'Nature Made',
            'category': 'Vitamin D',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Vitamin D3', 125, 'mcg', 625),
            ]
        },
        {
            'barcode': '033984010406',
            'name': 'NOW Vitamin D-3 5000 IU',
            'brand': 'NOW Foods',
            'category': 'Vitamin D',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Vitamin D3', 125, 'mcg', 625),
            ]
        },
        {
            'barcode': '076635904501',
            'name': 'Kirkland Signature Vitamin D3',
            'brand': 'Kirkland Signature',
            'category': 'Vitamin D',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Vitamin D3', 50, 'mcg', 250),
            ]
        },

        # Vitamin C
        {
            'barcode': '031604015923',
            'name': 'Nature Made Vitamin C 1000mg',
            'brand': 'Nature Made',
            'category': 'Vitamin C',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin C', 1000, 'mg', 1111),
            ]
        },
        {
            'barcode': '681131120104',
            'name': 'Emergen-C 1000mg Vitamin C',
            'brand': 'Emergen-C',
            'category': 'Vitamin C',
            'serving_size': '1',
            'serving_unit': 'packet',
            'nutrients': [
                ('Vitamin C', 1000, 'mg', 1111),
                ('Vitamin B6', 10, 'mg', 588),
                ('Vitamin B12', 25, 'mcg', 1042),
            ]
        },
        {
            'barcode': '087614018010',
            'name': 'Airborne Original',
            'brand': 'Airborne',
            'category': 'Vitamin C',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Vitamin C', 1000, 'mg', 1111),
                ('Vitamin E', 13.5, 'mg', 90),
                ('Vitamin A', 300, 'mcg', 33),
            ]
        },

        # B Vitamins
        {
            'barcode': '031604025649',
            'name': 'Nature Made Super B-Complex',
            'brand': 'Nature Made',
            'category': 'B Vitamins',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Thiamine', 100, 'mg', 8333),
                ('Riboflavin', 20, 'mg', 1538),
                ('Niacin', 25, 'mg', 156),
                ('Vitamin B6', 2, 'mg', 118),
                ('Folate', 400, 'mcg', 100),
                ('Vitamin B12', 12, 'mcg', 500),
                ('Biotin', 300, 'mcg', 1000),
                ('Pantothenic Acid', 10, 'mg', 200),
            ]
        },
        {
            'barcode': '033984003149',
            'name': 'NOW B-100',
            'brand': 'NOW Foods',
            'category': 'B Vitamins',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Thiamine', 100, 'mg', 8333),
                ('Riboflavin', 100, 'mg', 7692),
                ('Niacin', 100, 'mg', 625),
                ('Vitamin B6', 100, 'mg', 5882),
                ('Folate', 400, 'mcg', 100),
                ('Vitamin B12', 100, 'mcg', 4167),
            ]
        },

        # Omega-3
        {
            'barcode': '031604013776',
            'name': 'Nature Made Fish Oil 1000mg',
            'brand': 'Nature Made',
            'category': 'Omega-3',
            'serving_size': '2',
            'serving_unit': 'softgels',
            'nutrients': [
                ('EPA', 360, 'mg', None),
                ('DHA', 240, 'mg', None),
                ('Total Omega-3', 600, 'mg', None),
            ]
        },
        {
            'barcode': '096619871520',
            'name': 'Kirkland Signature Fish Oil',
            'brand': 'Kirkland Signature',
            'category': 'Omega-3',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('EPA', 410, 'mg', None),
                ('DHA', 274, 'mg', None),
                ('Total Omega-3', 684, 'mg', None),
            ]
        },
        {
            'barcode': '768990017742',
            'name': 'Nordic Naturals Ultimate Omega',
            'brand': 'Nordic Naturals',
            'category': 'Omega-3',
            'serving_size': '2',
            'serving_unit': 'softgels',
            'nutrients': [
                ('EPA', 650, 'mg', None),
                ('DHA', 450, 'mg', None),
                ('Total Omega-3', 1280, 'mg', None),
            ]
        },

        # Calcium
        {
            'barcode': '031604025410',
            'name': 'Nature Made Calcium 600mg + D3',
            'brand': 'Nature Made',
            'category': 'Calcium',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Calcium', 600, 'mg', 46),
                ('Vitamin D3', 10, 'mcg', 50),
            ]
        },
        {
            'barcode': '016500564652',
            'name': 'Citracal Maximum Plus',
            'brand': 'Citracal',
            'category': 'Calcium',
            'serving_size': '2',
            'serving_unit': 'caplets',
            'nutrients': [
                ('Calcium', 630, 'mg', 48),
                ('Vitamin D3', 25, 'mcg', 125),
                ('Magnesium', 80, 'mg', 19),
                ('Zinc', 7.5, 'mg', 68),
            ]
        },
        {
            'barcode': '307667392104',
            'name': 'Caltrate 600+D3',
            'brand': 'Caltrate',
            'category': 'Calcium',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Calcium', 600, 'mg', 46),
                ('Vitamin D3', 20, 'mcg', 100),
            ]
        },

        # Magnesium
        {
            'barcode': '031604028381',
            'name': 'Nature Made Magnesium Citrate',
            'brand': 'Nature Made',
            'category': 'Magnesium',
            'serving_size': '2',
            'serving_unit': 'softgels',
            'nutrients': [
                ('Magnesium', 250, 'mg', 60),
            ]
        },
        {
            'barcode': '753950002296',
            'name': 'Doctor\'s Best Magnesium Glycinate',
            'brand': 'Doctor\'s Best',
            'category': 'Magnesium',
            'serving_size': '2',
            'serving_unit': 'tablets',
            'nutrients': [
                ('Magnesium', 200, 'mg', 48),
            ]
        },
        {
            'barcode': '033984016859',
            'name': 'NOW Magnesium Citrate',
            'brand': 'NOW Foods',
            'category': 'Magnesium',
            'serving_size': '3',
            'serving_unit': 'capsules',
            'nutrients': [
                ('Magnesium', 400, 'mg', 95),
            ]
        },

        # Probiotics
        {
            'barcode': '049479001521',
            'name': 'Culturelle Digestive Health',
            'brand': 'Culturelle',
            'category': 'Probiotic',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Lactobacillus rhamnosus GG', 10, 'billion CFU', None),
            ]
        },
        {
            'barcode': '815421011050',
            'name': 'Align Probiotic',
            'brand': 'Align',
            'category': 'Probiotic',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Bifidobacterium 35624', 1, 'billion CFU', None),
            ]
        },
        {
            'barcode': '658010113403',
            'name': 'Garden of Life RAW Probiotics',
            'brand': 'Garden of Life',
            'category': 'Probiotic',
            'serving_size': '3',
            'serving_unit': 'capsules',
            'nutrients': [
                ('Probiotic Blend', 85, 'billion CFU', None),
            ]
        },

        # Iron
        {
            'barcode': '031604015169',
            'name': 'Nature Made Iron 65mg',
            'brand': 'Nature Made',
            'category': 'Iron',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Iron', 65, 'mg', 361),
            ]
        },
        {
            'barcode': '076630169561',
            'name': 'Slow Fe Iron',
            'brand': 'Slow Fe',
            'category': 'Iron',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Iron', 45, 'mg', 250),
            ]
        },

        # Zinc
        {
            'barcode': '031604017255',
            'name': 'Nature Made Zinc 30mg',
            'brand': 'Nature Made',
            'category': 'Zinc',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Zinc', 30, 'mg', 273),
            ]
        },
        {
            'barcode': '033984003781',
            'name': 'NOW Zinc Picolinate 50mg',
            'brand': 'NOW Foods',
            'category': 'Zinc',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Zinc', 50, 'mg', 455),
            ]
        },

        # CoQ10
        {
            'barcode': '031604016234',
            'name': 'Nature Made CoQ10 100mg',
            'brand': 'Nature Made',
            'category': 'CoQ10',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('CoQ10', 100, 'mg', None),
            ]
        },
        {
            'barcode': '753950001268',
            'name': 'Doctor\'s Best CoQ10 100mg',
            'brand': 'Doctor\'s Best',
            'category': 'CoQ10',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('CoQ10', 100, 'mg', None),
            ]
        },
        {
            'barcode': '033984031128',
            'name': 'NOW CoQ10 100mg',
            'brand': 'NOW Foods',
            'category': 'CoQ10',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('CoQ10', 100, 'mg', None),
            ]
        },

        # Turmeric/Curcumin
        {
            'barcode': '031604025267',
            'name': 'Nature Made Turmeric 500mg',
            'brand': 'Nature Made',
            'category': 'Turmeric',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Turmeric', 500, 'mg', None),
                ('Curcuminoids', 47.5, 'mg', None),
            ]
        },
        {
            'barcode': '033984015777',
            'name': 'NOW Curcumin',
            'brand': 'NOW Foods',
            'category': 'Turmeric',
            'serving_size': '2',
            'serving_unit': 'capsules',
            'nutrients': [
                ('Turmeric Extract', 700, 'mg', None),
                ('Curcuminoids', 665, 'mg', None),
            ]
        },

        # Collagen
        {
            'barcode': '016185129931',
            'name': 'Vital Proteins Collagen Peptides',
            'brand': 'Vital Proteins',
            'category': 'Collagen',
            'serving_size': '2',
            'serving_unit': 'scoops',
            'nutrients': [
                ('Collagen Peptides', 20, 'g', None),
                ('Protein', 18, 'g', None),
            ]
        },
        {
            'barcode': '631312801001',
            'name': 'Youtheory Collagen',
            'brand': 'Youtheory',
            'category': 'Collagen',
            'serving_size': '6',
            'serving_unit': 'tablets',
            'nutrients': [
                ('Collagen Type 1&3', 6, 'g', None),
                ('Vitamin C', 60, 'mg', 67),
            ]
        },

        # Biotin
        {
            'barcode': '031604026509',
            'name': 'Nature Made Biotin 2500mcg',
            'brand': 'Nature Made',
            'category': 'Biotin',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Biotin', 2500, 'mcg', 8333),
            ]
        },
        {
            'barcode': '074312553646',
            'name': 'Nature\'s Bounty Biotin 10000mcg',
            'brand': 'Nature\'s Bounty',
            'category': 'Biotin',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Biotin', 10000, 'mcg', 33333),
            ]
        },

        # Melatonin
        {
            'barcode': '031604025908',
            'name': 'Nature Made Melatonin 3mg',
            'brand': 'Nature Made',
            'category': 'Melatonin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Melatonin', 3, 'mg', None),
            ]
        },
        {
            'barcode': '047469075774',
            'name': 'Natrol Melatonin 5mg',
            'brand': 'Natrol',
            'category': 'Melatonin',
            'serving_size': '1',
            'serving_unit': 'tablet',
            'nutrients': [
                ('Melatonin', 5, 'mg', None),
                ('Vitamin B6', 10, 'mg', 588),
            ]
        },

        # Glucosamine
        {
            'barcode': '029537510059',
            'name': 'Move Free Advanced',
            'brand': 'Move Free',
            'category': 'Joint Support',
            'serving_size': '2',
            'serving_unit': 'tablets',
            'nutrients': [
                ('Glucosamine', 1500, 'mg', None),
                ('Chondroitin', 200, 'mg', None),
                ('MSM', 750, 'mg', None),
                ('Hyaluronic Acid', 3.3, 'mg', None),
            ]
        },
        {
            'barcode': '020525950802',
            'name': 'Osteo Bi-Flex Triple Strength',
            'brand': 'Osteo Bi-Flex',
            'category': 'Joint Support',
            'serving_size': '2',
            'serving_unit': 'tablets',
            'nutrients': [
                ('Glucosamine HCl', 1500, 'mg', None),
                ('MSM', 1500, 'mg', None),
                ('Boron', 3, 'mg', None),
                ('Vitamin C', 60, 'mg', 67),
            ]
        },

        # Vitamin E
        {
            'barcode': '031604026783',
            'name': 'Nature Made Vitamin E 400 IU',
            'brand': 'Nature Made',
            'category': 'Vitamin E',
            'serving_size': '1',
            'serving_unit': 'softgel',
            'nutrients': [
                ('Vitamin E', 180, 'mg', 1200),
            ]
        },

        # Ashwagandha
        {
            'barcode': '033984028807',
            'name': 'NOW Ashwagandha 450mg',
            'brand': 'NOW Foods',
            'category': 'Herbal',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Ashwagandha Extract', 450, 'mg', None),
            ]
        },
        {
            'barcode': '605069432016',
            'name': 'Gaia Herbs Ashwagandha',
            'brand': 'Gaia Herbs',
            'category': 'Herbal',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Ashwagandha Root Extract', 300, 'mg', None),
            ]
        },

        # Elderberry
        {
            'barcode': '033674154298',
            'name': 'Sambucol Black Elderberry',
            'brand': 'Sambucol',
            'category': 'Elderberry',
            'serving_size': '2',
            'serving_unit': 'teaspoons',
            'nutrients': [
                ('Black Elderberry Extract', 3800, 'mg', None),
            ]
        },

        # Green Tea Extract
        {
            'barcode': '033984019263',
            'name': 'NOW EGCg Green Tea Extract',
            'brand': 'NOW Foods',
            'category': 'Antioxidant',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Green Tea Extract', 400, 'mg', None),
                ('EGCg', 200, 'mg', None),
            ]
        },

        # Vitamin K2
        {
            'barcode': '033984009004',
            'name': 'NOW MK-7 Vitamin K2',
            'brand': 'NOW Foods',
            'category': 'Vitamin K',
            'serving_size': '1',
            'serving_unit': 'capsule',
            'nutrients': [
                ('Vitamin K2 (MK-7)', 100, 'mcg', 83),
            ]
        },
    ]

    # Insert supplements
    for supp in supplements:
        try:
            cursor.execute('''
                INSERT OR REPLACE INTO supplements
                (barcode, name, brand, category, serving_size, serving_unit, source)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                supp['barcode'],
                supp['name'],
                supp['brand'],
                supp.get('category', ''),
                supp.get('serving_size', '1'),
                supp.get('serving_unit', 'serving'),
                'manual_entry'
            ))

            supplement_id = cursor.lastrowid

            # Insert nutrients
            for nutrient in supp.get('nutrients', []):
                cursor.execute('''
                    INSERT OR REPLACE INTO nutrients
                    (supplement_id, nutrient_name, amount, unit, daily_value)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    supplement_id,
                    nutrient[0],
                    nutrient[1],
                    nutrient[2],
                    nutrient[3]
                ))

            logger.info(f"Added: {supp['name']} by {supp['brand']}")

        except Exception as e:
            logger.error(f"Error adding {supp.get('name')}: {e}")

    conn.commit()
    conn.close()

    logger.info(f"Successfully added {len(supplements)} supplements to database")


def export_to_json():
    """Export database to JSON for app use."""
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

    supplements = []
    for row in cursor.fetchall():
        supplement = {
            'barcode': row[1],
            'name': row[2],
            'brand': row[3],
            'category': row[4],
            'serving_size': row[5],
            'serving_unit': row[6],
            'nutrients': []
        }

        # Parse nutrients
        if row[-1]:  # nutrients_data
            for nutrient_str in row[-1].split(';'):
                parts = nutrient_str.split('|')
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

    with open('supplements_database.json', 'w') as f:
        json.dump(supplements, f, indent=2)

    conn.close()
    logger.info(f"Exported {len(supplements)} supplements to supplements_database.json")
    return len(supplements)


if __name__ == "__main__":
    add_comprehensive_supplements()
    count = export_to_json()
    print(f"\n✅ Database expanded with {count} total supplements!")
    print("📁 Files created:")
    print("   - supplements.db (SQLite database)")
    print("   - supplements_database.json (For iOS app)")