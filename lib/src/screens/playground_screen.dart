import 'package:flutter/material.dart';

import '../model/navigation/navigation_item.dart';
import '../widgets/card/glowing_border_container.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/playground/hero/hero_view.dart';
import '../widgets/playground/sample_feature/sample_item_list_view.dart';
import '../widgets/select/color_picker.dart';
import '../widgets/select/icon_picker.dart';
import 'administration/settings_screen.dart';

class PlaygroundScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.adb_outlined),
    routeName: '/playground',
    titleBuilder: (t) => "Playground",
  );

  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: const Text("Playground"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(
                  context, SettingsScreen.navItem.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text("Playground")),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(
                  context, SampleItemListView.routeName);
            },
            child: Text('SampleListView'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, HeroView.routeName);
            },
            child: Text('HeroView'),
          ),
          const GlowingBorderContainer(
            // glowColor: Colors.red, // Customize glow color
            borderWidth: 1.0,
            blurRadius: 10.0,
            child: Text(
              "Glowing Box",
              // style: TextStyle(color: Colors.white),
            ),
          ),
          ColorPicker(
            color: themeData.colorScheme.primary,
            colorSelected: (color) => print('Color selected: $color'),
          ),
          IconPicker(
            icoSelected: (icoName) => print('Icon selected: $icoName'),
          ),
        ],
      ),
    );
  }
}
