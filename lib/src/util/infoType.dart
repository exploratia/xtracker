import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';

enum InfoType {
  legalNotice('legalNotice', """<span>
Please click <a href="https://pub.dartlang.org">here</a> or 
<a href="https://old.reddit.com">here</a>. No with a lot more text to see what happens on end of width.<br/>
<br/>
Go ahead! Try it.
</span>"""),
  unknown("unknown", 'xTracker');

  final String typeName;
  final String infoHTML;

  const InfoType(this.typeName, this.infoHTML);

  String title() {
    return titleOf(this);
  }

  static String titleOf(InfoType seriesType) {
    return switch (seriesType) {
      InfoType.legalNotice => LocaleKeys.series_seriesType_bloodPressure_info.tr(),
      InfoType.unknown => LocaleKeys.appTitle.tr(),
    };
  }

  static InfoType byTypeName(dynamic input) {
    String typeName = input.toString();
    return InfoType.values.firstWhere((element) => element.typeName == typeName, orElse: () => unknown);
  }
}
