import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/date_time_utils.dart';
import 'package:xtracker/src/util/theme_utils.dart';
import 'package:xtracker/src/widgets/series/data/input/date_time_scrub_overlay.dart';
import 'package:xtracker/src/widgets/series/data/input/input_header.dart';

void main() {
  final initial = DateTime(2026, 10, 26, 14, 45);
  final preview = find.byKey(const ValueKey('dateTimeScrubPreview'));

  setUpAll(() {
    final translations = jsonDecode(File('assets/translations/en-US.json').readAsStringSync()) as Map<String, dynamic>;
    Localization.load(const Locale('en', 'US'), translations: Translations(translations));
  });

  Future<void> pumpHeader(WidgetTester tester, ValueChanged<DateTime> onChanged, {bool dialog = false, ThemeData? theme}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final header = InputHeader(dateTime: initial, setDateTime: onChanged);
              return dialog
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(content: header),
                        ),
                        child: const Text('open'),
                      ),
                    )
                  : Center(child: header);
            },
          ),
        ),
      ),
    );
    if (dialog) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }
  }

  Future<TestGesture> hold(WidgetTester tester, {bool time = false}) async {
    final target = find.text(time ? DateTimeUtils.formatTime(initial) : DateTimeUtils.formatDate(initial));
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
    return gesture;
  }

  testWidgets('tapping still opens the date and time pickers', (tester) async {
    await pumpHeader(tester, (_) {});
    await tester.tap(find.text(DateTimeUtils.formatDate(initial)));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text(DateTimeUtils.formatTime(initial)));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('only the preview changes during a drag and release commits once', (tester) async {
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add, dialog: true);
    final gesture = await hold(tester);
    await gesture.moveTo(const Offset(400, 24));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(find.text(DateTimeUtils.formatDate(initial)), findsOneWidget);
    expect(tester.widget<Text>(preview).data, DateTimeUtils.formatDateWithDay(initial.copyWith(day: 38)));
    expect(find.byType(DatePickerDialog), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [initial.copyWith(day: 38)]);
    expect(preview, findsNothing);
  });

  testWidgets('time drag combines both axes and previews the adjacent date', (tester) async {
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add);
    final gesture = await hold(tester, time: true);
    await gesture.moveTo(const Offset(776, 24));
    await tester.pumpAndSettle();
    final expected = DateTime(2026, 10, 27, 3, 15);
    expect(changes, isEmpty);
    expect(tester.widget<Text>(preview).data, '${DateTimeUtils.formatDate(expected)}\n${DateTimeUtils.formatTime(expected)}');
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [expected]);
  });

  testWidgets('preview glides down when the finger approaches it', (tester) async {
    await pumpHeader(tester, (_) {});
    final gesture = await hold(tester);
    await tester.pumpAndSettle();
    final bounds = tester.widget<DateTimeScrubOverlay>(find.byType(DateTimeScrubOverlay)).bounds;
    final top = tester.getCenter(preview).dy;
    expect(top, closeTo(bounds.top + bounds.height / 6, 1));
    await gesture.moveTo(Offset(400, top + 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final intermediate = tester.getCenter(preview).dy;
    // Updating the preview during the transition must keep the slide running.
    await gesture.moveTo(Offset(400, top + 25));
    await tester.pump(const Duration(milliseconds: 100));
    final continued = tester.getCenter(preview).dy;
    await tester.pumpAndSettle();
    final bottom = tester.getCenter(preview).dy;
    expect(intermediate, greaterThan(top));
    expect(intermediate, lessThan(bottom));
    expect(continued, greaterThan(intermediate));
    expect(continued, lessThan(bottom));
    expect(bottom, closeTo(bounds.top + bounds.height * 5 / 6, 1));

    await gesture.moveTo(const Offset(400, 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final returning = tester.getCenter(preview).dy;
    expect(returning, greaterThan(top));
    expect(returning, lessThan(bottom));
    await tester.pumpAndSettle();
    expect(tester.getCenter(preview).dy, closeTo(top, 1));
    await gesture.cancel();
    await tester.pumpAndSettle();
  });

  for (final dark in [false, true]) {
    testWidgets('preview uses readable card surfaces in the ${dark ? 'dark' : 'light'} theme', (tester) async {
      await pumpHeader(tester, (_) {});
      final theme = ThemeUtils.buildThemeData(tester.element(find.byType(InputHeader)), dark);
      await pumpHeader(tester, (_) {}, theme: theme);
      final gesture = await hold(tester, time: true);
      await tester.pumpAndSettle();
      final scheme = theme.colorScheme;
      final previewMaterial = tester.widget<Material>(find.ancestor(of: preview, matching: find.byType(Material)).first);
      expect(previewMaterial.color, theme.cardTheme.color);
      expect(tester.widget<Text>(preview).style?.color, scheme.onSurface);

      final hintMaterial = tester.widget<Material>(
        find.ancestor(of: find.byIcon(Icons.arrow_upward), matching: find.byType(Material)).first,
      );
      expect(hintMaterial.color, scheme.surfaceContainerHighest);
      final surfaces = [
        scheme.surfaceContainerLowest,
        scheme.surface,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
      ];
      for (var i = 0; i < surfaces.length; ++i) {
        final luminance = surfaces[i].computeLuminance();
        final textLuminance = scheme.onSurface.computeLuminance();
        final contrast = dark ? (textLuminance + 0.05) / (luminance + 0.05) : (luminance + 0.05) / (textLuminance + 0.05);
        expect(contrast, greaterThanOrEqualTo(4.5));
        if (i > 0) {
          final previous = surfaces[i - 1].computeLuminance();
          expect(luminance, dark ? greaterThan(previous) : lessThan(previous));
        }
      }
      await gesture.cancel();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('cancellation and returning to the origin discard the change', (tester) async {
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add);
    final gesture = await hold(tester);
    final origin = tester.getCenter(find.text(DateTimeUtils.formatDate(initial)));
    await gesture.moveTo(const Offset(400, 24));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(preview, findsNothing);

    final returning = await hold(tester);
    await returning.moveTo(const Offset(400, 24));
    await returning.moveTo(origin);
    await returning.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(preview, findsNothing);
  });

  testWidgets('removing the input during a drag removes its overlay', (tester) async {
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add);
    final gesture = await hold(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DateTimeScrubOverlay), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(preview, findsNothing);
    expect(changes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding the app cancels without applying the preview', (tester) async {
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add);
    final gesture = await hold(tester);
    await gesture.moveTo(const Offset(400, 24));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    await gesture.up();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(preview, findsNothing);
    expect(changes, isEmpty);
  });

  for (final size in [const Size(360, 800), const Size(800, 360), const Size(1200, 800)]) {
    testWidgets('gesture fits a ${size.width} by ${size.height} screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final changes = <DateTime>[];
      await pumpHeader(tester, changes.add, dialog: true);
      final gesture = await hold(tester, time: true);
      await gesture.moveTo(Offset(size.width - 24, 24));
      await tester.pumpAndSettle();
      final previewRect = tester.getRect(preview);
      expect(previewRect.top, greaterThanOrEqualTo(24));
      expect(previewRect.bottom, lessThanOrEqualTo(size.height - 24));
      expect(previewRect.left, greaterThanOrEqualTo(24));
      expect(previewRect.right, lessThanOrEqualTo(size.width - 24));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changes, [DateTime(2026, 10, 27, 3, 15)]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('hints and preview stay above the software keyboard', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final changes = <DateTime>[];
    await pumpHeader(tester, changes.add);
    final gesture = await hold(tester, time: true);
    await gesture.moveTo(const Offset(376, 476));
    await tester.pumpAndSettle();
    expect(tester.getRect(preview).bottom, lessThan(500));
    final overlay = tester.widget<DateTimeScrubOverlay>(find.byType(DateTimeScrubOverlay));
    expect(overlay.bounds.bottom, 476);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [DateTime(2026, 10, 26, 3, 15)]);
  });
}
