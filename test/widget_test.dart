// This is an example Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
//
// Visit https://flutter.dev/to/widget-testing for
// more information about Widget testing.

import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
// The compatibility test exercises the SDK types used by older packages.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:xtracker/src/app.dart';
import 'package:xtracker/src/util/date_time_utils.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/changelog/change_log_view.dart';
import 'package:xtracker/src/widgets/controls/select/month_switcher.dart';

void main() {
  testWidgets('MyApp provides the active theme and German strings to both Material libraries', (tester) async {
    final context = await _pumpGermanApp(tester);
    expect(sdk.Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary);
    expect(sdk.Theme.of(context).brightness, Brightness.dark);
    expect(sdk.MaterialLocalizations.of(context).cancelButtonLabel, 'Abbrechen');
    expect(MaterialLocalizations.of(context).cancelButtonLabel, 'Abbrechen');
    expect(tester.takeException(), isNull);
  }, variant: const TargetPlatformVariant({TargetPlatform.windows}));

  testWidgets('the month picker confirms a month in the German app', (tester) async {
    final context = await _pumpGermanApp(tester);
    final initialDate = DateTime(2025, 3, 1, 8, 15);
    DateTime? selectedMonth;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: MonthSwitcher(initialDate: initialDate, monthCallback: (month) => selectedMonth = month),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(DateTimeUtils.formatMonthYear(initialDate)));
    await tester.pumpAndSettle();
    expect(find.text('Abbrechen'), findsOneWidget);
    await tester.tap(find.text(MaterialLocalizations.of(context).okButtonLabel));
    await tester.pumpAndSettle();

    expect(selectedMonth, initialDate);
  }, variant: const TargetPlatformVariant({TargetPlatform.windows}));

  group('MyWidget', () {
    testWidgets('should display a string of text', (WidgetTester tester) async {
      // Define a Widget
      const myWidget = MaterialApp(
        home: Scaffold(
          body: Text('Hello'),
        ),
      );

      // Build myWidget and trigger a frame.
      await tester.pumpWidget(myWidget);

      // Verify myWidget shows some text
      expect(find.byType(Text), findsOneWidget);
    });
  });
}

Future<BuildContext> _pumpGermanApp(WidgetTester tester) async {
  await initializeDateFormatting();
  final settings = _ChangeLogSettingsController();
  addTearDown(settings.dispose);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: SettingsService.supportedLocales,
      startLocale: const Locale('de', 'DE'),
      saveLocale: false,
      path: 'assets/translations',
      assetLoader: const _TranslationLoader(),
      child: MyApp(settingsController: settings),
    ),
  );
  await tester.pumpAndSettle();
  return tester.element(find.byType(ChangeLogView));
}

class _ChangeLogSettingsController extends SettingsController {
  _ChangeLogSettingsController() : super(SettingsService());

  @override
  bool get showChangeLog => true;

  @override
  ThemeMode get themeMode => ThemeMode.dark;
}

class _TranslationLoader extends AssetLoader {
  const _TranslationLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.toLanguageTag()}.json').readAsStringSync()) as Map<String, dynamic>;
}
