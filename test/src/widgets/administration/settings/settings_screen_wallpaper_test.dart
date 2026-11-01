import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xtracker/generated/locale_keys.g.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/routing.dart';
import 'package:xtracker/src/screens/administration/settings_screen.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/controls/animation/animated_expansion.dart';
import 'package:xtracker/src/widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper_refresh.dart';
import 'package:xtracker/src/widgets/controls/navigation/hide_bottom_navigation_bar.dart';

void main() {
  for (final style in [WallpaperStyle.hills, WallpaperStyle.mountainLake]) {
    testWidgets('settings keeps $style stable while hiding navigation and toggling wallpaper', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({});
      final settings = SettingsController(SettingsService());
      addTearDown(settings.dispose);
      await settings.loadSettings();
      await settings.updateHideWallpaper(false);
      await settings.updateWallpaperStyle(style);
      Routing(settings);
      HideBottomNavigationBar.setVisible(true);
      addTearDown(() => HideBottomNavigationBar.setVisible(true));

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: SettingsService.supportedLocales,
          startLocale: const Locale('en', 'US'),
          saveLocale: false,
          path: 'assets/translations',
          assetLoader: const _TranslationLoader(),
          child: Builder(
            builder: (context) => ChangeNotifierProvider.value(
              value: settings,
              child: MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                theme: ThemeData(useMaterial3: false, tooltipTheme: const TooltipThemeData(textStyle: TextStyle())),
                home: ListenableBuilder(
                  listenable: settings,
                  builder: (context, child) => SettingsScreen(settingsController: settings),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final wallpaper = find.byType(LiveWallpaperRefresh);
      final originalRect = tester.getRect(wallpaper);
      final body = find.byType(SingleChildScrollViewWithScrollbar);
      final originalBodyHeight = tester.getSize(body).height;

      HideBottomNavigationBar.setVisible(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getRect(wallpaper), originalRect);
      await tester.pumpAndSettle();
      expect(tester.getRect(wallpaper), originalRect);
      expect(tester.getSize(body).height, originalBodyHeight + kBottomNavigationBarHeight);

      HideBottomNavigationBar.setVisible(true);
      await tester.pumpAndSettle();
      expect(tester.getRect(wallpaper), originalRect);

      await tester.tap(find.text(LocaleKeys.settings_general_wallpaper_title.tr()));
      await tester.pumpAndSettle();
      final expansion = find.byType(AnimatedExpansion).at(1);
      expect(tester.widget<AnimatedExpansion>(expansion).expanded, isTrue);
      final expansionState = tester.state(expansion);

      for (final hidden in [true, false]) {
        await settings.updateHideWallpaper(hidden);
        await tester.pumpAndSettle();
        expect(tester.state(expansion), same(expansionState));
        expect(tester.widget<AnimatedExpansion>(expansion).expanded, isTrue);
        expect(wallpaper, hidden ? findsNothing : findsOneWidget);
      }
      expect(tester.getRect(wallpaper), originalRect);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _TranslationLoader extends AssetLoader {
  const _TranslationLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.toLanguageTag()}.json').readAsStringSync()) as Map<String, dynamic>;
}
