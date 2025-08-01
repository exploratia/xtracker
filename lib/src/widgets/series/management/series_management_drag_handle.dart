import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';

class SeriesManagementDragHandle extends StatelessWidget {
  const SeriesManagementDragHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Tooltip(
          message: LocaleKeys.seriesDefRenderer_action_dragSeries_tooltip.tr(),
          child: const Icon(Icons.drag_handle_outlined),
        ),
      ),
    );
  }
}
