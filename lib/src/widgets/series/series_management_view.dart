import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/series_provider.dart';
import 'series_def_renderer.dart';

class SeriesManagementView extends StatelessWidget {
  const SeriesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(t.seriesManagementTitle),
          actions: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit_off_outlined))
          ]),
      body: ReorderableListView(
        buildDefaultDragHandles: true,
        padding: const EdgeInsets.all(16),
        children: [
          ...series.map((s) => SeriesDefRenderer(
                key: Key(s.uuid),
                editMode: true,
                seriesDef: s,
              ))
        ],
        onReorder: (int oldIndex, int newIndex) =>
            context.read<SeriesProvider>().reorder(oldIndex, newIndex),
      ),
    );
  }
}
