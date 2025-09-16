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
public final class SupplementRegimeViewModel_Factory implements Factory<SupplementRegimeViewModel> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public SupplementRegimeViewModel_Factory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public SupplementRegimeViewModel get() {
    return newInstance(databaseProvider.get());
  }

  public static SupplementRegimeViewModel_Factory create(
      Provider<MLFitnessDatabase> databaseProvider) {
    return new SupplementRegimeViewModel_Factory(databaseProvider);
  }

  public static SupplementRegimeViewModel newInstance(MLFitnessDatabase database) {
    return new SupplementRegimeViewModel(database);
  }
}
