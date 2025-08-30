import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_provider.dart';
import '../../../util/series/series_import_export.dart';
import '../../controls/animation/animate_in.dart';
import '../../controls/animation/fade_in.dart';
import '../../controls/layout/centered_message.dart';
import '../../controls/responsive/device_dependent_constrained_box.dart';
import '../series_def_renderer.dart';

class SeriesManagementView extends StatelessWidget {
  const SeriesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.secondary,
        title: Text(LocaleKeys.seriesManagement_title.tr()),
        actions: [
          IconButton(
            tooltip: LocaleKeys.seriesDashboard_action_addSeries_tooltip.tr(),
            onPressed: () async {
              /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
            },
            icon: const Icon(Icons.add_chart_outlined),
          ),
          IconButton(
            tooltip: LocaleKeys.seriesManagement_action_importExport_tooltip.tr(),
            onPressed: () async => SeriesImportExport.showImportExportDlg(context),
            icon: const Icon(Icons.import_export_outlined),
          ),
          IconButton(
            tooltip: LocaleKeys.seriesManagement_action_closeSeriesManagement_tooltip.tr(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_off_outlined),
          ),
        ],
      ),
      // appBar: GradientAppBar.build(
      //   context,
      //   addLeadingBackBtn: true,
      //   title: Text(LocaleKeys.series_mgmt_title.tr()),
      //   actions: [
      //     IconButton(onPressed: () async => SeriesImportExport.showImportExportDlg(context), icon: const Icon(Icons.import_export_outlined)),
      //     IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.edit_off_outlined)),
      //   ],
      // ),
      body: const Center(child: DeviceDependentWidthConstrainedBox(child: _SeriesList())),
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList();

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;

    if (series.isEmpty) {
      return AnimateIn(
        fade: true,
        slideOffset: const Offset(0, -0.2),
        child: CenteredMessage(message: LocaleKeys.seriesManagement_label_noSeries.tr()),
      );
    }

    List<Widget> children = [];
    var idx = 0;
    for (var s in series) {
      children.add(FadeIn(
          key: Key(s.uuid),
          durationMS: 200 + idx * 400,
          child: SeriesDefRenderer(
            managementMode: true,
            seriesDef: s,
            index: idx,
          )));
      idx++;
    }

    return ReorderableListView(
      buildDefaultDragHandles: false,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Opacity(
          opacity: 0.6,
          child: Material(
            // elevation: 8, // Shadow effect while dragging
            borderRadius: BorderRadius.circular(16), // Rounded corners
            color: Colors.transparent,
            child: child,
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      children: children,
      // children: [...series.map((s) => SeriesDefRenderer(key: Key(s.uuid), managementMode: true, seriesDef: s))],
      onReorder: (int oldIndex, int newIndex) => context.read<SeriesProvider>().reorder(oldIndex, newIndex),
    );
  }
}
