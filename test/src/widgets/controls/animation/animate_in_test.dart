import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/animation/animate_in.dart';

void main() {
  testWidgets('waits for its delay and then completes the entrance animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimateIn(
          duration: Duration(milliseconds: 200),
          delay: Duration(milliseconds: 100),
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

  testWidgets('skips entrance delay when animations are disabled', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: AnimateIn(
            delay: Duration(seconds: 1),
            slideOffset: Offset(0, 0.2),
            child: SizedBox(),
          ),
        ),
      ),
    );

    final animateIn = find.byType(AnimateIn);
    final fade = tester.widget<FadeTransition>(
      find.descendant(of: animateIn, matching: find.byType(FadeTransition)),
    );
    final slide = tester.widget<SlideTransition>(
      find.descendant(of: animateIn, matching: find.byType(SlideTransition)),
    );
    expect(fade.opacity.value, 1);
    expect(slide.position.value, Offset.zero);
  });
}
