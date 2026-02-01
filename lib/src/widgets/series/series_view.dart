import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../providers/series_current_value_provider.dart';
import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/theme_utils.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/animation/animate_in.dart';
import '../controls/animation/fade_in.dart';
import '../controls/layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import '../controls/navigation/hide_bottom_navigation_bar.dart';
import '../controls/provider/data_provider_loader.dart';
import '../controls/responsive/device_dependent_constrained_box.dart';
import 'add_first_series.dart';
import 'series_def_renderer.dart';
import 'series_export_check.dart';

class SeriesView extends StatefulWidget {
  final SettingsController settingsController;

  const SeriesView({super.key, required this.settingsController});

  @override
  State<SeriesView> createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> onRefresh(BuildContext context) async {
    try {
      await context.read<SeriesProvider>().fetchData();
    } catch (e) {
      SimpleLogging.w('Failure on refresh view.', error: e);
      if (context.mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_loadFailed.tr(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataProviderLoader(
      obtainDataProviderFuture: Future.wait([
        context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
        context.read<SeriesCurrentValueProvider>().fetchDataIfNotYetLoaded(),
      ]),
      child: VCenteredSingleChildScrollViewWithScrollbar(
        scrollController: _scrollController,
        onRefreshCallback: () => onRefresh(context),
        scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
        child: _SeriesList(widget.settingsController),
      ),
    );
  }
}

class _SeriesList extends StatelessWidget {
  final SettingsController settingsController;

  const _SeriesList(this.settingsController);

  @override
  Widget build(BuildContext context) {
    var series = context.watch<SeriesProvider>().series;
    if (series.isEmpty) {
      return const FadeIn(child: AddFirstSeries());
    }

    List<Widget> children = [];
    var idx = 0;
    for (var s in series) {
      children.add(
        AnimateIn(
          durationMS: 1000 + idx * 500,
          slideOffset: const Offset(0, 0.2),
          child: SeriesDefRenderer(
            seriesDef: s,
            index: idx,
            settingsController: settingsController,
          ),
        ),
      );
      idx++;
    }

    return SeriesExportCheck(
      settingsController: settingsController,
      child: DeviceDependentWidthConstrainedBox(
        child: Column(
          spacing: ThemeUtils.verticalSpacingLarge,
          children: children,
          // children: [ ...series.map((s) => SeriesDefRenderer(seriesDef: s)) ],
        ),
      ),
    );
  }
}
