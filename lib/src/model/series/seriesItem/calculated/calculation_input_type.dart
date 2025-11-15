import 'package:easy_localization/easy_localization.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/ex.dart';

enum CalculationInputType {
  numeric,
  seriesValue,
  ;

  factory CalculationInputType.byName(String name) => CalculationInputType.values.firstWhere(
        (element) => element.name == name,
        orElse: () => throw Ex("'$name' is no valid calculation input type!"),
      );

  static String toDisplayString(CalculationInputType inputType) {
    return switch (inputType) {
      CalculationInputType.numeric => LocaleKeys.enum_calculationInputType_numeric_displayName.tr(),
      CalculationInputType.seriesValue => LocaleKeys.enum_calculationInputType_seriesValue_displayName.tr(),
    };
  }
}
