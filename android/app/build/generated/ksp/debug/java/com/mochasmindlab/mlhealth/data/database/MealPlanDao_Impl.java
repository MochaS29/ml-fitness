package com.mochasmindlab.mlhealth.data.database;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.mochasmindlab.mlhealth.data.entities.Converters;
import com.mochasmindlab.mlhealth.data.entities.MealPlan;
import java.lang.Class;
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
public final class MealPlanDao_Impl implements MealPlanDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<MealPlan> __insertionAdapterOfMealPlan;

  private final Converters __converters = new Converters();

  private final EntityDeletionOrUpdateAdapter<MealPlan> __deletionAdapterOfMealPlan;

  private final EntityDeletionOrUpdateAdapter<MealPlan> __updateAdapterOfMealPlan;

  private final SharedSQLiteStatement __preparedStmtOfDeleteAllForDate;

  public MealPlanDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfMealPlan = new EntityInsertionAdapter<MealPlan>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `meal_plans` (`id`,`date`,`mealType`,`recipeId`,`recipeName`,`servings`,`notes`) VALUES (?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final MealPlan entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(2);
        } else {
          statement.bindLong(2, _tmp_1);
        }
        statement.bindString(3, entity.getMealType());
        final String _tmp_2 = __converters.uuidToString(entity.getRecipeId());
        if (_tmp_2 == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, _tmp_2);
        }
        statement.bindString(5, entity.getRecipeName());
        statement.bindLong(6, entity.getServings());
        if (entity.getNotes() == null) {
          statement.bindNull(7);
        } else {
          statement.bindString(7, entity.getNotes());
        }
      }
    };
    this.__deletionAdapterOfMealPlan = new EntityDeletionOrUpdateAdapter<MealPlan>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `meal_plans` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final MealPlan entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfMealPlan = new EntityDeletionOrUpdateAdapter<MealPlan>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `meal_plans` SET `id` = ?,`date` = ?,`mealType` = ?,`recipeId` = ?,`recipeName` = ?,`servings` = ?,`notes` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final MealPlan entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(2);
        } else {
          statement.bindLong(2, _tmp_1);
        }
        statement.bindString(3, entity.getMealType());
        final String _tmp_2 = __converters.uuidToString(entity.getRecipeId());
        if (_tmp_2 == null) {
          statement.bindNull(4);
        } else {
          statement.bindString(4, _tmp_2);
        }
        statement.bindString(5, entity.getRecipeName());
        statement.bindLong(6, entity.getServings());
        if (entity.getNotes() == null) {
          statement.bindNull(7);
        } else {
          statement.bindString(7, entity.getNotes());
        }
        final String _tmp_3 = __converters.uuidToString(entity.getId());
        if (_tmp_3 == null) {
          statement.bindNull(8);
        } else {
          statement.bindString(8, _tmp_3);
        }
      }
    };
    this.__preparedStmtOfDeleteAllForDate = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "DELETE FROM meal_plans WHERE date = ?";
        return _query;
      }
    };
  }

  @Override
  public Object insert(final MealPlan mealPlan, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfMealPlan.insert(mealPlan);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final MealPlan mealPlan, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfMealPlan.handle(mealPlan);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final MealPlan mealPlan, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfMealPlan.handle(mealPlan);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object deleteAllForDate(final Date date, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfDeleteAllForDate.acquire();
        int _argIndex = 1;
        final Long _tmp = __converters.dateToTimestamp(date);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindLong(_argIndex, _tmp);
        }
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfDeleteAllForDate.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Object getMealPlansForDate(final Date date,
      final Continuation<? super List<MealPlan>> $completion) {
    final String _sql = "SELECT * FROM meal_plans WHERE date = ? ORDER BY mealType";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<MealPlan>>() {
      @Override
      @NonNull
      public List<MealPlan> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfMealType = CursorUtil.getColumnIndexOrThrow(_cursor, "mealType");
          final int _cursorIndexOfRecipeId = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeId");
          final int _cursorIndexOfRecipeName = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeName");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfNotes = CursorUtil.getColumnIndexOrThrow(_cursor, "notes");
          final List<MealPlan> _result = new ArrayList<MealPlan>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final MealPlan _item;
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
            final String _tmpMealType;
            _tmpMealType = _cursor.getString(_cursorIndexOfMealType);
            final UUID _tmpRecipeId;
            final String _tmp_5;
            if (_cursor.isNull(_cursorIndexOfRecipeId)) {
              _tmp_5 = null;
            } else {
              _tmp_5 = _cursor.getString(_cursorIndexOfRecipeId);
            }
            _tmpRecipeId = __converters.fromUUID(_tmp_5);
            final String _tmpRecipeName;
            _tmpRecipeName = _cursor.getString(_cursorIndexOfRecipeName);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final String _tmpNotes;
            if (_cursor.isNull(_cursorIndexOfNotes)) {
              _tmpNotes = null;
            } else {
              _tmpNotes = _cursor.getString(_cursorIndexOfNotes);
            }
            _item = new MealPlan(_tmpId,_tmpDate,_tmpMealType,_tmpRecipeId,_tmpRecipeName,_tmpServings,_tmpNotes);
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
  public Object getMealPlansInRange(final Date startDate, final Date endDate,
      final Continuation<? super List<MealPlan>> $completion) {
    final String _sql = "SELECT * FROM meal_plans WHERE date BETWEEN ? AND ? ORDER BY date, mealType";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 2);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(startDate);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    _argIndex = 2;
    final Long _tmp_1 = __converters.dateToTimestamp(endDate);
    if (_tmp_1 == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp_1);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<MealPlan>>() {
      @Override
      @NonNull
      public List<MealPlan> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfMealType = CursorUtil.getColumnIndexOrThrow(_cursor, "mealType");
          final int _cursorIndexOfRecipeId = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeId");
          final int _cursorIndexOfRecipeName = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeName");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfNotes = CursorUtil.getColumnIndexOrThrow(_cursor, "notes");
          final List<MealPlan> _result = new ArrayList<MealPlan>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final MealPlan _item;
            final UUID _tmpId;
            final String _tmp_2;
            if (_cursor.isNull(_cursorIndexOfId)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getString(_cursorIndexOfId);
            }
            final UUID _tmp_3 = __converters.fromUUID(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.UUID', but it was NULL.");
            } else {
              _tmpId = _tmp_3;
            }
            final Date _tmpDate;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfDate)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfDate);
            }
            final Date _tmp_5 = __converters.fromTimestamp(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpDate = _tmp_5;
            }
            final String _tmpMealType;
            _tmpMealType = _cursor.getString(_cursorIndexOfMealType);
            final UUID _tmpRecipeId;
            final String _tmp_6;
            if (_cursor.isNull(_cursorIndexOfRecipeId)) {
              _tmp_6 = null;
            } else {
              _tmp_6 = _cursor.getString(_cursorIndexOfRecipeId);
            }
            _tmpRecipeId = __converters.fromUUID(_tmp_6);
            final String _tmpRecipeName;
            _tmpRecipeName = _cursor.getString(_cursorIndexOfRecipeName);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final String _tmpNotes;
            if (_cursor.isNull(_cursorIndexOfNotes)) {
              _tmpNotes = null;
            } else {
              _tmpNotes = _cursor.getString(_cursorIndexOfNotes);
            }
            _item = new MealPlan(_tmpId,_tmpDate,_tmpMealType,_tmpRecipeId,_tmpRecipeName,_tmpServings,_tmpNotes);
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
