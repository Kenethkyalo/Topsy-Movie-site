plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin must be applied after Android/Kotlin plugins
}

flutter {
    source = "../.."
}

android {
    namespace = "com.example.android"
    compileSdk = 34 // ✅ Corrected syntax

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.android"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

   buildTypes {
    release {
        isMinifyEnabled = false  // ✅ Kotlin DSL requires "isMinifyEnabled"
        isShrinkResources = false  // ✅ Kotlin DSL requires "isShrinkResources"
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )

        signingConfig = signingConfigs.getByName("debug")  // ✅ Fix signingConfig reference
    }
}

}
