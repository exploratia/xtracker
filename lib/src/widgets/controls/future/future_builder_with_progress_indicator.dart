import 'package:flutter/material.dart';

import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/theme_utils.dart';

class FutureBuilderWithProgressIndicator<T> extends StatelessWidget {
  const FutureBuilderWithProgressIndicator({super.key, required this.future, this.errorBuilder, required this.widgetBuilder, this.marginTop = 0});

  final Future<T> future;
  final dynamic Function(Object error)? errorBuilder;
  final Widget Function(T? data, BuildContext context) widgetBuilder;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              if (marginTop > 0) SizedBox(height: marginTop),
              const LinearProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          SimpleLogging.w('Err result in future: ${snapshot.error}');
          if (errorBuilder != null) {
            var errorBuilderResult = errorBuilder!(snapshot.error!);
            if (errorBuilderResult == null) return Container();
            if (errorBuilderResult is Widget) return errorBuilderResult;
            return _ErrMsg(msg: errorBuilderResult.toString());
          } else {
            return _ErrMsg(msg: snapshot.error!.toString());
          }
        } else {
          return widgetBuilder(snapshot.data, context);
        }
      },
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
    ));
  }
}
