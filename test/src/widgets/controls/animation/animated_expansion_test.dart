import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/animation/animated_expansion.dart';

void main() {
  testWidgets('expands and collapses without RenderAnimatedSize', (tester) async {
    var expanded = false;
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (context, stateSetter) {
                setState = stateSetter;
                return Column(
                  children: [
                    AnimatedExpansion(
                      expanded: expanded,
                      duration: const Duration(milliseconds: 100),
                      child: const SizedBox(key: ValueKey('content'), height: 80),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    final sizeTransitionFinder = find.byType(SizeTransition);
    expect(find.byType(AnimatedSize), findsNothing);
    expect(tester.getSize(sizeTransitionFinder), const Size(200, 0));

    setState(() => expanded = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.getSize(sizeTransitionFinder).height, closeTo(40, 0.1));

    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.getSize(sizeTransitionFinder), const Size(200, 80));

    setState(() => expanded = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getSize(sizeTransitionFinder), const Size(200, 0));
  });
}
