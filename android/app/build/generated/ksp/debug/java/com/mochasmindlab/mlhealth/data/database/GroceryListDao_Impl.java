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
import com.mochasmindlab.mlhealth.data.entities.GroceryList;
import com.mochasmindlab.mlhealth.data.entities.StringListConverter;
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
public final class GroceryListDao_Impl implements GroceryListDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<GroceryList> __insertionAdapterOfGroceryList;

  private final Converters __converters = new Converters();

  private final StringListConverter __stringListConverter = new StringListConverter();

  private final EntityDeletionOrUpdateAdapter<GroceryList> __deletionAdapterOfGroceryList;

  private final EntityDeletionOrUpdateAdapter<GroceryList> __updateAdapterOfGroceryList;

  public GroceryListDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfGroceryList = new EntityInsertionAdapter<GroceryList>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `grocery_lists` (`id`,`name`,`createdDate`,`isCompleted`,`items`) VALUES (?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final GroceryList entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_1 == null) {
          statement.bindNull(3);
        } else {
          statement.bindLong(3, _tmp_1);
        }
        final int _tmp_2 = entity.isCompleted() ? 1 : 0;
        statement.bindLong(4, _tmp_2);
        final String _tmp_3 = __stringListConverter.fromStringList(entity.getItems());
        statement.bindString(5, _tmp_3);
      }
    };
    this.__deletionAdapterOfGroceryList = new EntityDeletionOrUpdateAdapter<GroceryList>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `grocery_lists` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final GroceryList entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfGroceryList = new EntityDeletionOrUpdateAdapter<GroceryList>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `grocery_lists` SET `id` = ?,`name` = ?,`createdDate` = ?,`isCompleted` = ?,`items` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final GroceryList entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getName());
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getCreatedDate());
        if (_tmp_1 == null) {
          statement.bindNull(3);
        } else {
          statement.bindLong(3, _tmp_1);
        }
        final int _tmp_2 = entity.isCompleted() ? 1 : 0;
        statement.bindLong(4, _tmp_2);
        final String _tmp_3 = __stringListConverter.fromStringList(entity.getItems());
        statement.bindString(5, _tmp_3);
        final String _tmp_4 = __converters.uuidToString(entity.getId());
        if (_tmp_4 == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, _tmp_4);
        }
      }
    };
  }

  @Override
  public Object insert(final GroceryList groceryList,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfGroceryList.insert(groceryList);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final GroceryList groceryList,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfGroceryList.handle(groceryList);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final GroceryList groceryList,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfGroceryList.handle(groceryList);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getActiveGroceryLists(final Continuation<? super List<GroceryList>> $completion) {
    final String _sql = "SELECT * FROM grocery_lists WHERE isCompleted = 0 ORDER BY createdDate DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<GroceryList>>() {
      @Override
      @NonNull
      public List<GroceryList> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfIsCompleted = CursorUtil.getColumnIndexOrThrow(_cursor, "isCompleted");
          final int _cursorIndexOfItems = CursorUtil.getColumnIndexOrThrow(_cursor, "items");
          final List<GroceryList> _result = new ArrayList<GroceryList>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final GroceryList _item;
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
            final Date _tmpCreatedDate;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_3 = __converters.fromTimestamp(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_3;
            }
            final boolean _tmpIsCompleted;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfIsCompleted);
            _tmpIsCompleted = _tmp_4 != 0;
            final List<String> _tmpItems;
            final String _tmp_5;
            _tmp_5 = _cursor.getString(_cursorIndexOfItems);
            _tmpItems = __stringListConverter.toStringList(_tmp_5);
            _item = new GroceryList(_tmpId,_tmpName,_tmpCreatedDate,_tmpIsCompleted,_tmpItems);
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
  public Object getAllGroceryLists(final Continuation<? super List<GroceryList>> $completion) {
    final String _sql = "SELECT * FROM grocery_lists ORDER BY createdDate DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<GroceryList>>() {
      @Override
      @NonNull
      public List<GroceryList> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfCreatedDate = CursorUtil.getColumnIndexOrThrow(_cursor, "createdDate");
          final int _cursorIndexOfIsCompleted = CursorUtil.getColumnIndexOrThrow(_cursor, "isCompleted");
          final int _cursorIndexOfItems = CursorUtil.getColumnIndexOrThrow(_cursor, "items");
          final List<GroceryList> _result = new ArrayList<GroceryList>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final GroceryList _item;
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
            final Date _tmpCreatedDate;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfCreatedDate)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfCreatedDate);
            }
            final Date _tmp_3 = __converters.fromTimestamp(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpCreatedDate = _tmp_3;
            }
            final boolean _tmpIsCompleted;
            final int _tmp_4;
            _tmp_4 = _cursor.getInt(_cursorIndexOfIsCompleted);
            _tmpIsCompleted = _tmp_4 != 0;
            final List<String> _tmpItems;
            final String _tmp_5;
            _tmp_5 = _cursor.getString(_cursorIndexOfItems);
            _tmpItems = __stringListConverter.toStringList(_tmp_5);
            _item = new GroceryList(_tmpId,_tmpName,_tmpCreatedDate,_tmpIsCompleted,_tmpItems);
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
