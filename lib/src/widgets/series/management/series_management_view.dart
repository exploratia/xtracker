import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_provider.dart';
import '../../../util/series/series_import_export.dart';
import '../../../util/theme_utils.dart';
import '../../administration/settings/settings_controller.dart';
import '../../controls/animation/animate_in.dart';
import '../../controls/appbar/gradient_app_bar.dart';
import '../../controls/layout/centered_message.dart';
import '../../controls/layout/wallpaper.dart';
import '../../controls/responsive/device_dependent_constrained_box.dart';
import '../series_def_renderer.dart';

class SeriesManagementView extends StatelessWidget {
  final SettingsController settingsController;

  const SeriesManagementView({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      backgroundColor: settingsController.showWallpaper ? Colors.transparent : null,
      appBar: GradientAppBar.build(
        context,
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
            onPressed: () async => SeriesImportExport.showImportExportDlg(context, settingsController: settingsController),
            icon: const Icon(Icons.import_export_outlined),
          ),
          IconButton(
            tooltip: LocaleKeys.seriesManagement_action_closeSeriesManagement_tooltip.tr(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_off_outlined),
          ),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
      body: Center(child: DeviceDependentWidthConstrainedBox(child: _SeriesList(settingsController))),
    );

    if (settingsController.showWallpaper) return Wallpaper(child: scaffold);
    return scaffold;
  }
}

class _SeriesList extends StatelessWidget {
  final SettingsController settingsController;

  const _SeriesList(this.settingsController);

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;

    if (series.isEmpty) {
      return AnimateIn(
        fade: true,
        slideOffset: const Offset(0, -0.2),
        child: Padding(
          padding: const EdgeInsets.only(top: 52),
          child: CenteredMessage(message: LocaleKeys.seriesManagement_label_noSeries.tr()),
        ),
      );
    }

    List<Widget> children = [];
    var idx = 0;
    for (var s in series) {
      children.add(AnimateIn(
          key: Key(s.uuid),
          durationMS: 2000 + idx * 500,
          slideOffset: const Offset(0, -0.2),
          child: SeriesDefRenderer(
            managementMode: true,
            seriesDef: s,
            index: idx,
            settingsController: settingsController,
          )));
      idx++;
    }

    return ReorderableListView(
      buildDefaultDragHandles: false,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Opacity(
          opacity: 0.6,
          child: Material(
            // elevation: ThemeUtils.elevation, // Shadow effect while dragging
            borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusLarge), // Rounded corners
            color: Colors.transparent,
            child: child,
          ),
        );
      },
      padding: const EdgeInsets.all(ThemeUtils.cardPadding),
      children: children,
      // children: [...series.map((s) => SeriesDefRenderer(key: Key(s.uuid), managementMode: true, seriesDef: s))],
      onReorder: (int oldIndex, int newIndex) => context.read<SeriesProvider>().reorder(oldIndex, newIndex),
    );
  }
}
