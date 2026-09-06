import 'package:material_ui/material_ui.dart';

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

class VoidFutureBuilderWithProgressIndicator extends StatelessWidget {
  /// [waitingWidget] optional Widget which is shown while waiting additional to progress indicator
  VoidFutureBuilderWithProgressIndicator({
    super.key,
    required this.future,
    this.errorBuilder,
    required this.widgetBuilder,
    this.marginTop = 0,
    this.waitingWidget,
  }) {
    futureWrapper = Future(() async {
      await future;
      return true;
    });
  }

  final Future<void> future;
  final dynamic Function(Object error)? errorBuilder;
  final Widget Function(BuildContext context) widgetBuilder;
  final double marginTop;
  final Widget? waitingWidget;

  late final Future<bool> futureWrapper;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWithProgressIndicator(
      future: futureWrapper,
      errorBuilder: errorBuilder,
      marginTop: marginTop,
      widgetBuilder: (_, context) => widgetBuilder(context),
      waitingWidget: waitingWidget,
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
