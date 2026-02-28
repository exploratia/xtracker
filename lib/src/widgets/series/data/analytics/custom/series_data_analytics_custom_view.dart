import 'package:flutter/material.dart';

import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../util/theme_utils.dart';
import '../series_data_analytics_days_recorded_view.dart';
import '../series_data_analytics_hours_recorded_view.dart';
import 'series_data_analytics_custom_attributes_proportions_view.dart';
import 'series_data_analytics_custom_hours_recorded.dart';

class SeriesDataAnalyticsCustomView extends StatelessWidget {
  const SeriesDataAnalyticsCustomView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<CustomValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    Widget? attributesProportionsView;
    if (seriesViewMetaData.seriesDef.isCustomSeriesWithAttributes()) {
      attributesProportionsView = SeriesDataAnalyticsCustomAttributesProportionsView(
        seriesViewMetaData: seriesViewMetaData,
        seriesDataValues: seriesDataValues,
      );
    }

    return Column(
      spacing: ThemeUtils.screenPadding,
      children: [
        ?attributesProportionsView,
        SeriesDataAnalyticsDaysRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
        SeriesDataAnalyticsHoursRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
          child: SeriesDataAnalyticsCustomHoursRecorded(
            seriesViewMetaData: seriesViewMetaData,
            seriesDataValues: seriesDataValues,
          ),
        ),
      ],
    );
  }
}
