import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/series/series_import_export.dart';
import '../../util/theme_utils.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';

/// Check if a backup reminder should be displayed.
class SeriesExportCheck extends StatefulWidget {
  final Widget child;
  final SettingsController settingsController;

  const SeriesExportCheck({super.key, required this.child, required this.settingsController});

  @override
  State<SeriesExportCheck> createState() => _SeriesExportCheckState();
}

class _SeriesExportCheckState extends State<SeriesExportCheck> {
  @override
  void initState() {
    super.initState();

    var settingsController = widget.settingsController;
    // reminder disabled?
    if (settingsController.seriesExportDisableReminder) return;

    // if no reminder date available use initialAppStart +30 days
    DateTime reminderDate = settingsController.seriesExportReminderDate ?? settingsController.initialAppStart.add(const Duration(days: 30));

    if (DateTime.now().isAfter(reminderDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlert(context);
      });
    }
  }

  void _showAlert(BuildContext context) async {
    final settingsController = widget.settingsController;
    String lastExport = SeriesImportExport.buildLastExportDateStr(settingsController);

    Widget dialogContent = SingleChildScrollViewWithScrollbar(
      useScreenPadding: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: ThemeUtils.verticalSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocaleKeys.seriesManagement_backupAlert_label_lastExport.tr(args: [lastExport])),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
              SeriesImportExport.showImportExportDlg(context, settingsController: settingsController);
            },
            icon: const Icon(Icons.upload_outlined),
            label: Text(LocaleKeys.seriesManagement_backupAlert_btn_export.tr()),
          ),
          const Divider(),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await settingsController.updateSeriesExportReminderDate(3);
            },
            icon: const Icon(Icons.update_outlined),
            label: Text(LocaleKeys.seriesManagement_backupAlert_btn_reminderIn3Days.tr()),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await settingsController.updateSeriesExportDisableReminder(true);
            },
            icon: const Icon(Icons.update_disabled_outlined),
            label: Text(LocaleKeys.seriesManagement_backupAlert_btn_disableReminder.tr()),
          ),
        ],
      ),
    );

    var res = await showDialog<bool?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.seriesManagement_backupAlert_title.tr()),
        content: dialogContent,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(LocaleKeys.commons_dialog_btn_close.tr()))
        ],
      ),
    );

    // case of close remember again in 1 day
    if (res == null) {
      await settingsController.updateSeriesExportReminderDate(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
