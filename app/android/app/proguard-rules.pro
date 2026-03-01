# ── flutter_local_notifications ───────────────────────────────────────────────
# The plugin uses GSON + RuntimeTypeAdapterFactory to persist scheduled
# notifications to SharedPreferences. Keep all plugin classes so their names
# and members survive R8 minification.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ── GSON + R8 v3 TypeToken fix ────────────────────────────────────────────────
# R8 v3+ removes Signature attributes from TypeToken anonymous subclasses even
# when -keepattributes Signature is set, unless these two rules are present.
# The plugin calls: new TypeToken<List<NotificationDetails>>() {}
# Without the second rule, getGenericSuperclass() returns a raw Class instead of
# a ParameterizedType → GSON throws "Missing type parameter" in TypeToken.<init>.
# Source: GSON official R8/ProGuard guidance (added in GSON 2.9.1).
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Keep generic type signatures and annotations (required for GSON reflection).
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
