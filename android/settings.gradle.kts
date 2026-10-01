pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// Plugins such as app_settings still declare their own Android Gradle Plugin
// and Kotlin Gradle Plugin classpaths. Align those with the app so Gradle does
// not try to download incompatible versions (for example AGP 7.4.2).
gradle.beforeProject {
    if (this == rootProject) {
        return@beforeProject
    }
    buildscript.configurations.configureEach {
        if (name != "classpath") {
            return@configureEach
        }
        resolutionStrategy.eachDependency {
            if (requested.group == "com.android.tools.build" && requested.name == "gradle") {
                useVersion("9.1.0")
                because("Align Flutter plugin Android Gradle Plugin with the app")
            }
            if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                useVersion("2.4.0")
                because("Align Flutter plugin Kotlin Gradle Plugin with the app")
            }
        }
    }
}
