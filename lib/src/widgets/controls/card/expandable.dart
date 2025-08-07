import 'package:flutter/material.dart';

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
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _toggleExpanded(),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              spacing: 10,
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
                Icon(_expanded ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: Duration(milliseconds: _expanded ? 300 : 150),
          crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const AlignmentDirectional(0, -0.7),
                end: const AlignmentDirectional(0, 1),
                colors: [Colors.transparent, themeData.cardTheme.color ?? Colors.black],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 10),
                widget.child,
                const SizedBox(height: 8),
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
