# Build a release

## Release branch

Create and checkout a release branch from main when all features/bugs are included.

## Changelog

Run automatic changelog generation:

```shell
node ../../update_changelog.js
```

Check the latest changelog entries.

## Version

Adjust version in `changelog.md` and `pubspec.yaml`.  
In `pubspec.yaml` also increase the build number (after +) by one.

## Check language files

Upload files to AI-Chatbot...

Prompt:

````
Füge in den translation Dateien einen neuen changelog Eintrag für die neuen Versionen hinzu.
Prüfe die Änderungen in den Sprachdateien auf Konsistenz und ob noch etwas verbessert werden sollte.
````

## Playstore images

Create images for phone and tablet with version no as prefix.

## Commit

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
flutter clean
flutter build appbundle --release
````

After building, the app bundle should reside in the `/build/app/outputs/bundle/release` directory.  
In the Google Play Console create a new release and upload the aab file.