package com.mochasmindlab.mlhealth.viewmodel;

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
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
public final class DashboardViewModel_Factory implements Factory<DashboardViewModel> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DashboardViewModel_Factory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public DashboardViewModel get() {
    return newInstance(databaseProvider.get());
  }

  public static DashboardViewModel_Factory create(Provider<MLFitnessDatabase> databaseProvider) {
    return new DashboardViewModel_Factory(databaseProvider);
  }

  public static DashboardViewModel newInstance(MLFitnessDatabase database) {
    return new DashboardViewModel(database);
  }
}
