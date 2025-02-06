import 'package:flutter/material.dart';

import '../model/navigation/navigation_item.dart';
import '../util/dialogs.dart';
import '../util/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/card/glowing_border_container.dart';
import '../widgets/fab/fab_action_button_data.dart';
import '../widgets/fab/fab_builder.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/layout/single_child_scroll_view_with_scrollbar.dart';
import '../widgets/playground/hero/hero_view.dart';
import '../widgets/playground/sample_feature/sample_item_list_view.dart';
import '../widgets/responsive/screen_builder.dart';
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
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        title: const Text("Playground"),
        addLeadingBackBtn: true,
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
      bodyBuilder: (context) => SingleChildScrollViewWithScrollbar(
        scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(16), child: Text("Playground")),
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
      ),
      floatingActionButtonBuilder: (context) {
        var fabActions = [
          FabActionButtonData(
            Icons.add_box,
            () => Dialogs.showSnackBar("Pressed FAB 1", context),
          ),
          FabActionButtonData(
            Icons.add_alarm,
            () => Dialogs.showSnackBar("Pressed FAB 2", context),
          ),
        ];

        return FABBuilder.build(context, fabActions);
      },
    );
  }
}
