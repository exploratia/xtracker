import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/dialogs.dart';
import '../../util/logging/daily_files.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/navigation/generic_route.dart';
import '../../widgets/administration/logging/logs_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';
import 'log_screen.dart';
import 'log_settings_screen.dart';

class LogsScreen extends StatefulWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.text_snippet_outlined),
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
            onPressed: () async {
              Navigator.restorablePushNamed(context, LogSettingsScreen.navItem.routeName);
            },
            icon: LogSettingsScreen.navItem.icon,
          ),
          IconButton(
            onPressed: () async {
              try {
                final zipAllLogs = await DailyFiles.zipAllLogs();
                try {
                  final result = await SharePlus.instance.share(ShareParams(files: [XFile(zipAllLogs)], text: 'App Logs'));
                  if (result.status == ShareResultStatus.success && context.mounted) {
                    Dialogs.showSnackBar("TODO share success", context);
                  }
                } catch (err) {
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog('${LocaleKeys.commons_msg_error_failedToShareData.tr()}\n\n$err', context);
                  }
                } finally {
                  try {
                    await File(zipAllLogs).delete();
                  } catch (err2) {
                    SimpleLogging.w('Failed to delete zipped logs "$zipAllLogs" after sharing!');
                  }
                }
              } catch (err) {
                if (context.mounted) {
                  Dialogs.simpleErrOkDialog('${LocaleKeys.logs_dialog_msg_error_failedToZipLogs.tr()}\n\n$err', context);
                }
              }
            },
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () async {
              bool? res = await Dialogs.simpleYesNoDialog(
                LocaleKeys.logs_dialog_msg_query_deleteAllLogs.tr(),
                context,
                title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
              );
              if (res == true) {
                try {
                  await DailyFiles.deleteAllLogs();
                } catch (err) {
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog('${LocaleKeys.logs_dialog_msg_error_deleteAllLogsFailed.tr()}\n\n$err', context);
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
}
