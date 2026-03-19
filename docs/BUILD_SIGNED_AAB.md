# Build signed AAB (Android App Bundle)

Do these steps once to sign, then run the build command.

---

## Step 1: Create a keystore (only if you don’t have one)

Run this in a terminal. Replace the placeholders, then run the command.

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You will be prompted to enter:

- **Keystore password** (remember it; you’ll use it as `storePassword`)
- **Key password** (can be same as keystore; you’ll use it as `keyPassword`)
- Your name, org, city, state, country (for the certificate)

**Important:** Keep the `.jks` file and passwords safe. Back up the keystore; you need it for all future Play Store updates.

---

## Step 2: Create `key.properties`

Create the file **`android/key.properties`** with this content (replace the values with yours):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

- **storePassword** – password you set for the keystore
- **keyPassword** – password you set for the key (often same as storePassword)
- **keyAlias** – alias you used in the keytool command (e.g. `upload`)
- **storeFile** – keystore file name. If the file is inside `android/`, use `upload-keystore.jks`. If it’s somewhere else, use the path relative to the `android` folder (e.g. `../keys/upload-keystore.jks`).

**Security:** `key.properties` is in `.gitignore`. Do not commit it or the keystore.

---

## Step 3: Build the signed AAB

From the **project root** (e.g. `e:\Berlin-Germany\provider-app`):

```bash
flutter build appbundle
```

The signed AAB will be at:

**`build/app/outputs/bundle/release/app-release.aab`**

Upload this file to Google Play Console.

---

## Quick reference

| What            | Where / Command |
|-----------------|------------------|
| Create keystore | `keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` |
| Signing config  | `android/key.properties` |
| Build AAB       | `flutter build appbundle` |
| Output AAB      | `build/app/outputs/bundle/release/app-release.aab` |
