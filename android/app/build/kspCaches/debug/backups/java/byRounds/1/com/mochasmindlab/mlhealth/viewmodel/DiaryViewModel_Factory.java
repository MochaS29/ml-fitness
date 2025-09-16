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
public final class DiaryViewModel_Factory implements Factory<DiaryViewModel> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public DiaryViewModel_Factory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public DiaryViewModel get() {
    return newInstance(databaseProvider.get());
  }

  public static DiaryViewModel_Factory create(Provider<MLFitnessDatabase> databaseProvider) {
    return new DiaryViewModel_Factory(databaseProvider);
  }

  public static DiaryViewModel newInstance(MLFitnessDatabase database) {
    return new DiaryViewModel(database);
  }
}
