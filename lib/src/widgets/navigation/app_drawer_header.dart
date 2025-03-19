import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../util/navigation/navigation_utils.dart';

class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    List<Color> gradientColors = [
      themeData.scaffoldBackgroundColor,
      themeData.colorScheme.secondary,
      themeData.colorScheme.primary,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
      ),
      height: 56, // AppBar height -> same optical line
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                NavigationUtils.closeDrawerIfOpen(context);
              },
              icon: const Icon(Icons.arrow_left)),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              width: 30,
              child: Assets.images.logos.appLogoWhite.image(fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
