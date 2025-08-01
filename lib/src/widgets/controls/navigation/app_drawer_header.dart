import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../util/navigation/navigation_utils.dart';

class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    List<Color> gradientColors = [
      if (themeData.brightness == Brightness.dark) themeData.scaffoldBackgroundColor,
      themeData.colorScheme.secondary,
      themeData.colorScheme.primary,
    ];

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors)),
      height: kToolbarHeight, // AppBar height -> same optical line
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              tooltip: LocaleKeys.commons_nav_hideMenu.tr(),
              onPressed: () {
                NavigationUtils.closeDrawerIfOpen(context);
              },
              icon: Icon(
                Icons.arrow_left,
                color: themeData.colorScheme.onPrimary,
              )),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              width: 40,
              child: Assets.images.logos.appLogoWhite.image(fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
