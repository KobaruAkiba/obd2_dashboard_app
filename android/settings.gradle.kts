pluginManagement {
    val flutterSdkPath = run {
        file("${rootDir.parentFile}/flutter").asFile.takeIf { it.exists() }
            ?: throw GradleException("Flutter SDK not found at ${rootDir.parent}")
    }

    plugins {
        id("com.android.application") version "8.1.0" apply false
        id("org.jetbrains.kotlin.android") version "1.9.0" apply false
        id("dev.flutter.flutter-plugin-loader") version "1.0.0" apply false
        id("com.google.gms.google-services") version "4.4.0" apply false
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

include(":app")

