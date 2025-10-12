import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import '../layout/center_horizontal.dart';
import '../responsive/device_dependent_constrained_box.dart';

class SettingsCard extends StatelessWidget {
  /// Damit die Card die Device-Constraints einhalten kann, muss umschliessende Column z.B. center sein.
  const SettingsCard({
    super.key,
    required this.settingCardEntries,
  });

  SettingsCard.singleEntry({super.key, dynamic title, bool showDivider = true, required Widget content})
      : settingCardEntries = [SettingsCardEntry(content: content, showDivider: showDivider, title: title)];

  final List<SettingsCardEntry> settingCardEntries;

  Widget _buildTitle(BuildContext context, dynamic title) {
    if (title == null) return Container(height: 0);
    if (title is Widget) {
      return title;
    }
    var titleText = title.toString();
    return Text(titleText, style: Theme.of(context).textTheme.titleLarge);
  }

  @override
  Widget build(BuildContext context) {
    return CenterH(
      child: DeviceDependentWidthConstrainedBox(
        child: Card(
          child: Padding(
            padding: ThemeUtils.cardPaddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ThemeUtils.verticalSpacingLarge * 2,
              children: [
                ...settingCardEntries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(context, entry.title),
                      if (entry.showDivider) const Divider(height: ThemeUtils.verticalSpacingLarge),
                      entry.content,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsCardEntry {
  final dynamic title;
  final bool showDivider;
  final Widget content;

  SettingsCardEntry({this.title, required this.content, this.showDivider = true});
}
