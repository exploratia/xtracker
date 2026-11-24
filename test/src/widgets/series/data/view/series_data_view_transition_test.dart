import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/view_type.dart';
import 'package:xtracker/src/widgets/series/data/view/series_data_view_transition.dart';

void main() {
  testWidgets('fades and subtly scales between data view types', (tester) async {
    final viewType = ValueNotifier(ViewType.table);
    addTearDown(viewType.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: viewType,
          builder: (context, currentViewType, _) => SeriesDataViewTransition(
            viewType: currentViewType,
            child: Text(currentViewType.name),
          ),
        ),
      ),
    );

    expect(find.text(ViewType.table.name), findsOneWidget);

    viewType.value = ViewType.lineChart;
    await tester.pump();

    expect(find.text(ViewType.table.name), findsOneWidget);
    expect(find.text(ViewType.lineChart.name), findsOneWidget);
    expect(
      find.descendant(of: find.byType(SeriesDataViewTransition), matching: find.byType(FadeTransition)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: find.byType(SeriesDataViewTransition), matching: find.byType(ScaleTransition)),
      findsNWidgets(2),
    );

    await tester.pump(const Duration(milliseconds: 100));
    final scales = tester
        .widgetList<ScaleTransition>(
          find.descendant(of: find.byType(SeriesDataViewTransition), matching: find.byType(ScaleTransition)),
        )
        .map((transition) => transition.scale.value);
    expect(scales.every((scale) => scale >= 0.985 && scale <= 1), isTrue);

    await tester.pumpAndSettle();
    expect(find.text(ViewType.table.name), findsNothing);
    expect(find.text(ViewType.lineChart.name), findsOneWidget);
  });

  testWidgets('does not transition updates within the same view type', (tester) async {
    final revision = ValueNotifier(1);
    addTearDown(revision.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: revision,
          builder: (context, currentRevision, _) => SeriesDataViewTransition(
            viewType: ViewType.table,
            child: Text('revision-$currentRevision'),
          ),
        ),
      ),
    );

    revision.value = 2;
    await tester.pump();

    expect(find.text('revision-1'), findsNothing);
    expect(find.text('revision-2'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(SeriesDataViewTransition), matching: find.byType(FadeTransition)),
      findsOneWidget,
    );
  });
}
