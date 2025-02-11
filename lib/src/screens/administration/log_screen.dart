import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/navigation/navigation_item.dart';
import '../../util/app_info.dart';
import '../../util/dialogs.dart';
import '../../util/logging/daily_files.dart';
import '../../widgets/administration/logging/log_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class LogScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.short_text_outlined),
    routeName: '/log_screen',
    titleBuilder: (t) => t.logTitle,
  );

  const LogScreen({super.key, this.logFileName, this.rebuildLogsView});

  final String? logFileName;
  final VoidCallback? rebuildLogsView;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    String logFileN = (logFileName ?? '');

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(navItem.titleBuilder(t) + logFileN.replaceAll('.txt', '')),
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
              bool? res = await Dialogs.simpleYesNoDialog(
                  t.logDialogMsgQueryDeleteLog, context,
                  title: t.commonsDialogTitleAreYouSure);
              if (res == true) {
                try {
                  await DailyFiles.deleteLog(logFileN);
                  // 1s warten, damit im Fall von heutigem Log das heutige File dann schon wieder erstellt wurde.
                  await Future.delayed(const Duration(seconds: 1), () {});
                } catch (err) {
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog(
                        '${t.logDialogMsgErrorDeleteLogFailed}\n\n$err',
                        context);
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
}
