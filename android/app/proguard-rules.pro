# Flutter Play Store Split Compat & In-App Review
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-dontwarn dev.f13.in_app_review.**
-keep class dev.f13.in_app_review.** { *; }

# WorkManager & Startup
-dontwarn androidx.work.**
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }

# Unity LevelPlay (ironSource)
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
-dontwarn com.ironsource.**
-keep class com.ironsource.** { *; }
-dontwarn com.unity3d.mediation.**
-keep class com.unity3d.mediation.** { *; }

# Room
-dontwarn androidx.room.**
-keep class androidx.room.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
