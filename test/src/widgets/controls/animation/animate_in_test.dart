import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/animation/animate_in.dart';

void main() {
  testWidgets('waits for its delay and then completes the entrance animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimateIn(
          durationMS: 200,
          delayMS: 100,
          slideOffset: Offset(0, 0.2),
          child: SizedBox(),
        ),
      ),
    );

    final animateIn = find.byType(AnimateIn);
    final fade = find.descendant(of: animateIn, matching: find.byType(FadeTransition));
    final slide = find.descendant(of: animateIn, matching: find.byType(SlideTransition));

    FadeTransition fadeTransition() => tester.widget<FadeTransition>(fade);
    SlideTransition slideTransition() => tester.widget<SlideTransition>(slide);

    expect(fadeTransition().opacity.value, 0);
    expect(slideTransition().position.value, const Offset(0, 0.2));

    await tester.pump(const Duration(milliseconds: 99));
    expect(fadeTransition().opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(fadeTransition().opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(fadeTransition().opacity.value, greaterThan(0));
    expect(fadeTransition().opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 100));
    expect(fadeTransition().opacity.value, 1);
    expect(slideTransition().position.value, Offset.zero);
  });
}
