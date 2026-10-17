# Flutter Play Store Split Compat & In-App Review
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-dontwarn dev.f13.in_app_review.**
-keep class dev.f13.in_app_review.** { *; }

# WorkManager & Startup
-dontwarn androidx.work.**
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }

# Google Mobile Ads
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class com.google.android.gms.ads.** { *; }

# Room
-dontwarn androidx.room.**
-keep class androidx.room.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
