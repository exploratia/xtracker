import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xtracker/src/providers/series_data_provider.dart';
import 'package:xtracker/src/widgets/series/data/view/series_data_mutation_transition.dart';

void main() {
  for (final mutationType in [SeriesDataMutationType.inserted, SeriesDataMutationType.updated]) {
    testWidgets('highlights an ${mutationType.name} value and returns to transparent', (tester) async {
      final provider = _TestSeriesDataProvider();
      await tester.pumpWidget(_TestApp(provider: provider));

      provider.publish(mutationType);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_highlightColor(tester).a, greaterThan(0));

      await tester.pump(SeriesDataMutation.highlightDuration);
      expect(_highlightColor(tester).a, 0);
    });
  }

  testWidgets('fades and collapses a deleted value', (tester) async {
    final provider = _TestSeriesDataProvider();
    await tester.pumpWidget(_TestApp(provider: provider));

    provider.publish(SeriesDataMutationType.deleted);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final fade = tester.widget<FadeTransition>(
      find.descendant(of: find.byType(SeriesDataMutationTransition), matching: find.byType(FadeTransition)),
    );
    final size = tester.widget<SizeTransition>(
      find.descendant(of: find.byType(SeriesDataMutationTransition), matching: find.byType(SizeTransition)),
    );
    expect(fade.opacity.value, greaterThan(0));
    expect(fade.opacity.value, lessThan(1));
    expect(size.sizeFactor.value, fade.opacity.value);

    await tester.pump(const Duration(milliseconds: 100));
    expect(fade.opacity.value, 0);
    expect(size.sizeFactor.value, 0);
  });

  testWidgets('keeps its child expanded to the available cell size', (tester) async {
    final provider = _TestSeriesDataProvider();
    var tapCount = 0;
    await tester.pumpWidget(
      _TestApp(
        provider: provider,
        child: InkWell(
          onTap: () => tapCount++,
          child: const Icon(Icons.check_box_outlined),
        ),
      ),
    );

    final transitionFinder = find.byType(SeriesDataMutationTransition);
    final coloredBoxFinder = find.descendant(of: transitionFinder, matching: find.byType(ColoredBox));
    final inkWellFinder = find.descendant(of: transitionFinder, matching: find.byType(InkWell));

    expect(tester.getSize(coloredBoxFinder), const Size(100, 40));
    expect(tester.getSize(inkWellFinder), const Size(100, 40));

    await tester.tapAt(tester.getTopLeft(transitionFinder) + const Offset(95, 20));
    expect(tapCount, 1);
  });
}

Color _highlightColor(WidgetTester tester) {
  final coloredBox = tester.widget<ColoredBox>(
    find.descendant(of: find.byType(SeriesDataMutationTransition), matching: find.byType(ColoredBox)),
  );
  return coloredBox.color;
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.provider, this.child = const SizedBox.expand()});

  final _TestSeriesDataProvider provider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SeriesDataProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 40,
              child: SeriesDataMutationTransition(
                valueUuids: const {'value-id'},
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestSeriesDataProvider extends SeriesDataProvider {
  SeriesDataMutation? mutation;
  int version = 0;

  @override
  SeriesDataMutation? get latestMutation => mutation;

  void publish(SeriesDataMutationType type) {
    mutation = SeriesDataMutation(
      seriesUuid: 'series-id',
      valueUuid: 'value-id',
      type: type,
      version: ++version,
    );
    notifyListeners();
  }
}
