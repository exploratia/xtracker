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
import '../../util/navigation/generic_route.dart';
import '../../util/theme_utils.dart';
import '../../widgets/administration/logging/logs_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/popupmenu/icon_popup_menu.dart';
import '../../widgets/controls/responsive/screen_builder.dart';
import 'log_screen.dart';
import 'log_settings_screen.dart';

class LogsScreen extends StatefulWidget {
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.text_snippet_outlined,
    routeName: '/logs_screen',
    titleBuilder: () => LocaleKeys.logs_title.tr(),
  );

  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: LogsScreen.navItem,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(LogsScreen.navItem.titleBuilder()),
        actions: [
          IconButton(
            tooltip: LocaleKeys.logs_action_logSettings_tooltip.tr(),
            onPressed: () async {
              Navigator.restorablePushNamed(context, LogSettingsScreen.navItem.routeName);
            },
            icon: LogSettingsScreen.navItem.icon(size: ThemeUtils.iconSize /* in app bar not scaled! */),
          ),
          Tooltip(
            message: LocaleKeys.logs_action_exportOrShareLogs_tooltip.tr(),
            child: IconPopupMenu(
              icon: const Icon(Icons.download_outlined),
              menuEntries: [
                _buildExportIconPopupMenuEntry(context),
                _buildShareIconPopupMenuEntry(context),
              ],
            ),
          ),
          IconButton(
            tooltip: LocaleKeys.logs_action_deleteLogs_tooltip.tr(),
            onPressed: () async {
              bool? res = await Dialogs.simpleYesNoDialog(
                LocaleKeys.logs_query_deleteAllLogs.tr(),
                context,
                title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
              );
              if (res == true) {
                try {
                  await DailyFiles.deleteAllLogs();
                } catch (err) {
                  SimpleLogging.w('Failed to delete all logs.', error: err);
                  if (context.mounted) {
                    Dialogs.showSnackBarWarning(LocaleKeys.logs_alert_deleteAllLogsFailed.tr(), context);
                  }
                }
                _rebuild();
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      bodyBuilder: (context) => LogsView(
        key: UniqueKey(),
        logSelectHandler: (String logFileName, void Function() rebuildLogsView) {
          Navigator.of(context).push(GenericRoute.route(LogScreen(
            logFileName: logFileName,
            rebuildLogsView: rebuildLogsView,
          )));
        },
      ),
    );
  }

  IconPopupMenuEntry _buildExportIconPopupMenuEntry(BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.download_outlined),
      () async {
        try {
          final zipAllLogs = await DailyFiles.zipAllLogs();
          if (!await zipAllLogs.exists()) {
            throw Ex("File does not exist!");
          }
          try {
            final fileBytes = await zipAllLogs.readAsBytes();

            var selectedFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Please select an output file:', fileName: zipAllLogs.name, type: FileType.custom, allowedExtensions: ["zip"], bytes: fileBytes);
            bool exported = selectedFile != null || kIsWeb; // in web no file select - just download

            if (exported) {
              SimpleLogging.i('Successfully exported logs.');
              if (context.mounted) {
                Dialogs.showSnackBar(LocaleKeys.commons_snackbar_exportSuccess.tr(), context);
              }
            }
          } catch (err) {
            if (context.mounted) {
              SimpleLogging.w('Failed to export logs.', error: err);
              Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_exportFailed.tr(), context);
            }
          } finally {
            try {
              await File(zipAllLogs.path).delete();
            } catch (err2) {
              SimpleLogging.w('Failed to delete zipped logs "${zipAllLogs.path}" after exporting!', error: err2);
            }
          }
        } catch (err) {
          SimpleLogging.w('Failed to zip logs.', error: err);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.logs_alert_failedToZipLogs.tr(), context);
          }
        }
      },
      LocaleKeys.logs_action_exportLogs_tooltip.tr(),
    );
  }

  IconPopupMenuEntry _buildShareIconPopupMenuEntry(BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.share_outlined),
      () async {
        try {
          final zipAllLogs = await DailyFiles.zipAllLogs();
          try {
            final result = await SharePlus.instance.share(ShareParams(files: [XFile(zipAllLogs.path)], text: 'App Logs'));
            if (result.status == ShareResultStatus.success) {
              SimpleLogging.i('Successfully shared logs.');
              if (context.mounted) {
                Dialogs.showSnackBar(LocaleKeys.commons_snackbar_shareSuccess.tr(), context);
              }
            }
          } catch (err) {
            if (context.mounted) {
              SimpleLogging.w('Failed to share logs.', error: err);
              Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_shareFailed.tr(), context);
            }
          } finally {
            try {
              await File(zipAllLogs.path).delete();
            } catch (err2) {
              SimpleLogging.w('Failed to delete zipped logs "${zipAllLogs.path}" after sharing!', error: err2);
            }
          }
        } catch (err) {
          SimpleLogging.w('Failed to zip logs.', error: err);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.logs_alert_failedToZipLogs.tr(), context);
          }
        }
      },
      LocaleKeys.logs_action_shareLogs_tooltip.tr(),
    );
  }
}
