import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/providers/series_provider.dart';
import 'package:xtracker/src/widgets/series/series_mutation_transition.dart';

void main() {
  testWidgets('fades and expands an inserted series', (tester) async {
    const mutation = SeriesMutation(
      seriesUuid: 'series-id',
      type: SeriesMutationType.inserted,
      version: 1,
    );

    await tester.pumpWidget(const _TestApp(mutation: mutation));

    expect(_fade(tester).opacity.value, 0);
    expect(_size(tester).sizeFactor.value, 0);

    await tester.pump(const Duration(milliseconds: 110));
    expect(_fade(tester).opacity.value, greaterThan(0));
    expect(_fade(tester).opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 110));
    expect(_fade(tester).opacity.value, 1);
    expect(_size(tester).sizeFactor.value, 1);
  });

  testWidgets('fades and collapses a deleted series', (tester) async {
    final mutation = ValueNotifier<SeriesMutation?>(null);
    addTearDown(mutation.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: mutation,
        builder: (context, currentMutation, _) => _TestApp(mutation: currentMutation),
      ),
    );

    mutation.value = const SeriesMutation(
      seriesUuid: 'series-id',
      type: SeriesMutationType.deleted,
      version: 1,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));

    expect(_fade(tester).opacity.value, greaterThan(0));
    expect(_fade(tester).opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 110));
    expect(_fade(tester).opacity.value, 0);
    expect(_size(tester).sizeFactor.value, 0);
  });

  testWidgets('ignores a mutation for another series', (tester) async {
    const mutation = SeriesMutation(
      seriesUuid: 'other-series-id',
      type: SeriesMutationType.deleted,
      version: 1,
    );

    await tester.pumpWidget(const _TestApp(mutation: mutation));
    await tester.pump(SeriesMutation.transitionDuration);

    expect(_fade(tester).opacity.value, 1);
    expect(_size(tester).sizeFactor.value, 1);
  });
}

FadeTransition _fade(WidgetTester tester) => tester.widget(
  find.descendant(of: find.byType(SeriesMutationTransition), matching: find.byType(FadeTransition)),
);

SizeTransition _size(WidgetTester tester) => tester.widget(
  find.descendant(of: find.byType(SeriesMutationTransition), matching: find.byType(SizeTransition)),
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.mutation});

  final SeriesMutation? mutation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SeriesMutationTransition(
        seriesUuid: 'series-id',
        mutation: mutation,
        child: const SizedBox(width: 100, height: 40),
      ),
    );
  }
}
