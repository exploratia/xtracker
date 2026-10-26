import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/date_time_scrub.dart';
import '../../../../util/theme_utils.dart';
import 'date_time_scrub_overlay.dart';

/// Adds deferred long-press editing to a date or time picker field.
class DateTimeScrubField extends StatefulWidget {
  const DateTimeScrubField({
    super.key,
    required this.value,
    required this.isTime,
    required this.onChanged,
    required this.onTap,
    required this.firstDate,
    required this.lastDate,
    required this.child,
  });

  final DateTime value;
  final bool isTime;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onTap;
  final DateTime firstDate;
  final DateTime lastDate;
  final Widget child;

  @override
  State<DateTimeScrubField> createState() => _DateTimeScrubFieldState();
}

class _DateTimeScrubFieldState extends State<DateTimeScrubField> with WidgetsBindingObserver {
  OverlayEntry? _entry;
  DateTimeScrub? _scrub;
  RenderBox? _overlayBox;
  DateTime? _preview;
  Offset _finger = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _cancel();
  }

  @override
  void didChangeMetrics() => _cancel();

  void _start(LongPressStartDetails details) {
    _cancel();
    final overlay = Overlay.of(context, rootOverlay: true);
    final box = overlay.context.findRenderObject() as RenderBox;
    final media = MediaQuery.of(overlay.context);
    // Use the visible screen, including safe areas and the software keyboard.
    final visible = Rect.fromLTRB(
      media.viewPadding.left,
      media.viewPadding.top,
      box.size.width - media.viewPadding.right,
      box.size.height - math.max(media.viewPadding.bottom, media.viewInsets.bottom),
    );
    final bounds = visible.deflate(math.min(24, visible.shortestSide / 8));
    _overlayBox = box;
    _finger = box.globalToLocal(details.globalPosition);
    _scrub = DateTimeScrub(
      initialValue: widget.value,
      origin: _finger,
      bounds: bounds,
      isTime: widget.isTime,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    _preview = widget.value;
    final themes = InheritedTheme.capture(from: context, to: overlay.context);
    _entry = OverlayEntry(
      builder: (_) => themes.wrap(
        DateTimeScrubOverlay(value: _preview!, finger: _finger, bounds: bounds, isTime: widget.isTime),
      ),
    );
    overlay.insert(_entry!);
    HapticFeedback.selectionClick();
  }

  void _move(Offset globalPosition) {
    if (_scrub == null) return;
    _finger = _overlayBox!.globalToLocal(globalPosition);
    _preview = _scrub!.valueAt(_finger);
    _entry?.markNeedsBuild();
  }

  void _finish(LongPressEndDetails details) {
    if (_scrub == null) return;
    _move(details.globalPosition);
    final value = _preview!;
    final initialValue = _scrub!.initialValue;
    _cancel();
    if (value != initialValue) widget.onChanged(value);
  }

  void _cancel() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    _scrub = null;
    _overlayBox = null;
    _preview = null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: (widget.isTime ? LocaleKeys.commons_date_scrub_timeGesture : LocaleKeys.commons_date_scrub_dateGesture).tr(),
      child: GestureDetector(
        onLongPressStart: _start,
        onLongPressMoveUpdate: (details) => _move(details.globalPosition),
        onLongPressEnd: _finish,
        onLongPressCancel: _cancel,
        child: InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: widget.onTap,
          child: Padding(padding: const EdgeInsets.all(2), child: widget.child),
        ),
      ),
    );
  }
}
