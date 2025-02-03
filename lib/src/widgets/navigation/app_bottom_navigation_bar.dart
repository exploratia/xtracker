import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/navigation/hide_bottom_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: HideBottomNavigationBar.visible,
      builder: (BuildContext ctx, value, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: value ? 80 : 0,
        child: OverflowBox(
          maxHeight: 80,
          minHeight: 0,
          alignment: AlignmentDirectional.topCenter,
          child: SafeArea(
            child: BottomNavigationBar(
              items: _buildNavItems(context),
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    List<BottomNavigationBarItem> result = [];

    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu1',
    ));
    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu2',
    ));
    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu3',
    ));
    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu4',
    ));
    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu5',
    ));
    result.add(const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Menu6',
    ));

    return result;
  }
}
