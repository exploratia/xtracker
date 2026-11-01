import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xtracker/generated/locale_keys.g.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_service.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_lighting.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/administration/settings/wallpaper_settings.dart';
import 'package:xtracker/src/widgets/administration/settings/wallpaper_style_select.dart';
import 'package:xtracker/src/widgets/controls/layout/drop_down_menu_item_child.dart';
import 'package:xtracker/src/widgets/controls/layout/wallpaper.dart';
import 'package:xtracker/src/widgets/controls/layout/wallpaper_image.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper_refresh.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/wallpaper_scene.dart';

void main() {
  for (final locale in SettingsService.supportedLocales) {
    testWidgets('keeps the motif label together on narrow screens in $locale', (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [280.0, 320.0, 360.0, 800.0]) {
        tester.view.physicalSize = Size(width, 600);
        for (final scale in [1.0, 1.5]) {
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
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                  home: Scaffold(
                    body: WallpaperStyleSelect(value: WallpaperStyle.hills, onChanged: (_) {}),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final label = LocaleKeys.settings_general_wallpaper_label.tr();
          final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
          expect(paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: label.length)), hasLength(1));
          if (width >= 320 && scale == 1) {
            expect(paragraph.didExceedMaxLines, isFalse);
          }
          final dropdown = tester.getRect(find.byKey(const Key('settingsWallpaperSelect')));
          if (width <= 320) {
            expect(dropdown.top, greaterThanOrEqualTo(tester.getRect(find.text(label)).bottom));
          }
          expect(dropdown.left, greaterThanOrEqualTo(0));
          expect(dropdown.right, lessThanOrEqualTo(width));
          expect(tester.takeException(), isNull);
        }
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('selects, changes and hides a custom image in $locale', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({});
      final images = _WidgetWallpaperImageService();
      final controller = SettingsController(SettingsService(wallpaperImageService: images));
      addTearDown(controller.dispose);
      await controller.loadSettings();
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: SettingsService.supportedLocales,
          startLocale: locale,
          saveLocale: false,
          path: 'assets/translations',
          assetLoader: const _TranslationLoader(),
          child: Builder(
            builder: (context) => ChangeNotifierProvider.value(
              value: controller,
              child: MaterialApp(
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                home: Scaffold(
                  body: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) => Wallpaper(
                      showWallpaper: controller.showWallpaper,
                      child: SingleChildScrollView(child: WallpaperSettings(controller: controller)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final frame = find.byKey(const Key('settingsWallpaperPreviewFrame'));
      expect(frame, findsNothing);
      final dropdown = find.byKey(const Key('settingsWallpaperSelect'));
      final customLabel = LocaleKeys.settings_general_wallpaper_customImage.tr();
      // Cancellation on first selection must keep the previous motif.
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(customLabel).last);
      await tester.pumpAndSettle();
      expect(controller.wallpaperStyle, WallpaperStyle.hills);

      images.selection = File('assets/images/logos/app_logo.png').readAsBytesSync();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(customLabel).last);
      await tester.pumpAndSettle();
      expect(controller.wallpaperStyle, WallpaperStyle.customImage);
      expect(find.byType(WallpaperImage), findsNWidgets(2));
      expect(frame, findsOneWidget);
      final decoration = tester.widget<DecoratedBox>(frame).decoration as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.boxShadow, isNull);
      final preview = find.descendant(of: find.byType(WallpaperSettings), matching: find.byType(WallpaperImage));
      for (final size in [const Size(360, 780), const Size(780, 360)]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.getSize(preview).height, 220);
        expect(tester.getSize(preview).width, tester.getSize(find.byType(WallpaperSettings)).width);
        expect(tester.getSize(frame).aspectRatio, closeTo(size.aspectRatio, 0.001));
        expect(tester.getCenter(frame), tester.getCenter(preview));
      }
      tester.view.physicalSize = const Size(800, 600);
      await tester.pumpAndSettle();
      expect(find.byType(LiveWallpaperRefresh), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      final sampledLighting = controller.wallpaperImageLighting;
      for (final image in tester.widgetList<WallpaperImage>(find.byType(WallpaperImage))) {
        expect(image.lighting, same(sampledLighting));
      }
      final liveImage = find.descendant(of: find.byType(LiveWallpaperRefresh), matching: find.byType(WallpaperImage));
      final liveTime = tester.widget<WallpaperImage>(liveImage).percentOfDay;
      await tester.ensureVisible(find.byType(Slider));
      tester.widget<Slider>(find.byType(Slider)).onChanged!(0.5);
      await tester.pump();
      expect(tester.widget<WallpaperImage>(preview).percentOfDay, 0.5);
      final dayFilter = tester.widget<ColorFiltered>(find.descendant(of: preview, matching: find.byType(ColorFiltered))).colorFilter;
      tester.widget<Slider>(find.byType(Slider)).onChanged!(0);
      await tester.pump();
      expect(tester.widget<WallpaperImage>(preview).percentOfDay, 0);
      expect(tester.widget<WallpaperImage>(preview).lighting, same(sampledLighting));
      expect(tester.widget<ColorFiltered>(find.descendant(of: preview, matching: find.byType(ColorFiltered))).colorFilter, isNot(dayFilter));
      expect(tester.widget<WallpaperImage>(liveImage).percentOfDay, liveTime);
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        expect(image.fit, BoxFit.cover);
      }

      final changeImage = find.byKey(const Key('settingsWallpaperChangeImage'));
      expect(tester.getTopLeft(changeImage).dy, greaterThan(tester.getBottomLeft(find.byType(Slider)).dy));
      expect(find.text(LocaleKeys.settings_general_wallpaper_changeImage.tr()), findsOneWidget);
      images.selection = File('assets/images/logos/app_logo_white.png').readAsBytesSync();
      await tester.ensureVisible(changeImage);
      await tester.tap(changeImage);
      await tester.pumpAndSettle();
      expect(controller.wallpaperImage, images.selection);
      expect(controller.wallpaperImageLighting, isNot(same(sampledLighting)));
      for (final image in tester.widgetList<WallpaperImage>(find.byType(WallpaperImage))) {
        expect(image.bytes, controller.wallpaperImage);
        expect(image.lighting, same(controller.wallpaperImageLighting));
      }

      final hideWallpaper = find.widgetWithText(SwitchListTile, LocaleKeys.settings_general_label_hideWallpaper.tr());
      await tester.ensureVisible(hideWallpaper);
      await tester.tap(hideWallpaper);
      await tester.pumpAndSettle();
      expect(find.byType(WallpaperImage), findsOneWidget); // Only the settings preview remains.
      expect(tester.widget<OutlinedButton>(changeImage).onPressed, isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    for (final (style, labelKey) in [
      (WallpaperStyle.mountainLake, LocaleKeys.settings_general_wallpaper_mountainLake),
      (WallpaperStyle.riverValley, LocaleKeys.settings_general_wallpaper_riverValley),
      (WallpaperStyle.moonlitHorizon, LocaleKeys.settings_general_wallpaper_moonlitHorizon),
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
        final preview = find.byType(WallpaperScene);
        final frame = find.byKey(const Key('settingsWallpaperPreviewFrame'));
        expect(tester.getSize(preview).height, 220);
        expect(tester.getSize(preview).width, tester.getSize(find.byType(WallpaperSettings)).width);
        expect(frame, findsNothing);

        tester.view.physicalSize = const Size(780, 360);
        await tester.pumpAndSettle();
        expect(tester.getSize(preview).height, 220);
        expect(tester.getSize(preview).width, tester.getSize(find.byType(WallpaperSettings)).width);
        expect(frame, findsNothing);

        tester.view.physicalSize = const Size(360, 780);
        await tester.pumpAndSettle();
        final dropdown = find.byType(DropdownButton<WallpaperStyle>);
        final hideWallpaperSwitch = find.widgetWithText(SwitchListTile, LocaleKeys.settings_general_label_hideWallpaper.tr());
        final dataWallpaperSwitch = find.byKey(const Key('settingsShowWallpaperOnDataScreens'));
        expect(tester.widget<SwitchListTile>(dataWallpaperSwitch).value, isFalse);
        expect(
          tester.getRect(dataWallpaperSwitch).top,
          tester.getRect(hideWallpaperSwitch).bottom,
        );
        expect(find.text(LocaleKeys.settings_general_label_showWallpaperOnDataScreens.tr()), findsOneWidget);
        await tester.tap(dataWallpaperSwitch);
        await tester.pumpAndSettle();
        expect(controller.showWallpaperOnDataScreens, isTrue);
        expect(await SettingsService().showWallpaperOnDataScreens(), isTrue);
        expect(controller.showDataScreenWallpaper, isTrue);
        final label = find.text(LocaleKeys.settings_general_wallpaper_label.tr());
        final labelRect = tester.getRect(label);
        final dropdownRect = tester.getRect(dropdown);
        if (labelRect.bottom <= dropdownRect.top) {
          expect(labelRect.left, dropdownRect.left);
        } else {
          expect(labelRect.right, lessThanOrEqualTo(dropdownRect.left));
          expect(labelRect.center.dy, closeTo(dropdownRect.center.dy, 1));
        }
        await tester.tap(find.byType(DropdownButton<WallpaperStyle>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(labelKey.tr()).last);
        await tester.pumpAndSettle();
        expect(controller.wallpaperStyle, style);
        expect(frame, findsNothing);
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
        await tester.ensureVisible(hideWallpaperSwitch);
        await tester.tap(hideWallpaperSwitch);
        await tester.pumpAndSettle();
        expect(controller.hideWallpaper, isTrue);
        expect(controller.showWallpaperOnDataScreens, isTrue);
        expect(controller.showDataScreenWallpaper, isFalse);
        expect(controller.wallpaperStyle, style);
        expect(tester.widget<SwitchListTile>(hideWallpaperSwitch).onChanged, isNotNull);
        expect(tester.widget<SwitchListTile>(dataWallpaperSwitch).onChanged, isNull);
        expect(tester.widget<DropdownButton<WallpaperStyle>>(dropdown).onChanged, isNull);
        expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
        final previewTime = tester.widget<WallpaperScene>(find.byType(WallpaperScene)).percentOfDay;

        await tester.tap(hideWallpaperSwitch);
        await tester.pumpAndSettle();
        expect(tester.widget<SwitchListTile>(dataWallpaperSwitch).onChanged, isNotNull);
        expect(tester.widget<DropdownButton<WallpaperStyle>>(dropdown).onChanged, isNotNull);
        expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
        expect(controller.showDataScreenWallpaper, isTrue);
        expect(controller.wallpaperStyle, style);
        expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)).percentOfDay, previewTime);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}

class _WidgetWallpaperImageService extends WallpaperImageService {
  Uint8List? selection;

  // Keep distinct sample instances so tests detect accidental per-widget defaults.
  // ignore: prefer_const_constructors
  WallpaperImageLighting _selectedLighting = WallpaperImageLighting(luminance: 0.5);

  @override
  WallpaperImageLighting get lighting => _selectedLighting;

  @override
  Future<Uint8List?> pick() async => selection;

  // Codec validation and filesystem persistence are covered in the service tests.
  @override
  Future<Uint8List> save(Uint8List bytes) async {
    // A replacement must publish a new sample even when luminance is unchanged.
    // ignore: prefer_const_constructors
    _selectedLighting = WallpaperImageLighting(luminance: 0.5);
    return bytes.asUnmodifiableView();
  }
}

class _TranslationLoader extends AssetLoader {
  const _TranslationLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.toLanguageTag()}.json').readAsStringSync()) as Map<String, dynamic>;
}
