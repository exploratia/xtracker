import 'package:flutter/cupertino.dart';

class SeriesDataViewOverlays {
  double topHeight;
  double bottomHeight;

  SeriesDataViewOverlays({this.topHeight = 0, this.bottomHeight = 0});

  bool setTopHeight(double? value) {
    if (value == null) return false;
    if (topHeight != value) {
      topHeight = value;
      return true;
    }
    return false;
  }

  bool setBottomHeight(double? value) {
    if (value == null) return false;
    if (bottomHeight != value) {
      bottomHeight = value;
      return true;
    }
    return false;
  }

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
