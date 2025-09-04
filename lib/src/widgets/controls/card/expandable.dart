import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import '../text/overflow_text.dart';

class Expandable extends StatefulWidget {
  const Expandable({super.key, required this.child, this.icon, this.title, this.initialExpanded = false});

  final Icon? icon;
  final String? title;
  final Widget child;
  final bool initialExpanded;

  @override
  State<Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable> {
  var _expanded = false;

  @override
  void initState() {
    _expanded = widget.initialExpanded;
    super.initState();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      spacing: 0,
      children: [
        const SizedBox(height: ThemeUtils.verticalSpacingLarge),
        InkWell(
          onTap: () => _toggleExpanded(),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ThemeUtils.defaultPadding),
            child: Row(
              spacing: ThemeUtils.horizontalSpacing,
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.icon != null) widget.icon!,
                if (widget.title != null)
                  OverflowText(
                    widget.title!,
                    expanded: true,
                    style: themeData.textTheme.titleMedium,
                  ),
                if (widget.title == null && widget.icon == null) Container(), // fallback -> expand icon always at the end
                Icon(
                  _expanded ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: ThemeUtils.iconSizeScaled,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: Duration(milliseconds: _expanded ? ThemeUtils.animationDuration : ThemeUtils.animationDurationShort),
          crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const AlignmentDirectional(0, -0.7),
                end: const AlignmentDirectional(0, 1),
                colors: [Colors.transparent, themeData.cardTheme.color ?? Colors.black],
              ),
              borderRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(ThemeUtils.borderRadius), bottomRight: Radius.circular(ThemeUtils.borderRadius)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: ThemeUtils.verticalSpacing),
                widget.child,
                const SizedBox(height: ThemeUtils.verticalSpacing),
                // const Divider(),
              ],
            ),
          ),
          secondChild: Container(
            height: 0,
          ),
        ),
      ],
    );
  }
}
