import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/animation/fade_in.dart';

void main() {
  testWidgets('uses a short default fade duration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FadeIn(child: Text('empty state')),
      ),
    );

    final fadeFinder = find.descendant(of: find.byType(FadeIn), matching: find.byType(FadeTransition));
    FadeTransition fade() => tester.widget(fadeFinder);

    expect(fade().opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 125));
    expect(fade().opacity.value, greaterThan(0));
    expect(fade().opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 125));
    expect(fade().opacity.value, 1);
  });

  testWidgets('shows content immediately when animations are disabled', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: FadeIn(child: Text('empty state')),
        ),
      ),
    );

    final fade = tester.widget<FadeTransition>(
      find.descendant(of: find.byType(FadeIn), matching: find.byType(FadeTransition)),
    );
    expect(fade.opacity.value, 1);
  });
}
