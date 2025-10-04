# Build a release

## Release branch

Create and checkout a release branch from main when all features/bugs are included.

## Check language files

Upload files to AI-Chatbot...

Prompt: improve_language_files

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
flutter clean
flutter build appbundle --release
````

After building, the app bundle should reside in the `/build/app/outputs/bundle/release` directory.  
In the Google Play Console create a new release and upload the aab file.