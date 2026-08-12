# Reflectively-referenced classes not present at runtime (R8 missing_rules.txt)
-dontwarn com.google.gson.internal.bind.DateTypeAdapter
-dontwarn org.slf4j.impl.StaticLoggerBinder

# Flutter / engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Play Core (optional; used only for deferred components - we don't use them)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Stripe (existing)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider