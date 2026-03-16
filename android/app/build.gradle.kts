import java.util.Properties

plugins {

    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


android {
    namespace = "de.persotel.pro"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "de.persotel.pro"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 91
        versionName = "11.13.0"
        ndk {
            debugSymbolLevel = "none"
        }
    }

    signingConfigs {
        create("release") {
            val props = loadKeystoreProps("key.properties")
            val storePath = props["storeFile"]
            if (storePath != null) {
                storeFile = rootProject.file(storePath)
                keyAlias = props["keyAlias"]
                keyPassword = props["keyPassword"]
                storePassword = props["storePassword"]
            }
        }
    }

    buildTypes {
        getByName("debug") {
            isShrinkResources = false
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }

        getByName("release") {
            isShrinkResources = true
            isMinifyEnabled = true
            signingConfig = if (signingConfigs.getByName("release").storeFile != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation(platform("com.google.firebase:firebase-bom:32.4.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.android.material:material:1.5.0")
    implementation("phonepe.intentsdk.android.release:IntentSDK:2.3.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}

fun loadKeystoreProps(path: String): Map<String, String> {
    val file = rootProject.file(path)
    if (!file.exists()) return emptyMap()
    val props = Properties()
    file.inputStream().use { props.load(it) }
    return props.entries.associate { it.key.toString() to it.value.toString() }
}