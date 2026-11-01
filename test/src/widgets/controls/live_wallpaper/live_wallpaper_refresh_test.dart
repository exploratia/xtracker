import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper_refresh.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/wallpaper_scene.dart';

void main() {
  testWidgets('custom images refresh every five minutes and motif changes reset the interval', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final style = ValueNotifier(WallpaperStyle.customImage);
    addTearDown(style.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: style,
          builder: (context, value, child) => LiveWallpaperRefresh(style: value),
        ),
      ),
    );
    final initial = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(minutes: 4, seconds: 59));
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), same(initial));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), isNot(same(initial)));

    style.value = WallpaperStyle.hills;
    await tester.pump();
    final live = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(minutes: 1));
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), isNot(same(live)));

    style.value = WallpaperStyle.customImage;
    await tester.pump();
    final custom = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(minutes: 1));
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), same(custom));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 10));
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), same(custom));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), isNot(same(custom)));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('does not refresh every frame or restart its timer on parent rebuilds', (tester) async {
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: rebuild,
          builder: (context, value, child) => LiveWallpaperRefresh(key: const ValueKey('wallpaper'), style: WallpaperStyle.values[value % 2]),
        ),
      ),
    );
    final initial = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(seconds: 30));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), initial), isTrue);
    rebuild.value++;
    await tester.pump();
    final afterParentBuild = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(seconds: 31));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), afterParentBuild), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pauses in the background and refreshes immediately on resume', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const MaterialApp(home: LiveWallpaperRefresh()));
    final initial = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 3));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), initial), isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    final resumed = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    expect(identical(resumed, initial), isFalse);
    await tester.pump(const Duration(seconds: 61));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), resumed), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pauses on hidden routes and cancels timers when removed', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: visible,
          builder: (context, enabled, child) => TickerMode(enabled: enabled, child: const LiveWallpaperRefresh()),
        ),
      ),
    );
    visible.value = false;
    await tester.pump();
    final hidden = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    await tester.pump(const Duration(minutes: 3));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), hidden), isTrue);
    visible.value = true;
    await tester.pump();
    final resumed = tester.widget<WallpaperScene>(find.byType(WallpaperScene));
    expect(identical(resumed, hidden), isFalse);
    await tester.pump(const Duration(seconds: 61));
    expect(identical(tester.widget<WallpaperScene>(find.byType(WallpaperScene)), resumed), isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 3));
    expect(tester.takeException(), isNull);
  });
}
