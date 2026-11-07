# --- TensorFlow Lite & GPU support ---
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }


# --- Prevent obfuscation for native/reflective access ---
-keepclassmembers class * {
    native <methods>;
}
-keepclassmembers class * {
    public <init>(...);
}
-keep class * extends java.lang.Exception

# Optional: Keep enums used by TensorFlow Lite
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
