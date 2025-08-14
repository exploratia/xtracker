import 'dart:async';

import 'package:flutter/material.dart';

class LazyTooltip extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext) tooltipBuilder;
  final Duration showDelay;
  final Duration hideDelay;

  const LazyTooltip({
    super.key,
    required this.child,
    required this.tooltipBuilder,
    this.showDelay = const Duration(milliseconds: 300),
    this.hideDelay = Duration.zero,
  });

  @override
  State<LazyTooltip> createState() => _LazyTooltipState();
}

class _LazyTooltipState extends State<LazyTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;

  void _showTooltip(BuildContext context) {
    _hideTimer?.cancel();
    _showTimer = Timer(widget.showDelay, () {
      final overlay = Overlay.of(context);

      final theme = TooltipTheme.of(context);

      // Get position and size of the triggering widget
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      final targetSize = renderBox.size;
      final targetPosition = renderBox.localToGlobal(
        Offset.zero,
        ancestor: overlay.context.findRenderObject(),
      );

      // Create tooltip content for measurement
      final tooltipKey = GlobalKey();
      final tooltipContent = Material(
        color: Colors.transparent,
        child: Container(
          key: tooltipKey,
          padding: theme.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: theme.decoration ??
              BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
          child: DefaultTextStyle(
            style: theme.textStyle ?? const TextStyle(color: Colors.white, fontSize: 12),
            child: widget.tooltipBuilder(context),
          ),
        ),
      );

      // Step 1: Insert off-screen for measurement
      final measureEntry = OverlayEntry(
        builder: (_) => Align(
          alignment: Alignment.topLeft,
          child: Offstage(child: tooltipContent),
        ),
      );
      overlay.insert(measureEntry);

      // Step 2: Measure after the frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tooltipBox = tooltipKey.currentContext?.findRenderObject() as RenderBox?;
        if (tooltipBox == null || !tooltipBox.hasSize) {
          measureEntry.remove();
          return;
        }
        final tooltipSize = tooltipBox.size;
        measureEntry.remove();

        // Step 3: Calculate final position
        final pos = _calculateSmartPosition(
          context,
          targetPosition,
          targetSize,
          tooltipSize,
        );

        // Step 4: Insert actual tooltip
        _overlayEntry = OverlayEntry(
          builder: (_) => SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: tooltipContent,
                ),
              ],
            ),
          ),
        );
        overlay.insert(_overlayEntry!);
      });
    });
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    _hideTimer = Timer(widget.hideDelay, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  /// Smart positioning with SafeArea and edge detection
  Offset _calculateSmartPosition(
    BuildContext context,
    Offset targetPos,
    Size targetSize,
    Size tooltipSize,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final safeLeft = mediaQuery.padding.left + 8;
    final safeRight = screenWidth - mediaQuery.padding.right - 8;
    final safeTop = mediaQuery.padding.top + 8;
    final safeBottom = screenHeight - mediaQuery.padding.bottom - 8;

    // Horizontal centering with clamp
    double left = targetPos.dx + targetSize.width / 2 - tooltipSize.width / 2;
    if (left < safeLeft) left = safeLeft;
    if (left + tooltipSize.width > safeRight) {
      left = safeRight - tooltipSize.width;
    }

    // Decide top/bottom
    final spaceAbove = targetPos.dy - safeTop;
    final spaceBelow = safeBottom - (targetPos.dy + targetSize.height);

    double top;
    if (tooltipSize.height <= spaceAbove) {
      // Above
      top = targetPos.dy - tooltipSize.height - 8;
    } else if (tooltipSize.height <= spaceBelow) {
      // Below
      top = targetPos.dy + targetSize.height + 8;
    } else {
      // Not enough space → choose larger side
      if (spaceAbove > spaceBelow) {
        top = safeTop;
      } else {
        top = safeBottom - tooltipSize.height;
      }
    }

    return Offset(left, top);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showTooltip(context),
      onExit: (_) => _hideTooltip(),
      child: GestureDetector(
        onLongPressStart: (_) => _showTooltip(context),
        onLongPressEnd: (_) => _hideTooltip(),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }
}
