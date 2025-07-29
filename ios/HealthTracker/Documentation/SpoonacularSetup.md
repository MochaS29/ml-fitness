# Spoonacular API Setup Guide

## Quick Start (5 minutes)

### 1. Get Your Free API Key

1. Go to [https://spoonacular.com/food-api](https://spoonacular.com/food-api)
2. Click "Start Now" (free plan)
3. Create an account
4. Copy your API key from the dashboard

### 2. Add API Key to Xcode

In Xcode, edit your scheme:
1. Click "HealthTracker" next to device selector
2. Select "Edit Scheme..."
3. Go to "Run" → "Arguments"
4. Add to "Environment Variables":
   - Name: `SPOONACULAR_API_KEY`
   - Value: `your-api-key-here`

### 3. Test It!

1. Run the app
2. Tap "Scan Dish"
3. Take a photo of any food
4. Watch Spoonacular identify it!

## API Limits

**Free Plan:**
- 150 requests/day
- Perfect for development
- Includes image analysis

**What counts as a request:**
- 1 image scan = 1 request
- 1 recipe search = 1 request
- 1 nutrition lookup = 1 request

## Features Available

### ✅ Image Recognition
- Identifies food categories
- Recognizes specific dishes
- Estimates portions
- Returns nutrition data

### ✅ Recipe Import
- Import from 1000+ websites
- Parse ingredients
- Calculate nutrition

### ✅ Food Search
- Search 600k+ foods
- Get detailed nutrition
- Find similar foods

## Upgrading

When you need more requests:
- $10/month = 1,500 requests
- $30/month = 5,000 requests
- $70/month = 15,000 requests

## Troubleshooting

**"API key not configured"**
- Make sure environment variable is set
- Restart Xcode after adding

**"Food recognition API error"**
- Check your daily limit (150 free)
- Verify API key is correct

**Image not recognized**
- Ensure good lighting
- Center food in frame
- Avoid blurry photos