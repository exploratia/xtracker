import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import '../layout/center_horizontal.dart';
import '../responsive/device_dependent_constrained_box.dart';

class SettingsCard extends StatelessWidget {
  /// Damit die Card die Device-Constraints einhalten kann, muss umschliessende Column z.B. center sein.
  const SettingsCard({
    super.key,
    this.title,
    required this.children,
    this.showDivider = true,
    this.childrenColumnCrossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
  });

  final dynamic title;
  final List<Widget> children;
  final bool showDivider;
  final CrossAxisAlignment childrenColumnCrossAxisAlignment;
  final double spacing;

  Widget _buildTitle(BuildContext context) {
    if (title == null) return Container(height: 0);
    if (title is Widget) {
      return title as Widget;
    }
    var titleText = title.toString();
    return Text(titleText, style: Theme.of(context).textTheme.titleLarge);
  }

  @override
  Widget build(BuildContext context) {
    return CenterH(
      child: DeviceDependentWidthConstrainedBox(
        child: Card(
          // margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: ThemeUtils.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context),
                if (showDivider) const SizedBox(height: 10),
                if (showDivider) const Divider(),
                if (showDivider) const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: childrenColumnCrossAxisAlignment,
                  spacing: spacing,
                  children: [...children],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
