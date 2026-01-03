import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties from key.properties file
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { stream ->
        keystoreProperties.load(stream)
    }
}

android {
    namespace = "com.tawfir.energy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID - MUST be unique and follow reverse domain notation
        // Format: com.company.appname (lowercase, no spaces, no special chars except dots)
        applicationId = "com.tawfir.energy"
        
        // SDK Versions - Flutter defaults are usually:
        // minSdk: 21 (Android 5.0) - Good for 95%+ devices
        // targetSdk: 34 (Android 14) - Latest stable
        // compileSdk: 34 - Must be >= targetSdk
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // Version info from pubspec.yaml (version: 1.0.0+1)
        // versionName = "1.0.0" (user-visible)
        // versionCode = 1 (internal, must increment for each release)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable MultiDex if needed (for apps > 65K methods)
        multiDexEnabled = true
    }

    // Signing configurations for release builds
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keyAliasValue = keystoreProperties["keyAlias"] as String?
                val keyPasswordValue = keystoreProperties["keyPassword"] as String?
                val storeFileValue = keystoreProperties["storeFile"] as String?
                val storePasswordValue = keystoreProperties["storePassword"] as String?
                
                if (keyAliasValue != null && keyPasswordValue != null && 
                    storeFileValue != null && storePasswordValue != null) {
                    keyAlias = keyAliasValue
                    keyPassword = keyPasswordValue
                    // Resolve keystore file path relative to android/ directory
                    val keystoreFile = if (storeFileValue.startsWith("/") || storeFileValue.contains(":")) {
                        file(storeFileValue) // Absolute path
                    } else {
                        rootProject.file(storeFileValue) // Relative to android/ directory
                    }
                    storeFile = keystoreFile
                    storePassword = storePasswordValue
                }
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config
            if (!keystorePropertiesFile.exists()) {
                println("⚠️  WARNING: key.properties not found!")
                println("⚠️  Building with DEBUG signing. This AAB will be REJECTED by Google Play!")
                println("⚠️  To fix: Create android/key.properties and android/upload-keystore.jks")
                println("⚠️  Run: create_keystore.bat or see FIX_RELEASE_SIGNING.md")
            }
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug") // Fallback for development
            }
            
            // Enable code shrinking, obfuscation, and optimization
            // Set to false temporarily if build fails, then enable after fixing issues
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Debug builds use debug signing
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

  // MultiDex support (required when multiDexEnabled = true)
  implementation("androidx.multidex:multidex:2.0.1")

  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  // https://firebase.google.com/docs/android/setup#available-libraries
}