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
import '../card/settings_card.dart';
import '../controls/btn_lnk.dart';
import '../controls/img_lnk.dart';
import '../layout/scroll_footer.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import '../logos/ca_logo.dart';
import '../logos/exploratia_logo.dart';
import '../navigation/hide_bottom_navigation_bar.dart';

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
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsCard(
            spacing: 10,
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
          const ScrollFooter(marginTop: 20),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
              spacing: 8,
              runSpacing: 4,
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
            spacing: 10,
            children: [
              // legals buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => AboutDlg.showAboutDlg(context),
                    icon: const Icon(Icons.info_outline),
                    label: Text(LocaleKeys.administration_app_btn_version.tr()),
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
              const Divider(height: 20),
              ...rows.map((r) => Wrap(
                    spacing: 10,
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
    return SettingsCard(spacing: 10, title: LocaleKeys.administration_supportApp_title.tr(), showDivider: true, children: [
      Text(LocaleKeys.administration_supportApp_labels_buyMeACoffee.tr()),
      ImgLnk(uri: Globals.urlCoffeeExploratia, imageProvider: Assets.images.bmc.bmcButton.provider(), height: 48, width: 171),
      const SizedBox(height: 16),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(LocaleKeys.administration_supportApp_labels_reportABug.tr()),
          TextButton(onPressed: () => LaunchUri.launchUri(Globals.uriGithubXtrackerIssues), child: Text("${Globals.uriGithubXtrackerIssues}")),
        ],
      )
    ]);
  }
}
