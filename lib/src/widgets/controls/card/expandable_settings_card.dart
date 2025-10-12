import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import 'settings_card.dart';

class ExpandableSettingsCard extends StatefulWidget {
  /// Damit die Card die Device-Constraints einhalten kann, muss umschliessende Column z.B. center sein.
  const ExpandableSettingsCard({super.key, required this.title, required this.content});

  final Widget title;
  final Widget content;

  @override
  State<ExpandableSettingsCard> createState() => _ExpandableSettingsCardState();
}

class _ExpandableSettingsCardState extends State<ExpandableSettingsCard> {
  var _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsCard.singleEntry(
      showDivider: false,
      title: InkWell(
        onTap: () => _toggleExpanded(),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeUtils.cardPadding),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeUtils.defaultPadding, horizontal: ThemeUtils.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.title,
              const SizedBox(width: ThemeUtils.verticalSpacing),
              Icon(
                _expanded ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: ThemeUtils.iconSizeScaled,
              ),
            ],
          ),
        ),
      ),
      content: AnimatedCrossFade(
        duration: Duration(milliseconds: _expanded ? ThemeUtils.animationDuration : ThemeUtils.animationDurationShort),
        crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: ThemeUtils.verticalSpacingLarge),
            widget.content,
          ],
        ),
        secondChild: Container(
          height: 0,
        ),
      ),
    );
  }
}
