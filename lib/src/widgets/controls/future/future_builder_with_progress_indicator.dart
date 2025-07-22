import 'package:flutter/material.dart';

import '../../../util/logging/flutter_simple_logging.dart';

class FutureBuilderWithProgressIndicator<T> extends StatelessWidget {
  const FutureBuilderWithProgressIndicator({super.key, required this.future, this.errorBuilder, required this.widgetBuilder});

  final Future<T> future;
  final dynamic Function(Object error)? errorBuilder;
  final Widget Function(T? data) widgetBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(children: [LinearProgressIndicator()]);
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
          return widgetBuilder(snapshot.data);
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
      padding: const EdgeInsets.all(8.0),
      child: Text(msg),
    ));
  }
}
