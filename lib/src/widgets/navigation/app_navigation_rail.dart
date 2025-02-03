import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({super.key});

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  bool _extended = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            // ohne LayoutBuilder:  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height,
            child: IntrinsicHeight(
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                destinations: _buildDestinations(),
                extended: _extended,
                onDestinationSelected: (int index) {
                  setState(() {
                    if (index == 0) {
                      _extended = !_extended;
                    } else {
                      _selectedIndex = index;
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      // expand-item
      NavigationRailDestination(
        icon: Icon(_extended ? Icons.arrow_left : Icons.arrow_right),
        label: const SizedBox(width: 0, height: 0),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.favorite),
        label: Text('Favorites'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.logout),
        label: Text('Logout'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.logout),
        label: Text('Logout2'),
      ),
    ];
  }
}
