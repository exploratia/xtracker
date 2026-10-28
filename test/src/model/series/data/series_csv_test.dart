import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/data/custom/custom_value.dart';
import 'package:xtracker/src/model/series/data/monthly/monthly_value.dart';
import 'package:xtracker/src/model/series/data/series_data.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_container.dart';
import 'package:xtracker/src/model/series/seriesItem/series_item.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/tags/tag.dart';
import 'package:xtracker/src/util/globals.dart';

void main() {
  final date = DateTime.utc(2026, 10, 1);
  final timestamp = date.millisecondsSinceEpoch;

  for (final type in [SeriesType.custom, SeriesType.monthly]) {
    group('${type.name} CSV', () {
      late SeriesDef seriesDef;

      setUp(() {
        seriesDef = SeriesDef(
          uuid: 'series',
          seriesType: type,
          seriesItems: [
            _item('calculatedFirst', calculated: true),
            _item('first'),
            _item('calculatedMiddle', calculated: true),
            _item('second'),
            _item('calculatedLast', calculated: true),
          ],
        );
      });

      CustomValue createValue(Map<String, double> values, String? tagId) =>
          type == SeriesType.monthly ? MonthlyValue('value', date, values, tagId) : CustomValue('value', date, values, tagId);

      CustomValue importRow(List<dynamic> row) =>
          type == SeriesType.monthly ? SeriesData.fromCSVMonthlyData(seriesDef, [row]).data.single : SeriesData.fromCSVCustomData(seriesDef, [row]).data.single;

      void configureTags() {
        seriesDef.customTagsSettingsEditable(() {}).tags = [Tag(tagId: 'tag-id', color: Colors.blue, name: 'A, "tag"')];
      }

      for (final withTags in [false, true]) {
        test('round-trips stored columns ${withTags ? 'with' : 'without'} tags', () {
          if (withTags) configureTags();
          final value = createValue({'first': 12, 'second': 3.5, 'calculatedMiddle': 999}, withTags ? 'tag-id' : null);
          final csv = const CsvEncoder().convert([
            seriesDef.toCSVHeaderList(),
            ...SeriesData(seriesDef.uuid, [value]).toCSVLists(seriesDef),
          ]);
          final rows = const CsvDecoder(dynamicTyping: true).convert(csv);

          expect(rows.first, ['utc(ms)', 'first', 'second', if (withTags) 'tag']);
          expect(rows.last, [timestamp, 12, 3.5, if (withTags) 'A, "tag"']);
          final imported = importRow(rows.last);
          expect(imported.values, {'first': 12.0, 'second': 3.5});
          expect(imported.dateTime.millisecondsSinceEpoch, timestamp);
          expect(imported.tagId, withTags ? 'tag-id' : null);
          expect(imported.uuid, isNot(value.uuid));
          if (type == SeriesType.monthly) expect(imported, isA<MonthlyValue>());
        });
      }

      test('preserves empty stored cells without shifting the tag', () {
        configureTags();
        final value = createValue({'second': 3.5}, 'tag-id');
        final csv = const CsvEncoder().convert([value.toCSVList(seriesDef)]);
        final row = const CsvDecoder(dynamicTyping: true).convert(csv).single;

        expect(value.toCSVList(seriesDef), [timestamp, null, 3.5, 'A, "tag"']);
        final imported = importRow(row);
        expect(imported.values, {'second': 3.5});
        expect(imported.tagId, 'tag-id');
      });

      test('handles a missing optional tag cell', () {
        configureTags();
        final imported = importRow([timestamp, 12, 3.5]);
        expect(imported.values, {'first': 12.0, 'second': 3.5});
        expect(imported.tagId, isNull);
      });

      test('keeps the invalid-tag fallback only when tags are configured', () {
        final value = createValue({'first': 12}, 'deleted-tag');
        expect(value.toCSVList(seriesDef), [timestamp, 12, null]);
        configureTags();
        expect(value.toCSVList(seriesDef), [timestamp, 12, null, Globals.invalid]);
        expect(importRow([timestamp, 12, '', Globals.invalid]).tagId, isNull);
      });

      test('supports a timestamp-only row when all items are calculated', () {
        seriesDef.seriesItems.removeWhere((item) => !item.isCalculated);
        expect(seriesDef.toCSVHeaderList(), ['utc(ms)']);
        expect(createValue({}, null).toCSVList(seriesDef), [timestamp]);
        expect(importRow([timestamp]).values, isEmpty);
      });
    });
  }
}

SeriesItem _item(String id, {bool calculated = false}) => SeriesItem(
  id,
  id,
  null,
  Colors.blue,
  false,
  false,
  null,
  false,
  calculated ? CalculationContainer(sourceSiid: 'first', calculationItems: [], usePreviousInput: false) : null,
);
