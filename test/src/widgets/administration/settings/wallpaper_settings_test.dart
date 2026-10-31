import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/generated/locale_keys.g.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/administration/settings/wallpaper_settings.dart';
import 'package:xtracker/src/widgets/controls/layout/drop_down_menu_item_child.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/wallpaper_scene.dart';

void main() {
  for (final locale in SettingsService.supportedLocales) {
    for (final (style, labelKey) in [
      (WallpaperStyle.mountainLake, LocaleKeys.settings_general_wallpaper_mountainLake),
      (WallpaperStyle.riverValley, LocaleKeys.settings_general_wallpaper_riverValley),
    ]) {
      testWidgets('selects and previews $style in $locale on a small screen', (tester) async {
        FlutterSecureStorage.setMockInitialValues({});
        final controller = SettingsController(SettingsService());
        addTearDown(controller.dispose);
        await controller.loadSettings();
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: SettingsService.supportedLocales,
            startLocale: locale,
            saveLocale: false,
            path: 'assets/translations',
            assetLoader: const _TranslationLoader(),
            child: Builder(
              builder: (context) => MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                home: Scaffold(
                  body: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) => SingleChildScrollView(child: WallpaperSettings(controller: controller)),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final dropdown = find.byType(DropdownButton<WallpaperStyle>);
        final label = find.text(LocaleKeys.settings_general_wallpaper_label.tr());
        expect(tester.getRect(label).right, lessThanOrEqualTo(tester.getRect(dropdown).left));
        expect(tester.getCenter(label).dy, closeTo(tester.getCenter(dropdown).dy, 1));
        await tester.tap(find.byType(DropdownButton<WallpaperStyle>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(labelKey.tr()).last);
        await tester.pumpAndSettle();
        expect(controller.wallpaperStyle, style);
        expect(await SettingsService().wallpaperStyle(), style);
        expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)).style, style);
        final selectedItems = tester
            .widgetList<DropDownMenuItemChild>(
              find.descendant(
                of: dropdown,
                matching: find.byType(DropDownMenuItemChild),
              ),
            )
            .where((item) => item.selected);
        expect(selectedItems, hasLength(1));
        expect((selectedItems.single.child as Text).data, labelKey.tr());

        final slider = tester.getRect(find.byType(Slider));
        await tester.tapAt(Offset(slider.left + slider.width * 0.75, slider.center.dy));
        await tester.pump();
        expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)).percentOfDay, inInclusiveRange(0.7, 0.85));
        expect(controller.wallpaperStyle, style);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(controller.hideWallpaper, isTrue);
        expect(controller.wallpaperStyle, style);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}

class _TranslationLoader extends AssetLoader {
  const _TranslationLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.toLanguageTag()}.json').readAsStringSync()) as Map<String, dynamic>;
}
