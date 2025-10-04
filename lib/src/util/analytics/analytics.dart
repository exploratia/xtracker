import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

class Analytics {
  static const int allDays = -1;
  static const List<int> datasetSizeInDays = [7, 30, 90, 365, allDays];

  static String buildDatasetSizeString(int size) {
    var sizeString = LocaleKeys.seriesDataAnalytics_label_lastVarDays.tr(args: [size.toString()]);
    if (size == Analytics.allDays) {
      sizeString = LocaleKeys.seriesDataAnalytics_label_total.tr();
    }
    return sizeString;
  }
}
