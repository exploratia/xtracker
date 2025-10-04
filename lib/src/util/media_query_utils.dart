import 'package:flutter/material.dart';

class MediaQueryUtils {
  static double textScaleFactor = 1;
  static double textScaleWidthFactor = 1;
  static double iconScaleFactor = 1;

  /// returns the height by which a text is larger by the actual text scale
  static double calcAdditionalHeightByTextScale(double fontSize) {
    var addHeightForTextScale = (fontSize * textScaleFactor - fontSize);
    return addHeightForTextScale;
  }

  late final MediaQueryData mediaQueryData;

  /// usage:
  ///
  /// final mediaQueryInfo = MediaQueryUtils(context);
  MediaQueryUtils(this.mediaQueryData);

  MediaQueryUtils.of(BuildContext context, {calcTextScale = false}) {
    mediaQueryData = MediaQuery.of(context);

    if (calcTextScale) {
      // might not be correct in all case (for larger font sizes it scales not linear)
      // round (ceil) scales to the first decimal
      textScaleFactor = ((mediaQueryData.textScaler.scale(1) * 10).ceil()) / 10;
      textScaleWidthFactor = ((1 + (textScaleFactor - 1) * 0.5) * 10).ceil() / 10;
      iconScaleFactor = textScaleFactor.clamp(1, 1.3);
      // print("textScaleFactor: $textScaleFactor");
      // print('textScaleWidthFactor: $textScaleWidthFactor');
    }
  }

  Orientation get orientation {
    return mediaOrientation(mediaQueryData);
  }

  bool get isLandscape {
    return mediaIsLandscape(mediaQueryData);
  }

  bool get isPortrait {
    return mediaIsPortrait(mediaQueryData);
  }

  bool get isTablet {
    return mediaIsTablet(mediaQueryData);
  }

  bool get isSmallScreen {
    return mediaQueryData.size.width < 250 || mediaQueryData.size.height < 300;
  }

  static Orientation mediaOrientation(MediaQueryData mediaQueryData) {
    return mediaQueryData.orientation;
  }

  static bool mediaIsLandscape(MediaQueryData mediaQueryData) {
    return mediaOrientation(mediaQueryData) == Orientation.landscape;
  }

  static bool mediaIsPortrait(MediaQueryData mediaQueryData) {
    return mediaOrientation(mediaQueryData) == Orientation.portrait;
  }

  static bool mediaIsTablet(MediaQueryData mediaQueryData) {
    return mediaQueryData.size.shortestSide >= 600;
    // return mediaQueryData.size.width > 750;
  }
}
