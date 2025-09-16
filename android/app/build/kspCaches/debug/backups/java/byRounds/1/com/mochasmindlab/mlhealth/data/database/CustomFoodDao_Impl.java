package com.mochasmindlab.mlhealth.data.database;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.mochasmindlab.mlhealth.data.entities.Converters;
import com.mochasmindlab.mlhealth.data.entities.CustomFood;
import com.mochasmindlab.mlhealth.data.entities.NutrientMapConverter;
import java.lang.Class;
import java.lang.Double;
import java.lang.Exception;
import java.lang.IllegalStateException;
import java.lang.Integer;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class CustomFoodDao_Impl implements CustomFoodDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<CustomFood> __insertionAdapterOfCustomFood;

  private final Converters __converters = new Converters();

  private final NutrientMapConverter __nutrientMapConverter = new NutrientMapConverter();

  private final EntityDeletionOrUpdateAdapter<CustomFood> __deletionAdapterOfCustomFood;

  private final EntityDeletionOrUpdateAdapter<CustomFood> __updateAdapterOfCustomFood;

  public CustomFoodDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfCustomFood = new EntityInsertionAdapter<CustomFood>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `custom_foods` (`id`,`name`,`brand`,`barcode`,`category`,`source`,`fdcId`,`isUserCreated`,`createdDate`,`servingSize`,`servingUnit`,`calories`,`protein`,`carbs`,`fat`,`saturatedFat`,`fiber`,`sugar`,`sodium`,`cholesterol`,`additionalNutrients`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomFood entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        if (entity.getBrand() == null) {
          statement.bindNull(3);
        } else {
          statement.bindString(3, entity.getBrand());
        }
        if (entity.getBarcode() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getBarcode());
        }
        if (entity.getCategory() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getCategory());
        }
        if (entity.getSource() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getSource());
        }
        if (entity.getFdcId() == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, entity.getFdcId());
        }
        final int _tmp_1 = entity.isUserCreated() ? 1 : 0;
        statement.bindLong(8, _tmp_1);
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_2 == null) {
          statement.bindNull(9);
        } else {
          statement.bindLong(9, _tmp_2);
        }
        statement.bindString(10, entity.getServingSize());
        statement.bindString(11, entity.getServingUnit());
        statement.bindDouble(12, entity.getCalories());
        statement.bindDouble(13, entity.getProtein());
        statement.bindDouble(14, entity.getCarbs());
        statement.bindDouble(15, entity.getFat());
        if (entity.getSaturatedFat() == null) {
          statement.bindNull(16);
        } else {
          statement.bindDouble(16, entity.getSaturatedFat());
        }
        if (entity.getFiber() == null) {
          statement.bindNull(17);
        } else {
          statement.bindDouble(17, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(18);
        } else {
          statement.bindDouble(18, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(19);
        } else {
          statement.bindDouble(19, entity.getSodium());
        }
        if (entity.getCholesterol() == null) {
          statement.bindNull(20);
        } else {
          statement.bindDouble(20, entity.getCholesterol());
        }
        final String _tmp_3 = __nutrientMapConverter.fromNutrientMap(entity.getAdditionalNutrients());
        statement.bindString(21, _tmp_3);
      }
    };
    this.__deletionAdapterOfCustomFood = new EntityDeletionOrUpdateAdapter<CustomFood>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `custom_foods` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomFood entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfCustomFood = new EntityDeletionOrUpdateAdapter<CustomFood>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `custom_foods` SET `id` = ?,`name` = ?,`brand` = ?,`barcode` = ?,`category` = ?,`source` = ?,`fdcId` = ?,`isUserCreated` = ?,`createdDate` = ?,`servingSize` = ?,`servingUnit` = ?,`calories` = ?,`protein` = ?,`carbs` = ?,`fat` = ?,`saturatedFat` = ?,`fiber` = ?,`sugar` = ?,`sodium` = ?,`cholesterol` = ?,`additionalNutrients` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final CustomFood entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        if (entity.getBrand() == null) {
          statement.bindNull(3);
        } else {
          statement.bindString(3, entity.getBrand());
        }
        if (entity.getBarcode() == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, entity.getBarcode());
        }
        if (entity.getCategory() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getCategory());
        }
        if (entity.getSource() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getSource());
        }
        if (entity.getFdcId() == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, entity.getFdcId());
        }
        final int _tmp_1 = entity.isUserCreated() ? 1 : 0;
        statement.bindLong(8, _tmp_1);
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_2 == null) {
          statement.bindNull(9);
        } else {
          statement.bindLong(9, _tmp_2);
        }
        statement.bindString(10, entity.getServingSize());
        statement.bindString(11, entity.getServingUnit());
        statement.bindDouble(12, entity.getCalories());
        statement.bindDouble(13, entity.getProtein());
        statement.bindDouble(14, entity.getCarbs());
        statement.bindDouble(15, entity.getFat());
        if (entity.getSaturatedFat() == null) {
          statement.bindNull(16);
        } else {
          statement.bindDouble(16, entity.getSaturatedFat());
        }
        if (entity.getFiber() == null) {
          statement.bindNull(17);
        } else {
          statement.bindDouble(17, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(18);
        } else {
          statement.bindDouble(18, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(19);
        } else {
          statement.bindDouble(19, entity.getSodium());
        }
        if (entity.getCholesterol() == null) {
          statement.bindNull(20);
        } else {
          statement.bindDouble(20, entity.getCholesterol());
        }
        final String _tmp_3 = __nutrientMapConverter.fromNutrientMap(entity.getAdditionalNutrients());
        statement.bindString(21, _tmp_3);
        final String _tmp_4 = __converters.uuidToString(entity.getId());
        if (_tmp_4 == null) {
          statement.bindNull(22);
        } else {
          statement.bindString(22, _tmp_4);
        }
      }
    };
  }

  @Override
  public Object insert(final CustomFood food, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfCustomFood.insert(food);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final CustomFood food, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfCustomFood.handle(food);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final CustomFood food, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfCustomFood.handle(food);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object searchFoods(final String query,
      final Continuation<? super List<CustomFood>> $completion) {
    final String _sql = "SELECT * FROM custom_foods WHERE name LIKE '%' || ? || '%' OR brand LIKE '%' || ? || '%' ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 2);
    int _argIndex = 1;
    _statement.bindString(_argIndex, query);
    _argIndex = 2;
    _statement.bindString(_argIndex, query);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomFood>>() {
      @Override
      @NonNull
      public List<CustomFood> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfBarcode = CursorUtil.getColumnIndexOrThrow(_cursor, "barcode");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFdcId = CursorUtil.getColumnIndexOrThrow(_cursor, "fdcId");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfSaturatedFat = CursorUtil.getColumnIndexOrThrow(_cursor, "saturatedFat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final int _cursorIndexOfCholesterol = CursorUtil.getColumnIndexOrThrow(_cursor, "cholesterol");
          final int _cursorIndexOfAdditionalNutrients = CursorUtil.getColumnIndexOrThrow(_cursor, "additionalNutrients");
          final List<CustomFood> _result = new ArrayList<CustomFood>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomFood _item;
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
            final String _tmpBrand;
            if (_cursor.isNull(_cursorIndexOfBrand)) {
              _tmpBrand = null;
            } else {
              _tmpBrand = _cursor.getString(_cursorIndexOfBrand);
            }
            final String _tmpBarcode;
            if (_cursor.isNull(_cursorIndexOfBarcode)) {
              _tmpBarcode = null;
            } else {
              _tmpBarcode = _cursor.getString(_cursorIndexOfBarcode);
            }
            final String _tmpCategory;
            if (_cursor.isNull(_cursorIndexOfCategory)) {
              _tmpCategory = null;
            } else {
              _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            }
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final Integer _tmpFdcId;
            if (_cursor.isNull(_cursorIndexOfFdcId)) {
              _tmpFdcId = null;
            } else {
              _tmpFdcId = _cursor.getInt(_cursorIndexOfFdcId);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_4 = __converters.fromTimestamp(_tmp_3);
            if (_tmp_4 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_4;
            }
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpSaturatedFat;
            if (_cursor.isNull(_cursorIndexOfSaturatedFat)) {
              _tmpSaturatedFat = null;
            } else {
              _tmpSaturatedFat = _cursor.getDouble(_cursorIndexOfSaturatedFat);
            }
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
            final Double _tmpCholesterol;
            if (_cursor.isNull(_cursorIndexOfCholesterol)) {
              _tmpCholesterol = null;
            } else {
              _tmpCholesterol = _cursor.getDouble(_cursorIndexOfCholesterol);
            }
            final Map<String, Double> _tmpAdditionalNutrients;
            final String _tmp_5;
            _tmp_5 = _cursor.getString(_cursorIndexOfAdditionalNutrients);
            _tmpAdditionalNutrients = __nutrientMapConverter.toNutrientMap(_tmp_5);
            _item = new CustomFood(_tmpId,_tmpName,_tmpBrand,_tmpBarcode,_tmpCategory,_tmpSource,_tmpFdcId,_tmpIsUserCreated,_tmpCreatedDate,_tmpServingSize,_tmpServingUnit,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpSaturatedFat,_tmpFiber,_tmpSugar,_tmpSodium,_tmpCholesterol,_tmpAdditionalNutrients);
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
  public Object getFoodByBarcode(final String barcode,
      final Continuation<? super CustomFood> $completion) {
    final String _sql = "SELECT * FROM custom_foods WHERE barcode = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, barcode);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<CustomFood>() {
      @Override
      @Nullable
      public CustomFood call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfBarcode = CursorUtil.getColumnIndexOrThrow(_cursor, "barcode");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFdcId = CursorUtil.getColumnIndexOrThrow(_cursor, "fdcId");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfSaturatedFat = CursorUtil.getColumnIndexOrThrow(_cursor, "saturatedFat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final int _cursorIndexOfCholesterol = CursorUtil.getColumnIndexOrThrow(_cursor, "cholesterol");
          final int _cursorIndexOfAdditionalNutrients = CursorUtil.getColumnIndexOrThrow(_cursor, "additionalNutrients");
          final CustomFood _result;
          if (_cursor.moveToFirst()) {
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
            final String _tmpBrand;
            if (_cursor.isNull(_cursorIndexOfBrand)) {
              _tmpBrand = null;
            } else {
              _tmpBrand = _cursor.getString(_cursorIndexOfBrand);
            }
            final String _tmpBarcode;
            if (_cursor.isNull(_cursorIndexOfBarcode)) {
              _tmpBarcode = null;
            } else {
              _tmpBarcode = _cursor.getString(_cursorIndexOfBarcode);
            }
            final String _tmpCategory;
            if (_cursor.isNull(_cursorIndexOfCategory)) {
              _tmpCategory = null;
            } else {
              _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            }
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final Integer _tmpFdcId;
            if (_cursor.isNull(_cursorIndexOfFdcId)) {
              _tmpFdcId = null;
            } else {
              _tmpFdcId = _cursor.getInt(_cursorIndexOfFdcId);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_4 = __converters.fromTimestamp(_tmp_3);
            if (_tmp_4 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_4;
            }
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpSaturatedFat;
            if (_cursor.isNull(_cursorIndexOfSaturatedFat)) {
              _tmpSaturatedFat = null;
            } else {
              _tmpSaturatedFat = _cursor.getDouble(_cursorIndexOfSaturatedFat);
            }
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
            final Double _tmpCholesterol;
            if (_cursor.isNull(_cursorIndexOfCholesterol)) {
              _tmpCholesterol = null;
            } else {
              _tmpCholesterol = _cursor.getDouble(_cursorIndexOfCholesterol);
            }
            final Map<String, Double> _tmpAdditionalNutrients;
            final String _tmp_5;
            _tmp_5 = _cursor.getString(_cursorIndexOfAdditionalNutrients);
            _tmpAdditionalNutrients = __nutrientMapConverter.toNutrientMap(_tmp_5);
            _result = new CustomFood(_tmpId,_tmpName,_tmpBrand,_tmpBarcode,_tmpCategory,_tmpSource,_tmpFdcId,_tmpIsUserCreated,_tmpCreatedDate,_tmpServingSize,_tmpServingUnit,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpSaturatedFat,_tmpFiber,_tmpSugar,_tmpSodium,_tmpCholesterol,_tmpAdditionalNutrients);
          } else {
            _result = null;
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
  public Object getUserCreatedFoods(final Continuation<? super List<CustomFood>> $completion) {
    final String _sql = "SELECT * FROM custom_foods WHERE isUserCreated = 1 ORDER BY createdDate DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<CustomFood>>() {
      @Override
      @NonNull
      public List<CustomFood> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfBarcode = CursorUtil.getColumnIndexOrThrow(_cursor, "barcode");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFdcId = CursorUtil.getColumnIndexOrThrow(_cursor, "fdcId");
          final int _cursorIndexOfIsUserCreated = CursorUtil.getColumnIndexOrThrow(_cursor, "isUserCreated");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfSaturatedFat = CursorUtil.getColumnIndexOrThrow(_cursor, "saturatedFat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final int _cursorIndexOfCholesterol = CursorUtil.getColumnIndexOrThrow(_cursor, "cholesterol");
          final int _cursorIndexOfAdditionalNutrients = CursorUtil.getColumnIndexOrThrow(_cursor, "additionalNutrients");
          final List<CustomFood> _result = new ArrayList<CustomFood>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final CustomFood _item;
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
            final String _tmpBrand;
            if (_cursor.isNull(_cursorIndexOfBrand)) {
              _tmpBrand = null;
            } else {
              _tmpBrand = _cursor.getString(_cursorIndexOfBrand);
            }
            final String _tmpBarcode;
            if (_cursor.isNull(_cursorIndexOfBarcode)) {
              _tmpBarcode = null;
            } else {
              _tmpBarcode = _cursor.getString(_cursorIndexOfBarcode);
            }
            final String _tmpCategory;
            if (_cursor.isNull(_cursorIndexOfCategory)) {
              _tmpCategory = null;
            } else {
              _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            }
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final Integer _tmpFdcId;
            if (_cursor.isNull(_cursorIndexOfFdcId)) {
              _tmpFdcId = null;
            } else {
              _tmpFdcId = _cursor.getInt(_cursorIndexOfFdcId);
            }
            final boolean _tmpIsUserCreated;
            final int _tmp_2;
            _tmp_2 = _cursor.getInt(_cursorIndexOfIsUserCreated);
            _tmpIsUserCreated = _tmp_2 != 0;
            final Date _tmpCreatedDate;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_4 = __converters.fromTimestamp(_tmp_3);
            if (_tmp_4 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_4;
            }
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final double _tmpCalories;
            _tmpCalories = _cursor.getDouble(_cursorIndexOfCalories);
            final double _tmpProtein;
            _tmpProtein = _cursor.getDouble(_cursorIndexOfProtein);
            final double _tmpCarbs;
            _tmpCarbs = _cursor.getDouble(_cursorIndexOfCarbs);
            final double _tmpFat;
            _tmpFat = _cursor.getDouble(_cursorIndexOfFat);
            final Double _tmpSaturatedFat;
            if (_cursor.isNull(_cursorIndexOfSaturatedFat)) {
              _tmpSaturatedFat = null;
            } else {
              _tmpSaturatedFat = _cursor.getDouble(_cursorIndexOfSaturatedFat);
            }
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
            final Double _tmpCholesterol;
            if (_cursor.isNull(_cursorIndexOfCholesterol)) {
              _tmpCholesterol = null;
            } else {
              _tmpCholesterol = _cursor.getDouble(_cursorIndexOfCholesterol);
            }
            final Map<String, Double> _tmpAdditionalNutrients;
            final String _tmp_5;
            _tmp_5 = _cursor.getString(_cursorIndexOfAdditionalNutrients);
            _tmpAdditionalNutrients = __nutrientMapConverter.toNutrientMap(_tmp_5);
            _item = new CustomFood(_tmpId,_tmpName,_tmpBrand,_tmpBarcode,_tmpCategory,_tmpSource,_tmpFdcId,_tmpIsUserCreated,_tmpCreatedDate,_tmpServingSize,_tmpServingUnit,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpSaturatedFat,_tmpFiber,_tmpSugar,_tmpSodium,_tmpCholesterol,_tmpAdditionalNutrients);
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
