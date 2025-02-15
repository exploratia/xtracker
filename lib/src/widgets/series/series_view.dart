import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import '../responsive/device_dependent_constrained_box.dart';
import 'add_first_series.dart';
import 'data_provider_loader.dart';
import 'series_def_renderer.dart';

class SeriesView extends StatelessWidget {
  const SeriesView({super.key});

  Future<void> onRefresh(BuildContext context) async {
    try {
      await context.read<SeriesProvider>().fetchData();
    } catch (e) {
      if (context.mounted) {
        await Dialogs.simpleErrOkDialog(e.toString(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
      child: VCenteredSingleChildScrollViewWithScrollbar(
        onRefreshCallback: () => onRefresh(context),
        child: const _SeriesList(),
      ),
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
    return DeviceDependentWidthConstrainedBox(
      child: Column(
        spacing: 16,
        children: [
          ...series.map((s) => SeriesDefRenderer(seriesDef: s)),
        ],
      ),
    );
  }
}
