# Build a release

## Release branch

Create and checkout a release branch from main when all features/bugs are included.

## Check language files

Upload files to AI-Chatbot...

Prompt:

````aiprompt
Die beiden Dateien sind die Sprach-Dateien in deutsch und englisch einer Smartphone-App. Der User soll freundlich, modern und per "du" (nicht per "Sie") angesprochen werden - wenn möglich sogar ganz ohne "du". D.h. eher mit z.B. "exportiere" statt mit "du kannst hier exportieren".
Prüfe die Dateien auf Fehler und optimiere wenn möglich.
````

## Changelog

Run automatic changelog generation:

```shell
node ../../update_changelog.js
```

Check the latest changelog entries.

## Version

Adjust version in `changelog.md` and `pubspec.yaml`.

Commit

````
update version and changelog
````

## Merge

Merge the release branch to main.

As a commit message use:

```
release <version>

<changelog since the last release>
```

## Tag

Tag the main branch with the adjusted version.

## Build

see https://www.dhiwise.com/post/mastering-flutter-release-on-android-ios-and-web
and https://medium.com/@mdazadhossain95/build-and-release-an-android-app-flutter-27a97974315c
and https://docs.flutter.dev/deployment/android

### Only once

#### Create the release key.

_Example:_

````shell
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
````

_App specific:_

````shell
keytool -genkey -v -keystore xtracker-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias xTracker
````

⚠⚠⚠ Store this file in a safe place separate from your project directory. ⚠⚠⚠

#### Referencing the Keystore in Your App

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

#### Symbolic link

Because of a flutter build bug, pub cache and project have to be on the same disc for building.
See https://stackoverflow.com/questions/69663243/could-not-create-task-this-and-base-files-have-different-roots

Therefore, create a symlink on c:

````shell
mklink /J C:\dev\xtracker D:\git\xtracker
````

### Building the App for Release

To construct an app bundle, use:

````shell
c:
cd \
cd dev/xtracker
flutter clean
flutter build appbundle --release
````

After building, the app bundle should reside in the `/build/app/outputs/bundle/release` directory.

In the Google Play Console upload the aab file.

#### Troubleshooting

- Java-version warnings:

Check Version in `android/app/build.gradle.kts` (actual: `VERSION_17`).
At the moment (July 2025) build has to be done with java17 (java21 delivers warnings).

Check the flutter jdk-dir:

````shell
flutter config --list
````

In case it is not set or points to other java than 17 use the following command to set the correct jdk for flutter:

````shell
flutter config --jdk-dir=<path to jdk>
````

Restart all tools after that.