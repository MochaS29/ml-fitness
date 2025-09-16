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
import com.mochasmindlab.mlhealth.data.entities.FavoriteRecipe;
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
public final class FavoriteRecipeDao_Impl implements FavoriteRecipeDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<FavoriteRecipe> __insertionAdapterOfFavoriteRecipe;

  private final Converters __converters = new Converters();

  private final EntityDeletionOrUpdateAdapter<FavoriteRecipe> __deletionAdapterOfFavoriteRecipe;

  private final EntityDeletionOrUpdateAdapter<FavoriteRecipe> __updateAdapterOfFavoriteRecipe;

  public FavoriteRecipeDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfFavoriteRecipe = new EntityInsertionAdapter<FavoriteRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `favorite_recipes` (`id`,`recipeId`,`recipeName`,`category`,`source`,`imageURL`,`dateAdded`,`prepTime`,`cookTime`,`servings`,`rating`) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FavoriteRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getRecipeId());
        statement.bindString(3, entity.getRecipeName());
        statement.bindString(4, entity.getCategory());
        if (entity.getSource() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getSource());
        }
        if (entity.getImageURL() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getImageURL());
        }
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDateAdded());
        if (_tmp_1 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_1);
        }
        statement.bindLong(8, entity.getPrepTime());
        statement.bindLong(9, entity.getCookTime());
        statement.bindLong(10, entity.getServings());
        statement.bindLong(11, entity.getRating());
      }
    };
    this.__deletionAdapterOfFavoriteRecipe = new EntityDeletionOrUpdateAdapter<FavoriteRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `favorite_recipes` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FavoriteRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
      }
    };
    this.__updateAdapterOfFavoriteRecipe = new EntityDeletionOrUpdateAdapter<FavoriteRecipe>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "UPDATE OR ABORT `favorite_recipes` SET `id` = ?,`recipeId` = ?,`recipeName` = ?,`category` = ?,`source` = ?,`imageURL` = ?,`dateAdded` = ?,`prepTime` = ?,`cookTime` = ?,`servings` = ?,`rating` = ? WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FavoriteRecipe entity) {
        final String _tmp = __converters.uuidToString(entity.getId());
        if (_tmp == null) {
          statement.bindNull(1);
        } else {
          statement.bindString(1, _tmp);
        }
        statement.bindString(2, entity.getRecipeId());
        statement.bindString(3, entity.getRecipeName());
        statement.bindString(4, entity.getCategory());
        if (entity.getSource() == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, entity.getSource());
        }
        if (entity.getImageURL() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getImageURL());
        }
        final Long _tmp_1 = __converters.dateToTimestamp(entity.getDateAdded());
        if (_tmp_1 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_1);
        }
        statement.bindLong(8, entity.getPrepTime());
        statement.bindLong(9, entity.getCookTime());
        statement.bindLong(10, entity.getServings());
        statement.bindLong(11, entity.getRating());
        final String _tmp_2 = __converters.uuidToString(entity.getId());
        if (_tmp_2 == null) {
          statement.bindNull(12);
        } else {
          statement.bindString(12, _tmp_2);
        }
      }
    };
  }

  @Override
  public Object insert(final FavoriteRecipe favorite,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfFavoriteRecipe.insert(favorite);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object delete(final FavoriteRecipe favorite,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfFavoriteRecipe.handle(favorite);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object update(final FavoriteRecipe favorite,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __updateAdapterOfFavoriteRecipe.handle(favorite);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getAllFavorites(final Continuation<? super List<FavoriteRecipe>> $completion) {
    final String _sql = "SELECT * FROM favorite_recipes ORDER BY dateAdded DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<List<FavoriteRecipe>>() {
      @Override
      @NonNull
      public List<FavoriteRecipe> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfRecipeId = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeId");
          final int _cursorIndexOfRecipeName = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeName");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfImageURL = CursorUtil.getColumnIndexOrThrow(_cursor, "imageURL");
          final int _cursorIndexOfDateAdded = CursorUtil.getColumnIndexOrThrow(_cursor, "dateAdded");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfRating = CursorUtil.getColumnIndexOrThrow(_cursor, "rating");
          final List<FavoriteRecipe> _result = new ArrayList<FavoriteRecipe>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final FavoriteRecipe _item;
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
            final String _tmpRecipeId;
            _tmpRecipeId = _cursor.getString(_cursorIndexOfRecipeId);
            final String _tmpRecipeName;
            _tmpRecipeName = _cursor.getString(_cursorIndexOfRecipeName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final String _tmpImageURL;
            if (_cursor.isNull(_cursorIndexOfImageURL)) {
              _tmpImageURL = null;
            } else {
              _tmpImageURL = _cursor.getString(_cursorIndexOfImageURL);
            }
            final Date _tmpDateAdded;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfDateAdded)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfDateAdded);
            }
            final Date _tmp_3 = __converters.fromTimestamp(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpDateAdded = _tmp_3;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final int _tmpRating;
            _tmpRating = _cursor.getInt(_cursorIndexOfRating);
            _item = new FavoriteRecipe(_tmpId,_tmpRecipeId,_tmpRecipeName,_tmpCategory,_tmpSource,_tmpImageURL,_tmpDateAdded,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpRating);
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
  public Object getFavoriteByRecipeId(final String recipeId,
      final Continuation<? super FavoriteRecipe> $completion) {
    final String _sql = "SELECT * FROM favorite_recipes WHERE recipeId = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, recipeId);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<FavoriteRecipe>() {
      @Override
      @Nullable
      public FavoriteRecipe call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfRecipeId = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeId");
          final int _cursorIndexOfRecipeName = CursorUtil.getColumnIndexOrThrow(_cursor, "recipeName");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfImageURL = CursorUtil.getColumnIndexOrThrow(_cursor, "imageURL");
          final int _cursorIndexOfDateAdded = CursorUtil.getColumnIndexOrThrow(_cursor, "dateAdded");
          final int _cursorIndexOfPrepTime = CursorUtil.getColumnIndexOrThrow(_cursor, "prepTime");
          final int _cursorIndexOfCookTime = CursorUtil.getColumnIndexOrThrow(_cursor, "cookTime");
          final int _cursorIndexOfServings = CursorUtil.getColumnIndexOrThrow(_cursor, "servings");
          final int _cursorIndexOfRating = CursorUtil.getColumnIndexOrThrow(_cursor, "rating");
          final FavoriteRecipe _result;
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
            final String _tmpRecipeId;
            _tmpRecipeId = _cursor.getString(_cursorIndexOfRecipeId);
            final String _tmpRecipeName;
            _tmpRecipeName = _cursor.getString(_cursorIndexOfRecipeName);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
            final String _tmpSource;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmpSource = null;
            } else {
              _tmpSource = _cursor.getString(_cursorIndexOfSource);
            }
            final String _tmpImageURL;
            if (_cursor.isNull(_cursorIndexOfImageURL)) {
              _tmpImageURL = null;
            } else {
              _tmpImageURL = _cursor.getString(_cursorIndexOfImageURL);
            }
            final Date _tmpDateAdded;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfDateAdded)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfDateAdded);
            }
            final Date _tmp_3 = __converters.fromTimestamp(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.util.Date', but it was NULL.");
            } else {
              _tmpDateAdded = _tmp_3;
            }
            final int _tmpPrepTime;
            _tmpPrepTime = _cursor.getInt(_cursorIndexOfPrepTime);
            final int _tmpCookTime;
            _tmpCookTime = _cursor.getInt(_cursorIndexOfCookTime);
            final int _tmpServings;
            _tmpServings = _cursor.getInt(_cursorIndexOfServings);
            final int _tmpRating;
            _tmpRating = _cursor.getInt(_cursorIndexOfRating);
            _result = new FavoriteRecipe(_tmpId,_tmpRecipeId,_tmpRecipeName,_tmpCategory,_tmpSource,_tmpImageURL,_tmpDateAdded,_tmpPrepTime,_tmpCookTime,_tmpServings,_tmpRating);
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
