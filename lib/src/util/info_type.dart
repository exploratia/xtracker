import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../../generated/assets.gen.dart';
import '../../generated/locale_keys.g.dart';

enum InfoType {
  legalNotice('legalNotice', LocaleKeys.enum_infoType_legalNotice_title),
  eula('eula', LocaleKeys.enum_infoType_eula_title),
  privacyPolicy('privacyPolicy', LocaleKeys.enum_infoType_privacyPolicy_title),
  disclaimer('disclaimer', LocaleKeys.enum_infoType_disclaimer_title),
  unknown("unknown", LocaleKeys.appTitle);

  final String typeName;
  final String _titleKey;

  const InfoType(this.typeName, this._titleKey);

  String title() {
    return titleOf(this);
  }

  Future<String> html(BuildContext context) {
    return htmlOf(this, context);
  }

  static String titleOf(InfoType seriesType) {
    return seriesType._titleKey.tr();
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
