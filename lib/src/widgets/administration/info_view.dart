import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/app_info.dart';
import '../../util/globals.dart';
import '../card/settings_card.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import '../logos/ca_logo.dart';
import '../logos/eagle_logo.dart';
import '../logos/exploratia_logo.dart';
import '../navigation/hide_bottom_navigation_bar.dart';
import '../text/overflow_text.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
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
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    var rows = [
      [
        const CaLogo(radius: 16),
        OverflowText(
            '${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler')
      ],
      [
        const ExploratiaLogo(radius: 16),
        const OverflowText(maxLines: 100, 'https://www.exploratia.de')
      ],
      [
        const EagleLogo(radius: 16),
        const OverflowText('https://www.adlers-online.de'),
      ],
    ];
    return SettingsCard(title: AppInfo.appName, spacing: 10, children: [
      ...rows.map((r) => Row(
            spacing: 10,
            children: [...r],
          )),
    ]);
  }
}
