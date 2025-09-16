package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.FavoriteRecipeDao;
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata
@QualifierMetadata
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava"
})
public final class DatabaseModule_ProvideFavoriteRecipeDaoFactory implements Factory<FavoriteRecipeDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideFavoriteRecipeDaoFactory(
      Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public FavoriteRecipeDao get() {
    return provideFavoriteRecipeDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideFavoriteRecipeDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideFavoriteRecipeDaoFactory(databaseProvider);
  }

  public static FavoriteRecipeDao provideFavoriteRecipeDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideFavoriteRecipeDao(database));
  }
}
