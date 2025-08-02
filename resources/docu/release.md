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
In `pubspec.yaml` also increase the build number (after +) by one.

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

## Build the app for release

To construct an app bundle, use:

````shell
c:
cd \
cd dev/xtracker
flutter clean
flutter build appbundle --release
````

After building, the app bundle should reside in the `/build/app/outputs/bundle/release` directory.  
In the Google Play Console create a new release and upload the aab file.

### Troubleshooting

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