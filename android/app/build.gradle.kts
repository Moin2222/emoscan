plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.emoscan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Required NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.emoscan"
        minSdk = 26 // To support TensorFlow Lite
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false // ✅ Kotlin DSL syntax
            isShrinkResources = false
            // 🔒 Comment out this line unless you've defined a signing config
            // signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // TensorFlow Lite Core
    implementation("org.tensorflow:tensorflow-lite:2.13.0")
    // Add GPU delegate or other TensorFlow components if needed
}
