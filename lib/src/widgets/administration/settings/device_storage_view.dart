import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../util/device_storage/device_storage.dart';
import '../../../util/dialogs.dart';
import '../../../util/table_utils.dart';
import 'settings_controller.dart';

class DeviceStorageView extends StatelessWidget {
  const DeviceStorageView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
          builder: (context, deviceStorageSnapshot) {
            if (deviceStorageSnapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            final storageData = deviceStorageSnapshot.data;
            if (storageData == null) {
              return Text(t.settingsDeviceStorageNoData);
            }

            List<TableRow> rows = [
              TableUtils.tableHeadline([t.settingsDeviceStorageTableHeadKey, t.settingsDeviceStorageTableHeadValue])
            ];

            final keys = storageData.keys.toList();
            keys.sort();
            for (var key in keys) {
              var value = storageData[key];
              rows.add(TableUtils.tableRow([key, value ?? '-']));
            }

            return Table(
              // https://api.flutter.dev/flutter/widgets/Table-class.html
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(128), // IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: const TableBorder.symmetric(
                inside: BorderSide(width: 1, color: Colors.black12),
              ),
              children: rows,
            );
          },
          future: DeviceStorage.readAll(),
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
}

class _ClearDeviceStorage extends StatelessWidget {
  const _ClearDeviceStorage(this.controller);

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return OutlinedButton.icon(
      onPressed: () async {
        bool? res = await Dialogs.simpleYesNoDialog(t.settingsDeviceStorageDialogMsgQueryRemoveAllData, context, title: t.commonsDialogTitleAreYouSure);
        if (res == true) {
          await DeviceStorage.deleteAll();
          await controller.loadSettings();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      icon: const Icon(Icons.clear_outlined),
      label: Text(t!.settingsDeviceStorageBtnClearStorage),
    );
  }
}
