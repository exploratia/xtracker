import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/store/stores_utils.dart';
import 'src/util/app_info.dart';
import 'src/util/date_time_utils.dart';
import 'src/util/logging/daily_files.dart';
import 'src/util/stack/stack_utils.dart';
import 'src/util/tmp_clean.dart';
import 'src/widgets/administration/settings/settings_controller.dart';
import 'src/widgets/administration/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization only show > warning
  EasyLocalization.logger.enableLevels = EasyLocalization.logger.enableLevels.sublist(2);
  await EasyLocalization.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Init date formatting
  await initializeDateFormatting();

  DateTimeUtils.init();

  // Load app info
  await AppInfo.init();

  // init stack utils with determined project name
  StackUtils.init(AppInfo.projectName);

  await DailyFiles.init();

  await TmpClean.clearTmpDirectory();

  await StoresUtils.initDb();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the SettingsView.
  runApp(EasyLocalization(
    supportedLocales: SettingsService.supportedLocales,
    path: 'assets/translations',
    fallbackLocale: SettingsService.supportedLocales[0],
    startLocale: settingsController.locale,
    // done by ourselves:
    saveLocale: false,
    child: MyApp(settingsController: settingsController),
  ));
}
