import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/data/daily_check/daily_check_value.dart';
import 'package:xtracker/src/model/series/data/series_data_filter.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/series_view_meta_data.dart';
import 'package:xtracker/src/model/series/view_type.dart';
import 'package:xtracker/src/util/date_time_utils.dart';
import 'package:xtracker/src/widgets/series/data/view/series_data_view.dart';

void main() {
  setUpAll(() {
    final translations = jsonDecode(File('assets/translations/en-US.json').readAsStringSync()) as Map<String, dynamic>;
    Localization.load(const Locale('en', 'US'), translations: Translations(translations));
  });

  for (final viewType in [ViewType.table, ViewType.lineChart, ViewType.pixels]) {
    for (final showFilter in [false, true]) {
      testWidgets('${viewType.name} includes a new latest value with filter visible: $showFilter', (tester) async {
        final firstDate = DateTime(2026, 10, 1);
        final latestDate = DateTime(2026, 10, 15, 12);
        final filter = SeriesDataFilter()..start = firstDate;
        final values = [DailyCheckValue('first', firstDate), DailyCheckValue('latest', latestDate)];
        final metaData = _metaData(viewType, showFilter);

        await _pumpView(tester, metaData, filter, values);
        expect(filter.end, isNull);

        // Keep the view mounted while the data changes, as after creating,
        // duplicating or editing a value in the input dialog.
        final newDate = latestDate.add(const Duration(days: 1));
        values.add(DailyCheckValue('new', newDate));
        await _pumpView(tester, metaData, filter, values);

        expect(filter.end, isNull);
        expect(filter.filterDate(newDate), isTrue);
        expect(find.byKey(const ValueKey('new')), findsOneWidget);
        expect(_slider(tester).values.end, _slider(tester).max);
        expect(filter.start, firstDate);

        values.add(DailyCheckValue('newer', newDate.add(const Duration(days: 1))));
        await _pumpView(tester, metaData, filter, values);

        expect(filter.end, isNull);
        expect(find.byKey(const ValueKey('newer')), findsOneWidget);
      });
    }
  }

  testWidgets('preserves a deliberately restricted date range when a newer value is added', (tester) async {
    final firstDate = DateTime(2026, 10, 1);
    final selectedStart = DateTime(2026, 10, 3);
    final selectedEnd = DateTimeUtils.endOfDay(DateTime(2026, 10, 10));
    final filter = SeriesDataFilter()..setDate(startDate: selectedStart, endDate: selectedEnd);
    final values = [DailyCheckValue('first', firstDate), DailyCheckValue('latest', DateTime(2026, 10, 15))];
    final metaData = _metaData(ViewType.table, true);

    await _pumpView(tester, metaData, filter, values);
    values.add(DailyCheckValue('new', DateTime(2026, 10, 16)));
    await _pumpView(tester, metaData, filter, values);

    expect(filter.start, selectedStart);
    expect(filter.end, selectedEnd);
    expect(find.byKey(const ValueKey('new')), findsNothing);
    expect(_slider(tester).values.end, lessThan(_slider(tester).max));
  });

  testWidgets('keeps the end open when the latest day is removed', (tester) async {
    final firstDate = DateTime(2026, 10, 1);
    final filter = SeriesDataFilter()..start = firstDate;
    final values = [
      DailyCheckValue('first', firstDate),
      DailyCheckValue('previous', DateTime(2026, 10, 14)),
      DailyCheckValue('latest', DateTime(2026, 10, 15)),
    ];
    final metaData = _metaData(ViewType.table, false);

    await _pumpView(tester, metaData, filter, values);
    values.removeLast();
    await _pumpView(tester, metaData, filter, values);

    expect(filter.end, isNull);
    expect(_slider(tester).values.end, _slider(tester).max);
    expect(find.byKey(const ValueKey('previous')), findsOneWidget);
  });
}

SeriesViewMetaData _metaData(ViewType viewType, bool showFilter) {
  return SeriesViewMetaData(
      seriesDef: SeriesDef(uuid: 'series', seriesType: SeriesType.dailyCheck, seriesItems: []),
    )
    ..viewType = viewType
    ..showDateFilter = showFilter;
}

RangeSlider _slider(WidgetTester tester) => tester.widget(find.byType(RangeSlider));

Future<void> _pumpView(
  WidgetTester tester,
  SeriesViewMetaData metaData,
  SeriesDataFilter filter,
  List<DailyCheckValue> values,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SeriesDataView(
            seriesViewMetaData: metaData,
            seriesDataValues: values,
            filter: filter,
            updateFilter: () {
              if (filter.getAndResetDirty()) setState(() {});
            },
            updateOverlays: ({topHeight, bottomHeight}) {},
            seriesDataViewContentBuilder: () => Column(
              children: [
                for (final value in values.where(filter.filter)) SizedBox(key: ValueKey(value.uuid)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
