import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xtracker/src/model/series/data/series_data.dart';
import 'package:xtracker/src/model/series/data/series_data_value.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/providers/series_current_value_provider.dart';
import 'package:xtracker/src/providers/series_data_provider.dart';
import 'package:xtracker/src/store/stores_utils.dart';

void main() {
  setUpAll(() async {
    StoresUtils.db = await databaseFactoryMemory.openDatabase('series-data-test.db');
  });

  testWidgets('stores a dialog result after the opening widget is unmounted', (tester) async {
    final callerVisible = ValueNotifier<bool>(true);
    final dataProvider = _RecordingSeriesDataProvider();
    final currentValueProvider = SeriesCurrentValueProvider();
    final seriesDef = SeriesDef(
      uuid: 'series-id',
      seriesType: SeriesType.dailyCheck,
      name: 'Daily check',
      seriesItems: const [],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SeriesDataProvider>.value(value: dataProvider),
          ChangeNotifierProvider<SeriesCurrentValueProvider>.value(value: currentValueProvider),
        ],
        child: MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: callerVisible,
            builder: (context, visible, _) {
              if (!visible) {
                return const Scaffold();
              }
              return Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => SeriesData.showSeriesDataInputDlg(context, seriesDef),
                    child: const Text('Add value'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add value'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    callerVisible.value = false;
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'commons.dialog.btn.okay'));
    await tester.pumpAndSettle();

    expect(dataProvider.addedValues, hasLength(1));
  });
}

class _RecordingSeriesDataProvider extends SeriesDataProvider {
  final List<SeriesDataValue> addedValues = [];

  @override
  Future<void> addValue(
    SeriesDef seriesDef,
    SeriesDataValue value,
    SeriesCurrentValueProvider seriesCurrentValueProvider,
  ) async {
    addedValues.add(value);
  }
}
