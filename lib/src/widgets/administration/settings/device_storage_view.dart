import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/device_storage/device_storage.dart';
import '../../../util/device_storage/device_storage_keys.dart';
import '../../../util/dialogs.dart';
import '../../../util/table_utils.dart';
import '../../controls/future/future_builder_with_progress_indicator.dart';
import 'settings_controller.dart';

class DeviceStorageView extends StatelessWidget {
  const DeviceStorageView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? child) {
            return FutureBuilderWithProgressIndicator(
              future: DeviceStorage.readAll(),
              errorBuilder: (error) => 'Failed to storage data!',
              widgetBuilder: (storageData, BuildContext ctx) {
                List<TableRow> rows = TableUtils.buildKeyValueTableRows(context);

                final keys = storageData.keys.toList();
                keys.sort();
                for (var key in keys) {
                  var value = storageData[key];
                  rows.add(TableUtils.tableRow([key, _formatStorageValueForView(key, value)]));
                }

                return LayoutBuilder(
                  builder: (BuildContext _, BoxConstraints constraints) {
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
                  },
                );
              },
            );
          },
        ),
        const Divider(),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            _ClearDeviceStorage(controller),
          ],
        ),
      ],
    );
  }

  String _formatStorageValueForView(String key, String? value) {
    if (value == null) {
      return '-';
    }
    if (key == DeviceStorageKeys.seriesQuickActions) {
      return _seriesQuickActionsCount(value).toString();
    }
    return value;
  }

  int _seriesQuickActionsCount(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    try {
      var parsed = jsonDecode(trimmed);
      if (parsed is Map<String, dynamic>) {
        var series = parsed['series'];
        if (series is List) {
          return series.where((entry) => entry is Map && entry['id'] is String && (entry['id'] as String).trim().isNotEmpty).length;
        }
      }
    } catch (_) {
      // Fallback below for non-JSON values.
    }

    return trimmed.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).length;
  }
}

class _ClearDeviceStorage extends StatelessWidget {
  const _ClearDeviceStorage(this.controller);

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        bool? res = await Dialogs.simpleYesNoDialog(
          LocaleKeys.settings_deviceStorage_query_removeAllData.tr(),
          context,
          title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
        );
        if (res == true) {
          await DeviceStorage.deleteAll();
          await controller.loadSettings();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      icon: const Icon(Icons.clear_outlined),
      label: Text(LocaleKeys.settings_deviceStorage_btn_clearStorage.tr()),
    );
  }
}
