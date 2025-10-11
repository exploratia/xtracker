import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/table_utils.dart';
import '../../../util/theme_utils.dart';
import '../../controls/card/settings_card.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';
import '../../controls/layout/scroll_footer.dart';
import '../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../controls/navigation/hide_bottom_navigation_bar.dart';

class LogSettingsView extends StatelessWidget {
  const LogSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      useScreenPadding: true,
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SettingsCard.singleEntry(
            showDivider: false,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(LocaleKeys.logSettings_label_logLevel.tr()),
                    const _LogLevelSelector(),
                  ],
                ),
                const Divider(),
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
                    TableUtils.tableRow([
                      Text(LocaleKeys.logSettings_label_logFullStack.tr()),
                      const _FullStackSwitch(),
                    ]),
                    TableUtils.tableRow([
                      Text(LocaleKeys.logSettings_label_writeTestLogMessages.tr()),
                      IconButton(
                          iconSize: ThemeUtils.iconSizeScaled,
                          tooltip: LocaleKeys.logSettings_btn_writeTestLogMessages_tooltip.tr(),
                          onPressed: () {
                            SimpleLogging.d('Debug Message');
                            SimpleLogging.i('Info Message');
                            SimpleLogging.w('Warning Message');
                            SimpleLogging.e('Error Message');
                            // logger.wtf('WTF Message');
                          },
                          icon: const Icon(
                            Icons.short_text_rounded,
                          )),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const ScrollFooter(),
        ],
      ),
    );
  }
}

class _LogLevelSelector extends StatefulWidget {
  const _LogLevelSelector();

  @override
  State<_LogLevelSelector> createState() => _LogLevelSelectorState();
}

class _LogLevelSelectorState extends State<_LogLevelSelector> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Level>(
        key: const Key('logSettingsLogLevelSelect'),
        borderRadius: ThemeUtils.cardBorderRadius,
        value: SimpleLogging.logLevel,
        items: SimpleLogging.getKnownLevels().map<DropdownMenuItem<Level>>((logLevel) {
          var selected = (logLevel == SimpleLogging.logLevel);
          return DropdownMenuItem(
            key: Key('logSettingsLogLevelSelect_${logLevel.name}'),
            value: logLevel,
            child: DropDownMenuItemChild(
              selected: selected,
              child: Text(logLevel.name.toUpperCase()),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            SimpleLogging.logLevel = value;
            setState(() {});
          }
        });
  }
}

class _FullStackSwitch extends StatefulWidget {
  const _FullStackSwitch();

  @override
  State<_FullStackSwitch> createState() => _FullStackSwitchState();
}

class _FullStackSwitchState extends State<_FullStackSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: SimpleLogging.useFullStack,
      onChanged: (value) {
        SimpleLogging.useFullStack = value;
        setState(() {});
      },
    );
  }
}
