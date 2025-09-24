#!/usr/bin/env python3
import pyarrow.parquet as pq

parquet_file = pq.ParquetFile('/Users/mocha/Downloads/food.parquet')
schema = parquet_file.schema_arrow

print(f"Total columns: {len(schema.names)}")
print("\nFirst 50 columns:")
for col in sorted(schema.names)[:50]:
    print(f"  {col}")

# Check for category-related columns
print("\nCategory-related columns:")
for col in schema.names:
    if 'categ' in col.lower():
        print(f"  {col}")

print("\nProduct name columns:")
for col in schema.names:
    if 'product' in col.lower() or 'name' in col.lower():
        print(f"  {col}")

print("\nNutrient columns (sample):")
for col in schema.names:
    if 'vitamin' in col.lower() or 'calcium' in col.lower() or 'iron' in col.lower():
        print(f"  {col}")