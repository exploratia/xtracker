import 'package:material_ui/material_ui.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../series_data_analytics_tags_proportions_view.dart';

class SeriesDataAnalyticsDailyLifeTagsProportionsView extends StatelessWidget {
  const SeriesDataAnalyticsDailyLifeTagsProportionsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyLifeValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return SeriesDataAnalyticsTagsProportionsView(
      seriesViewMetaData: seriesViewMetaData,
      seriesDataValues: seriesDataValues,
      tagIdResolver: (seriesDataValue) => seriesDataValue.tagId,
    );
  }
}
