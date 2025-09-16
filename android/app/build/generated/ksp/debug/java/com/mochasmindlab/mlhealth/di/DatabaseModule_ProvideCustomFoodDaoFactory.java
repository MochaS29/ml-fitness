package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.CustomFoodDao;
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
public final class DatabaseModule_ProvideCustomFoodDaoFactory implements Factory<CustomFoodDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideCustomFoodDaoFactory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public CustomFoodDao get() {
    return provideCustomFoodDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideCustomFoodDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideCustomFoodDaoFactory(databaseProvider);
  }

  public static CustomFoodDao provideCustomFoodDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideCustomFoodDao(database));
  }
}
