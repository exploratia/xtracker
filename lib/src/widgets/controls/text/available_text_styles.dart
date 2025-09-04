import 'package:flutter/material.dart';

import '../card/settings_card.dart';

/// Overview over all TextStyles
class AvailableTextStyles extends StatelessWidget {
  const AvailableTextStyles({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = <String, TextStyle?>{
      // "displayLarge": textTheme.displayLarge,
      // "displayMedium": textTheme.displayMedium,
      // "displaySmall": textTheme.displaySmall,
      // "headlineLarge": textTheme.headlineLarge,
      // "headlineMedium": textTheme.headlineMedium,
      // "headlineSmall": textTheme.headlineSmall,
      "titleLarge": textTheme.titleLarge,
      "titleMedium": textTheme.titleMedium,
      "titleSmall": textTheme.titleSmall,
      "bodyLarge": textTheme.bodyLarge,
      "bodyMedium": textTheme.bodyMedium,
      "bodySmall": textTheme.bodySmall,
      "labelLarge": textTheme.labelLarge,
      "labelMedium": textTheme.labelMedium,
      "labelSmall": textTheme.labelSmall,
    };

    return SettingsCard(
      children: styles.entries.map((entry) {
        final style = entry.value;
        return ListTile(
          title: Text(
            entry.key,
            style: style,
          ),
          subtitle: Text(
            "fontSize: ${style?.fontSize?.toStringAsFixed(1) ?? 'null'}, fontWeight: ${style?.fontWeight ?? 'null'} ",
          ),
        );
      }).toList(),
    );
  }
}
