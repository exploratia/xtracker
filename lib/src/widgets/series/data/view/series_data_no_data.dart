import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../controls/animation/fade_in.dart';
import '../../../controls/layout/centered_message.dart';

class SeriesDataNoData extends StatelessWidget {
  const SeriesDataNoData({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return CenteredMessage(
      message: IntrinsicHeight(
        child: FadeIn(
          child: Column(
            children: [
              Icon(seriesViewMetaData.seriesDef.iconData(), color: seriesViewMetaData.seriesDef.color, size: 40),
              Text(LocaleKeys.seriesData_label_noData.tr()),
            ],
          ),
        ),
      ),
    );
  }

  static bool isNoData(SeriesData<dynamic>? seriesData) {
    return (seriesData == null || seriesData.isEmpty());
  }
}
