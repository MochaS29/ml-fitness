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
import com.mochasmindlab.mlhealth.data.entities.FoodEntry;
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
public final class FoodDao_Impl implements FoodDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<FoodEntry> __insertionAdapterOfFoodEntry;

  private final Converters __converters = new Converters();

  private final EntityDeletionOrUpdateAdapter<FoodEntry> __deletionAdapterOfFoodEntry;

  private final EntityDeletionOrUpdateAdapter<FoodEntry> __updateAdapterOfFoodEntry;

  public FoodDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfFoodEntry = new EntityInsertionAdapter<FoodEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `food_entries` (`id`,`name`,`brand`,`barcode`,`date`,`timestamp`,`mealType`,`servingSize`,`servingUnit`,`servingCount`,`calories`,`protein`,`carbs`,`fat`,`fiber`,`sugar`,`sodium`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FoodEntry entity) {
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
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(5);
        } else {
          statement.bindLong(5, _tmp_1);
        }
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getTimestamp());
        if (_tmp_2 == null) {
          statement.bindNull(6);
        } else {
          statement.bindLong(6, _tmp_2);
        }
        statement.bindString(7, entity.getMealType());
        statement.bindString(8, entity.getServingSize());
        statement.bindString(9, entity.getServingUnit());
        statement.bindDouble(10, entity.getServingCount());
        statement.bindDouble(11, entity.getCalories());
        statement.bindDouble(12, entity.getProtein());
        statement.bindDouble(13, entity.getCarbs());
        statement.bindDouble(14, entity.getFat());
        if (entity.getFiber() == null) {
          statement.bindNull(15);
        } else {
          statement.bindDouble(15, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(16);
        } else {
          statement.bindDouble(16, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(17);
        } else {
          statement.bindDouble(17, entity.getSodium());
        }
      }
    };
    this.__deletionAdapterOfFoodEntry = new EntityDeletionOrUpdateAdapter<FoodEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `food_entries` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FoodEntry entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfFoodEntry = new EntityDeletionOrUpdateAdapter<FoodEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `food_entries` SET `id` = ?,`name` = ?,`brand` = ?,`barcode` = ?,`date` = ?,`timestamp` = ?,`mealType` = ?,`servingSize` = ?,`servingUnit` = ?,`servingCount` = ?,`calories` = ?,`protein` = ?,`carbs` = ?,`fat` = ?,`fiber` = ?,`sugar` = ?,`sodium` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FoodEntry entity) {
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
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(5);
        } else {
          statement.bindLong(5, _tmp_1);
        }
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getTimestamp());
        if (_tmp_2 == null) {
          statement.bindNull(6);
        } else {
          statement.bindLong(6, _tmp_2);
        }
        statement.bindString(7, entity.getMealType());
        statement.bindString(8, entity.getServingSize());
        statement.bindString(9, entity.getServingUnit());
        statement.bindDouble(10, entity.getServingCount());
        statement.bindDouble(11, entity.getCalories());
        statement.bindDouble(12, entity.getProtein());
        statement.bindDouble(13, entity.getCarbs());
        statement.bindDouble(14, entity.getFat());
        if (entity.getFiber() == null) {
          statement.bindNull(15);
        } else {
          statement.bindDouble(15, entity.getFiber());
        }
        if (entity.getSugar() == null) {
          statement.bindNull(16);
        } else {
          statement.bindDouble(16, entity.getSugar());
        }
        if (entity.getSodium() == null) {
          statement.bindNull(17);
        } else {
          statement.bindDouble(17, entity.getSodium());
        }
        final String _tmp_3 = __converters.uuidToString(entity.getId());
        if (_tmp_3 == null) {
          statement.bindNull(18);
        } else {
          statement.bindString(18, _tmp_3);
        }
      }
    };
  }

  @Override
  public Object insert(final FoodEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfFoodEntry.insert(entry);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final FoodEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfFoodEntry.handle(entry);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final FoodEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfFoodEntry.handle(entry);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getEntriesForDate(final Date date,
      final Continuation<? super List<FoodEntry>> $completion) {
    final String _sql = "SELECT * FROM food_entries WHERE date = ? ORDER BY timestamp DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<FoodEntry>>() {
      @Override
      @NonNull
      public List<FoodEntry> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfBarcode = CursorUtil.getColumnIndexOrThrow(_cursor, "barcode");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfMealType = CursorUtil.getColumnIndexOrThrow(_cursor, "mealType");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfServingCount = CursorUtil.getColumnIndexOrThrow(_cursor, "servingCount");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<FoodEntry> _result = new ArrayList<FoodEntry>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final FoodEntry _item;
            final UUID _tmpId;
            final String _tmp_1;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_2 = __converters.fromUUID(_tmp_1);
            if (_tmp_2 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_2;
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
            final Date _tmpDate;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfDate)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfDate);
            }
            final Date _tmp_4 = __converters.fromTimestamp(_tmp_3);
            if (_tmp_4 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpDate = _tmp_4;
            }
            final Date _tmpTimestamp;
            final Long _tmp_5;
            if (_cursor.isNull(_cursorIndexOfTimestamp)) {
              _tmp_5 = null;
            } else {
              _tmp_5 = _cursor.getLong(_cursorIndexOfTimestamp);
            }
            final Date _tmp_6 = __converters.fromTimestamp(_tmp_5);
            if (_tmp_6 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpTimestamp = _tmp_6;
            }
            final String _tmpMealType;
            _tmpMealType = _cursor.getString(_cursorIndexOfMealType);
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final double _tmpServingCount;
            _tmpServingCount = _cursor.getDouble(_cursorIndexOfServingCount);
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
            _item = new FoodEntry(_tmpId,_tmpName,_tmpBrand,_tmpBarcode,_tmpDate,_tmpTimestamp,_tmpMealType,_tmpServingSize,_tmpServingUnit,_tmpServingCount,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
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
  public Object getEntriesForMeal(final String mealType, final Date date,
      final Continuation<? super List<FoodEntry>> $completion) {
    final String _sql = "SELECT * FROM food_entries WHERE mealType = ? AND date = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 2);
    int _argIndex = 1;
    _statement.bindString(_argIndex, mealType);
    _argIndex = 2;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<FoodEntry>>() {
      @Override
      @NonNull
      public List<FoodEntry> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfBarcode = CursorUtil.getColumnIndexOrThrow(_cursor, "barcode");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfMealType = CursorUtil.getColumnIndexOrThrow(_cursor, "mealType");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfServingCount = CursorUtil.getColumnIndexOrThrow(_cursor, "servingCount");
          final int _cursorIndexOfCalories = CursorUtil.getColumnIndexOrThrow(_cursor, "calories");
          final int _cursorIndexOfProtein = CursorUtil.getColumnIndexOrThrow(_cursor, "protein");
          final int _cursorIndexOfCarbs = CursorUtil.getColumnIndexOrThrow(_cursor, "carbs");
          final int _cursorIndexOfFat = CursorUtil.getColumnIndexOrThrow(_cursor, "fat");
          final int _cursorIndexOfFiber = CursorUtil.getColumnIndexOrThrow(_cursor, "fiber");
          final int _cursorIndexOfSugar = CursorUtil.getColumnIndexOrThrow(_cursor, "sugar");
          final int _cursorIndexOfSodium = CursorUtil.getColumnIndexOrThrow(_cursor, "sodium");
          final List<FoodEntry> _result = new ArrayList<FoodEntry>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final FoodEntry _item;
            final UUID _tmpId;
            final String _tmp_1;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_2 = __converters.fromUUID(_tmp_1);
            if (_tmp_2 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_2;
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
            final Date _tmpDate;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfDate)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfDate);
            }
            final Date _tmp_4 = __converters.fromTimestamp(_tmp_3);
            if (_tmp_4 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpDate = _tmp_4;
            }
            final Date _tmpTimestamp;
            final Long _tmp_5;
            if (_cursor.isNull(_cursorIndexOfTimestamp)) {
              _tmp_5 = null;
            } else {
              _tmp_5 = _cursor.getLong(_cursorIndexOfTimestamp);
            }
            final Date _tmp_6 = __converters.fromTimestamp(_tmp_5);
            if (_tmp_6 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpTimestamp = _tmp_6;
            }
            final String _tmpMealType;
            _tmpMealType = _cursor.getString(_cursorIndexOfMealType);
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final double _tmpServingCount;
            _tmpServingCount = _cursor.getDouble(_cursorIndexOfServingCount);
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
            _item = new FoodEntry(_tmpId,_tmpName,_tmpBrand,_tmpBarcode,_tmpDate,_tmpTimestamp,_tmpMealType,_tmpServingSize,_tmpServingUnit,_tmpServingCount,_tmpCalories,_tmpProtein,_tmpCarbs,_tmpFat,_tmpFiber,_tmpSugar,_tmpSodium);
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
  public Object getTotalCaloriesForDate(final Date date,
      final Continuation<? super Double> $completion) {
    final String _sql = "SELECT SUM(calories * servingCount) FROM food_entries WHERE date = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Double>() {
      @Override
      @Nullable
      public Double call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final Double _result;
          if (_cursor.moveToFirst()) {
            final Double _tmp_1;
            if (_cursor.isNull(0)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getDouble(0);
            }
            _result = _tmp_1;
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
  public Object getTotalProteinForDate(final Date date,
      final Continuation<? super Double> $completion) {
    final String _sql = "SELECT SUM(protein * servingCount) FROM food_entries WHERE date = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Double>() {
      @Override
      @Nullable
      public Double call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final Double _result;
          if (_cursor.moveToFirst()) {
            final Double _tmp_1;
            if (_cursor.isNull(0)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getDouble(0);
            }
            _result = _tmp_1;
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
  public Object getTotalCarbsForDate(final Date date,
      final Continuation<? super Double> $completion) {
    final String _sql = "SELECT SUM(carbs * servingCount) FROM food_entries WHERE date = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Double>() {
      @Override
      @Nullable
      public Double call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final Double _result;
          if (_cursor.moveToFirst()) {
            final Double _tmp_1;
            if (_cursor.isNull(0)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getDouble(0);
            }
            _result = _tmp_1;
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
  public Object getTotalFatForDate(final Date date,
      final Continuation<? super Double> $completion) {
    final String _sql = "SELECT SUM(fat * servingCount) FROM food_entries WHERE date = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Double>() {
      @Override
      @Nullable
      public Double call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final Double _result;
          if (_cursor.moveToFirst()) {
            final Double _tmp_1;
            if (_cursor.isNull(0)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getDouble(0);
            }
            _result = _tmp_1;
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

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
