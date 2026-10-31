import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/future/future_builder_with_progress_indicator.dart';
import 'package:xtracker/src/widgets/controls/layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import 'package:xtracker/src/widgets/controls/provider/data_provider_loader.dart';

void main() {
  testWidgets('rebuilding loaded content preserves the scroll area and touch scrolling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final future = Future<void>.value();
    final revision = ValueNotifier(0);
    addTearDown(revision.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: revision,
            builder: (context, value, _) => DataProviderLoader(
              obtainDataProviderFuture: future,
              child: VCenteredSingleChildScrollViewWithScrollbar(
                scrollController: controller,
                onRefreshCallback: () async {},
                child: Column(
                  children: List.generate(20, (index) => SizedBox(height: 100, child: Text('Series $index ($value)'))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    final position = controller.position;
    final offset = controller.offset;
    expect(offset, greaterThan(0));

    revision.value++;
    await tester.pump();
    await tester.pump();
    expect(controller.positions, hasLength(1));
    expect(controller.position, same(position));
    expect(controller.offset, offset);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(offset));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling works after a fullscreen dialog and viewport changes', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final future = Future<void>.value();
    final navigatorKey = GlobalKey<NavigatorState>();
    final bottomBarVisible = ValueNotifier(true);
    addTearDown(bottomBarVisible.dispose);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: ValueListenableBuilder(
          valueListenable: bottomBarVisible,
          builder: (context, visible, _) => Scaffold(
            bottomNavigationBar: visible ? const SizedBox(height: kBottomNavigationBarHeight) : null,
            body: DataProviderLoader(
              obtainDataProviderFuture: future,
              child: VCenteredSingleChildScrollViewWithScrollbar(
                scrollController: controller,
                onRefreshCallback: () async {},
                child: Column(
                  children: List.generate(20, (index) => SizedBox(height: 100, child: Text('Series $index'))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final position = controller.position;
    final dialog = showDialog<void>(
      context: tester.element(find.byType(DataProviderLoader)),
      builder: (_) => const Dialog.fullscreen(child: SizedBox.expand()),
    );
    bottomBarVisible.value = false;
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await dialog;
    bottomBarVisible.value = true;
    await tester.pumpAndSettle();

    expect(controller.position, same(position));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a different future still reloads content', (tester) async {
    final first = Completer<void>();
    final second = Completer<void>();
    final future = ValueNotifier(first.future);
    addTearDown(future.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: future,
          builder: (context, currentFuture, _) => VoidFutureBuilderWithProgressIndicator(
            future: currentFuture,
            widgetBuilder: (_) => Text(currentFuture == first.future ? 'First loaded' : 'Second loaded'),
          ),
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    first.complete();
    await tester.pumpAndSettle();
    expect(find.text('First loaded'), findsOneWidget);

    future.value = second.future;
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    second.complete();
    await tester.pumpAndSettle();
    expect(find.text('Second loaded'), findsOneWidget);
    expect(find.text('First loaded'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
