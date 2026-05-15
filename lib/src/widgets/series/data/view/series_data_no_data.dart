import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../controls/animation/fade_in.dart';
import '../../../controls/layout/centered_message.dart';

class SeriesDataNoData extends StatelessWidget {
  const SeriesDataNoData({super.key, required this.seriesViewMetaData, this.noDataBecauseOfFilter = false, this.msg});

  final SeriesViewMetaData seriesViewMetaData;
  final bool noDataBecauseOfFilter;
  final String? msg;

  @override
  Widget build(BuildContext context) {
    String text = LocaleKeys.seriesData_label_noData.tr();
    if (noDataBecauseOfFilter) {
      text = LocaleKeys.seriesData_label_noDataBecauseOfFilter.tr();
    } else if (msg != null) {
      text = msg!;
    }

    return CenteredMessage(
      message: IntrinsicHeight(
        child: FadeIn(
          child: Column(
            children: [
              Icon(seriesViewMetaData.seriesDef.iconData(), color: seriesViewMetaData.seriesDef.color, size: 40),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  static bool isNoData(List<dynamic>? seriesData) {
    return (seriesData == null || seriesData.isEmpty);
  }
}
