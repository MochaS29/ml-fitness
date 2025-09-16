package com.mochasmindlab.mlhealth.utils;

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

@ScopeMetadata("javax.inject.Singleton")
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
public final class SampleDataGenerator_Factory implements Factory<SampleDataGenerator> {
  private final Provider<MLFitnessDatabase> databaseProvider;

  public SampleDataGenerator_Factory(Provider<MLFitnessDatabase> databaseProvider) {
    this.databaseProvider = databaseProvider;
  }

  @Override
  public SampleDataGenerator get() {
    return newInstance(databaseProvider.get());
  }

  public static SampleDataGenerator_Factory create(Provider<MLFitnessDatabase> databaseProvider) {
    return new SampleDataGenerator_Factory(databaseProvider);
  }

  public static SampleDataGenerator newInstance(MLFitnessDatabase database) {
    return new SampleDataGenerator(database);
  }
}
