import 'package:flutter/material.dart';

import '../../model/series/series_def.dart';
import '../../util/theme_utils.dart';
import '../controls/card/glowing_border_container.dart';
import '../controls/select/icon_map.dart';
import '../controls/text/overflow_text.dart';
import 'data/view/series_latest_value_renderer.dart';
import 'management/series_management_actions.dart';
import 'management/series_management_drag_handle.dart';
import 'series_actions.dart';

class SeriesDefRenderer extends StatelessWidget {
  const SeriesDefRenderer({
    super.key,
    required this.seriesDef,
    this.managementMode = false,
    required this.index,
  });

  final SeriesDef seriesDef;
  final bool managementMode;
  final int index;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (managementMode) {
      content = LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        var twoRows = (constraints.maxWidth < 500);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Builder(
                  builder: (BuildContext context) {
                    if (twoRows) {
                      return Column(
                        children: [
                          _SeriesIconAndName(seriesDef: seriesDef, verticalPadding: ThemeUtils.defaultPadding),
                          Divider(
                            height: 2,
                            thickness: 2,
                            color: seriesDef.color,
                          ),
                          SeriesManagementActions(seriesDef: seriesDef),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _SeriesIconAndName(seriesDef: seriesDef),
                          _LeftBorder(color: seriesDef.color, child: SeriesManagementActions(seriesDef: seriesDef)),
                        ],
                      );
                    }
                  },
                ),
              ),
              _LeftBorder(color: seriesDef.color, child: SeriesManagementDragHandle(index: index)),
            ],
          ),
        );
      });
    } else {
      content = IntrinsicHeight(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SeriesIconAndName(seriesDef: seriesDef),
                _LeftBorder(color: seriesDef.color, child: SeriesActions(seriesDef: seriesDef)),
              ],
            ),
            _HDivider(seriesDef: seriesDef),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding, vertical: ThemeUtils.defaultPadding / 2),
              child: SeriesLatestValueRenderer(seriesDef: seriesDef),
            )),
          ],
        ),
      );
    }

    return GlowingBorderContainer(
      glowColor: seriesDef.color,
      child: content,
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider({required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 2,
      thickness: 2,
      color: seriesDef.color,
    );
  }
}

class _SeriesIconAndName extends StatelessWidget {
  const _SeriesIconAndName({
    required this.seriesDef,
    this.verticalPadding = 0,
  });

  final SeriesDef seriesDef;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding, vertical: verticalPadding),
            child: Hero(
              tag: 'seriesDef_${seriesDef.uuid}',
              child: Icon(
                IconMap.iconData(seriesDef.iconName),
                color: seriesDef.color,
              ),
            ),
          ),
          OverflowText(seriesDef.name),
        ],
      ),
    );
  }
}

class _LeftBorder extends StatelessWidget {
  const _LeftBorder({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: color,
            width: 2.0,
          ),
        ),
      ),
      child: child,
    );
  }
}
