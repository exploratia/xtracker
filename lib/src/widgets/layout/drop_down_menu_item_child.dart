import 'package:flutter/material.dart';

/// DropDownMenuItem with "selected" border
class DropDownMenuItemChild extends StatelessWidget {
  const DropDownMenuItemChild({
    super.key,
    required this.selected,
    required this.child,
  });

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    BoxDecoration? boxDeco;
    if (selected) {
      boxDeco = BoxDecoration(
          border: Border(
              left:
                  BorderSide(width: 2, color: themeData.colorScheme.primary)));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
          decoration: boxDeco,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: child,
          )),
    );
  }
}
