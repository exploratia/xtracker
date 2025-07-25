import 'package:flutter/material.dart';

class AnimatedHighlightContainer<T> extends StatefulWidget {
  final T Function(BuildContext) valueSelector;
  final Widget Function(BuildContext, T) builder;
  final Duration duration;
  final Color highlightColor;
  final Color baseColor;

  const AnimatedHighlightContainer({
    super.key,
    required this.valueSelector,
    required this.builder,
    this.duration = const Duration(milliseconds: 600),
    this.highlightColor = const Color(0xFFE0F7FA),
    this.baseColor = Colors.transparent,
  });

  @override
  State<AnimatedHighlightContainer<T>> createState() => _AnimatedHighlightState<T>();
}

class _AnimatedHighlightState<T> extends State<AnimatedHighlightContainer<T>> {
  late T _lastValue;
  bool _highlight = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastValue = widget.valueSelector(context);
  }

  @override
  void didUpdateWidget(covariant AnimatedHighlightContainer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentValue = widget.valueSelector(context);
    if (currentValue != _lastValue) {
      _lastValue = currentValue;
      _triggerHighlight();
    }
  }

  void _triggerHighlight() {
    setState(() => _highlight = true);
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _highlight = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.valueSelector(context);
    return AnimatedContainer(
      duration: widget.duration,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _highlight ? widget.highlightColor : widget.baseColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: widget.builder(context, value),
      ),
    );
  }
}
