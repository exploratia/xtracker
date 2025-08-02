# Release Troubleshooting

## Java-version warnings:

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