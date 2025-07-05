import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../../generated/assets.gen.dart';
import '../../generated/locale_keys.g.dart';

enum InfoType {
  legalNotice('legalNotice'),
  eula('eula'),
  privacyPolicy('privacyPolicy'),
  disclaimer('disclaimer'),
  unknown("unknown");

  final String typeName;

  const InfoType(this.typeName);

  String title() {
    return titleOf(this);
  }

  Future<String> html(BuildContext context) {
    return htmlOf(this, context);
  }

  static String titleOf(InfoType seriesType) {
    return switch (seriesType) {
      InfoType.legalNotice => "Impressum / Legal Notice",
      InfoType.eula => 'EULA',
      InfoType.privacyPolicy => 'Privacy Policy',
      InfoType.disclaimer => 'Disclaimer',
      InfoType.unknown => LocaleKeys.appTitle.tr(),
    };
  }

  static Future<String> htmlOf(InfoType seriesType, BuildContext context) {
    return switch (seriesType) {
      InfoType.legalNotice => _loadStringAsset(context, Assets.infos.legalNotice),
      InfoType.eula => _loadStringAsset(context, Assets.infos.eula),
      InfoType.privacyPolicy => _loadStringAsset(context, Assets.infos.privacyPolicy),
      InfoType.disclaimer => _loadStringAsset(context, Assets.infos.disclaimer),
      InfoType.unknown => Future.value(LocaleKeys.appTitle.tr()),
    };
  }

  static Future<String> _loadStringAsset(BuildContext context, String assetPath) async {
    return await DefaultAssetBundle.of(context).loadString(assetPath);
  }

  static InfoType byTypeName(dynamic input) {
    String typeName = input.toString();
    return InfoType.values.firstWhere((element) => element.typeName == typeName, orElse: () => legalNotice);
  }
}
