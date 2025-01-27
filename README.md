# littletracker

Generic tracker app

Skeleton by flutter create --org com.yourdomain -t skeleton your_app_name

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/to/state-management-sample).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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