import 'package:flutter/material.dart';

import '../../../../util/theme_utils.dart';

class TabToCloseFab extends StatelessWidget {
  const TabToCloseFab({super.key, required this.toggle});

  final VoidCallback toggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: ThemeUtils.elevation,
          child: InkWell(
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.all(ThemeUtils.defaultPadding),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
