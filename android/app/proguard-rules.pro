# MindLab Fitness — release ProGuard rules.
#
# The base proguard-android-optimize.txt covers most Android framework reflection.
# Below are project-specific keep rules for libraries that use reflection / generated
# code that R8's static analysis can't infer from source.

# ========== Hilt / Dagger ==========
# Hilt's generated _HiltModules and ViewModel factories are referenced by reflection.
-keep,allowobfuscation,allowshrinking class dagger.hilt.** { *; }
-keep,allowobfuscation,allowshrinking class * extends androidx.lifecycle.ViewModel
-keepclasseswithmembers class * { @dagger.hilt.android.lifecycle.HiltViewModel <init>(...); }
-keepclasseswithmembers class * { @javax.inject.Inject <init>(...); }

# ========== kotlinx.serialization ==========
# @Serializable classes' companion serializers are accessed by reflection.
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault,InnerClasses
-keepclasseswithmembers class **$$serializer { *; }
-keepclassmembers class kotlinx.serialization.json.** { *; }
-keepclassmembers class * {
    @kotlinx.serialization.Serializable *;
}
-keep,allowobfuscation,allowshrinking @kotlinx.serialization.Serializable class *

# ========== Room ==========
# Room generates _Impl classes that the compiled DAO interfaces look up at runtime.
-keep class * extends androidx.room.RoomDatabase
-keep class **_Impl { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao interface * { *; }

# Keep our Room entities + JSON DTOs whole — their property names matter for
# Room column mapping and serialization.
-keep class com.mochasmindlab.mlhealth.data.entities.** { *; }
-keep class com.mochasmindlab.mlhealth.data.models.** { *; }

# ========== Health Connect ==========
-keep class androidx.health.connect.client.** { *; }
-keep class androidx.health.platform.client.** { *; }

# ========== Google Play Billing ==========
-keep class com.android.billingclient.api.** { *; }

# ========== ML Kit (barcode) ==========
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }

# ========== Ktor / kotlinx-coroutines ==========
-keepattributes Signature,InnerClasses,EnclosingMethod
-keepclassmembernames class kotlinx.** { volatile <fields>; }
-keep class io.ktor.** { *; }

# ========== Misc ==========
# Keep BuildConfig (read at runtime via reflection-free static field access — usually safe)
-keep class com.mochasmindlab.mlhealth.BuildConfig { *; }

# Strip release log calls — verbose/debug only.
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# ========== Suppress safe missing references ==========
# Ktor 1.6.7's WebSocket module references the deprecated kotlin.Experimental
# annotation that was removed in Kotlin 1.5+. We don't use WebSockets — safe to ignore.
-dontwarn kotlin.Experimental
-dontwarn io.ktor.http.cio.websocket.**
-dontwarn io.ktor.client.engine.android.**

# slf4j-api expects a static binder that is supplied by an impl jar (none on Android).
# Ktor / OkHttp pull it transitively. Safe to ignore at link time.
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.**

# Conscrypt / BouncyCastle / OpenJSSE — OkHttp tries to detect them at runtime.
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
