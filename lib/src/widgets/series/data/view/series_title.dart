import 'package:flutter/material.dart';

import '../../../../model/series/series_view_meta_data.dart';
import '../../../controls/text/overflow_text.dart';

class SeriesTitle extends StatelessWidget {
  const SeriesTitle({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const AlignmentDirectional(0, -1),
                end: const AlignmentDirectional(0, 1),
                colors: [
                  themeData.colorScheme.primary,
                  seriesViewMetaData.seriesDef.color,
                ],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: seriesViewMetaData.seriesDef.color.withValues(alpha: 0.8), // Glow effect
                  blurRadius: 10,
                  spreadRadius: 1, // Intensity of the glow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1, top: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.scaffoldBackgroundColor, // Inner background color
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntrinsicWidth(
                    child: Row(
                      spacing: 8,
                      children: [
                        Hero(tag: 'seriesDef_${seriesViewMetaData.seriesDef.uuid}', child: seriesViewMetaData.seriesDef.icon()),
                        OverflowText(
                          seriesViewMetaData.seriesDef.name,
                          expanded: true,
                          style: themeData.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
