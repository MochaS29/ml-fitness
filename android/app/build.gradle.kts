import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
    id("dagger.hilt.android.plugin")
    id("kotlinx-serialization")
    id("kotlin-parcelize")
}

val localProperties = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}
val anthropicApiKey: String = localProperties.getProperty("anthropic.api.key", "")
val usdaApiKey: String = localProperties.getProperty("usda.api.key", "")
val spoonacularApiKey: String = localProperties.getProperty("spoonacular.api.key", "")
val nutritionixAppId: String = localProperties.getProperty("nutritionix.app.id", "")
val nutritionixAppKey: String = localProperties.getProperty("nutritionix.app.key", "")

val keystoreProps = Properties().apply {
    val f = rootProject.file("keystore.properties")
    if (f.exists()) load(f.inputStream())
}

android {
    namespace = "com.mochasmindlab.mlhealth"
    compileSdk = 35

    testOptions {
        unitTests.isReturnDefaultValues = true
    }

    defaultConfig {
        applicationId = "com.mochasmindlab.mlhealth"
        minSdk = 26
        targetSdk = 35
        versionCode = 2
        versionName = "1.1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
        buildConfigField("String", "ANTHROPIC_API_KEY", "\"$anthropicApiKey\"")
        buildConfigField("String", "USDA_API_KEY", "\"$usdaApiKey\"")
        buildConfigField("String", "SPOONACULAR_API_KEY", "\"$spoonacularApiKey\"")
        buildConfigField("String", "NUTRITIONIX_APP_ID", "\"$nutritionixAppId\"")
        buildConfigField("String", "NUTRITIONIX_APP_KEY", "\"$nutritionixAppKey\"")
    }

    signingConfigs {
        // Release signing reads from keystore.properties (gitignored). To configure:
        //   1. keytool -genkey -v -keystore release.keystore -alias ml-fitness \
        //        -keyalg RSA -keysize 2048 -validity 10000
        //   2. Create keystore.properties at the project root with:
        //        storeFile=release.keystore
        //        storePassword=...
        //        keyAlias=ml-fitness
        //        keyPassword=...
        //   3. Add keystore.properties + the .keystore file to .gitignore.
        if (keystoreProps.getProperty("storeFile") != null) {
            create("release") {
                storeFile = rootProject.file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            buildConfigField("String", "BASE_URL", "\"https://api-dev.mochasmindlab.com/\"")
            buildConfigField("Boolean", "ENABLE_LOGGING", "true")
            // Off by default — sample data confuses real-user testing. Flip to true
            // only when validating UI states with a populated database.
            buildConfigField("Boolean", "ENABLE_DEMO_DATA", "false")
        }

        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            buildConfigField("String", "BASE_URL", "\"https://api.mochasmindlab.com/\"")
            buildConfigField("Boolean", "ENABLE_LOGGING", "false")
            buildConfigField("Boolean", "ENABLE_DEMO_DATA", "false")
            // Wire signing config when keystore.properties exists.
            if (keystoreProps.getProperty("storeFile") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
    flavorDimensions += listOf("environment")

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            buildConfigField("String", "ENVIRONMENT", "\"development\"")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            buildConfigField("String", "ENVIRONMENT", "\"staging\"")
        }
        create("production") {
            dimension = "environment"
            buildConfigField("String", "ENVIRONMENT", "\"production\"")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf(
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api"
        )
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.4"
    }

    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "META-INF/versions/9/previous-compilation-data.bin"
        }
    }

    androidResources {
        noCompress += "sqlite"
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.4.0")
    implementation("androidx.activity:activity-compose:1.4.0")

    // Compose
    implementation("androidx.compose.ui:ui:1.5.4")
    implementation("androidx.compose.ui:ui-tooling-preview:1.5.4")
    implementation("androidx.compose.material3:material3:1.1.2")
    implementation("androidx.compose.material:material:1.5.4")
    implementation("androidx.compose.material:material-icons-extended:1.5.4")
    implementation("androidx.navigation:navigation-compose:2.7.5")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.6.2")

    // Room Database
    implementation("androidx.room:room-runtime:2.6.0")
    implementation("androidx.room:room-ktx:2.6.0")
    ksp("androidx.room:room-compiler:2.6.0")

    // Hilt for Dependency Injection
    implementation("com.google.dagger:hilt-android:2.48")
    ksp("com.google.dagger:hilt-compiler:2.48")
    implementation("androidx.hilt:hilt-navigation-compose:1.0.0")

    // Networking
    implementation("io.ktor:ktor-client-core:1.6.7")
    implementation("io.ktor:ktor-client-android:1.6.7")
    implementation("io.ktor:ktor-client-serialization:1.6.7")
    implementation("io.ktor:ktor-client-logging:1.6.7")
    implementation("com.squareup.okhttp3:okhttp:4.11.0")

    // Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")

    // DataStore for Preferences
    implementation("androidx.datastore:datastore-preferences:1.0.0")

    // Accompanist for UI utilities
    implementation("com.google.accompanist:accompanist-systemuicontroller:0.20.0")
    implementation("com.google.accompanist:accompanist-permissions:0.20.0")

    // Camera
    implementation("androidx.camera:camera-camera2:1.1.0-beta01")
    implementation("androidx.camera:camera-lifecycle:1.1.0-beta01")
    implementation("androidx.camera:camera-view:1.1.0-beta01")

    // ML Kit
    implementation("com.google.mlkit:barcode-scanning:17.0.2")

    // Google Play Billing
    implementation("com.android.billingclient:billing-ktx:6.2.1")

    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.7.1")

    // Health Connect
    implementation("androidx.health.connect:connect-client:1.1.0-alpha07")

    // ListenableFuture (CameraX + Health Connect transitive — explicit for Kotlin compile resolution)
    implementation("com.google.guava:guava:32.1.3-android")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("com.google.truth:truth:1.1.5")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("io.mockk:mockk:1.13.8")
    androidTestImplementation("androidx.test.ext:junit:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:1.0.5")
    debugImplementation("androidx.compose.ui:ui-tooling:1.0.5")
    debugImplementation("androidx.compose.ui:ui-test-manifest:1.0.5")
}