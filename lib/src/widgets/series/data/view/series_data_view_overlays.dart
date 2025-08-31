import 'package:flutter/cupertino.dart';

class SeriesDataViewOverlays {
  double topHeight;
  double bottomHeight;

  SeriesDataViewOverlays({this.topHeight = 0, this.bottomHeight = 0});

  /// returns overall heights
  double get height {
    return topHeight + bottomHeight;
  }

  SizedBox buildTopSpacer() {
    return SizedBox(height: topHeight);
  }

  SizedBox buildBottomSpacer() {
    return SizedBox(height: bottomHeight);
  }
}
