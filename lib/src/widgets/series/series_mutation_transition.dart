import 'package:flutter/material.dart';

import '../../providers/series_provider.dart';

/// Animates a single series card when it is inserted or deleted.
class SeriesMutationTransition extends StatefulWidget {
  const SeriesMutationTransition({
    super.key,
    required this.seriesUuid,
    required this.mutation,
    required this.child,
  });

  /// UUID represented by this card.
  final String seriesUuid;

  /// Most recent structural list change, if one is active.
  final SeriesMutation? mutation;

  /// Series card receiving the transition.
  final Widget child;

  @override
  State<SeriesMutationTransition> createState() => _SeriesMutationTransitionState();
}

class _SeriesMutationTransitionState extends State<SeriesMutationTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    value: 1,
    duration: SeriesMutation.transitionDuration,
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  int? _handledMutationVersion;

  @override
  void initState() {
    super.initState();
    _handleMutation(widget.mutation);
  }

  @override
  void didUpdateWidget(covariant SeriesMutationTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleMutation(widget.mutation);
  }

  void _handleMutation(SeriesMutation? mutation) {
    if (mutation == null || mutation.version == _handledMutationVersion || mutation.seriesUuid != widget.seriesUuid) {
      return;
    }

    _handledMutationVersion = mutation.version;
    if (mutation.type == SeriesMutationType.inserted) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SizeTransition(
        sizeFactor: _animation,
        child: widget.child,
      ),
    );
  }
}
