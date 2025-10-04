import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/appbar/gradient_app_bar.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/responsive/device_dependent_constrained_box.dart';
import '../view/series_title.dart';
import 'series_data_analytics_view_content_builder.dart';

class SeriesDataAnalyticsView extends StatelessWidget {
  const SeriesDataAnalyticsView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar.build(
        addLeadingBackBtn: true,
        context,
        title: Text(LocaleKeys.seriesDataAnalytics_title.tr()),
        actions: [
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesDataAnalytics_action_close_tooltip.tr(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_outlined),
          ),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollViewWithScrollbar(
              useScreenPadding: true,
              child: DeviceDependentWidthConstrainedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: SeriesTitle.seriesTitleHeight,
                    ),
                    SeriesDataAnalyticsViewContentBuilder(
                      seriesViewMetaData: seriesViewMetaData,
                      builder: (Widget Function() seriesDataViewBuilder) {
                        return seriesDataViewBuilder();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: SeriesTitle.seriesTitleHeight,
            child: IgnorePointer(
              child: SeriesTitle(seriesViewMetaData: seriesViewMetaData),
            ),
          ),
        ],
      ),
    );
  }
}
