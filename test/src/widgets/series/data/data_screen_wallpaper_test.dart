import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xtracker/src/model/series/data/daily_check/daily_check_value.dart';
import 'package:xtracker/src/model/series/data/series_data.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/series_view_meta_data.dart';
import 'package:xtracker/src/providers/series_data_provider.dart';
import 'package:xtracker/src/providers/series_provider.dart';
import 'package:xtracker/src/screens/series/series_data_screen.dart';
import 'package:xtracker/src/store/stores_utils.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/controls/layout/wallpaper.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper_refresh.dart';
import 'package:xtracker/src/widgets/series/data/analytics/series_data_analytics_view.dart';

void main() {
  setUpAll(() async {
    StoresUtils.db = await databaseFactoryMemory.openDatabase('data-screen-wallpaper.db');
    final translations = jsonDecode(File('assets/translations/en-US.json').readAsStringSync()) as Map<String, dynamic>;
    Localization.load(const Locale('en', 'US'), translations: Translations(translations));
  });

  tearDownAll(() async => StoresUtils.db.close());

  for (final analysis in [false, true]) {
    testWidgets('${analysis ? 'analysis' : 'data'} screen responds to wallpaper preferences', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({});
      final settings = SettingsController(SettingsService());
      final seriesProvider = _LoadedSeriesProvider();
      final dataProvider = _LoadedDataProvider();
      addTearDown(settings.dispose);
      addTearDown(seriesProvider.dispose);
      addTearDown(dataProvider.dispose);
      await settings.loadSettings();
      final series = SeriesDef(uuid: 'series', name: 'Measurements', seriesType: SeriesType.dailyCheck, seriesItems: []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsController>.value(value: settings),
            ChangeNotifierProvider<SeriesProvider>.value(value: seriesProvider),
            ChangeNotifierProvider<SeriesDataProvider>.value(value: dataProvider),
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false, tooltipTheme: const TooltipThemeData(textStyle: TextStyle())),
            home: analysis
                ? Dialog.fullscreen(
                    child: SeriesDataAnalyticsView(seriesViewMetaData: SeriesViewMetaData(seriesDef: series)),
                  )
                : SeriesDataScreen(args: {'series': series}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Wallpaper), findsNothing);

      await settings.updateShowWallpaperOnDataScreens(true);
      await tester.pumpAndSettle();
      expect(find.byType(Wallpaper), findsOneWidget);
      expect(find.byType(LiveWallpaperRefresh), findsOneWidget);
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor?.a, 0);

      await settings.updateHideWallpaper(true);
      await tester.pumpAndSettle();
      expect(find.byType(Wallpaper), findsNothing);

      await settings.updateHideWallpaper(false);
      await tester.pumpAndSettle();
      expect(find.byType(Wallpaper), findsOneWidget);

      await settings.updateShowWallpaperOnDataScreens(false);
      await tester.pumpAndSettle();
      expect(find.byType(Wallpaper), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _LoadedSeriesProvider extends SeriesProvider {
  @override
  Future<void> fetchDataIfNotYetLoaded() async {}
}

class _LoadedDataProvider extends SeriesDataProvider {
  final values = SeriesData('series', [
    DailyCheckValue('first', DateTime.now().subtract(const Duration(days: 2))),
    DailyCheckValue('last', DateTime.now()),
  ]);

  @override
  Future<void> fetchDataIfNotYetLoaded(SeriesDef seriesDef) async {}

  @override
  SeriesData<DailyCheckValue>? dailyCheckData(SeriesDef seriesDef) => values;
}
