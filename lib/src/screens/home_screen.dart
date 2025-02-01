import 'package:flutter/material.dart';

import '../util/globals.dart';
import '../widgets/layout/gradient_app_bar.dart';
import './playground_screen.dart';
import 'administration/info_screen.dart';
import 'administration/logs_screen.dart';
import 'administration/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Row(
          children: [
            SizedBox(
              width: 30,
              child: Image.asset(
                Globals.assetImgAppLogoWhite,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
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
          Padding(padding: const EdgeInsets.all(16), child: Text("Home")),
          ElevatedButton(
            onPressed: () {
              print('button pressed!');
            },
            child: Text('Next'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(
                  context, PlaygroundScreen.routeName);
            },
            child: Text('Playground'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsScreen.routeName);
            },
            child: Text('Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, LogsScreen.routeName);
            },
            child: Text('Logs'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, InfoScreen.routeName);
            },
            child: Text('Info'),
          ),
        ],
      ),
    );
  }
}
