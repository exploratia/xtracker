import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../util/app_info.dart';
import '../../util/dialogs.dart';
import '../../util/logging/daily_files.dart';
import '../../widgets/administration/logging/log_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';

class LogScreen extends StatelessWidget {
  static const routeName = '/log_screen';

  const LogScreen({super.key, this.logFileName, this.rebuildLogsView});

  final String? logFileName;
  final VoidCallback? rebuildLogsView;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    String logFileN = (logFileName ?? '');

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(t!.logTitle + logFileN.replaceAll('.txt', '')),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await Share.shareXFiles(
                    [XFile(DailyFiles.getFullLogPath(logFileN))],
                    text: '${AppInfo.appName} Log $logFileName');
              } catch (err) {
                if (context.mounted) {
                  Dialogs.simpleErrOkDialog(
                      '${t.commonsMsgErrorFailedToShareData}\n\n$err', context);
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
                  content: Text(t.logDialogMsgQueryDeleteLog),
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
                        Navigator.of(ctx).pop(false);
                        try {
                          await DailyFiles.deleteLog(logFileN);
                          // 1s warten, damit im Fall von heutigem Log das heutige File dann schon wieder erstellt wurde.
                          await Future.delayed(
                              const Duration(seconds: 1), () {});
                        } catch (err) {
                          if (ctx.mounted) {
                            Dialogs.simpleErrOkDialog(
                                '${t.logDialogMsgErrorDeleteLogFailed}\n\n$err',
                                ctx);
                          }
                        }
                        final rebuildLogs = rebuildLogsView;
                        if (rebuildLogs != null) rebuildLogs();
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
      body: LogView(logFileN),
    );
  }
}
