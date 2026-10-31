import 'dart:async';

import 'package:flutter/material.dart';

import '../../../model/wallpaper_style.dart';
import 'wallpaper_day_cycle.dart';
import 'wallpaper_scene.dart';

/// Refreshes clock-based scenery only while the route and app are active.
class LiveWallpaperRefresh extends StatefulWidget {
  const LiveWallpaperRefresh({
    super.key,
    this.intervalInSeconds = 60,
    this.speedFactor = 1,
    this.style = WallpaperStyle.hills,
  }) : assert(intervalInSeconds > 0),
       assert(speedFactor > 0);

  final int intervalInSeconds;
  final int speedFactor;
  final WallpaperStyle style;

  @override
  State<LiveWallpaperRefresh> createState() => _LiveWallpaperRefreshState();
}

class _LiveWallpaperRefreshState extends State<LiveWallpaperRefresh> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchronizeTimer();
  }

  @override
  void didUpdateWidget(covariant LiveWallpaperRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intervalInSeconds != widget.intervalInSeconds || oldWidget.speedFactor != widget.speedFactor) {
      _synchronizeTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _synchronizeTimer();
    if (state == AppLifecycleState.resumed && TickerMode.valuesOf(context).enabled) {
      setState(() => _now = DateTime.now());
    }
  }

  void _synchronizeTimer() {
    _timer?.cancel();
    _timer = null;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (!TickerMode.valuesOf(context).enabled || (lifecycle != null && lifecycle != AppLifecycleState.resumed)) return;
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: widget.intervalInSeconds), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WallpaperScene(
    style: widget.style,
    percentOfDay: WallpaperDayCycle.fractionAt(_now, speedFactor: widget.speedFactor),
  );
}
