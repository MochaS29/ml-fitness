package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase;
import com.mochasmindlab.mlhealth.data.database.SupplementDao;
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
public final class DatabaseModule_ProvideSupplementDaoFactory implements Factory<SupplementDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideSupplementDaoFactory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public SupplementDao get() {
    return provideSupplementDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideSupplementDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideSupplementDaoFactory(databaseProvider);
  }

  public static SupplementDao provideSupplementDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideSupplementDao(database));
  }
}
