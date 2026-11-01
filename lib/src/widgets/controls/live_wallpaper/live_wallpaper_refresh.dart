import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../model/wallpaper_style.dart';
import '../../../util/wallpaper/wallpaper_image_lighting.dart';
import 'wallpaper_day_cycle.dart';
import 'wallpaper_scene.dart';

/// Refreshes wallpaper lighting only while the route and app are active.
class LiveWallpaperRefresh extends StatefulWidget {
  const LiveWallpaperRefresh({
    super.key,
    int? intervalInSeconds,
    this.speedFactor = 1,
    this.style = WallpaperStyle.hills,
    this.image,
    this.imageLighting = const WallpaperImageLighting(luminance: 0),
  }) : _intervalInSeconds = intervalInSeconds,
       assert(intervalInSeconds == null || intervalInSeconds > 0),
       assert(speedFactor > 0);

  final int? _intervalInSeconds;

  /// Refreshes photos every five minutes and live motifs every minute by default.
  int get intervalInSeconds => _intervalInSeconds ?? (style == WallpaperStyle.customImage ? 300 : 60);
  final int speedFactor;
  final WallpaperStyle style;

  /// Selected photo when [style] is [WallpaperStyle.customImage].
  final Uint8List? image;

  /// Previously sampled lighting, reused on every timer tick.
  final WallpaperImageLighting imageLighting;

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
    image: widget.image,
    imageLighting: widget.imageLighting,
    percentOfDay: WallpaperDayCycle.fractionAt(_now, speedFactor: widget.speedFactor),
  );
}
