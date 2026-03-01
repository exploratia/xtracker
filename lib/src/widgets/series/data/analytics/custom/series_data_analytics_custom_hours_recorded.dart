import 'package:flutter/material.dart';

import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../series_data_analytics_tags_hours_recorded.dart';

class SeriesDataAnalyticsCustomHoursRecorded extends StatelessWidget {
  const SeriesDataAnalyticsCustomHoursRecorded({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<CustomValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return SeriesDataAnalyticsTagsHoursRecorded(
      seriesViewMetaData: seriesViewMetaData,
      seriesDataValues: seriesDataValues,
      tagIdResolver: (seriesDataValue) => seriesDataValue.tagId,
    );
  }
}
