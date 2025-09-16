package com.mochasmindlab.mlhealth.data.database;

import androidx.annotation.NonNull;
import androidx.room.DatabaseConfiguration;
import androidx.room.InvalidationTracker;
import androidx.room.RoomDatabase;
import androidx.room.RoomOpenHelper;
import androidx.room.migration.AutoMigrationSpec;
import androidx.room.migration.Migration;
import androidx.room.util.DBUtil;
import androidx.room.util.TableInfo;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteOpenHelper;
import java.lang.Class;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class MLFitnessDatabase_Impl extends MLFitnessDatabase {
  private volatile ExerciseDao _exerciseDao;

  private volatile FoodDao _foodDao;

  private volatile SupplementDao _supplementDao;

  private volatile WeightDao _weightDao;

  private volatile WaterDao _waterDao;

  private volatile CustomFoodDao _customFoodDao;

  private volatile CustomRecipeDao _customRecipeDao;

  private volatile FavoriteRecipeDao _favoriteRecipeDao;

  private volatile MealPlanDao _mealPlanDao;

  private volatile GroceryListDao _groceryListDao;

  @Override
  @NonNull
  protected SupportSQLiteOpenHelper createOpenHelper(@NonNull final DatabaseConfiguration config) {
    final SupportSQLiteOpenHelper.Callback _openCallback = new RoomOpenHelper(config, new RoomOpenHelper.Delegate(1) {
      @Override
      public void createAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS `exercise_entries` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `category` TEXT NOT NULL, `type` TEXT NOT NULL, `date` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL, `duration` INTEGER NOT NULL, `caloriesBurned` REAL NOT NULL, `notes` TEXT, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `food_entries` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `brand` TEXT, `barcode` TEXT, `date` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL, `mealType` TEXT NOT NULL, `servingSize` TEXT NOT NULL, `servingUnit` TEXT NOT NULL, `servingCount` REAL NOT NULL, `calories` REAL NOT NULL, `protein` REAL NOT NULL, `carbs` REAL NOT NULL, `fat` REAL NOT NULL, `fiber` REAL, `sugar` REAL, `sodium` REAL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `supplement_entries` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `brand` TEXT, `date` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL, `servingSize` TEXT NOT NULL, `servingUnit` TEXT NOT NULL, `imageData` BLOB, `nutrients` TEXT NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `weight_entries` (`id` TEXT NOT NULL, `weight` REAL NOT NULL, `date` INTEGER NOT NULL, `timestamp` INTEGER NOT NULL, `notes` TEXT, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `water_entries` (`id` TEXT NOT NULL, `amount` REAL NOT NULL, `unit` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `custom_foods` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `brand` TEXT, `barcode` TEXT, `category` TEXT, `source` TEXT, `fdcId` INTEGER, `isUserCreated` INTEGER NOT NULL, `createdDate` INTEGER NOT NULL, `servingSize` TEXT NOT NULL, `servingUnit` TEXT NOT NULL, `calories` REAL NOT NULL, `protein` REAL NOT NULL, `carbs` REAL NOT NULL, `fat` REAL NOT NULL, `saturatedFat` REAL, `fiber` REAL, `sugar` REAL, `sodium` REAL, `cholesterol` REAL, `additionalNutrients` TEXT NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `custom_recipes` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `category` TEXT NOT NULL, `source` TEXT, `isUserCreated` INTEGER NOT NULL, `isFavorite` INTEGER NOT NULL, `createdDate` INTEGER NOT NULL, `prepTime` INTEGER NOT NULL, `cookTime` INTEGER NOT NULL, `servings` INTEGER NOT NULL, `imageData` BLOB, `ingredients` TEXT NOT NULL, `instructions` TEXT NOT NULL, `tags` TEXT NOT NULL, `calories` REAL NOT NULL, `protein` REAL NOT NULL, `carbs` REAL NOT NULL, `fat` REAL NOT NULL, `fiber` REAL, `sugar` REAL, `sodium` REAL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `favorite_recipes` (`id` TEXT NOT NULL, `recipeId` TEXT NOT NULL, `recipeName` TEXT NOT NULL, `category` TEXT NOT NULL, `source` TEXT, `imageURL` TEXT, `dateAdded` INTEGER NOT NULL, `prepTime` INTEGER NOT NULL, `cookTime` INTEGER NOT NULL, `servings` INTEGER NOT NULL, `rating` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `meal_plans` (`id` TEXT NOT NULL, `date` INTEGER NOT NULL, `mealType` TEXT NOT NULL, `recipeId` TEXT, `recipeName` TEXT NOT NULL, `servings` INTEGER NOT NULL, `notes` TEXT, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS `grocery_lists` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `createdDate` INTEGER NOT NULL, `isCompleted` INTEGER NOT NULL, `items` TEXT NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)");
        db.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, '2e2e8b8b582f3738384497c4980ee59b')");
      }

      @Override
      public void dropAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("DROP TABLE IF EXISTS `exercise_entries`");
        db.execSQL("DROP TABLE IF EXISTS `food_entries`");
        db.execSQL("DROP TABLE IF EXISTS `supplement_entries`");
        db.execSQL("DROP TABLE IF EXISTS `weight_entries`");
        db.execSQL("DROP TABLE IF EXISTS `water_entries`");
        db.execSQL("DROP TABLE IF EXISTS `custom_foods`");
        db.execSQL("DROP TABLE IF EXISTS `custom_recipes`");
        db.execSQL("DROP TABLE IF EXISTS `favorite_recipes`");
        db.execSQL("DROP TABLE IF EXISTS `meal_plans`");
        db.execSQL("DROP TABLE IF EXISTS `grocery_lists`");
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onDestructiveMigration(db);
          }
        }
      }

      @Override
      public void onCreate(@NonNull final SupportSQLiteDatabase db) {
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onCreate(db);
          }
        }
      }

      @Override
      public void onOpen(@NonNull final SupportSQLiteDatabase db) {
        mDatabase = db;
        internalInitInvalidationTracker(db);
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onOpen(db);
          }
        }
      }

      @Override
      public void onPreMigrate(@NonNull final SupportSQLiteDatabase db) {
        DBUtil.dropFtsSyncTriggers(db);
      }

      @Override
      public void onPostMigrate(@NonNull final SupportSQLiteDatabase db) {
      }

      @Override
      @NonNull
      public RoomOpenHelper.ValidationResult onValidateSchema(
          @NonNull final SupportSQLiteDatabase db) {
        final HashMap<String, TableInfo.Column> _columnsExerciseEntries = new HashMap<String, TableInfo.Column>(9);
        _columnsExerciseEntries.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("category", new TableInfo.Column("category", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("type", new TableInfo.Column("type", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("date", new TableInfo.Column("date", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("duration", new TableInfo.Column("duration", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("caloriesBurned", new TableInfo.Column("caloriesBurned", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExerciseEntries.put("notes", new TableInfo.Column("notes", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysExerciseEntries = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesExerciseEntries = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoExerciseEntries = new TableInfo("exercise_entries", _columnsExerciseEntries, _foreignKeysExerciseEntries, _indicesExerciseEntries);
        final TableInfo _existingExerciseEntries = TableInfo.read(db, "exercise_entries");
        if (!_infoExerciseEntries.equals(_existingExerciseEntries)) {
          return new RoomOpenHelper.ValidationResult(false, "exercise_entries(com.mochasmindlab.mlhealth.data.entities.ExerciseEntry).\n"
                  + " Expected:\n" + _infoExerciseEntries + "\n"
                  + " Found:\n" + _existingExerciseEntries);
        }
        final HashMap<String, TableInfo.Column> _columnsFoodEntries = new HashMap<String, TableInfo.Column>(17);
        _columnsFoodEntries.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("brand", new TableInfo.Column("brand", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("barcode", new TableInfo.Column("barcode", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("date", new TableInfo.Column("date", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("mealType", new TableInfo.Column("mealType", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("servingSize", new TableInfo.Column("servingSize", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("servingUnit", new TableInfo.Column("servingUnit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("servingCount", new TableInfo.Column("servingCount", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("calories", new TableInfo.Column("calories", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("protein", new TableInfo.Column("protein", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("carbs", new TableInfo.Column("carbs", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("fat", new TableInfo.Column("fat", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("fiber", new TableInfo.Column("fiber", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("sugar", new TableInfo.Column("sugar", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFoodEntries.put("sodium", new TableInfo.Column("sodium", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysFoodEntries = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesFoodEntries = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoFoodEntries = new TableInfo("food_entries", _columnsFoodEntries, _foreignKeysFoodEntries, _indicesFoodEntries);
        final TableInfo _existingFoodEntries = TableInfo.read(db, "food_entries");
        if (!_infoFoodEntries.equals(_existingFoodEntries)) {
          return new RoomOpenHelper.ValidationResult(false, "food_entries(com.mochasmindlab.mlhealth.data.entities.FoodEntry).\n"
                  + " Expected:\n" + _infoFoodEntries + "\n"
                  + " Found:\n" + _existingFoodEntries);
        }
        final HashMap<String, TableInfo.Column> _columnsSupplementEntries = new HashMap<String, TableInfo.Column>(9);
        _columnsSupplementEntries.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("brand", new TableInfo.Column("brand", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("date", new TableInfo.Column("date", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("servingSize", new TableInfo.Column("servingSize", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("servingUnit", new TableInfo.Column("servingUnit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("imageData", new TableInfo.Column("imageData", "BLOB", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSupplementEntries.put("nutrients", new TableInfo.Column("nutrients", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysSupplementEntries = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesSupplementEntries = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoSupplementEntries = new TableInfo("supplement_entries", _columnsSupplementEntries, _foreignKeysSupplementEntries, _indicesSupplementEntries);
        final TableInfo _existingSupplementEntries = TableInfo.read(db, "supplement_entries");
        if (!_infoSupplementEntries.equals(_existingSupplementEntries)) {
          return new RoomOpenHelper.ValidationResult(false, "supplement_entries(com.mochasmindlab.mlhealth.data.entities.SupplementEntry).\n"
                  + " Expected:\n" + _infoSupplementEntries + "\n"
                  + " Found:\n" + _existingSupplementEntries);
        }
        final HashMap<String, TableInfo.Column> _columnsWeightEntries = new HashMap<String, TableInfo.Column>(5);
        _columnsWeightEntries.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWeightEntries.put("weight", new TableInfo.Column("weight", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWeightEntries.put("date", new TableInfo.Column("date", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWeightEntries.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWeightEntries.put("notes", new TableInfo.Column("notes", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysWeightEntries = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesWeightEntries = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoWeightEntries = new TableInfo("weight_entries", _columnsWeightEntries, _foreignKeysWeightEntries, _indicesWeightEntries);
        final TableInfo _existingWeightEntries = TableInfo.read(db, "weight_entries");
        if (!_infoWeightEntries.equals(_existingWeightEntries)) {
          return new RoomOpenHelper.ValidationResult(false, "weight_entries(com.mochasmindlab.mlhealth.data.entities.WeightEntry).\n"
                  + " Expected:\n" + _infoWeightEntries + "\n"
                  + " Found:\n" + _existingWeightEntries);
        }
        final HashMap<String, TableInfo.Column> _columnsWaterEntries = new HashMap<String, TableInfo.Column>(4);
        _columnsWaterEntries.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWaterEntries.put("amount", new TableInfo.Column("amount", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWaterEntries.put("unit", new TableInfo.Column("unit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsWaterEntries.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysWaterEntries = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesWaterEntries = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoWaterEntries = new TableInfo("water_entries", _columnsWaterEntries, _foreignKeysWaterEntries, _indicesWaterEntries);
        final TableInfo _existingWaterEntries = TableInfo.read(db, "water_entries");
        if (!_infoWaterEntries.equals(_existingWaterEntries)) {
          return new RoomOpenHelper.ValidationResult(false, "water_entries(com.mochasmindlab.mlhealth.data.entities.WaterEntry).\n"
                  + " Expected:\n" + _infoWaterEntries + "\n"
                  + " Found:\n" + _existingWaterEntries);
        }
        final HashMap<String, TableInfo.Column> _columnsCustomFoods = new HashMap<String, TableInfo.Column>(21);
        _columnsCustomFoods.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("brand", new TableInfo.Column("brand", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("barcode", new TableInfo.Column("barcode", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("category", new TableInfo.Column("category", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("source", new TableInfo.Column("source", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("fdcId", new TableInfo.Column("fdcId", "INTEGER", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("isUserCreated", new TableInfo.Column("isUserCreated", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("createdDate", new TableInfo.Column("createdDate", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("servingSize", new TableInfo.Column("servingSize", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("servingUnit", new TableInfo.Column("servingUnit", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("calories", new TableInfo.Column("calories", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("protein", new TableInfo.Column("protein", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("carbs", new TableInfo.Column("carbs", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("fat", new TableInfo.Column("fat", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("saturatedFat", new TableInfo.Column("saturatedFat", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("fiber", new TableInfo.Column("fiber", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("sugar", new TableInfo.Column("sugar", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("sodium", new TableInfo.Column("sodium", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("cholesterol", new TableInfo.Column("cholesterol", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomFoods.put("additionalNutrients", new TableInfo.Column("additionalNutrients", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysCustomFoods = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesCustomFoods = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoCustomFoods = new TableInfo("custom_foods", _columnsCustomFoods, _foreignKeysCustomFoods, _indicesCustomFoods);
        final TableInfo _existingCustomFoods = TableInfo.read(db, "custom_foods");
        if (!_infoCustomFoods.equals(_existingCustomFoods)) {
          return new RoomOpenHelper.ValidationResult(false, "custom_foods(com.mochasmindlab.mlhealth.data.entities.CustomFood).\n"
                  + " Expected:\n" + _infoCustomFoods + "\n"
                  + " Found:\n" + _existingCustomFoods);
        }
        final HashMap<String, TableInfo.Column> _columnsCustomRecipes = new HashMap<String, TableInfo.Column>(21);
        _columnsCustomRecipes.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("category", new TableInfo.Column("category", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("source", new TableInfo.Column("source", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("isUserCreated", new TableInfo.Column("isUserCreated", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("isFavorite", new TableInfo.Column("isFavorite", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("createdDate", new TableInfo.Column("createdDate", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("prepTime", new TableInfo.Column("prepTime", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("cookTime", new TableInfo.Column("cookTime", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("servings", new TableInfo.Column("servings", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("imageData", new TableInfo.Column("imageData", "BLOB", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("ingredients", new TableInfo.Column("ingredients", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("instructions", new TableInfo.Column("instructions", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("tags", new TableInfo.Column("tags", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("calories", new TableInfo.Column("calories", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("protein", new TableInfo.Column("protein", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("carbs", new TableInfo.Column("carbs", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("fat", new TableInfo.Column("fat", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("fiber", new TableInfo.Column("fiber", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("sugar", new TableInfo.Column("sugar", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsCustomRecipes.put("sodium", new TableInfo.Column("sodium", "REAL", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysCustomRecipes = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesCustomRecipes = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoCustomRecipes = new TableInfo("custom_recipes", _columnsCustomRecipes, _foreignKeysCustomRecipes, _indicesCustomRecipes);
        final TableInfo _existingCustomRecipes = TableInfo.read(db, "custom_recipes");
        if (!_infoCustomRecipes.equals(_existingCustomRecipes)) {
          return new RoomOpenHelper.ValidationResult(false, "custom_recipes(com.mochasmindlab.mlhealth.data.entities.CustomRecipe).\n"
                  + " Expected:\n" + _infoCustomRecipes + "\n"
                  + " Found:\n" + _existingCustomRecipes);
        }
        final HashMap<String, TableInfo.Column> _columnsFavoriteRecipes = new HashMap<String, TableInfo.Column>(11);
        _columnsFavoriteRecipes.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("recipeId", new TableInfo.Column("recipeId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("recipeName", new TableInfo.Column("recipeName", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("category", new TableInfo.Column("category", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("source", new TableInfo.Column("source", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("imageURL", new TableInfo.Column("imageURL", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("dateAdded", new TableInfo.Column("dateAdded", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("prepTime", new TableInfo.Column("prepTime", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("cookTime", new TableInfo.Column("cookTime", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("servings", new TableInfo.Column("servings", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFavoriteRecipes.put("rating", new TableInfo.Column("rating", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysFavoriteRecipes = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesFavoriteRecipes = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoFavoriteRecipes = new TableInfo("favorite_recipes", _columnsFavoriteRecipes, _foreignKeysFavoriteRecipes, _indicesFavoriteRecipes);
        final TableInfo _existingFavoriteRecipes = TableInfo.read(db, "favorite_recipes");
        if (!_infoFavoriteRecipes.equals(_existingFavoriteRecipes)) {
          return new RoomOpenHelper.ValidationResult(false, "favorite_recipes(com.mochasmindlab.mlhealth.data.entities.FavoriteRecipe).\n"
                  + " Expected:\n" + _infoFavoriteRecipes + "\n"
                  + " Found:\n" + _existingFavoriteRecipes);
        }
        final HashMap<String, TableInfo.Column> _columnsMealPlans = new HashMap<String, TableInfo.Column>(7);
        _columnsMealPlans.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("date", new TableInfo.Column("date", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("mealType", new TableInfo.Column("mealType", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("recipeId", new TableInfo.Column("recipeId", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("recipeName", new TableInfo.Column("recipeName", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("servings", new TableInfo.Column("servings", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsMealPlans.put("notes", new TableInfo.Column("notes", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysMealPlans = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesMealPlans = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoMealPlans = new TableInfo("meal_plans", _columnsMealPlans, _foreignKeysMealPlans, _indicesMealPlans);
        final TableInfo _existingMealPlans = TableInfo.read(db, "meal_plans");
        if (!_infoMealPlans.equals(_existingMealPlans)) {
          return new RoomOpenHelper.ValidationResult(false, "meal_plans(com.mochasmindlab.mlhealth.data.entities.MealPlan).\n"
                  + " Expected:\n" + _infoMealPlans + "\n"
                  + " Found:\n" + _existingMealPlans);
        }
        final HashMap<String, TableInfo.Column> _columnsGroceryLists = new HashMap<String, TableInfo.Column>(5);
        _columnsGroceryLists.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsGroceryLists.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsGroceryLists.put("createdDate", new TableInfo.Column("createdDate", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsGroceryLists.put("isCompleted", new TableInfo.Column("isCompleted", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsGroceryLists.put("items", new TableInfo.Column("items", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysGroceryLists = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesGroceryLists = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoGroceryLists = new TableInfo("grocery_lists", _columnsGroceryLists, _foreignKeysGroceryLists, _indicesGroceryLists);
        final TableInfo _existingGroceryLists = TableInfo.read(db, "grocery_lists");
        if (!_infoGroceryLists.equals(_existingGroceryLists)) {
          return new RoomOpenHelper.ValidationResult(false, "grocery_lists(com.mochasmindlab.mlhealth.data.entities.GroceryList).\n"
                  + " Expected:\n" + _infoGroceryLists + "\n"
                  + " Found:\n" + _existingGroceryLists);
        }
        return new RoomOpenHelper.ValidationResult(true, null);
      }
    }, "2e2e8b8b582f3738384497c4980ee59b", "c474a46d13bdff23f4d8e8e5a38e4cb1");
    final SupportSQLiteOpenHelper.Configuration _sqliteConfig = SupportSQLiteOpenHelper.Configuration.builder(config.context).name(config.name).callback(_openCallback).build();
    final SupportSQLiteOpenHelper _helper = config.sqliteOpenHelperFactory.create(_sqliteConfig);
    return _helper;
  }

  @Override
  @NonNull
  protected InvalidationTracker createInvalidationTracker() {
    final HashMap<String, String> _shadowTablesMap = new HashMap<String, String>(0);
    final HashMap<String, Set<String>> _viewTables = new HashMap<String, Set<String>>(0);
    return new InvalidationTracker(this, _shadowTablesMap, _viewTables, "exercise_entries","food_entries","supplement_entries","weight_entries","water_entries","custom_foods","custom_recipes","favorite_recipes","meal_plans","grocery_lists");
  }

  @Override
  public void clearAllTables() {
    super.assertNotMainThread();
    final SupportSQLiteDatabase _db = super.getOpenHelper().getWritableDatabase();
    try {
      super.beginTransaction();
      _db.execSQL("DELETE FROM `exercise_entries`");
      _db.execSQL("DELETE FROM `food_entries`");
      _db.execSQL("DELETE FROM `supplement_entries`");
      _db.execSQL("DELETE FROM `weight_entries`");
      _db.execSQL("DELETE FROM `water_entries`");
      _db.execSQL("DELETE FROM `custom_foods`");
      _db.execSQL("DELETE FROM `custom_recipes`");
      _db.execSQL("DELETE FROM `favorite_recipes`");
      _db.execSQL("DELETE FROM `meal_plans`");
      _db.execSQL("DELETE FROM `grocery_lists`");
      super.setTransactionSuccessful();
    } finally {
      super.endTransaction();
      _db.query("PRAGMA wal_checkpoint(FULL)").close();
      if (!_db.inTransaction()) {
        _db.execSQL("VACUUM");
      }
    }
  }

  @Override
  @NonNull
  protected Map<Class<?>, List<Class<?>>> getRequiredTypeConverters() {
    final HashMap<Class<?>, List<Class<?>>> _typeConvertersMap = new HashMap<Class<?>, List<Class<?>>>();
    _typeConvertersMap.put(ExerciseDao.class, ExerciseDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(FoodDao.class, FoodDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(SupplementDao.class, SupplementDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(WeightDao.class, WeightDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(WaterDao.class, WaterDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(CustomFoodDao.class, CustomFoodDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(CustomRecipeDao.class, CustomRecipeDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(FavoriteRecipeDao.class, FavoriteRecipeDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(MealPlanDao.class, MealPlanDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(GroceryListDao.class, GroceryListDao_Impl.getRequiredConverters());
    return _typeConvertersMap;
  }

  @Override
  @NonNull
  public Set<Class<? extends AutoMigrationSpec>> getRequiredAutoMigrationSpecs() {
    final HashSet<Class<? extends AutoMigrationSpec>> _autoMigrationSpecsSet = new HashSet<Class<? extends AutoMigrationSpec>>();
    return _autoMigrationSpecsSet;
  }

  @Override
  @NonNull
  public List<Migration> getAutoMigrations(
      @NonNull final Map<Class<? extends AutoMigrationSpec>, AutoMigrationSpec> autoMigrationSpecs) {
    final List<Migration> _autoMigrations = new ArrayList<Migration>();
    return _autoMigrations;
  }

  @Override
  public ExerciseDao exerciseDao() {
    if (_exerciseDao != null) {
      return _exerciseDao;
    } else {
      synchronized(this) {
        if(_exerciseDao == null) {
          _exerciseDao = new ExerciseDao_Impl(this);
        }
        return _exerciseDao;
      }
    }
  }

  @Override
  public FoodDao foodDao() {
    if (_foodDao != null) {
      return _foodDao;
    } else {
      synchronized(this) {
        if(_foodDao == null) {
          _foodDao = new FoodDao_Impl(this);
        }
        return _foodDao;
      }
    }
  }

  @Override
  public SupplementDao supplementDao() {
    if (_supplementDao != null) {
      return _supplementDao;
    } else {
      synchronized(this) {
        if(_supplementDao == null) {
          _supplementDao = new SupplementDao_Impl(this);
        }
        return _supplementDao;
      }
    }
  }

  @Override
  public WeightDao weightDao() {
    if (_weightDao != null) {
      return _weightDao;
    } else {
      synchronized(this) {
        if(_weightDao == null) {
          _weightDao = new WeightDao_Impl(this);
        }
        return _weightDao;
      }
    }
  }

  @Override
  public WaterDao waterDao() {
    if (_waterDao != null) {
      return _waterDao;
    } else {
      synchronized(this) {
        if(_waterDao == null) {
          _waterDao = new WaterDao_Impl(this);
        }
        return _waterDao;
      }
    }
  }

  @Override
  public CustomFoodDao customFoodDao() {
    if (_customFoodDao != null) {
      return _customFoodDao;
    } else {
      synchronized(this) {
        if(_customFoodDao == null) {
          _customFoodDao = new CustomFoodDao_Impl(this);
        }
        return _customFoodDao;
      }
    }
  }

  @Override
  public CustomRecipeDao customRecipeDao() {
    if (_customRecipeDao != null) {
      return _customRecipeDao;
    } else {
      synchronized(this) {
        if(_customRecipeDao == null) {
          _customRecipeDao = new CustomRecipeDao_Impl(this);
        }
        return _customRecipeDao;
      }
    }
  }

  @Override
  public FavoriteRecipeDao favoriteRecipeDao() {
    if (_favoriteRecipeDao != null) {
      return _favoriteRecipeDao;
    } else {
      synchronized(this) {
        if(_favoriteRecipeDao == null) {
          _favoriteRecipeDao = new FavoriteRecipeDao_Impl(this);
        }
        return _favoriteRecipeDao;
      }
    }
  }

  @Override
  public MealPlanDao mealPlanDao() {
    if (_mealPlanDao != null) {
      return _mealPlanDao;
    } else {
      synchronized(this) {
        if(_mealPlanDao == null) {
          _mealPlanDao = new MealPlanDao_Impl(this);
        }
        return _mealPlanDao;
      }
    }
  }

  @Override
  public GroceryListDao groceryListDao() {
    if (_groceryListDao != null) {
      return _groceryListDao;
    } else {
      synchronized(this) {
        if(_groceryListDao == null) {
          _groceryListDao = new GroceryListDao_Impl(this);
        }
        return _groceryListDao;
      }
    }
  }
}
