/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/bmc
  $AssetsImagesBmcGen get bmc => const $AssetsImagesBmcGen();

  /// Directory path: assets/images/logos
  $AssetsImagesLogosGen get logos => const $AssetsImagesLogosGen();
}

class $AssetsInfosGen {
  const $AssetsInfosGen();

  /// File path: assets/infos/disclaimer.html
  String get disclaimer => 'assets/infos/disclaimer.html';

  /// File path: assets/infos/eula.html
  String get eula => 'assets/infos/eula.html';

  /// File path: assets/infos/legal_notice.html
  String get legalNotice => 'assets/infos/legal_notice.html';

  /// File path: assets/infos/privacy_policy.html
  String get privacyPolicy => 'assets/infos/privacy_policy.html';

  /// List of all assets
  List<String> get values => [disclaimer, eula, legalNotice, privacyPolicy];
}

class $AssetsImagesBmcGen {
  const $AssetsImagesBmcGen();

  /// File path: assets/images/bmc/bmc-button.png
  AssetGenImage get bmcButton => const AssetGenImage('assets/images/bmc/bmc-button.png');

  /// List of all assets
  List<AssetGenImage> get values => [bmcButton];
}

class $AssetsImagesLogosGen {
  const $AssetsImagesLogosGen();

  /// File path: assets/images/logos/app_logo.png
  AssetGenImage get appLogo => const AssetGenImage('assets/images/logos/app_logo.png');

  /// File path: assets/images/logos/app_logo_white.png
  AssetGenImage get appLogoWhite => const AssetGenImage('assets/images/logos/app_logo_white.png');

  /// File path: assets/images/logos/ca_logo.png
  AssetGenImage get caLogo => const AssetGenImage('assets/images/logos/ca_logo.png');

  /// File path: assets/images/logos/exploratia_logo.png
  AssetGenImage get exploratiaLogo => const AssetGenImage('assets/images/logos/exploratia_logo.png');

  /// File path: assets/images/logos/exploratia_logo_wide.png
  AssetGenImage get exploratiaLogoWide => const AssetGenImage('assets/images/logos/exploratia_logo_wide.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogo, appLogoWhite, caLogo, exploratiaLogo, exploratiaLogoWide];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsInfosGen infos = $AssetsInfosGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
