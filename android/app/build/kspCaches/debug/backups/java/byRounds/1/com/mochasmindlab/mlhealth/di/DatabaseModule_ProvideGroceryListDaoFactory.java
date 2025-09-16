package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.GroceryListDao;
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
public final class DatabaseModule_ProvideGroceryListDaoFactory implements Factory<GroceryListDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideGroceryListDaoFactory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public GroceryListDao get() {
    return provideGroceryListDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideGroceryListDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideGroceryListDaoFactory(databaseProvider);
  }

  public static GroceryListDao provideGroceryListDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideGroceryListDao(database));
  }
}
