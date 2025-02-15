import 'package:flutter/material.dart';

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
    // Falls build aufgrund anderer state-Aenderungen mehrmals ausgefuehrt wuerde.
    // Future nur einmal ausfuehren und speichern.
    _dataProviderFuture = widget.obtainDataProviderFuture;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(children: [LinearProgressIndicator()]);
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error!.toString()));
        } else {
          return widget.child;
        }
      },
    );
  }
}
