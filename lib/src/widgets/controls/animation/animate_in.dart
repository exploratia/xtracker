import 'dart:async';

import 'package:flutter/material.dart';

class AnimateIn extends StatefulWidget {
  final Widget child;
  final int durationMS;
  final int delayMS;
  final bool fade;
  final Offset? slideOffset;

  const AnimateIn({
    super.key,
    required this.child,
    this.durationMS = 220,
    this.delayMS = 0,
    this.fade = true,
    this.slideOffset,
  });

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: widget.durationMS),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: widget.slideOffset ?? const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delayMS <= 0) {
      _controller.forward();
      return;
    }

    _delayTimer = Timer(
      Duration(milliseconds: widget.delayMS),
      _controller.forward,
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget w = widget.child;

    if (widget.fade) {
      w = FadeTransition(
        opacity: _animation,
        child: w,
      );
    }

    if (widget.slideOffset != null) {
      w = SlideTransition(
        position: _offsetAnimation,
        child: w,
      );
    }

    return w;
  }
}
