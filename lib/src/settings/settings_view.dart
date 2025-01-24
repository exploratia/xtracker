import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    var actTheme = controller.themeMode;
    var themeItems = [
      {'v': ThemeMode.system, 'text': "System"},
      {'v': ThemeMode.light, 'text': "Light"},
      {'v': ThemeMode.dark, 'text': "Dark"},
    ];

    var actLocale = controller.locale;
    var localeItems = [
      {'v': null, 'text': "System"},
      {'v': Locale("de"), 'text': "Deutsch"},
      {'v': Locale("en"), 'text': "English"},
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t!.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Column(
          children: [
            DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: actTheme,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateThemeMode,
              items: themeItems.map((i) {
                var text = Text(i["text"] as String);
                var value = i["v"] as ThemeMode;
                var selected = actTheme == value;
                return DropdownMenuItem<ThemeMode>(
                    value: value,
                    child:
                        _DropDownMenuItemChild(selected: selected, text: text));
              }).toList(),
            ),
            DropdownButton<Locale>(
              // Read selected from the controller
              value: actLocale,
              // Call the update method any time the user selects.
              onChanged: controller.updateLocale,
              items: localeItems.map((i) {
                var text = Text(i["text"] as String);
                var value = i["v"] as Locale?;
                var selected = actLocale == value;
                return DropdownMenuItem<Locale>(
                    value: value,
                    child:
                        _DropDownMenuItemChild(selected: selected, text: text));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropDownMenuItemChild extends StatelessWidget {
  const _DropDownMenuItemChild({
    required this.selected,
    required this.text,
  });

  final bool selected;
  final Text text;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    BoxDecoration? boxDeco;
    if (selected) {
      boxDeco = BoxDecoration(
          border: Border(
              left:
                  BorderSide(width: 2, color: themeData.colorScheme.primary)));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
          decoration: boxDeco,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: text,
          )),
    );
  }
}
