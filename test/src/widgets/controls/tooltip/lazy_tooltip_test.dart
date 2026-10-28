import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/tooltip/lazy_tooltip.dart';

void main() {
  const message = 'Show very large positive and negative changes as gaps once five deltas are available. Genuine large changes may also be hidden.';
  final cases = [
    (width: 240.0, padding: const EdgeInsets.only(left: 24, right: 12), maxWidth: 300.0, scale: 1.5, alignment: Alignment.centerRight),
    (width: 320.0, padding: EdgeInsets.zero, maxWidth: 200.0, scale: 1.0, alignment: Alignment.centerLeft),
    (width: 1200.0, padding: EdgeInsets.zero, maxWidth: null, scale: 1.0, alignment: Alignment.center),
  ];

  for (final scenario in cases) {
    testWidgets('wraps long tooltips within the safe viewport at width ${scenario.width}', (tester) async {
      tester.view.physicalSize = Size(scenario.width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            tooltipTheme: TooltipThemeData(constraints: scenario.maxWidth == null ? null : BoxConstraints(maxWidth: scenario.maxWidth!)),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(padding: scenario.padding, textScaler: TextScaler.linear(scenario.scale)),
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: scenario.alignment,
              child: LazyTooltip(
                showDelay: Duration.zero,
                animationDuration: Duration.zero,
                tooltipBuilder: (_) => const Text(message),
                child: const SizedBox(width: 80, height: 48, child: Text('Target')),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(find.text('Target')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pumpAndSettle();

      final text = find.text(message);
      expect(text, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(text);
      final lines = paragraph.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: message.length));
      expect(lines.length, greaterThan(1));
      expect(paragraph.didExceedMaxLines, isFalse);
      final tooltip = find.ancestor(of: text, matching: find.byType(Container)).first;
      final bounds = tester.getRect(tooltip);
      expect(bounds.left, greaterThanOrEqualTo(scenario.padding.left));
      expect(bounds.right, lessThanOrEqualTo(scenario.width - scenario.padding.right));
      expect(bounds.width, lessThanOrEqualTo(scenario.maxWidth ?? 300));
      expect(tester.takeException(), isNull);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  }
}
