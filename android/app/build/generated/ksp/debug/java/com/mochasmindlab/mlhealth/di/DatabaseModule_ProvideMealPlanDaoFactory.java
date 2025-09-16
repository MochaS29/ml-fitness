package com.mochasmindlab.mlhealth.di;

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase;
import com.mochasmindlab.mlhealth.data.database.MealPlanDao;
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
public final class DatabaseModule_ProvideMealPlanDaoFactory implements Factory<MealPlanDao> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DatabaseModule_ProvideMealPlanDaoFactory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public MealPlanDao get() {
    return provideMealPlanDao(databaseProvider.get());
  }

  public static DatabaseModule_ProvideMealPlanDaoFactory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new DatabaseModule_ProvideMealPlanDaoFactory(databaseProvider);
  }

  public static MealPlanDao provideMealPlanDao(MLFitnessDatabase database) {
    return Preconditions.checkNotNullFromProvides(DatabaseModule.INSTANCE.provideMealPlanDao(database));
  }
}
