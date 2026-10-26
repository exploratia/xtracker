import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/motion_utils.dart';

/// Displays gesture directions and a preview without dimming the input dialog.
class DateTimeScrubOverlay extends StatefulWidget {
  const DateTimeScrubOverlay({
    super.key,
    required this.value,
    required this.finger,
    required this.bounds,
    required this.isTime,
  });

  final DateTime value;
  final Offset finger;
  final Rect bounds;
  final bool isTime;

  @override
  State<DateTimeScrubOverlay> createState() => _DateTimeScrubOverlayState();
}

class _DateTimeScrubOverlayState extends State<DateTimeScrubOverlay> {
  bool _previewAtBottom = false;

  @override
  void initState() {
    super.initState();
    _updatePreviewPosition();
  }

  @override
  void didUpdateWidget(DateTimeScrubOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePreviewPosition();
  }

  void _updatePreviewPosition() {
    final topPreview = widget.bounds.top + widget.bounds.height / 6;
    // Hysteresis prevents the preview from oscillating near the boundary.
    if (widget.finger.dy < topPreview + 80) {
      _previewAtBottom = true;
    } else if (widget.finger.dy > topPreview + 140) {
      _previewAtBottom = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bounds = widget.bounds;
    final verticalUnit = (widget.isTime ? LocaleKeys.commons_date_scrub_hours : LocaleKeys.commons_date_scrub_days).tr();

    return Positioned.fromRect(
      rect: bounds,
      child: IgnorePointer(
        child: Stack(
          children: [
            Align(alignment: Alignment.topCenter, child: _hint(context, Icons.arrow_upward, '+12 $verticalUnit')),
            Align(alignment: Alignment.bottomCenter, child: _hint(context, Icons.arrow_downward, '−12 $verticalUnit')),
            if (widget.isTime) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: _hint(context, Icons.arrow_back, '−30 ${LocaleKeys.commons_date_scrub_minutes.tr()}'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _hint(context, Icons.arrow_forward, '+30 ${LocaleKeys.commons_date_scrub_minutes.tr()}'),
              ),
            ],
            AnimatedAlign(
              duration: MotionUtils.resolve(context, MotionUtils.routeTransition),
              curve: Curves.easeInOutCubic,
              alignment: _previewAtBottom ? Alignment.bottomCenter : Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.85,
                heightFactor: 1 / 3,
                child: Center(
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        widget.isTime
                            ? '${DateTimeUtils.formatDate(widget.value)}\n${DateTimeUtils.formatTime(widget.value)}'
                            : DateTimeUtils.formatDateWithDay(widget.value),
                        key: const ValueKey('dateTimeScrubPreview'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurface),
            Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
