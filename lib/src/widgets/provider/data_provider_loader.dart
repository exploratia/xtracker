import 'package:flutter/material.dart';

import '../future/future_builder_with_progress_indicator.dart';

class DataProviderLoader extends StatefulWidget {
  const DataProviderLoader({super.key, required this.child, required this.obtainDataProviderFuture});

  final Widget child;
  final Future obtainDataProviderFuture;

  @override
  State<DataProviderLoader> createState() => _DataProviderLoaderState();
}

class _DataProviderLoaderState extends State<DataProviderLoader> {
  late Future _dataProviderFuture;

  @override
  void initState() {
    // if build is called multiple times because of state changes call future only once and store it.
    _dataProviderFuture = widget.obtainDataProviderFuture;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWithProgressIndicator(
      future: _dataProviderFuture,
      errorBuilder: (error) => 'Failed to load data...',
      widgetBuilder: (_) => widget.child,
    );
  }
}
