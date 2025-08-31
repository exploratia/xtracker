import 'package:flutter/material.dart';

import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/text/overflow_text.dart';

class SeriesTitle extends StatelessWidget {
  static const double seriesTitleHeight = 50;

  const SeriesTitle({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: ThemeUtils.defaultPadding, right: ThemeUtils.defaultPadding, bottom: ThemeUtils.defaultPadding),
        child: Container(
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
                padding: const EdgeInsets.all(ThemeUtils.defaultPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: ThemeUtils.horizontalSpacing,
                  children: [
                    Hero(tag: 'seriesDef_${seriesViewMetaData.seriesDef.uuid}', child: seriesViewMetaData.seriesDef.icon()),
                    OverflowText(
                      seriesViewMetaData.seriesDef.name,
                      expanded: false,
                      flexible: true,
                      style: themeData.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
