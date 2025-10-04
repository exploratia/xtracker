import 'package:flutter/material.dart';

import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../controls/grid/daily/pixel.dart';

class PixelViewPreview extends StatelessWidget {
  static final List<SeriesType> _allowedSeriesTypes = [SeriesType.habit];

  static bool applicableOn(SeriesDef seriesDef) {
    return _allowedSeriesTypes.contains(seriesDef.seriesType);
  }

  final Color color;
  final bool invertHueDirection;

  final double hueFactor;

  const PixelViewPreview({super.key, required this.color, required this.invertHueDirection, required this.hueFactor});

  @override
  Widget build(BuildContext context) {
    Pixel.updatePixelStyles(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double pixelWidth = 20;
        int numPixels = (constraints.maxWidth / pixelWidth).toInt();
        if (numPixels > 10) {
          numPixels = 10;
          pixelWidth = constraints.maxWidth / numPixels;
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List<int>.generate(numPixels, (i) => i + 1).map(
              (e) => SizedBox(
                width: pixelWidth,
                child: Pixel(
                  colors: [Pixel.pixelColor(color, e.toDouble(), 1, numPixels, hueFactor: hueFactor, invertHueDirection: invertHueDirection)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
