import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/administration/logs_screen.dart';
import '../../util/about_dlg.dart';
import '../../util/app_info.dart';
import '../../util/globals.dart';
import '../../util/logging/daily_files.dart';
import '../../util/navigation/navigator_transition_builder.dart';
import '../card/settings_card.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import '../logos/ca_logo.dart';
import '../logos/eagle_logo.dart';
import '../logos/exploratia_logo.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    VoidCallback? showLogsHandler;
    if (DailyFiles.logsDirAvailable()) {
      showLogsHandler = () => Navigator.of(context).push(
          NavigatorTransitionBuilder.buildSlideHTransition(const LogsScreen()));
    }

    return SingleChildScrollViewWithScrollbar(
      // scrollPositionHandler: HideBottomNavigationBar.setScrollPosition, // TODO
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              EagleLogo(),
              CaLogo(),
              ExploratiaLogo(),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 96,
            width: 96,
            child: Center(
              child: Image.asset(
                Globals.assetImgBackground,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _AppInfoCard(),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => AboutDlg.showAboutDlg(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('App info'),
            ),
          ),
          Center(
            child: OutlinedButton.icon(
              onPressed: showLogsHandler,
              icon: Icon(Icons.text_snippet_outlined),
              // TODO Icon(LogsScreen.screenNavInfo.iconData),
              label: Text(
                  "Logs"), // TODO Text(LogsScreen.screenNavInfo.titleBuilder(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return SettingsCard(title: AppInfo.appName, spacing: 10, children: [
      Row(
        spacing: 10,
        children: [
          CaLogo(radius: 16),
          Text(
              '${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler'),
        ],
      ),
      Row(
        spacing: 10,
        children: [
          ExploratiaLogo(radius: 16),
          const Text(' https://www.exploratia.de'),
        ],
      ),
      Row(
        spacing: 10,
        children: [
          EagleLogo(radius: 16),
          const Text(' https://www.adlers-online.de'),
        ],
      ),
    ]);
  }
}
