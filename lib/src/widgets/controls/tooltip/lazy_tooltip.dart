import 'dart:async';

import 'package:flutter/material.dart';

class LazyTooltip extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext) tooltipBuilder;
  final Duration showDelay;
  final Duration hideDelay;
  final Duration animationDuration;

  const LazyTooltip({
    super.key,
    required this.child,
    required this.tooltipBuilder,
    this.showDelay = const Duration(milliseconds: 300),
    this.hideDelay = Duration.zero,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<LazyTooltip> createState() => _LazyTooltipState();
}

class _LazyTooltipState extends State<LazyTooltip> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
  }

  void _showTooltip(BuildContext context, {bool isTouch = false}) {
    _hideTimer?.cancel();
    _showTimer = Timer(widget.showDelay, () {
      final overlay = Overlay.of(context);

      final theme = TooltipTheme.of(context);

      // Measure the target widget position
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      final targetSize = renderBox.size;
      final targetPosition = renderBox.localToGlobal(
        Offset.zero,
        ancestor: overlay.context.findRenderObject(),
      );

      // Prepare tooltip content for measurement
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

      // Step 1: measure off-screen
      final measureEntry = OverlayEntry(
        builder: (_) => Align(
          alignment: Alignment.topLeft,
          child: Offstage(child: tooltipContent),
        ),
      );
      overlay.insert(measureEntry);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tooltipBox = tooltipKey.currentContext?.findRenderObject() as RenderBox?;
        if (tooltipBox == null || !tooltipBox.hasSize) {
          measureEntry.remove();
          return;
        }
        final tooltipSize = tooltipBox.size;
        measureEntry.remove();

        // Calculate position with smart edge handling
        final pos = _calculateSmartPosition(
          context,
          targetPosition,
          targetSize,
          tooltipSize,
          isTouch,
        );

        _overlayEntry = OverlayEntry(
          builder: (_) => SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: tooltipContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        overlay.insert(_overlayEntry!);

        // Start animation
        _animController.forward(from: 0);
      });
    });
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    _hideTimer = Timer(widget.hideDelay, () async {
      await _animController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Offset _calculateSmartPosition(
    BuildContext context,
    Offset targetPos,
    Size targetSize,
    Size tooltipSize,
    bool isTouch,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final touchMargin = isTouch ? 24 : 0;

    final safeLeft = mediaQuery.padding.left + 8;
    final safeRight = screenWidth - mediaQuery.padding.right - 8;
    final safeTop = mediaQuery.padding.top + 8 + touchMargin;
    final safeBottom = screenHeight - mediaQuery.padding.bottom - 8 - touchMargin;

    // Horizontal position
    double left = targetPos.dx + targetSize.width / 2 - tooltipSize.width / 2;
    if (left < safeLeft) left = safeLeft;
    if (left + tooltipSize.width > safeRight) {
      left = safeRight - tooltipSize.width;
    }

    // Vertical position (prefer above)
    final spaceAbove = targetPos.dy - safeTop;
    final spaceBelow = safeBottom - (targetPos.dy + targetSize.height);
    double top;
    if (tooltipSize.height <= spaceAbove) {
      top = targetPos.dy - tooltipSize.height - 8 - touchMargin;
    } else if (tooltipSize.height <= spaceBelow) {
      top = targetPos.dy + targetSize.height + 8 + touchMargin;
    } else {
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
        onLongPressStart: (_) => _showTooltip(context, isTouch: true),
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
    _animController.dispose();
    super.dispose();
  }
}
