import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xtracker/generated/locale_keys.g.dart';
import 'package:xtracker/src/model/changelog/change_log_entry.dart';
import 'package:xtracker/src/routing.dart';
import 'package:xtracker/src/screens/administration/change_log_screen.dart';
import 'package:xtracker/src/util/app_info.dart';
import 'package:xtracker/src/widgets/administration/administration_view.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/changelog/change_log_view.dart';

void main() {
  setUpAll(() {
    final translations = jsonDecode(File('assets/translations/en-US.json').readAsStringSync()) as Map<String, dynamic>;
    Localization.load(const Locale('en', 'US'), translations: Translations(translations));
  });

  testWidgets('administration opens and restores the changelog route and back returns to administration', (tester) async {
    final settingsController = SettingsController(SettingsService());
    addTearDown(settingsController.dispose);
    final routing = Routing(settingsController);
    await tester.pumpWidget(
      MaterialApp(
        restorationScopeId: 'app',
        onGenerateRoute: routing.generateRoute,
        home: const Scaffold(body: AdministrationView()),
      ),
    );
    final button = find.widgetWithText(OutlinedButton, LocaleKeys.changeLog_title.tr());
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(ChangeLogScreen), findsOneWidget);
    expect(ModalRoute.of(tester.element(find.byType(ChangeLogScreen)))!.settings.name, ChangeLogScreen.navItem.routeName);
    expect(find.byType(Dialog), findsNothing);
    for (final entry in ChangeLog.entries) {
      expect(find.text(entry.messageKey.tr()), findsOneWidget);
    }
    expect(find.text(LocaleKeys.changeLog_label_versionChanged.tr(args: [AppInfo.version])), findsNothing);

    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.byType(ChangeLogScreen), findsOneWidget);
    expect(find.text(ChangeLog.entries.last.messageKey.tr()), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ChangeLogScreen), findsNothing);
    expect(find.byType(AdministrationView), findsOneWidget);
  });

  testWidgets('update changelog shows only supplied entries and confirms through the callback', (tester) async {
    var dismissed = false;
    final entry = ChangeLog.entries.first;
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeLogView(
          entries: [entry],
          onDismiss: () => dismissed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(entry.messageKey.tr()), findsOneWidget);
    expect(find.text(ChangeLog.entries.last.messageKey.tr()), findsNothing);
    expect(find.text(LocaleKeys.changeLog_label_versionChanged.tr(args: [AppInfo.version])), findsOneWidget);

    final confirmation = find.widgetWithText(ElevatedButton, LocaleKeys.commons_dialog_btn_okay.tr());
    await tester.ensureVisible(confirmation);
    await tester.tap(confirmation);
    expect(dismissed, isTrue);
  });
}
