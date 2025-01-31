import 'package:flutter/material.dart';

import '../widgets/card/glowing_border_container.dart';
import '../widgets/playground/hero/hero_view.dart';
import '../widgets/playground/sample_feature/sample_item_list_view.dart';
import 'administration/settings_screen.dart';

class PlaygroundScreen extends StatelessWidget {
  static const routeName = '/playground';

  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playground"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsScreen.routeName);
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
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
