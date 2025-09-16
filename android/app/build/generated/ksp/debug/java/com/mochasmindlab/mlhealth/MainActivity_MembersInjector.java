package com.mochasmindlab.mlhealth;

import com.mochasmindlab.mlhealth.utils.PreferencesManager;
import com.mochasmindlab.mlhealth.utils.SampleDataGenerator;
import dagger.MembersInjector;
import dagger.internal.DaggerGenerated;
import dagger.internal.InjectedFieldSignature;
import dagger.internal.QualifierMetadata;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

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
public final class MainActivity_MembersInjector implements MembersInjector<MainActivity> {
  private final Provider<PreferencesManager> preferencesManagerProvider;

  private final Provider<SampleDataGenerator> sampleDataGeneratorProvider;

  public MainActivity_MembersInjector(Provider<PreferencesManager> preferencesManagerProvider,
      Provider<SampleDataGenerator> sampleDataGeneratorProvider) {
    this.preferencesManagerProvider = preferencesManagerProvider;
    this.sampleDataGeneratorProvider = sampleDataGeneratorProvider;
  }

  public static MembersInjector<MainActivity> create(
      Provider<PreferencesManager> preferencesManagerProvider,
      Provider<SampleDataGenerator> sampleDataGeneratorProvider) {
    return new MainActivity_MembersInjector(preferencesManagerProvider, sampleDataGeneratorProvider);
  }

  @Override
  public void injectMembers(MainActivity instance) {
    injectPreferencesManager(instance, preferencesManagerProvider.get());
    injectSampleDataGenerator(instance, sampleDataGeneratorProvider.get());
  }

  @InjectedFieldSignature("com.mochasmindlab.mlhealth.MainActivity.preferencesManager")
  public static void injectPreferencesManager(MainActivity instance,
      PreferencesManager preferencesManager) {
    instance.preferencesManager = preferencesManager;
  }

  @InjectedFieldSignature("com.mochasmindlab.mlhealth.MainActivity.sampleDataGenerator")
  public static void injectSampleDataGenerator(MainActivity instance,
      SampleDataGenerator sampleDataGenerator) {
    instance.sampleDataGenerator = sampleDataGenerator;
  }
}
