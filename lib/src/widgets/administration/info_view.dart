import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../card/settings_card.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import '../logos/ca_logo.dart';
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
        spacing: 16,
        children: [
          SizedBox(
            height: 96,
            width: 96,
            child: Center(
              child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
            ),
          ),
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
        const OverflowText(maxLines: 100, 'TODO'),
      ],
    ];
    return SettingsCard(
      showDivider: true,
      title: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Center(
              child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
            ),
          ),
          Text(/*AppInfo.appName*/ LocaleKeys.appTitle.tr(), style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      spacing: 10,
      children: [
        ...rows.map((r) => Row(
              spacing: 10,
              children: [...r],
            )),
      ],
    );
  }
}
