# Build AAB when "strip debug symbols" fails (Windows)

If `flutter build appbundle --release` fails with **"Release app bundle failed to strip debug symbols from native libraries"**, the bundle is still built by Gradle. You can get the AAB in either way below.

## Option 1: Use the AAB Gradle already built

After the Flutter command fails, check whether the AAB exists:

**Path:** `android\app\build\outputs\bundle\release\app-release.aab`

If that file exists, you can **upload it to Play Console** as-is. It is a valid release bundle; Play Store will accept it (it may be slightly larger if it still contains debug symbols).

## Option 2: Build the AAB with Gradle only (no Flutter strip step)

From the **project root** (e.g. `E:\Berlin-Germany\provider-app`):

```powershell
cd android
.\gradlew.bat bundleRelease
cd ..
```

The AAB is written to:

**`android\app\build\outputs\bundle\release\app-release.aab`**

Copy it to your usual place if you want, e.g.:

```powershell
copy android\app\build\outputs\bundle\release\app-release.aab build\app\outputs\bundle\release\
```

Then upload **app-release.aab** to Google Play Console. This avoids the Flutter strip step that fails on some Windows/NDK setups.
