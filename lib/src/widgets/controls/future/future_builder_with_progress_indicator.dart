import 'package:flutter/material.dart';

import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/motion_utils.dart';
import '../../../util/theme_utils.dart';

class FutureBuilderWithProgressIndicator<T> extends StatelessWidget {
  /// [waitingWidget] optional Widget which is shown while waiting additional to progress indicator
  const FutureBuilderWithProgressIndicator({
    super.key,
    required this.future,
    this.errorBuilder,
    required this.widgetBuilder,
    this.marginTop = 0,
    this.waitingWidget,
  });

  final Future<T> future;
  final dynamic Function(Object error)? errorBuilder;
  final Widget Function(T data, BuildContext context) widgetBuilder;
  final double marginTop;
  final Widget? waitingWidget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        Widget content;
        String stateKey;
        if (snapshot.connectionState == ConnectionState.waiting) {
          stateKey = 'waiting';
          content = Column(
            children: [
              if (marginTop > 0) SizedBox(height: marginTop),
              const LinearProgressIndicator(),
              ?waitingWidget,
            ],
          );
        } else if (snapshot.hasError) {
          stateKey = 'error';
          SimpleLogging.w('Err result in future: ${snapshot.error}');
          if (errorBuilder != null) {
            var errorBuilderResult = errorBuilder!(snapshot.error!);
            if (errorBuilderResult == null) {
              content = Container();
            } else if (errorBuilderResult is Widget) {
              content = errorBuilderResult;
            } else {
              content = _ErrMsg(msg: errorBuilderResult.toString());
            }
          } else {
            content = _ErrMsg(msg: snapshot.error!.toString());
          }
        } else {
          stateKey = 'content';
          T? data = snapshot.data;
          if (data == null) {
            SimpleLogging.w('No data in future - although there was no snapshot error.');
            stateKey = 'error';
            content = const _ErrMsg(msg: "Future failure - no data.");
          } else {
            content = widgetBuilder(data, context);
          }
        }

        return AnimatedSwitcher(
          duration: MotionUtils.resolve(context, MotionUtils.quick),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey(stateKey),
            child: content,
          ),
        );
      },
    );
  }
}

class VoidFutureBuilderWithProgressIndicator extends StatefulWidget {
  /// [waitingWidget] optional Widget which is shown while waiting additional to progress indicator
  const VoidFutureBuilderWithProgressIndicator({
    super.key,
    required this.future,
    this.errorBuilder,
    required this.widgetBuilder,
    this.marginTop = 0,
    this.waitingWidget,
  });

  final Future<void> future;
  final dynamic Function(Object error)? errorBuilder;
  final Widget Function(BuildContext context) widgetBuilder;
  final double marginTop;
  final Widget? waitingWidget;

  @override
  State<VoidFutureBuilderWithProgressIndicator> createState() => _VoidFutureBuilderWithProgressIndicatorState();
}

class _VoidFutureBuilderWithProgressIndicatorState extends State<VoidFutureBuilderWithProgressIndicator> {
  late Future<bool> _futureWrapper;

  @override
  void initState() {
    super.initState();
    _futureWrapper = _wrapFuture();
  }

  @override
  void didUpdateWidget(covariant VoidFutureBuilderWithProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      _futureWrapper = _wrapFuture();
    }
  }

  // Keep the future stable across layout and route rebuilds. Restarting the
  // loading transition would replace loaded content and its scroll state.
  Future<bool> _wrapFuture() async {
    await widget.future;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWithProgressIndicator(
      future: _futureWrapper,
      errorBuilder: widget.errorBuilder,
      marginTop: widget.marginTop,
      widgetBuilder: (_, context) => widget.widgetBuilder(context),
      waitingWidget: widget.waitingWidget,
    );
  }
}

class _ErrMsg extends StatelessWidget {
  const _ErrMsg({
    required this.msg,
  });

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeUtils.defaultPadding),
        child: Text(msg),
      ),
    );
  }
}
