import 'package:flutter/material.dart';

class MediaQueryUtils {
  late final MediaQueryData mediaQueryData;

  /// usage:
  ///
  /// final mediaQueryInfo = MediaQueryUtils(context);
  MediaQueryUtils(this.mediaQueryData);

  MediaQueryUtils.of(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
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
