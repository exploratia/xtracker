import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/navigation_item.dart';
import '../../widgets/administration/info_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class InfoScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.info_outline),
    routeName: '/info',
    titleBuilder: (t) => t.infoTitle,
  );

  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context,
          addLeadingBackBtn: true, title: Text(navItem.titleBuilder(t))),
      bodyBuilder: (context) => const InfoView(),
    );
  }
}
