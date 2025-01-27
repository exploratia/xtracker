import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/util/app_info.dart';
import 'src/util/logging/daily_files.dart';
import 'src/widgets/administration/settings/settings_controller.dart';
import 'src/widgets/administration/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Load app info
  await AppInfo.init();

  await DailyFiles.init();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
