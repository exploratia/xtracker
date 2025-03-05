import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_blood_pressure.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../chart/chart_container.dart';
import '../../../../../layout/single_child_scroll_view_with_scrollbar.dart';

class SeriesDataBloodPressureChartView extends StatelessWidget {
  const SeriesDataBloodPressureChartView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return SingleChildScrollViewWithScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
        child: Column(
          children: [
            ChartContainer(
              child: LineChart(
                ChartUtilsBloodPressure.buildLineChartData(seriesData, themeData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
