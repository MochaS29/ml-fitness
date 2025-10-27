# Environment Variables Setup for HealthTracker

## Required API Keys

Add these environment variables to your Xcode scheme:

### 1. Open Xcode Scheme Editor
- Select the HealthTracker scheme in the toolbar
- Click "Edit Scheme..." or use Cmd+<

### 2. Add Environment Variables
Go to Run → Arguments → Environment Variables and add:

| Variable Name | Description | Where to Get |
|--------------|-------------|--------------|
| `NUTRITIONIX_APP_ID` | Nutritionix App ID | https://www.nutritionix.com/api |
| `NUTRITIONIX_APP_KEY` | Nutritionix App Key | https://www.nutritionix.com/api |
| `SPOONACULAR_API_KEY` | Spoonacular API Key | https://spoonacular.com/food-api/pricing |
| `USDA_API_KEY` | USDA FoodData Central Key | https://fdc.nal.usda.gov/api-key-signup.html |
| `EDAMAM_APP_ID` | Edamam App ID | https://developer.edamam.com/ |
| `EDAMAM_APP_KEY` | Edamam App Key | https://developer.edamam.com/ |
| `FATSECRET_CLIENT_ID` | FatSecret Client ID | https://platform.fatsecret.com/api/ |
| `FATSECRET_CLIENT_SECRET` | FatSecret Client Secret | https://platform.fatsecret.com/api/ |

### 3. Optional Settings
| Variable Name | Description | Default |
|--------------|-------------|---------|
| `USE_MOCK_DATA` | Force use of mock data | false |

## Example Values (for testing only)
```
NUTRITIONIX_APP_ID=your_app_id_here
NUTRITIONIX_APP_KEY=your_app_key_here
SPOONACULAR_API_KEY=your_spoonacular_key_here
USDA_API_KEY=DEMO_KEY
```

## Notes
- The app will work without API keys using mock data
- USDA API provides a "DEMO_KEY" for testing with limited requests
- For production use, obtain your own API keys from the providers listed above