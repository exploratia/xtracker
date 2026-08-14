import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/motion_utils.dart';

void main() {
  testWidgets('resolves motion durations from media accessibility settings', (tester) async {
    late BuildContext enabledContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            enabledContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(MotionUtils.resolve(enabledContext, MotionUtils.complex), MotionUtils.complex);

    late BuildContext disabledContext;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              disabledContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(MotionUtils.animationsDisabled(disabledContext), isTrue);
    expect(MotionUtils.resolve(disabledContext, MotionUtils.complex), Duration.zero);
  });
}
