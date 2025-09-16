package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.FoodDao;
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
public final class DatabaseModule_ProvideFoodDaoFactory implements Factory<FoodDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideFoodDaoFactory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public FoodDao get() {
    return provideFoodDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideFoodDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideFoodDaoFactory(databaseProvider);
  }

  public static FoodDao provideFoodDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideFoodDao(database));
  }
}
