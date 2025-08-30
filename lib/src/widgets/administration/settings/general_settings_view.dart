import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/navigation/hide_navigation_labels.dart';
import '../../../util/table_utils.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';
import './settings_controller.dart';
import 'settings_service.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    var actTheme = controller.themeMode;
    var themeItems = [
      {'v': ThemeMode.system, 'text': LocaleKeys.settings_general_theme_system.tr()},
      {'v': ThemeMode.light, 'text': LocaleKeys.settings_general_theme_light.tr()},
      {'v': ThemeMode.dark, 'text': LocaleKeys.settings_general_theme_dark.tr()},
    ];

    var actLocale = controller.locale;
    var localeItems = [
      {'v': null, 'text': LocaleKeys.settings_general_language_system.tr()},
      {'v': SettingsService.supportedLocales[1], 'text': LocaleKeys.settings_general_language_german.tr()},
      {'v': SettingsService.supportedLocales[0], 'text': LocaleKeys.settings_general_language_english.tr()},
    ];
    if (actLocale != null) {
      // check
      var idx = localeItems.indexWhere((element) => element['v'] == actLocale);
      if (idx < 0) actLocale = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
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
              Text(LocaleKeys.settings_general_label_theme.tr()),
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
                      key: Key('settingsThemeSelect_$i'), value: value, child: DropDownMenuItemChild(selected: selected, child: text));
                }).toList(),
              )
            ]),
            TableUtils.tableRow([
              Text(LocaleKeys.settings_general_label_lang.tr()),
              DropdownButton<Locale?>(
                key: const Key('settingsLocaleSelect'),
                borderRadius: ThemeUtils.cardBorderRadius,
                // Read selected from the controller
                value: actLocale,
                // Call the update method any time the user selects.
                onChanged: (value) => controller.updateLocale(value, context),
                items: localeItems.map((i) {
                  var text = Text(i["text"] as String);
                  var value = i["v"] as Locale?;
                  var selected = actLocale == value;
                  return DropdownMenuItem<Locale?>(
                      key: Key('settingsLocaleSelect_$i'), value: value, child: DropDownMenuItemChild(selected: selected, child: text));
                }).toList(),
              ),
            ]),
          ],
        ),
        const Divider(),
        ValueListenableBuilder(
          valueListenable: HideNavigationLabels.visible,
          builder: (BuildContext ctx1, navLabelsVisible, _) => SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: ThemeUtils.defaultPadding),
            value: controller.hideNavigationLabels,
            onChanged: (bool value) {
              controller.updateHideNavigationLabels(value);
            },
            title: Text(LocaleKeys.settings_general_label_hideNavigationLabels.tr()),
          ),
        ),
      ],
    );
  }
}
