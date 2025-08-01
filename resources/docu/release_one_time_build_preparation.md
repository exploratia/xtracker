# Build a release - one-time preparation

see https://www.dhiwise.com/post/mastering-flutter-release-on-android-ios-and-web  
and https://medium.com/@mdazadhossain95/build-and-release-an-android-app-flutter-27a97974315c  
and https://docs.flutter.dev/deployment/android

## Create the release key.

_Example:_

````shell
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
````

_App specific:_

````shell
keytool -genkey -v -keystore xtracker-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias xTracker
````

⚠⚠⚠ Store this file in a safe place separate from your project directory. ⚠⚠⚠

## Referencing the keystore in the app

After creating the keystore, reference it in your app.  
In the `android/` directory, create a file named `key.properties` that contains a reference to the keystore using the
following format:

````
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=my-alias
storeFile=/path/to/my-release-key.jks
````

Remember, replace the placeholders `<password from previous step>` with your actual passwords,
and `/path/to/my-release-key.jks` with the actual path where your key is stored.

⚠⚠⚠ This file should NOT be checked in into your source version control. ⚠⚠⚠

Configure signing in gradle in android/app/build.gradle.kts

````kotlin
// import java.io.FileInputStream
// import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "de.exploratia.xtracker"
    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "de.exploratia.xtracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storePassword = keystoreProperties["storePassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
        }
    }

    buildTypes {
        release {
            // Enables code-related app optimization.
            isMinifyEnabled = true

            // Enables resource shrinking.
            isShrinkResources = true

            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")

//            isDebuggable = true
            signingConfig = signingConfigs["release"]
        }
    }
}

flutter {
    source = "../.."
}
````

## Symbolic link

Because of a flutter build bug, pub cache and project have to be on the same disc for building.  
See https://stackoverflow.com/questions/69663243/could-not-create-task-this-and-base-files-have-different-roots

Therefore, create a symlink on c - run builds from there:

````shell
mklink /J C:\dev\xtracker D:\git\xtracker
````
