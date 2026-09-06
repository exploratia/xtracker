import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../providers/series_data_provider.dart';
import '../../../../util/motion_utils.dart';

/// Provides short, non-blocking feedback for a recently changed series value.
class SeriesDataMutationTransition extends StatefulWidget {
  const SeriesDataMutationTransition({
    super.key,
    required this.valueUuids,
    required this.child,
  });

  /// Value UUIDs represented by this table row or pixel.
  final Set<String> valueUuids;

  /// Content receiving the mutation feedback.
  final Widget child;

  @override
  State<SeriesDataMutationTransition> createState() => _SeriesDataMutationTransitionState();
}

class _SeriesDataMutationTransitionState extends State<SeriesDataMutationTransition> with TickerProviderStateMixin {
  late final AnimationController _highlightController = AnimationController(
    duration: SeriesDataMutation.highlightDuration,
    vsync: this,
  );
  late final Animation<double> _highlight = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 80),
  ]).animate(_highlightController);
  late final AnimationController _visibilityController = AnimationController(
    value: 1,
    duration: SeriesDataMutation.deletionDuration,
    vsync: this,
  );
  int? _handledMutationVersion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _highlightController.duration = MotionUtils.resolve(context, SeriesDataMutation.highlightDuration);
    _visibilityController.duration = MotionUtils.resolve(context, SeriesDataMutation.deletionDuration);
    final mutation = context.watch<SeriesDataProvider>().latestMutation;
    if (mutation == null || mutation.version == _handledMutationVersion || !widget.valueUuids.contains(mutation.valueUuid)) {
      return;
    }

    _handledMutationVersion = mutation.version;
    if (mutation.type == SeriesDataMutationType.deleted) {
      _highlightController.reset();
      if (MotionUtils.animationsDisabled(context)) {
        _visibilityController.value = 0;
      } else {
        _visibilityController.reverse(from: 1);
      }
    } else {
      _visibilityController.value = 1;
      if (!MotionUtils.animationsDisabled(context)) {
        _highlightController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35);
    final highlightedChild = SizedBox.expand(
      child: AnimatedBuilder(
        animation: _highlight,
        child: widget.child,
        builder: (context, child) => ColoredBox(
          color: highlightColor.withValues(alpha: highlightColor.a * _highlight.value),
          child: child,
        ),
      ),
    );

    return FadeTransition(
      opacity: _visibilityController,
      child: SizeTransition(
        sizeFactor: _visibilityController,
        child: highlightedChild,
      ),
    );
  }
}
