import 'package:flutter/material.dart';

import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../series_data_analytics_attributes_proportions_view.dart';

class SeriesDataAnalyticsCustomAttributesProportionsView extends StatelessWidget {
  const SeriesDataAnalyticsCustomAttributesProportionsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<CustomValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return SeriesDataAnalyticsAttributesProportionsView(
      seriesViewMetaData: seriesViewMetaData,
      seriesDataValues: seriesDataValues,
      attributeIdResolver: (seriesDataValue) => seriesDataValue.aid,
    );
  }
}
