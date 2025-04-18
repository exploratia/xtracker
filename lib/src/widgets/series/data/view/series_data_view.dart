import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../../util/theme_utils.dart';
import '../../../navigation/hide_bottom_navigation_bar.dart';
import '../../../provider/data_provider_loader.dart';
import '../../../text/overflow_text.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';
import 'daily_check/series_data_daily_check_view.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return HideBottomNavigationBar(
      child: Stack(
        fit: StackFit.loose,
        children: [
          _SeriesDataView(seriesViewMetaData: seriesViewMetaData),
          _Title(seriesViewMetaData: seriesViewMetaData),
        ],
      ),
    );
  }
}

class _SeriesDataView extends StatelessWidget {
  const _SeriesDataView({required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    Widget view = switch (seriesViewMetaData.seriesDef.seriesType) {
      SeriesType.bloodPressure => SeriesDataBloodPressureView(seriesViewMetaData: seriesViewMetaData),
      SeriesType.dailyCheck => SeriesDataDailyCheckView(seriesViewMetaData: seriesViewMetaData),
      SeriesType.monthly => throw UnimplementedError(),
      SeriesType.free => throw UnimplementedError(),
    };

    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesViewMetaData.seriesDef),
      child: view,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.seriesViewMetaData,
  });

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Positioned(
      left: 40,
      right: 40,
      top: 0,
      height: ThemeUtils.seriesDataViewTopPadding,
      child: IgnorePointer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const AlignmentDirectional(0, -1),
                  end: const AlignmentDirectional(0, 1),
                  colors: [
                    themeData.colorScheme.primary,
                    seriesViewMetaData.seriesDef.color,
                  ],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: seriesViewMetaData.seriesDef.color.withValues(alpha: 0.8), // Glow effect
                    blurRadius: 10,
                    spreadRadius: 1, // Intensity of the glow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1, top: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.scaffoldBackgroundColor, // Inner background color
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicWidth(
                      child: Row(
                        spacing: 8,
                        children: [
                          Hero(tag: 'seriesDef_${seriesViewMetaData.seriesDef.uuid}', child: seriesViewMetaData.seriesDef.icon()),
                          OverflowText(
                            seriesViewMetaData.seriesDef.name,
                            expanded: true,
                            style: themeData.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
