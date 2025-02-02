import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../util/table_utils.dart';
import '../../../util/theme_utils.dart';
import '../../layout/drop_down_menu_item_child.dart';
import './settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    var actTheme = controller.themeMode;
    var themeItems = [
      {'v': ThemeMode.system, 'text': t!.settingsGeneralThemeNameSystem},
      {'v': ThemeMode.light, 'text': t.settingsGeneralThemeNameLight},
      {'v': ThemeMode.dark, 'text': t.settingsGeneralThemeNameDark},
    ];

    var actLocale = controller.locale;
    var localeItems = [
      {'v': null, 'text': t.settingsGeneralLangNameSystem},
      {'v': Locale("de"), 'text': t.settingsGeneralLangNameGerman},
      {'v': Locale("en"), 'text': t.settingsGeneralLangNameEnglish},
    ];
    if (actLocale != null) {
      // check
      var idx = localeItems.indexWhere((element) => element['v'] == actLocale);
      if (idx < 0) actLocale = null;
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      // https://api.flutter.dev/flutter/widgets/Table-class.html
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(96),
        // 0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        // 1: FlexColumnWidth(),
      },
      // border: TableBorder.symmetric(
      //   inside: const BorderSide(width: 1, color: Colors.black12),
      // ),
      children: [
        TableUtils.tableRow([
          Text(t.settingsGeneralThemeLabel),
          DropdownButton<ThemeMode>(
            key: const Key('settingsThemeSelect'),
            borderRadius: ThemeUtils.cardBorderRadius,
            // Read the selected themeMode from the controller
            value: actTheme,
            // Call the updateThemeMode method any time the user selects a theme.
            onChanged: controller.updateThemeMode,
            items: themeItems.map((i) {
              var text = Text(i["text"] as String);
              var value = i["v"] as ThemeMode;
              var selected = actTheme == value;
              return DropdownMenuItem<ThemeMode>(
                  key: Key('settingsThemeSelect_$i'),
                  value: value,
                  child:
                      DropDownMenuItemChild(selected: selected, child: text));
            }).toList(),
          )
        ]),
        TableUtils.tableRow([
          Text(t.settingsGeneralLangLabel),
          DropdownButton<Locale?>(
            key: const Key('settingsLocaleSelect'),
            borderRadius: ThemeUtils.cardBorderRadius,
            // Read selected from the controller
            value: actLocale,
            // Call the update method any time the user selects.
            onChanged: controller.updateLocale,
            items: localeItems.map((i) {
              var text = Text(i["text"] as String);
              var value = i["v"] as Locale?;
              var selected = actLocale == value;
              return DropdownMenuItem<Locale?>(
                  key: Key('settingsLocaleSelect_$i'),
                  value: value,
                  child:
                      DropDownMenuItemChild(selected: selected, child: text));
            }).toList(),
          ),
        ]),
      ],
    );
  }
}
