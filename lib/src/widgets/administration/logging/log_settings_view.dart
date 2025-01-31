import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/table_utils.dart';
import '../../card/settings_card.dart';
import '../../layout/drop_down_menu_item_child.dart';
import '../../layout/single_child_scroll_view_with_scrollbar.dart';

class LogSettingsView extends StatelessWidget {
  const LogSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SingleChildScrollViewWithScrollbar(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCard(
            showDivider: false,
            children: [
              Row(
                children: [
                  Text(t!.logSettingsLogLevelLabel),
                  _LogLevelSelector(),
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
                    Text(t.logSettingsLogFullStackLabel),
                    _FullStackSwitch(),
                  ]),
                  TableUtils.tableRow([
                    Text(t.logSettingsWriteTestLogMessagesLabel),
                    MaterialButton(
                        height: 50,
                        onPressed: () {
                          SimpleLogging.d('Debug Message');
                          SimpleLogging.i('Info Message');
                          SimpleLogging.w('Warning Message');
                          SimpleLogging.e('Error Message');
                          // logger.wtf('WTF Message');
                        },
                        shape: const CircleBorder(),
                        child: Icon(
                          Icons.short_text_rounded,
                        )),
                  ]),
                ],
              ),
            ],
          ),
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
    final themeData = Theme.of(context);

    return DropdownButton<Level>(
        key: Key('logSettingsLogLevelSelect'),
        dropdownColor: themeData.cardColor,
        // borderRadius: BorderRadius.circular(4),
        value: SimpleLogging.logLevel,
        items: SimpleLogging.getKnownLevels()
            .map<DropdownMenuItem<Level>>((logLevel) {
          var selected = (logLevel == SimpleLogging.logLevel);
          return DropdownMenuItem(
              key: Key('logSettingsLogLevelSelect_${logLevel.name}'),
              value: logLevel,
              child: DropDownMenuItemChild(
                  selected: selected, text: Text(logLevel.name.toUpperCase())));
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
