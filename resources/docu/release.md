# Build a release

## Release branch

Create and checkout a release branch from main when all features/bugs are included.

## Check dependencies (again - and do tests after that)

New major versions available?

```shell
flutter pub upgrade --major-versions
```

Check pubspec.yaml in IDE

```shell
flutter pub upgrade
flutter pub get
```

## Changelog

Run automatic changelog generation:

```shell
node update_changelog.js
```

Check the latest changelog entries:
`lib/src/model/changelog/change_log_entry.dart`

Ensure every released version is registered there and covered by a test in
`test/src/model/changelog/change_log_entry_test.dart`.

## Language files

Optionally check changes in language files on consistency and if there are any improvements to be made.

## Version

Adjust version in `changelog.md` and `pubspec.yaml`.  
In `pubspec.yaml` also increase the build number (after +) by one.

## Playstore images

Create images for phone and tablet with version no as prefix.

Maybe update readme screenshots.

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
