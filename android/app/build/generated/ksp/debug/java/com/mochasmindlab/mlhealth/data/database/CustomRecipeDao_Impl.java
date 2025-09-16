package com.mochasmindlab.mlhealth.data.database;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.mochasmindlab.mlhealth.data.entities.Converters;
import com.mochasmindlab.mlhealth.data.entities.CustomRecipe;
import com.mochasmindlab.mlhealth.data.entities.StringListConverter;
import java.lang.Class;
import java.lang.Double;
import java.lang.Exception;
import java.lang.IllegalStateException;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class CustomRecipeDao_Impl implements CustomRecipeDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<CustomRecipe> __insertionAdapterOfCustomRecipe;

  private final Converters __converters = new Converters();

  private final StringListConverter __stringListConverter = new StringListConverter();

  private final EntityDeletionOrUpdateAdapter<CustomRecipe> __deletionAdapterOfCustomRecipe;

  private final EntityDeletionOrUpdateAdapter<CustomRecipe> __updateAdapterOfCustomRecipe;

  public CustomRecipeDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfCustomRecipe = new EntityInsertionAdapter<CustomRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `custom_recipes` (`id`,`name`,`category`,`source`,`isUserCreated`,`isFavorite`,`createdDate`,`prepTime`,`cookTime`,`servings`,`imageData`,`ingredients`,`instructions`,`tags`,`calories`,`protein`,`carbs`,`fat`,`fiber`,`sugar`,`sodium`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        statement.bindString(3, entity.getCategory());
        if (entity.getSource() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getSource());
        }
        final int _tmp_1 = entity.isUserCreated() ? 1 : 0;
        statement.bindLong(5, _tmp_1);
        final int _tmp_2 = entity.isFavorite() ? 1 : 0;
        statement.bindLong(6, _tmp_2);
        final Long _tmp_3 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_3 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_3);
        }
        statement.bindLong(8, entity.getPrepTime());
        statement.bindLong(9, entity.getCookTime());
        statement.bindLong(10, entity.getServings());
        if (entity.getImageData() == null) {
          statement.bindNull(11);
        } else {
          statement.bindBlob(11, entity.getImageData());
        }
        final String _tmp_4 = __stringListConverter.fromStringList(entity.getIngredients());
        statement.bindString(12, _tmp_4);
        final String _tmp_5 = __stringListConverter.fromStringList(entity.getInstructions());
        statement.bindString(13, _tmp_5);
        final String _tmp_6 = __stringListConverter.fromStringList(entity.getTags());
        statement.bindString(14, _tmp_6);
        statement.bindDouble(15, entity.getCalories());
        statement.bindDouble(16, entity.getProtein());
        statement.bindDouble(17, entity.getCarbs());
        statement.bindDouble(18, entity.getFat());
        if (entity.getFiber() == null) {
          statement.bindNull(19);
        } else {
          statement.bindDouble(19, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(20);
        } else {
          statement.bindDouble(20, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(21);
        } else {
          statement.bindDouble(21, entity.getSodium());
        }
      }
    };
    this.__deletionAdapterOfCustomRecipe = new EntityDeletionOrUpdateAdapter<CustomRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `custom_recipes` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfCustomRecipe = new EntityDeletionOrUpdateAdapter<CustomRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `custom_recipes` SET `id` = ?,`name` = ?,`category` = ?,`source` = ?,`isUserCreated` = ?,`isFavorite` = ?,`createdDate` = ?,`prepTime` = ?,`cookTime` = ?,`servings` = ?,`imageData` = ?,`ingredients` = ?,`instructions` = ?,`tags` = ?,`calories` = ?,`protein` = ?,`carbs` = ?,`fat` = ?,`fiber` = ?,`sugar` = ?,`sodium` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        statement.bindString(3, entity.getCategory());
        if (entity.getSource() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getSource());
        }
        final int _tmp_1 = entity.isUserCreated() ? 1 : 0;
        statement.bindLong(5, _tmp_1);
        final int _tmp_2 = entity.isFavorite() ? 1 : 0;
        statement.bindLong(6, _tmp_2);
        final Long _tmp_3 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_3 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_3);
        }
        statement.bindLong(8, entity.getPrepTime());
        statement.bindLong(9, entity.getCookTime());
        statement.bindLong(10, entity.getServings());
        if (entity.getImageData() == null) {
          statement.bindNull(11);
        } else {
          statement.bindBlob(11, entity.getImageData());
        }
        final String _tmp_4 = __stringListConverter.fromStringList(entity.getIngredients());
        statement.bindString(12, _tmp_4);
        final String _tmp_5 = __stringListConverter.fromStringList(entity.getInstructions());
        statement.bindString(13, _tmp_5);
        final String _tmp_6 = __stringListConverter.fromStringList(entity.getTags());
        statement.bindString(14, _tmp_6);
        statement.bindDouble(15, entity.getCalories());
        statement.bindDouble(16, entity.getProtein());
        statement.bindDouble(17, entity.getCarbs());
        statement.bindDouble(18, entity.getFat());
        if (entity.getFiber() == null) {
          statement.bindNull(19);
        } else {
          statement.bindDouble(19, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(20);
        } else {
          statement.bindDouble(20, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(21);
        } else {
          statement.bindDouble(21, entity.getSodium());
        }
        final String _tmp_7 = __converters.uuidToString(entity.getId());
        if (_tmp_7 == null) {
          statement.bindNull(22);
        } else {
          statement.bindString(22, _tmp_7);
        }
      }
    };
  }

  @Override
  public Object insert(final CustomRecipe recipe, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfCustomRecipe.insert(recipe);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final CustomRecipe recipe, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfCustomRecipe.handle(recipe);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final CustomRecipe recipe, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfCustomRecipe.handle(recipe);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getAllRecipes(final Continuation<? super List<CustomRecipe>> $completion) {
    final String _sql = "SELECT * FROM custom_recipes ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomRecipe>>() {
      @Override
      @NonNull
      public List<CustomRecipe> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfIsFavorite = CursorUtil.getColumnIndexOrThrow(_cursor, "isFavorite");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfImageData = CursorUtil.getColumnIndexOrThrow(_cursor, "imageData");
          final int _cursorIndexOfIngredients = CursorUtil.getColumnIndexOrThrow(_cursor, "ingredients");
          final int _cursorIndexOfInstructions = CursorUtil.getColumnIndexOrThrow(_cursor, "instructions");
          final int _cursorIndexOfTags = CursorUtil.getColumnIndexOrThrow(_cursor, "tags");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<CustomRecipe> _result = new ArrayList<CustomRecipe>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomRecipe _item;
            final UUID _tmpId;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_1 = __converters.fromUUID(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_1;
            }
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final boolean _tmpIsFavorite;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfIsFavorite);
            _tmpIsFavorite = _tmp_3 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_5 = __converters.fromTimestamp(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_5;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final byte[] _tmpImageData;
            if (_cursor.isNull(_cursorIndexOfImageData)) {
              _tmpImageData = null;
            } else {
              _tmpImageData = _cursor.getBlob(_cursorIndexOfImageData);
            }
            final List<String> _tmpIngredients;
            final String _tmp_6;
            _tmp_6 = _cursor.getString(_cursorIndexOfIngredients);
            _tmpIngredients = __stringListConverter.toStringList(_tmp_6);
            final List<String> _tmpInstructions;
            final String _tmp_7;
            _tmp_7 = _cursor.getString(_cursorIndexOfInstructions);
            _tmpInstructions = __stringListConverter.toStringList(_tmp_7);
            final List<String> _tmpTags;
            final String _tmp_8;
            _tmp_8 = _cursor.getString(_cursorIndexOfTags);
            _tmpTags = __stringListConverter.toStringList(_tmp_8);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpFiber;
            if (_cursor.isNull(_cursorIndexOfFiber)) {
              _tmpFiber = null;
            } else {
              _tmpFiber = _cursor.getDouble(_cursorIndexOfFiber);
            }
            final Double _tmpSugar;
            if (_cursor.isNull(_cursorIndexOfSugar)) {
              _tmpSugar = null;
            } else {
              _tmpSugar = _cursor.getDouble(_cursorIndexOfSugar);
            }
            final Double _tmpSodium;
            if (_cursor.isNull(_cursorIndexOfSodium)) {
              _tmpSodium = null;
            } else {
              _tmpSodium = _cursor.getDouble(_cursorIndexOfSodium);
            }
            _item = new CustomRecipe(_tmpId,_tmpName,_tmpCategory,_tmpSource,_tmpIsUserCreated,_tmpIsFavorite,_tmpCreatedDate,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpImageData,_tmpIngredients,_tmpInstructions,_tmpTags,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getFavoriteRecipes(final Continuation<? super List<CustomRecipe>> $completion) {
    final String _sql = "SELECT * FROM custom_recipes WHERE isFavorite = 1 ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomRecipe>>() {
      @Override
      @NonNull
      public List<CustomRecipe> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfIsFavorite = CursorUtil.getColumnIndexOrThrow(_cursor, "isFavorite");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfImageData = CursorUtil.getColumnIndexOrThrow(_cursor, "imageData");
          final int _cursorIndexOfIngredients = CursorUtil.getColumnIndexOrThrow(_cursor, "ingredients");
          final int _cursorIndexOfInstructions = CursorUtil.getColumnIndexOrThrow(_cursor, "instructions");
          final int _cursorIndexOfTags = CursorUtil.getColumnIndexOrThrow(_cursor, "tags");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<CustomRecipe> _result = new ArrayList<CustomRecipe>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomRecipe _item;
            final UUID _tmpId;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_1 = __converters.fromUUID(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_1;
            }
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final boolean _tmpIsFavorite;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfIsFavorite);
            _tmpIsFavorite = _tmp_3 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_5 = __converters.fromTimestamp(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_5;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final byte[] _tmpImageData;
            if (_cursor.isNull(_cursorIndexOfImageData)) {
              _tmpImageData = null;
            } else {
              _tmpImageData = _cursor.getBlob(_cursorIndexOfImageData);
            }
            final List<String> _tmpIngredients;
            final String _tmp_6;
            _tmp_6 = _cursor.getString(_cursorIndexOfIngredients);
            _tmpIngredients = __stringListConverter.toStringList(_tmp_6);
            final List<String> _tmpInstructions;
            final String _tmp_7;
            _tmp_7 = _cursor.getString(_cursorIndexOfInstructions);
            _tmpInstructions = __stringListConverter.toStringList(_tmp_7);
            final List<String> _tmpTags;
            final String _tmp_8;
            _tmp_8 = _cursor.getString(_cursorIndexOfTags);
            _tmpTags = __stringListConverter.toStringList(_tmp_8);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpFiber;
            if (_cursor.isNull(_cursorIndexOfFiber)) {
              _tmpFiber = null;
            } else {
              _tmpFiber = _cursor.getDouble(_cursorIndexOfFiber);
            }
            final Double _tmpSugar;
            if (_cursor.isNull(_cursorIndexOfSugar)) {
              _tmpSugar = null;
            } else {
              _tmpSugar = _cursor.getDouble(_cursorIndexOfSugar);
            }
            final Double _tmpSodium;
            if (_cursor.isNull(_cursorIndexOfSodium)) {
              _tmpSodium = null;
            } else {
              _tmpSodium = _cursor.getDouble(_cursorIndexOfSodium);
            }
            _item = new CustomRecipe(_tmpId,_tmpName,_tmpCategory,_tmpSource,_tmpIsUserCreated,_tmpIsFavorite,_tmpCreatedDate,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpImageData,_tmpIngredients,_tmpInstructions,_tmpTags,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object getRecipesByCategory(final String category,
      final Continuation<? super List<CustomRecipe>> $completion) {
    final String _sql = "SELECT * FROM custom_recipes WHERE category = ? ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, category);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomRecipe>>() {
      @Override
      @NonNull
      public List<CustomRecipe> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfIsFavorite = CursorUtil.getColumnIndexOrThrow(_cursor, "isFavorite");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfImageData = CursorUtil.getColumnIndexOrThrow(_cursor, "imageData");
          final int _cursorIndexOfIngredients = CursorUtil.getColumnIndexOrThrow(_cursor, "ingredients");
          final int _cursorIndexOfInstructions = CursorUtil.getColumnIndexOrThrow(_cursor, "instructions");
          final int _cursorIndexOfTags = CursorUtil.getColumnIndexOrThrow(_cursor, "tags");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<CustomRecipe> _result = new ArrayList<CustomRecipe>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomRecipe _item;
            final UUID _tmpId;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_1 = __converters.fromUUID(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_1;
            }
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final boolean _tmpIsFavorite;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfIsFavorite);
            _tmpIsFavorite = _tmp_3 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_5 = __converters.fromTimestamp(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_5;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final byte[] _tmpImageData;
            if (_cursor.isNull(_cursorIndexOfImageData)) {
              _tmpImageData = null;
            } else {
              _tmpImageData = _cursor.getBlob(_cursorIndexOfImageData);
            }
            final List<String> _tmpIngredients;
            final String _tmp_6;
            _tmp_6 = _cursor.getString(_cursorIndexOfIngredients);
            _tmpIngredients = __stringListConverter.toStringList(_tmp_6);
            final List<String> _tmpInstructions;
            final String _tmp_7;
            _tmp_7 = _cursor.getString(_cursorIndexOfInstructions);
            _tmpInstructions = __stringListConverter.toStringList(_tmp_7);
            final List<String> _tmpTags;
            final String _tmp_8;
            _tmp_8 = _cursor.getString(_cursorIndexOfTags);
            _tmpTags = __stringListConverter.toStringList(_tmp_8);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpFiber;
            if (_cursor.isNull(_cursorIndexOfFiber)) {
              _tmpFiber = null;
            } else {
              _tmpFiber = _cursor.getDouble(_cursorIndexOfFiber);
            }
            final Double _tmpSugar;
            if (_cursor.isNull(_cursorIndexOfSugar)) {
              _tmpSugar = null;
            } else {
              _tmpSugar = _cursor.getDouble(_cursorIndexOfSugar);
            }
            final Double _tmpSodium;
            if (_cursor.isNull(_cursorIndexOfSodium)) {
              _tmpSodium = null;
            } else {
              _tmpSodium = _cursor.getDouble(_cursorIndexOfSodium);
            }
            _item = new CustomRecipe(_tmpId,_tmpName,_tmpCategory,_tmpSource,_tmpIsUserCreated,_tmpIsFavorite,_tmpCreatedDate,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpImageData,_tmpIngredients,_tmpInstructions,_tmpTags,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @Override
  public Object searchRecipes(final String query,
      final Continuation<? super List<CustomRecipe>> $completion) {
    final String _sql = "SELECT * FROM custom_recipes WHERE name LIKE '%' || ? || '%' ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, query);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomRecipe>>() {
      @Override
      @NonNull
      public List<CustomRecipe> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfIsFavorite = CursorUtil.getColumnIndexOrThrow(_cursor, "isFavorite");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfImageData = CursorUtil.getColumnIndexOrThrow(_cursor, "imageData");
          final int _cursorIndexOfIngredients = CursorUtil.getColumnIndexOrThrow(_cursor, "ingredients");
          final int _cursorIndexOfInstructions = CursorUtil.getColumnIndexOrThrow(_cursor, "instructions");
          final int _cursorIndexOfTags = CursorUtil.getColumnIndexOrThrow(_cursor, "tags");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<CustomRecipe> _result = new ArrayList<CustomRecipe>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomRecipe _item;
            final UUID _tmpId;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_1 = __converters.fromUUID(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_1;
            }
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final boolean _tmpIsFavorite;
            final int _tmp_3;
            _tmp_3 = _cursor.getInt(_cursorIndexOfIsFavorite);
            _tmpIsFavorite = _tmp_3 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_5 = __converters.fromTimestamp(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_5;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final byte[] _tmpImageData;
            if (_cursor.isNull(_cursorIndexOfImageData)) {
              _tmpImageData = null;
            } else {
              _tmpImageData = _cursor.getBlob(_cursorIndexOfImageData);
            }
            final List<String> _tmpIngredients;
            final String _tmp_6;
            _tmp_6 = _cursor.getString(_cursorIndexOfIngredients);
            _tmpIngredients = __stringListConverter.toStringList(_tmp_6);
            final List<String> _tmpInstructions;
            final String _tmp_7;
            _tmp_7 = _cursor.getString(_cursorIndexOfInstructions);
            _tmpInstructions = __stringListConverter.toStringList(_tmp_7);
            final List<String> _tmpTags;
            final String _tmp_8;
            _tmp_8 = _cursor.getString(_cursorIndexOfTags);
            _tmpTags = __stringListConverter.toStringList(_tmp_8);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpFiber;
            if (_cursor.isNull(_cursorIndexOfFiber)) {
              _tmpFiber = null;
            } else {
              _tmpFiber = _cursor.getDouble(_cursorIndexOfFiber);
            }
            final Double _tmpSugar;
            if (_cursor.isNull(_cursorIndexOfSugar)) {
              _tmpSugar = null;
            } else {
              _tmpSugar = _cursor.getDouble(_cursorIndexOfSugar);
            }
            final Double _tmpSodium;
            if (_cursor.isNull(_cursorIndexOfSodium)) {
              _tmpSodium = null;
            } else {
              _tmpSodium = _cursor.getDouble(_cursorIndexOfSodium);
            }
            _item = new CustomRecipe(_tmpId,_tmpName,_tmpCategory,_tmpSource,_tmpIsUserCreated,_tmpIsFavorite,_tmpCreatedDate,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpImageData,_tmpIngredients,_tmpInstructions,_tmpTags,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
