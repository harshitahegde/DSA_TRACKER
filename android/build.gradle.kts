// Top-level build file where you can add configuration options common to all sub-projects/modules.

// Define the required plugin versions
val androidGradlePluginVersion = "8.1.1"
val kotlinVersion = "1.8.20"
val flutterGradlePluginVersion = "1.0.0"

// Plugin declarations. These must match what's used in the app-level build.gradle.kts
plugins {
    id("com.android.application") version androidGradlePluginVersion apply false
    id("org.jetbrains.kotlin.android") version kotlinVersion apply false
    id("dev.flutter.flutter-gradle-plugin") version flutterGradlePluginVersion apply false
}

// Ensure repositories are defined for all sub-projects (like the app module)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define the 'clean' task to correctly handle 'flutter clean' at the project root
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
