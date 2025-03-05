# littletracker

Generic tracker app

Skeleton by flutter create --org com.yourdomain -t skeleton your_app_name

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).
TODO for iOS:
https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#localizing-for-ios-updating-the-ios-app-bundle

## Dependencies

### Appinfo

https://pub.dev/packages/package_info_plus

#### Usage

- Init AppInfo in main before running the app.
- Use AppInfo where needed.

```dart
import 'package:flutter_app_info/flutter_app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.init();
  runApp(const MyApp());
}

void doSomething() {
  const appName = AppInfo.appName;
}
```

### DeviceStorage

https://pub.dev/packages/flutter_secure_storage

### SimpleLogging

https://pub.dev/packages/path_provider
https://pub.dev/packages/flutter_archive
https://pub.dev/packages/logger
https://pub.dev/packages/share_plus

### UUId

https://pub.dev/packages/uuid

### Provider

https://pub.dev/packages/provider

### LinkedScrollController

https://pub.dev/packages/linked_scroll_controller

### Chart

https://pub.dev/packages/fl_chart

### Launcher icon (dev)

https://pub.dev/packages/flutter_launcher_icons

## App Icon

resources/`app_icon_source.png`
Save origin img as 192px and then increase (not resize) image to 432px

## Create Launcher Icons

- run `dart run flutter_launcher_icons`

## Build apk (Android)

- Increase version in pubspec.yaml

### CPU special apk

- run `flutter build apk --split-per-abi`
- use e.g. `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`

### one apk bundle for all CPUs

- run `flutter build apk`
- use `build\app\outputs\flutter-apk\app-release.apk`

## IOS

### How to fix Using `ARCHS` setting to build architectures of target `Pods-Runner`

Pod-File ändern:

```
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Installation des pod-files (M1/M2-Chip) - Did you try:

- sudo gem install cocoapods
- sudo arch -x86_64 gem install ffi
- arch -x86_64 pod repo update
- arch -x86_64 pod install (im ios Verzeichnis auf Console ausführen!)

## Edit readme.md

https://stackedit.io/app#