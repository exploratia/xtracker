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

Build apk - upload to PlayStore.