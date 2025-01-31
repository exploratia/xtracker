import 'package:flutter/material.dart';

import 'settings_card.dart';

class ExpandableSettingsCard extends StatefulWidget {
  /// Damit die Card die Device-Constraints einhalten kann, muss umschliessende Column z.B. center sein.
  const ExpandableSettingsCard(
      {super.key, required this.title, required this.content});

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
    return SettingsCard(
        showDivider: false,
        title: InkWell(
          onTap: () => _toggleExpanded(),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.title,
                const SizedBox(width: 10),
                Icon(
                    _expanded
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
        children: [
          AnimatedCrossFade(
            duration: Duration(milliseconds: _expanded ? 300 : 150),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                const Divider(),
                widget.content,
              ],
            ),
            secondChild: Container(
              height: 0,
            ),
          ),
        ]);
  }
}
