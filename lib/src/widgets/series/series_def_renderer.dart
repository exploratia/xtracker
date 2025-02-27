import 'package:flutter/material.dart';

import '../../model/series/series_def.dart';
import '../card/glowing_border_container.dart';
import '../select/icon_map.dart';
import 'data/input/series_latest_value.dart';
import 'management/series_management_actions.dart';
import 'series_actions.dart';

class SeriesDefRenderer extends StatelessWidget {
  const SeriesDefRenderer({
    super.key,
    required this.seriesDef,
    this.managementMode = false,
  });

  final SeriesDef seriesDef;
  final bool managementMode;

  @override
  Widget build(BuildContext context) {
    return GlowingBorderContainer(
      glowColor: seriesDef.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                  tag: 'seriesDef_${seriesDef.uuid}',
                  child: Icon(
                    IconMap.iconData(seriesDef.iconName),
                    color: seriesDef.color,
                  ),
                ),
              ),
              Expanded(child: Text(seriesDef.name)),
              if (managementMode) SeriesManagementActions(seriesDef: seriesDef),
              if (!managementMode) SeriesActions(seriesDef: seriesDef),
            ],
          ),
          if (!managementMode)
            Divider(
              height: 0,
              thickness: 1,
              color: seriesDef.color,
            ),
          if (!managementMode) SeriesLatestValue(seriesDef: seriesDef),
        ],
      ),
    );
  }
}
