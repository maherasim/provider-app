# Flutter Setup Guide for Windows - Provider App

## Overview
This guide is customized for your **provider-app** Flutter project. Your project has specific requirements that must be met.

## Your Project Requirements

Based on your codebase analysis:
- **Flutter SDK:** >=3.0.0 <4.0.0 (Flutter 3.x required)
- **Android SDK:** 36 (Android 14) - **CRITICAL**
- **Target SDK:** 36
- **NDK Version:** 28.2.13676358 (specific version required)
- **Java/JDK:** Version 11 (required)
- **Kotlin:** 2.1.0
- **Android Gradle Plugin:** 8.9.1
- **Firebase:** Already configured (google-services.json exists)
- **Build Tools:** MobX code generation required

## Step-by-Step Installation

### Step 1: Install Java JDK 11 (Required First!)
**Your project requires Java 11 specifically!**

1. **Download JDK 11:**
   - Go to: https://adoptium.net/temurin/releases/?version=11
   - Download "JDK 11" for Windows (x64)
   - Or use Oracle JDK 11: https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html

2. **Install JDK 11:**
   - Run the installer
   - Note the installation path (usually `C:\Program Files\Java\jdk-11.x.x`)

3. **Set JAVA_HOME Environment Variable:**
   - Press `Win + X` → "System" → "Advanced system settings" → "Environment Variables"
   - Under "User variables", click "New"
   - Variable name: `JAVA_HOME`
   - Variable value: `C:\Program Files\Java\jdk-11.x.x` (your JDK path)
   - Click "OK"
   - Also add to PATH: `%JAVA_HOME%\bin`

4. **Verify Java Installation:**
   - Open new PowerShell: `java -version`
   - Should show version 11.x.x

### Step 2: Install Flutter SDK
1. **Download Flutter SDK:**
   
   **Option 1 - Official Download Page (Recommended):**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Scroll down and click the download button for "Flutter SDK (stable)"
   - Or use direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.6-stable.zip
   
   **Option 2 - GitHub Releases (Alternative):**
   - Go to: https://github.com/flutter/flutter/releases
   - Find the latest **stable** release (version 3.x.x)
   - Download: `flutter_windows_3.x.x-stable.zip`
   
   **Important:** 
   - Must be Flutter 3.x (your project requires >=3.0.0 <4.0.0)
   - Download the ZIP file (not the source code)
   - File size is approximately 1.5 GB

2. **Extract Flutter SDK:**
   - Extract the ZIP file to `C:\src\flutter`
   - **Important:** 
     - Do NOT extract to `C:\Program Files\` (requires admin privileges)
     - The final path should be: `C:\src\flutter\bin\flutter.bat`
     - If `C:\src` doesn't exist, create it first

2. **Add Flutter to PATH:**
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin`
   - **Important:** Must include `\bin` at the end! (NOT just `C:\src\flutter`)
   - Click "OK" on all dialogs

3. **Verify Flutter Installation:**
   - Open a new PowerShell/Command Prompt window
   - Run: `flutter --version`
   - You should see Flutter version information

### Step 2: Install Android Studio
**Yes, you should install Android Studio!** It provides:
- Android SDK (required for Android development)
- Android Emulator (to test apps)
- Flutter and Dart plugins

1. **Download Android Studio:**
   - Go to: https://developer.android.com/studio
   - Download the installer for Windows
   - Run the installer and follow the setup wizard

2. **During Android Studio Setup:**
   - Choose "Standard" installation
   - Let it download Android SDK components
   - Accept all licenses when prompted

3. **Install Flutter and Dart Plugins:**
   - Open Android Studio
   - Go to `File` → `Settings` (or `Configure` → `Plugins` on welcome screen)
   - Click "Plugins" tab
   - Search for "Flutter" and install it (Dart plugin will be installed automatically)
   - Restart Android Studio

### Step 3: Install Android SDK Components (CRITICAL - Your Project Needs SDK 36!)
1. **Open Android Studio:**
   - Go to `File` → `Settings` → `Appearance & Behavior` → `System Settings` → `Android SDK`
   - Or use `Tools` → `SDK Manager`

2. **Install Required Components (YOUR PROJECT SPECIFIC):**
   - **SDK Platforms tab:** 
     - ✅ **Android 14.0 (API 36)** - **REQUIRED** (your project uses compileSdk 36)
     - ✅ Android 13.0 (API 33) - Recommended for compatibility
   - **SDK Tools tab:** Ensure these are checked:
     - ✅ Android SDK Build-Tools (latest version)
     - ✅ Android SDK Command-line Tools (latest)
     - ✅ Android SDK Platform-Tools
     - ✅ Android Emulator
     - ✅ Google Play services
     - ✅ **NDK (Side by side)** - **IMPORTANT** - Your project needs NDK version 28.2.13676358
     - ✅ CMake (if available)
   - Click "Apply" and wait for installation (this may take 10-20 minutes)

3. **Verify NDK Installation:**
   - After installation, check: `C:\Users\YourUsername\AppData\Local\Android\Sdk\ndk\`
   - Your project requires NDK version: **28.2.13676358**
   - If this specific version is not available, you may need to download it manually or use Android Studio's SDK Manager

### Step 4: Set Up Android Emulator (Optional but Recommended)
1. **Create Virtual Device:**
   - In Android Studio, go to `Tools` → `Device Manager`
   - Click "Create Device"
   - Select a device (e.g., Pixel 5 or Pixel 6)
   - **Download system image:** Android 14.0 (API 36) - **Recommended** to match your target SDK
   - Or Android 13.0 (API 33) for compatibility
   - Finish the setup

### Step 5: Verify Flutter Setup
1. **Run Flutter Doctor:**
   - Open PowerShell/Command Prompt
   - Run: `flutter doctor`
   - This will check your setup and show what's missing

2. **Fix Common Issues:**
   - If Android toolchain is missing: Install Android Studio and SDK
   - If Android license not accepted: Run `flutter doctor --android-licenses` and accept all
   - If VS Code is mentioned: Optional, you can install VS Code with Flutter extension later

### Step 6: Accept Android Licenses
Run this command in PowerShell/Command Prompt:
```bash
flutter doctor --android-licenses
```
Accept all licenses by typing `y` when prompted.

### Step 7: Install Git (If Not Already Installed)
Flutter requires Git for package management:
- Download from: https://git-scm.com/download/win
- Install with default settings

### Step 8: Configure Your Project's local.properties
**Your project has a `local.properties` file that needs to be updated with YOUR paths!**

1. **Update local.properties:**
   - Navigate to: `E:\Berlin-Germany\provider-app\android\local.properties`
   - Open it in a text editor
   - Update the paths:
     ```
     sdk.dir=C:\\Users\\YOUR_USERNAME\\AppData\\Local\\Android\\sdk
     flutter.sdk=C:\\src\\flutter
     flutter.buildMode=debug
     flutter.versionName=11.13.0
     flutter.versionCode=91
     ```
   - Replace `YOUR_USERNAME` with your actual Windows username
   - Verify `flutter.sdk` path matches where you installed Flutter

2. **Navigate to Your Project:**
   ```bash
   cd E:\Berlin-Germany\provider-app
   ```

3. **Get Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Generate MobX Code (Your project uses MobX):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Verify Project Setup:**
   ```bash
   flutter doctor -v
   ```

## Quick Verification Checklist

After setup, verify everything works:

- [ ] `java -version` shows Java 11.x.x
- [ ] `flutter --version` shows Flutter 3.x (not 2.x or 4.x)
- [ ] `flutter doctor` shows no critical issues (warnings are OK)
- [ ] Android Studio is installed with Flutter plugin
- [ ] Android SDK 36 (API 36) is installed
- [ ] NDK is installed (check for version 28.2.13676358 if possible)
- [ ] Android licenses are accepted
- [ ] `local.properties` file has correct paths
- [ ] `flutter pub get` runs successfully
- [ ] `flutter pub run build_runner build` completes without errors

## Running Your Project

1. **List Available Devices:**
   ```bash
   flutter devices
   ```

2. **Run on Android Emulator:**
   - Start Android Emulator from Android Studio
   - Run: `flutter run`

3. **Run on Connected Android Device:**
   - Enable USB debugging on your Android phone
   - Connect via USB
   - Run: `flutter run`

## Troubleshooting

### Flutter Doctor Shows Issues:
- **Android toolchain missing:** Install Android Studio and SDK
- **Android licenses not accepted:** Run `flutter doctor --android-licenses`
- **VS Code not found:** Optional, can install later if needed

### Build Errors:
- **Java version mismatch:** Ensure Java 11 is installed and JAVA_HOME is set correctly
- **SDK 36 not found:** Install Android SDK 36 (API 36) from Android Studio SDK Manager
- **NDK issues:** Verify NDK is installed. Your project needs version 28.2.13676358
- **local.properties errors:** Check that paths in `android/local.properties` are correct
- **MobX code generation:** Run `flutter pub run build_runner build --delete-conflicting-outputs`
- **Gradle sync issues:** In Android Studio, go to `File` → `Sync Project with Gradle Files`
- Run `flutter clean` then `flutter pub get`
- Check that your Flutter SDK version is 3.x (>=3.0.0 <4.0.0)

### Emulator Not Starting:
- Enable virtualization in BIOS (Intel VT-x or AMD-V)
- Check Windows Hyper-V settings

## Additional Tools (Optional)

- **VS Code:** Lightweight editor with Flutter extension
- **Chrome:** For web development (if needed)
- **Visual Studio:** For Windows desktop development (if needed)

## Next Steps

Once setup is complete:
1. Open your project in Android Studio
2. Wait for indexing to complete
3. Run `flutter pub get` to install dependencies
4. Start an emulator or connect a device
5. Click the "Run" button or use `flutter run`

## Project-Specific Notes

### Firebase Configuration
- ✅ Your project already has `google-services.json` in `android/app/`
- Firebase is pre-configured, but you may need to verify Firebase project settings match your environment

### Key Files in Your Project
- `android/app/build.gradle.kts` - Uses Kotlin DSL, requires SDK 36, NDK 28.2.13676358
- `android/settings.gradle.kts` - Uses Android Gradle Plugin 8.9.1, Kotlin 2.1.0
- `android/local.properties` - **MUST be updated with your paths**
- `pubspec.yaml` - Requires Flutter SDK >=3.0.0 <4.0.0

### MobX Code Generation
Your project uses MobX for state management. After any changes to MobX stores, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Payment SDKs
Your project includes multiple payment integrations (Stripe, Razorpay, PhonePe, etc.). These should work once the project builds successfully.

---

## Installation Order Summary

1. ✅ **Java JDK 11** (Required first!)
2. ✅ **Flutter SDK 3.x** (>=3.0.0)
3. ✅ **Android Studio** (with Flutter plugin)
4. ✅ **Android SDK 36** (API 36) - Critical!
5. ✅ **NDK** (version 28.2.13676358 if possible)
6. ✅ **Update local.properties** with your paths
7. ✅ **Run flutter pub get**
8. ✅ **Run build_runner** for MobX code generation
