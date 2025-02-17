import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../layout/centered_message.dart';
import 'series_data_blood_pressure_chart_view.dart';
import 'series_data_blood_pressure_dots_view.dart';
import 'table/series_data_blood_pressure_table_view.dart';

class SeriesDataBloodPressureView extends StatelessWidget {
  const SeriesDataBloodPressureView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seriesDef = seriesViewMetaData.seriesDef;

    var seriesDataProvider = context.watch<SeriesDataProvider>();
    var bloodPressureSeriesData = seriesDataProvider.bloodPressureData(seriesDef);
    if (bloodPressureSeriesData == null || bloodPressureSeriesData.isEmpty()) {
      return CenteredMessage(
        message: IntrinsicHeight(
          child: Column(
            children: [
              Icon(seriesDef.iconData(), color: seriesDef.color, size: 40),
              Text(t.seriesDataNoData),
            ],
          ),
        ),
      );
    }

    return switch (seriesViewMetaData.viewType) {
      ViewType.table => SeriesDataBloodPressureTableView(seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData),
      ViewType.chart => SeriesDataBloodPressureChartView(seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData),
      ViewType.dots => SeriesDataBloodPressureDotsView(seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData),
    };
  }
}
