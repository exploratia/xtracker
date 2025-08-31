import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/device_storage/device_storage.dart';
import '../../../util/dialogs.dart';
import '../../../util/table_utils.dart';
import '../../controls/future/future_builder_with_progress_indicator.dart';
import 'settings_controller.dart';

class DeviceStorageView extends StatelessWidget {
  const DeviceStorageView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
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
                  if (storageData == null) {
                    return Container();
                  }
                  List<TableRow> rows = [
                    TableUtils.tableHeadline([
                      LocaleKeys.settings_deviceStorage_table_column_key.tr(),
                      LocaleKeys.settings_deviceStorage_table_column_value.tr(),
                    ])
                  ];

                  final keys = storageData.keys.toList();
                  keys.sort();
                  for (var key in keys) {
                    var value = storageData[key];
                    rows.add(TableUtils.tableRow([key, value ?? '-']));
                  }

                  return LayoutBuilder(builder: (BuildContext _, BoxConstraints constraints) {
                    return Table(
                      // https://api.flutter.dev/flutter/widgets/Table-class.html
                      columnWidths: <int, TableColumnWidth>{
                        0: constraints.maxWidth < 200 ? FixedColumnWidth(constraints.maxWidth / 2) : const IntrinsicColumnWidth(),
                        1: const FlexColumnWidth(),
                      },
                      border: const TableBorder.symmetric(
                        inside: BorderSide(width: 1, color: Colors.black12),
                      ),
                      children: rows,
                    );
                  });
                },
              );
            }),
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
