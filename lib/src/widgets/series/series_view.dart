import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../card/glowing_border_container.dart';
import '../layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import '../select/icon_map.dart';
import 'add_first_series.dart';

class SeriesView extends StatefulWidget {
  const SeriesView({super.key});

  @override
  State<SeriesView> createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView> {
  late Future _dataProviderFuture;

  Future _obtainDataProviderFuture() {
    return context.read<SeriesProvider>().fetchDataIfNotYetLoaded();
  }

  @override
  void initState() {
    // Falls build aufgrund anderer state-Aenderungen mehrmals ausgefuehrt wuerde.
    // Future nur einmal ausfuehren und speichern.
    _dataProviderFuture = _obtainDataProviderFuture();
    super.initState();
  }

  Future<void> onRefresh() async {
    try {
      await context.read<SeriesProvider>().fetchData();
    } catch (e) {
      if (mounted) {
        await Dialogs.simpleErrOkDialog(e.toString(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataProviderFuture,
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(snapshot.error!.toString());
        } else {
          child = const _SeriesList();
        }

        return VCenteredSingleChildScrollViewWithScrollbar(
          onRefreshCallback: onRefresh,
          child: child,
        );
      },
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList();

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;
    if (series.isEmpty) {
      return const AddFirstSeries();
    }
    return Column(children: [
      ...series.map((s) => GlowingBorderContainer(
          glowColor: s.color,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconMap.icon(s.iconName),
                    Text(s.name),
                  ],
                ),
              ],
            ),
          )))
    ]);
  }
}
