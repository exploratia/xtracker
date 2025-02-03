import 'package:flutter/material.dart';

import '../util/globals.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/navigation/double_back_to_close.dart';
import './playground_screen.dart';
import 'administration/administration_screen.dart';
import 'administration/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackToClose(
      child: Scaffold(
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
                Navigator.restorablePushNamed(
                    context, SettingsScreen.routeName);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text("Home")),
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(
                    context, PlaygroundScreen.routeName);
              },
              child: Text('Playground'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(
                    context, AdministrationScreen.routeName);
              },
              child: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    AdministrationScreen.icon,
                    Text('Mehr...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
