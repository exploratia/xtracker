import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/series/data/view/series_data_filter_transition.dart';

void main() {
  testWidgets('fades and slides the filter in and out', (tester) async {
    final visible = ValueNotifier(false);
    var hiddenCount = 0;
    addTearDown(visible.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: visible,
          builder: (context, isVisible, _) => SeriesDataFilterTransition(
            visible: isVisible,
            onHidden: () => hiddenCount++,
            child: const Text('filter'),
          ),
        ),
      ),
    );

    FadeTransition fade() => tester.widget(
      find.descendant(of: find.byType(SeriesDataFilterTransition), matching: find.byType(FadeTransition)),
    );
    SlideTransition slide() => tester.widget(
      find.descendant(of: find.byType(SeriesDataFilterTransition), matching: find.byType(SlideTransition)),
    );
    IgnorePointer pointerGuard() => tester.widget(
      find.descendant(of: find.byType(SeriesDataFilterTransition), matching: find.byType(IgnorePointer)),
    );

    expect(fade().opacity.value, 0);
    expect(slide().position.value, const Offset(0, 0.08));
    expect(pointerGuard().ignoring, isTrue);

    visible.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(fade().opacity.value, greaterThan(0));
    expect(fade().opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 100));
    expect(fade().opacity.value, 1);
    expect(slide().position.value, Offset.zero);
    expect(pointerGuard().ignoring, isFalse);

    visible.value = false;
    await tester.pump();
    expect(pointerGuard().ignoring, isTrue);
    await tester.pump(const Duration(milliseconds: 199));
    expect(hiddenCount, 0);

    await tester.pump(const Duration(milliseconds: 2));
    expect(fade().opacity.value, 0);
    expect(hiddenCount, 1);
  });
}
