plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dotted_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Move coreLibraryDesugaringEnabled here and use 'is' prefix for Kotlin DSL
        isCoreLibraryDesugaringEnabled = true // This is the correct placement and syntax
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true // This line remains in defaultConfig
        // REMOVE: coreLibraryDesugaringEnabled = true from here
    }

    buildTypes {
        debug {
            // FIX: Use assignment operator for Kotlin DSL
            isMinifyEnabled = false
            isShrinkResources = false
        }

        release {
            // FIX: Use assignment operator for Kotlin DSL
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // This is correctly placed here
}

flutter {
    source = "../.."
}