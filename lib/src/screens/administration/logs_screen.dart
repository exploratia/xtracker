import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../util/dialogs.dart';
import '../../util/logging/daily_files.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/navigation/navigator_transition_builder.dart';
import '../../widgets/administration/logging/logs_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import 'log_screen.dart';
import 'log_settings_screen.dart';

class LogsScreen extends StatefulWidget {
  static const routeName = '/logs_screen';

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
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(t!.logsTitle),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.restorablePushNamed(
                  context, LogSettingsScreen.routeName);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: () async {
              try {
                final zipAllLogs = await DailyFiles.zipAllLogs();
                try {
                  await Share.shareXFiles([XFile(zipAllLogs)],
                      text: 'App Logs');
                } catch (err) {
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog(
                        '${t.commonsMsgErrorFailedToShareData}\n\n$err',
                        context);
                  }
                } finally {
                  try {
                    await File(zipAllLogs).delete();
                  } catch (err2) {
                    SimpleLogging.w(
                        'Failed to delete zipped logs "$zipAllLogs" after sharing!');
                  }
                }
              } catch (err) {
                if (context.mounted) {
                  Dialogs.simpleErrOkDialog(
                      '${t.logsDialogMsgErrorFailedToZipLogs}\n\n$err',
                      context);
                }
              }
            },
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(t.commonsDialogTitleAreYouSure),
                  content: Text(t.logsDialogMsgQueryDeleteAllLogs),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text(t.commonsDialogBtnNo),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop(false);
                        try {
                          await DailyFiles.deleteAllLogs();
                        } catch (err) {
                          if (ctx.mounted) {
                            Dialogs.simpleErrOkDialog(
                                '${t.logsDialogMsgErrorDeleteAllLogsFailed}\n\n$err',
                                ctx);
                          }
                        }
                        _rebuild();
                      },
                      child: Text(t.commonsDialogBtnYes),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: LogsView(
        key: UniqueKey(),
        logSelectHandler:
            (String logFileName, void Function() rebuildLogsView) {
          Navigator.of(context).push(
            NavigatorTransitionBuilder.buildSlideHTransition(LogScreen(
              logFileName: logFileName,
              rebuildLogsView: rebuildLogsView,
            )),
          );
        },
      ),
    );
  }
}
