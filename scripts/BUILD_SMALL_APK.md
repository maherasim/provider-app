# Building a smaller APK

## 1. Split APKs by CPU (recommended – biggest size drop)

One “fat” APK contains native libs for **all** CPUs (arm64, arm32, x86_64), so it’s large.

Build **one APK per ABI** so each file is much smaller (e.g. ~40–60 MB instead of ~117 MB):

```bash
flutter build apk --release --split-per-abi
```

Outputs in `build/app/outputs/flutter-apk/`:

- `app-armeabi-v7a-release.apk`  (older 32-bit ARM)
- `app-arm64-v8a-release.apk`    (most current phones – use this for testing)
- `app-x86_64-release.apk`      (emulators / some devices)

Install the one that matches the device (usually **app-arm64-v8a-release.apk**).

## 2. Code and resource shrinking (already enabled)

In `android/app/build.gradle.kts`, release has:

- **minifyEnabled = true** (R8 shrinks/obfuscates Java/Kotlin code)
- **shrinkResources = true** (removes unused resources)

Together these often save a noticeable amount. ProGuard rules are in `android/app/proguard-rules.pro`.

## 3. For Play Store – use App Bundle

For uploads to Google Play, use an Android App Bundle. Play then generates optimized APKs per device (smaller downloads):

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Summary

| Command | Use case | Typical size |
|--------|----------|--------------|
| `flutter build apk --release` | Single fat APK | ~100+ MB |
| `flutter build apk --release --split-per-abi` | 3 APKs, one per CPU | ~40–60 MB each |
| `flutter build appbundle --release` | Upload to Play Store | Users get smaller downloads |

Prefer **`--split-per-abi`** for direct APK installs, and **appbundle** for Play Store.
