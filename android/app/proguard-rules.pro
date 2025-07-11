# CRITICAL: Jitsi Meet ProGuard rules
-keep class org.jitsi.meet.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.jitsi.meet.**
-dontwarn org.webrtc.**

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep WebRTC classes
-keep class org.webrtc.** { *; }
-dontwarn org.chromium.build.BuildHooksAndroid

# Keep React Native classes (used by Jitsi)
-keep class com.facebook.react.** { *; }
-dontwarn com.facebook.react.**
