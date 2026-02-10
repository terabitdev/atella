import java.util.Properties
import java.io.FileInputStream
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
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
    namespace = "com.company.atella"
    compileSdk = 36
    // ndkVersion = flutter.ndkVersion as String

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.company.atella"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            val storeFileProp = keystoreProperties["storeFile"] as String?
            if (storeFileProp != null && storeFileProp.isNotEmpty()) {
                create("release") {
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                    storeFile = file(storeFileProp)
                    storePassword = keystoreProperties["storePassword"] as String?
                }
            }
        }
        getByName("debug") {
            storeFile = file("${rootProject.projectDir}/app/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }
    buildTypes {
        release {
            // Use release signing config if available, otherwise use debug signing
            if (keystorePropertiesFile.exists()) {
                val storeFileProp = keystoreProperties["storeFile"] as String?
                if (storeFileProp != null && storeFileProp.isNotEmpty()) {
                    signingConfig = signingConfigs.getByName("release")
                } else {
                    // Fall back to debug signing if key.properties exists but is incomplete
                    signingConfig = signingConfigs.getByName("debug")
                }
            } else {
                // Use debug signing if key.properties doesn't exist
                signingConfig = signingConfigs.getByName("debug")
            }
        }
}
}


flutter {
    source = "../.."
}

dependencies {
    // Google Play Billing library for in-app purchases
    implementation("com.android.billingclient:billing:7.1.1")
}
