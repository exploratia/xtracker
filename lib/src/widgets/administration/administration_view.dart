import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../screens/administration/info_screen.dart';
import '../../screens/administration/logs_screen.dart';
import '../../screens/administration/settings_screen.dart';
import '../../util/about_dlg.dart';
import '../../util/globals.dart';
import '../../util/info_type.dart';
import '../../util/launch_uri.dart';
import '../../util/theme_utils.dart';
import '../controls/card/settings_card.dart';
import '../controls/layout/scroll_footer.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../controls/lnk/btn_lnk.dart';
import '../controls/lnk/img_lnk.dart';
import '../controls/logos/ca_logo.dart';
import '../controls/logos/exploratia_logo.dart';
import '../controls/navigation/hide_bottom_navigation_bar.dart';

class AdministrationView extends StatelessWidget {
  const AdministrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final links = [SettingsScreen.navItem, LogsScreen.navItem].map((navItem) => {
          'ico': navItem.icon,
          'title': navItem.titleBuilder(),
          'routeName': navItem.routeName,
        });

    return SingleChildScrollViewWithScrollbar(
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: Column(
        spacing: ThemeUtils.cardPadding,
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsCard(
            spacing: ThemeUtils.verticalSpacing,
            showDivider: false,
            children: [
              ...links.map((lnk) => ListTile(
                    leading: lnk['ico'] as Widget,
                    title: Text(lnk['title'] as String),
                    trailing: Icon(
                      Icons.navigate_next,
                      color: themeData.colorScheme.primary,
                    ),
                    onTap: () => Navigator.restorablePushNamed(context, lnk['routeName'] as String),
                  )),
            ],
          ),
          const _SupportTheApp(),
          const _AppInfoCard(),
          const ScrollFooter(),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var maxWidth = constraints.maxWidth;

        List<List<Widget>> rows = [
          [
            CaLogo(radius: 16, backgroundColor: themeData.scaffoldBackgroundColor),
            Text('${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler'),
          ],
        ];

        var exploratiaLaunchUrl = BtnLnk(uri: Globals.urlExploratia);
        var exploratiaLogoWide = Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(ThemeUtils.borderRadius)),
          clipBehavior: Clip.antiAlias,
          child: ImgLnk(uri: Globals.urlExploratia, imageProvider: Assets.images.logos.exploratiaLogoWide.provider(), height: 32, width: 138, darkHover: false),
        );
        if (maxWidth > 450) {
          rows.add([
            ExploratiaLogo(radius: 16, backgroundColor: themeData.scaffoldBackgroundColor),
            exploratiaLaunchUrl,
            exploratiaLogoWide,
          ]);
        } else if (maxWidth <= 400) {
          rows.add([
            ExploratiaLogo(radius: 16, backgroundColor: themeData.scaffoldBackgroundColor),
            exploratiaLaunchUrl,
          ]);
        } else {
          rows.add([
            exploratiaLogoWide,
            exploratiaLaunchUrl,
          ]);
        }

        return SettingsCard(
            title: Wrap(
              spacing: ThemeUtils.horizontalSpacing,
              runSpacing: ThemeUtils.verticalSpacingSmall,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(/*AppInfo.appName*/ LocaleKeys.appTitle.tr(), style: Theme.of(context).textTheme.titleLarge),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
                ),
              ],
            ),
            spacing: ThemeUtils.verticalSpacing,
            children: [
              // legals buttons
              Wrap(
                spacing: ThemeUtils.horizontalSpacing,
                runSpacing: ThemeUtils.verticalSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => AboutDlg.showAboutDlg(context),
                    icon: const Icon(Icons.info_outline),
                    label: Text(LocaleKeys.administration_infoAndLegals_btn_version.tr()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.restorablePushNamed(context, InfoScreen.navItem.routeName, arguments: {'infoType': InfoType.legalNotice.typeName}),
                    icon: InfoScreen.navItem.icon,
                    label: Text(InfoType.legalNotice.title()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.restorablePushNamed(context, InfoScreen.navItem.routeName, arguments: {'infoType': InfoType.privacyPolicy.typeName}),
                    icon: InfoScreen.navItem.icon,
                    label: Text(InfoType.privacyPolicy.title()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.restorablePushNamed(context, InfoScreen.navItem.routeName, arguments: {'infoType': InfoType.disclaimer.typeName}),
                    icon: InfoScreen.navItem.icon,
                    label: Text(InfoType.disclaimer.title()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.restorablePushNamed(context, InfoScreen.navItem.routeName, arguments: {'infoType': InfoType.eula.typeName}),
                    icon: InfoScreen.navItem.icon,
                    label: Text(InfoType.eula.title()),
                  ),
                ],
              ),
              const Divider(height: ThemeUtils.verticalSpacingLarge),
              ...rows.map((r) => Wrap(
                    spacing: ThemeUtils.horizontalSpacing,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [...r],
                  )),
            ]);
      },
    );
  }
}

class _SupportTheApp extends StatelessWidget {
  const _SupportTheApp();

  @override
  Widget build(BuildContext context) {
    return SettingsCard(spacing: ThemeUtils.verticalSpacing, title: LocaleKeys.administration_supportApp_title.tr(), showDivider: true, children: [
      Text(LocaleKeys.administration_supportApp_label_buyMeACoffee.tr()),
      ImgLnk(uri: Globals.urlCoffeeExploratia, imageProvider: Assets.images.bmc.bmcButton.provider(), height: 48, width: 171),
      const SizedBox(height: ThemeUtils.verticalSpacing),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(LocaleKeys.administration_supportApp_label_reportABug.tr()),
          TextButton(onPressed: () => LaunchUri.launchUri(Globals.uriGithubXtrackerIssues), child: Text("${Globals.uriGithubXtrackerIssues}")),
        ],
      )
    ]);
  }
}
