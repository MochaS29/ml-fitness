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
import com.mochasmindlab.mlhealth.data.entities.NutrientMapConverter;
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry;
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
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class SupplementDao_Impl implements SupplementDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<SupplementEntry> __insertionAdapterOfSupplementEntry;

  private final Converters __converters = new Converters();

  private final NutrientMapConverter __nutrientMapConverter = new NutrientMapConverter();

  private final EntityDeletionOrUpdateAdapter<SupplementEntry> __deletionAdapterOfSupplementEntry;

  private final EntityDeletionOrUpdateAdapter<SupplementEntry> __updateAdapterOfSupplementEntry;

  public SupplementDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfSupplementEntry = new EntityInsertionAdapter<SupplementEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `supplement_entries` (`id`,`name`,`brand`,`date`,`timestamp`,`servingSize`,`servingUnit`,`imageData`,`nutrients`) VALUES (?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final SupplementEntry entity) {
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
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(4);
        } else {
          statement.bindLong(4, _tmp_1);
        }
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getTimestamp());
        if (_tmp_2 == null) {
          statement.bindNull(5);
        } else {
          statement.bindLong(5, _tmp_2);
        }
        statement.bindString(6, entity.getServingSize());
        statement.bindString(7, entity.getServingUnit());
        if (entity.getImageData() == null) {
          statement.bindNull(8);
        } else {
          statement.bindBlob(8, entity.getImageData());
        }
        final String _tmp_3 = __nutrientMapConverter.fromNutrientMap(entity.getNutrients());
        statement.bindString(9, _tmp_3);
      }
    };
    this.__deletionAdapterOfSupplementEntry = new EntityDeletionOrUpdateAdapter<SupplementEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `supplement_entries` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final SupplementEntry entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfSupplementEntry = new EntityDeletionOrUpdateAdapter<SupplementEntry>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `supplement_entries` SET `id` = ?,`name` = ?,`brand` = ?,`date` = ?,`timestamp` = ?,`servingSize` = ?,`servingUnit` = ?,`imageData` = ?,`nutrients` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final SupplementEntry entity) {
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
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDate());
        if (_tmp_1 == null) {
          statement.bindNull(4);
        } else {
          statement.bindLong(4, _tmp_1);
        }
        final Long _tmp_2 = __converters.dateToTimestamp(entity.getTimestamp());
        if (_tmp_2 == null) {
          statement.bindNull(5);
        } else {
          statement.bindLong(5, _tmp_2);
        }
        statement.bindString(6, entity.getServingSize());
        statement.bindString(7, entity.getServingUnit());
        if (entity.getImageData() == null) {
          statement.bindNull(8);
        } else {
          statement.bindBlob(8, entity.getImageData());
        }
        final String _tmp_3 = __nutrientMapConverter.fromNutrientMap(entity.getNutrients());
        statement.bindString(9, _tmp_3);
        final String _tmp_4 = __converters.uuidToString(entity.getId());
        if (_tmp_4 == null) {
          statement.bindNull(10);
        } else {
          statement.bindString(10, _tmp_4);
        }
      }
    };
  }

  @Override
  public Object insert(final SupplementEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfSupplementEntry.insert(entry);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final SupplementEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfSupplementEntry.handle(entry);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final SupplementEntry entry, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfSupplementEntry.handle(entry);
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
      final Continuation<? super List<SupplementEntry>> $completion) {
    final String _sql = "SELECT * FROM supplement_entries WHERE date = ? ORDER BY timestamp DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    final Long _tmp = __converters.dateToTimestamp(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindLong(_argIndex, _tmp);
    }
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<SupplementEntry>>() {
      @Override
      @NonNull
      public List<SupplementEntry> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfBrand = CursorUtil.getColumnIndexOrThrow(_cursor, "brand");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfServingSize = CursorUtil.getColumnIndexOrThrow(_cursor, "servingSize");
          final int _cursorIndexOfServingUnit = CursorUtil.getColumnIndexOrThrow(_cursor, "servingUnit");
          final int _cursorIndexOfImageData = CursorUtil.getColumnIndexOrThrow(_cursor, "imageData");
          final int _cursorIndexOfNutrients = CursorUtil.getColumnIndexOrThrow(_cursor, "nutrients");
          final List<SupplementEntry> _result = new ArrayList<SupplementEntry>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final SupplementEntry _item;
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
            final String _tmpServingSize;
            _tmpServingSize = _cursor.getString(_cursorIndexOfServingSize);
            final String _tmpServingUnit;
            _tmpServingUnit = _cursor.getString(_cursorIndexOfServingUnit);
            final byte[] _tmpImageData;
            if (_cursor.isNull(_cursorIndexOfImageData)) {
              _tmpImageData = null;
            } else {
              _tmpImageData = _cursor.getBlob(_cursorIndexOfImageData);
            }
            final Map<String, Double> _tmpNutrients;
            final String _tmp_7;
            _tmp_7 = _cursor.getString(_cursorIndexOfNutrients);
            _tmpNutrients = __nutrientMapConverter.toNutrientMap(_tmp_7);
            _item = new SupplementEntry(_tmpId,_tmpName,_tmpBrand,_tmpDate,_tmpTimestamp,_tmpServingSize,_tmpServingUnit,_tmpImageData,_tmpNutrients);
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
  public Object getAllSupplementNames(final Continuation<? super List<String>> $completion) {
    final String _sql = "SELECT DISTINCT name FROM supplement_entries ORDER BY name";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<String>>() {
      @Override
      @NonNull
      public List<String> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final List<String> _result = new ArrayList<String>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final String _item;
            _item = _cursor.getString(0);
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
