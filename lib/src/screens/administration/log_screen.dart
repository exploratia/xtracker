import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/dialogs.dart';
import '../../util/ex.dart';
import '../../util/file_extension.dart';
import '../../util/logging/daily_files.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../widgets/administration/logging/log_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/popupmenu/icon_popup_menu.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class LogScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.short_text_outlined),
    routeName: '/log_screen',
    titleBuilder: () => LocaleKeys.log_title.tr(),
  );

  const LogScreen({super.key, this.logFileName, this.rebuildLogsView});

  final String? logFileName;
  final VoidCallback? rebuildLogsView;

  @override
  Widget build(BuildContext context) {
    String logFileN = (logFileName ?? '');

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text("${navItem.titleBuilder()} ${logFileN.replaceAll('.txt', '')}"),
        actions: [
          Tooltip(
            message: LocaleKeys.log_action_exportOrShareLog_tooltip.tr(),
            child: IconPopupMenu(
              icon: const Icon(Icons.download_outlined),
              menuEntries: [
                _buildExportIconPopupMenuEntry(logFileN, context),
                _buildShareIconPopupMenuEntry(logFileN, context),
              ],
            ),
          ),
          IconButton(
            tooltip: LocaleKeys.log_action_deleteLog_tooltip.tr(),
            onPressed: () async {
              bool? res = await Dialogs.simpleYesNoDialog(
                LocaleKeys.log_query_deleteLog.tr(),
                context,
                title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
              );
              if (res == true) {
                try {
                  await DailyFiles.deleteLog(logFileN);
                  // 1s warten, damit im Fall von heutigem Log das heutige File dann schon wieder erstellt wurde.
                  await Future.delayed(const Duration(seconds: 1), () {});
                  SimpleLogging.i('Successfully deleted log.');
                } catch (err) {
                  SimpleLogging.w('Failed to delete log.', error: err);
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog('${LocaleKeys.log_alert_deleteLogFailed.tr()}\n\n$err', context);
                  }
                }
                final rebuildLogs = rebuildLogsView;
                if (rebuildLogs != null) rebuildLogs();
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      bodyBuilder: (context) => LogView(logFileN),
    );
  }

  IconPopupMenuEntry _buildExportIconPopupMenuEntry(String logFileN, BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.download_outlined),
      () async {
        try {
          final logFile = File(DailyFiles.getFullLogPath(logFileN));
          if (!await logFile.exists()) {
            throw Ex("File does not exist!");
          }
          final fileBytes = await logFile.readAsBytes();

          var selectedFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Please select an output file:', fileName: logFile.name, type: FileType.custom, allowedExtensions: ["txt"], bytes: fileBytes);
          bool exported = selectedFile != null || kIsWeb; // in web no file select - just download

          if (exported) {
            SimpleLogging.i('Successfully exported log.');
            if (context.mounted) {
              Dialogs.showSnackBar(LocaleKeys.log_snackbar_exportSuccess.tr(), context);
            }
          }
        } catch (err) {
          SimpleLogging.w('Failed to export log.', error: err);
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('${LocaleKeys.commons_alert_failedToSaveData.tr()}\n\n$err', context);
          }
        }
      },
      LocaleKeys.log_action_exportLog_tooltip.tr(),
    );
  }

  IconPopupMenuEntry _buildShareIconPopupMenuEntry(String logFileN, BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.share_outlined),
      () async {
        try {
          final result = await SharePlus.instance.share(
              ShareParams(files: [XFile(DailyFiles.getFullLogPath(logFileN))], text: '${/*AppInfo.appName*/ LocaleKeys.appTitle.tr()} Log $logFileName'));
          if (result.status == ShareResultStatus.success) {
            SimpleLogging.i("Successfully shared log '$logFileName'.");
            if (context.mounted) {
              Dialogs.showSnackBar(LocaleKeys.log_snackbar_shareSuccess.tr(), context);
            }
          }
        } catch (err) {
          SimpleLogging.w('Failed to share log.', error: err);
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('${LocaleKeys.commons_alert_failedToShareData.tr()}\n\n$err', context);
          }
        }
      },
      LocaleKeys.log_action_shareLog_tooltip.tr(),
    );
  }
}
