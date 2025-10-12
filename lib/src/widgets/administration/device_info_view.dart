import 'package:flutter/material.dart';

import '../../util/table_utils.dart';
import '../../util/theme_utils.dart';
import '../controls/card/settings_card.dart';
import '../controls/layout/scroll_footer.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../controls/navigation/hide_bottom_navigation_bar.dart';

class DeviceInfoView extends StatelessWidget {
  final Map<String, dynamic> deviceData;
  final Map<String, dynamic> screenData;

  const DeviceInfoView({super.key, required this.deviceData, required this.screenData});

  @override
  Widget build(BuildContext context) {
    // device
    List<TableRow> rows = TableUtils.buildKeyValueTableRows(context);

    final keys = deviceData.keys.toList();
    keys.sort();
    for (var key in keys) {
      var value = deviceData[key];
      rows.add(TableUtils.tableRow([key, value ?? '-']));
    }

    // screen
    var tableDevice = _KeyValueTable(rows: rows);

    rows = TableUtils.buildKeyValueTableRows(context);

    for (var entry in screenData.entries) {
      rows.add(TableUtils.tableRow([entry.key, entry.value ?? '-']));
    }

    var tableScreen = _KeyValueTable(rows: rows);

    return SingleChildScrollViewWithScrollbar(
      useScreenPadding: true,
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: Column(
        spacing: ThemeUtils.screenPadding,
        children: [
          SettingsCard.singleEntry(
            showDivider: false,
            content: tableDevice,
          ),
          SettingsCard.singleEntry(
            showDivider: false,
            content: tableScreen,
          ),
          const ScrollFooter(),
        ],
      ),
    );
  }
}

class _KeyValueTable extends StatelessWidget {
  const _KeyValueTable({
    required this.rows,
  });

  final List<TableRow> rows;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(builder: (BuildContext _, BoxConstraints constraints) {
      return Table(
        // https://api.flutter.dev/flutter/widgets/Table-class.html
        columnWidths: <int, TableColumnWidth>{
          0: constraints.maxWidth < 200 ? FixedColumnWidth(constraints.maxWidth / 2) : const IntrinsicColumnWidth(),
          1: const FlexColumnWidth(),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(width: 1, color: themeData.canvasColor),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      );
    });
  }
}
