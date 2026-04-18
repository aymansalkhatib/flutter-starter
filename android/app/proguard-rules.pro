# ============================================================
# ProGuard / R8 rules for Flutter release build
# ============================================================

# --- Flutter engine ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Kotlin ---
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# --- AndroidX ---
-dontwarn androidx.**
-keep class androidx.lifecycle.** { *; }

# --- Firebase / Google Play Services ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# --- Google Sign-In ---
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# --- OkHttp / Retrofit / Dio underlying ---
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# --- Hive / Reflection (hive_ce uses code generation, still safe) ---
-keep class **.*$HiveFieldAdapter { *; }

# --- Permission Handler ---
-dontwarn com.baseflow.permissionhandler.**

# --- Image Picker / File Picker ---
-dontwarn com.mr.flutter.plugin.filepicker.**
-dontwarn io.flutter.plugins.imagepicker.**

# --- Connectivity Plus ---
-dontwarn dev.fluttercommunity.plus.connectivity.**

# --- Keep annotations ---
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# --- Remove logging in release (reduces size + avoids log leakage) ---
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# --- Parcelables ---
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# --- Enums ---
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# --- Native methods ---
-keepclasseswithmembernames class * {
    native <methods>;
}
