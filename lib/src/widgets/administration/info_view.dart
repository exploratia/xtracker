import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../generated/assets.gen.dart';
import '../../util/app_info.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              CaLogo(),
              ExploratiaLogo(),
              EagleLogo(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 96,
            width: 96,
            child: Center(
              child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
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
        CaLogo(radius: 16, backgroundColor: Colors.white),
        OverflowText('${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler'),
      ],
      [
        ExploratiaLogo(radius: 16, backgroundColor: Colors.white),
        const OverflowText(maxLines: 100, 'https://www.exploratia.de'),
      ],
      [
        EagleLogo(radius: 16, backgroundColor: Colors.white),
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
