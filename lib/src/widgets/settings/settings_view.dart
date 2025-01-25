import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    var actTheme = controller.themeMode;
    var themeItems = [
      {'v': ThemeMode.system, 'text': t!.settingsThemeNameSystem},
      {'v': ThemeMode.light, 'text': t.settingsThemeNameLight},
      {'v': ThemeMode.dark, 'text': t.settingsThemeNameDark},
    ];

    var actLocale = controller.locale;
    var localeItems = [
      {'v': null, 'text': t.settingsLangNameSystem},
      {'v': Locale("de"), 'text': t.settingsLangNameGerman},
      {'v': Locale("en"), 'text': t.settingsLangNameEnglish},
    ];
    return Column(
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          // https://api.flutter.dev/flutter/widgets/Table-class.html
          columnWidths: const <int, TableColumnWidth>{
            // 0: FixedColumnWidth(128),
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            // 1: FlexColumnWidth(),
          },
          // border: TableBorder.symmetric(
          //   inside: const BorderSide(width: 1, color: Colors.black12),
          // ),
          children: [
            TableRow(children: [
              _TableCellPadding(Text(t.settingsThemeLabel)),
              _TableCellPadding(DropdownButton<ThemeMode>(
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
                      child: _DropDownMenuItemChild(
                          selected: selected, text: text));
                }).toList(),
              ))
            ]),
            TableRow(children: [
              _TableCellPadding(Text(t.settingsLangLabel)),
              _TableCellPadding(
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
                        child: _DropDownMenuItemChild(
                            selected: selected, text: text));
                  }).toList(),
                ),
              )
            ]),
          ],
        ),
      ],
    );
  }
}

class _TableCellPadding extends StatelessWidget {
  final Widget child;

  const _TableCellPadding(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: child,
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
