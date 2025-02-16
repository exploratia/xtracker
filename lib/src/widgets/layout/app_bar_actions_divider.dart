import 'package:flutter/material.dart';

class AppBarActionsDivider extends StatelessWidget {
  const AppBarActionsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      width: 1, // Divider thickness
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const AlignmentDirectional(0, 1),
          end: const AlignmentDirectional(0, -0.7),
          colors: [
            Colors.transparent,
            themeData.colorScheme.onPrimary.withAlpha(32),
            themeData.colorScheme.onPrimary.withAlpha(64),
            themeData.scaffoldBackgroundColor.withAlpha(0),
          ],
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8), // Spacing
    );
  }
}
