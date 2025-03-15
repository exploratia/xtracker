import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../providers/series_provider.dart';
import '../../responsive/device_dependent_constrained_box.dart';
import '../series_def_renderer.dart';

class SeriesManagementView extends StatelessWidget {
  const SeriesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.secondary,
        title: Text(LocaleKeys.series_management_title.tr()),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.edit_off_outlined)),
        ],
      ),
      body: const Center(child: DeviceDependentWidthConstrainedBox(child: _SeriesList())),
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList();

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;
    return ReorderableListView(
      buildDefaultDragHandles: true,
      padding: const EdgeInsets.all(16),
      children: [
        ...series.map((s) => SeriesDefRenderer(
              key: Key(s.uuid),
              managementMode: true,
              seriesDef: s,
            )),
      ],
      onReorder: (int oldIndex, int newIndex) => context.read<SeriesProvider>().reorder(oldIndex, newIndex),
    );
  }
}
