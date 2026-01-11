// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    // Add Kotlin DSL plugins
    id("com.android.application") version "8.1.1" apply false
    id("org.jetbrains.kotlin.android") version "1.8.20" apply false
    kotlin("android") version "1.8.20" apply false // Ensure this is present
}

android {
    namespace = "com.example.dsa_tracker" // Replace with your actual package name if different
    compileSdk = 34 // Ensure this is a recent SDK version

    defaultConfig {
        // TODO: Specify your minSdkVersion here
        minSdk = 21 
        targetSdk = 34
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        create("release") {
            // Your release keystore configuration (if applicable)
        }
    }

    buildTypes {
        release {
            // TODO: Add your release settings here
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // --- START OF FIX: CORE LIBRARY DESUGARING ---
    compileOptions {
        // Set compatibility to Java 1.8 to support flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
    // --- END OF FIX ---
}

dependencies {
    // Other dependencies...

    // --- START OF FIX: CORE LIBRARY DESUGARING DEPENDENCY ---
    // This library provides the Java 8+ features needed by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // --- END OF FIX ---
}