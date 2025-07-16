import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/dialogs.dart';
import '../../util/logging/daily_files.dart';
import '../../widgets/administration/logging/log_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

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
        title: Text(navItem.titleBuilder() + logFileN.replaceAll('.txt', '')),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final result = await SharePlus.instance.share(
                    ShareParams(files: [XFile(DailyFiles.getFullLogPath(logFileN))], text: '${/*AppInfo.appName*/ LocaleKeys.appTitle.tr()} Log $logFileName'));
                if (result.status == ShareResultStatus.success && context.mounted) {
                  Dialogs.showSnackBar(LocaleKeys.log_msg_shareSuccess.tr(), context);
                }
              } catch (err) {
                if (context.mounted) {
                  Dialogs.simpleErrOkDialog('${LocaleKeys.commons_msg_error_failedToShareData.tr()}\n\n$err', context);
                }
              }
            },
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () async {
              bool? res = await Dialogs.simpleYesNoDialog(
                LocaleKeys.log_dialog_msg_query_deleteLog.tr(),
                context,
                title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
              );
              if (res == true) {
                try {
                  await DailyFiles.deleteLog(logFileN);
                  // 1s warten, damit im Fall von heutigem Log das heutige File dann schon wieder erstellt wurde.
                  await Future.delayed(const Duration(seconds: 1), () {});
                } catch (err) {
                  if (context.mounted) {
                    Dialogs.simpleErrOkDialog('${LocaleKeys.log_dialog_msg_error_deleteLogFailed.tr()}\n\n$err', context);
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
