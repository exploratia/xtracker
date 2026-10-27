import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_container.dart';
import 'package:xtracker/src/model/series/seriesItem/series_item.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/tags/tag.dart';
import 'package:xtracker/src/providers/series_current_value_provider.dart';
import 'package:xtracker/src/providers/series_data_provider.dart';
import 'package:xtracker/src/providers/series_provider.dart';
import 'package:xtracker/src/store/stores_utils.dart';
import 'package:xtracker/src/util/series/series_import_export.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';

void main() {
  setUpAll(() async {
    StoresUtils.db = await databaseFactoryMemory.openDatabase('series-import-export-test.db');
  });

  tearDownAll(() async {
    await StoresUtils.db.close();
  });

  for (final language in ['de-DE', 'en-US']) {
    for (final type in [SeriesType.custom, SeriesType.monthly]) {
      for (final withTags in [false, true]) {
        testWidgets('$language ${type.name} dialog shows matching CSV examples, tags: $withTags', (tester) async {
          final translations = jsonDecode(File('assets/translations/$language.json').readAsStringSync()) as Map<String, dynamic>;
          final localeParts = language.split('-');
          Localization.load(Locale(localeParts.first, localeParts.last), translations: Translations(translations));
          final settings = SettingsController(SettingsService());
          addTearDown(settings.dispose);
          final seriesDef = SeriesDef(
            uuid: 'series',
            name: 'Measurements',
            seriesType: type,
            seriesItems: [
              SeriesItem('stored', 'Stored', null, Colors.blue, false, false, null, false, null),
              SeriesItem(
                'calculated',
                'Calculated',
                null,
                Colors.blue,
                false,
                false,
                null,
                false,
                CalculationContainer(sourceSiid: 'stored', calculationItems: [], usePreviousInput: false),
              ),
            ],
          );
          if (withTags) {
            seriesDef.customTagsSettingsEditable(() {}).tags = [Tag(tagId: 'tag', color: Colors.blue, name: 'Tag')];
          }
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => SeriesProvider()),
                ChangeNotifierProvider(create: (_) => SeriesDataProvider()),
                ChangeNotifierProvider(create: (_) => SeriesCurrentValueProvider()),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => SeriesImportExport.showImportExportDlg(context, seriesDef: seriesDef, settingsController: settings),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          final expectedHeader = 'utc(ms),Stored${withTags ? ',tag' : ''}';
          final examples = tester.widgetList<Text>(find.byType(Text)).map((text) => text.data ?? '').where((text) => text.contains('utc(ms)')).toList();
          expect(examples, hasLength(2));
          for (final example in examples) {
            expect(example, endsWith(expectedHeader));
            expect(example, isNot(contains(',Calculated')));
            expect(example, isNot(contains('{}')));
            expect(example, contains(language == 'de-DE' ? 'Berechnete Parameter werden nicht' : 'Calculated parameters are not'));
          }
          expect(
            examples.singleWhere((text) => text.contains('Measurements')),
            contains(language == 'de-DE' ? 'dürfen nicht als Spalten' : 'must not be included as columns'),
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
