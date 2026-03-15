# Using a new Google Services JSON file

To use a **new** `google-services.json` (e.g. for a different Firebase project or Persotel Pro):

## Android

1. **Get the new file from Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project (or create one)
   - Project settings (gear) → **Your apps**
   - If the Android app is not added: add Android app with package name **`com.Persotel.provide`** (or your app’s package name)
   - Download **google-services.json**

2. **Replace the file in the project**
   - Put the new file here (overwrite the existing one):
   - **`android/app/google-services.json`**

3. **Check package name**
   - Open the new `google-services.json` and ensure under `client` → `client_info` → `android_client_info` the **`package_name`** matches your app (**`com.Persotel.provide`**).

4. **Rebuild**
   - Clean and build:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

No code changes are needed; the Android build already applies the Google Services plugin and reads `android/app/google-services.json`.

---

## iOS (GoogleService-Info.plist)

If you switched Firebase project, update iOS too:

1. In Firebase Console, open the same project → add **iOS app** if needed (Bundle ID **`com.Persotel.provide`**).
2. Download **GoogleService-Info.plist**.
3. Replace:
   - **`ios/Runner/GoogleService-Info.plist`**
4. Rebuild the iOS app.

---

## Summary

| Platform | File to replace | Location |
|----------|------------------|----------|
| Android  | `google-services.json` | `android/app/google-services.json` |
| iOS      | `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

Replace the existing file with your new one, then run `flutter clean` and rebuild.
