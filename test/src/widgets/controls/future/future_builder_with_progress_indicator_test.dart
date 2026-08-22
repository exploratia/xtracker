import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/future/future_builder_with_progress_indicator.dart';

void main() {
  testWidgets('crossfades from the loading indicator to content', (tester) async {
    final completer = Completer<String>();

    await tester.pumpWidget(
      MaterialApp(
        home: FutureBuilderWithProgressIndicator(
          future: completer.future,
          widgetBuilder: (data, _) => Text(data),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('loaded'), findsNothing);

    completer.complete('loaded');
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('loaded'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AnimatedSwitcher), matching: find.byType(FadeTransition)),
      findsNWidgets(2),
    );

    await tester.pump(const Duration(milliseconds: 151));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('loaded'), findsOneWidget);
  });
}
