import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    // Unfortunately tooltip sometime causes null pointer exception when showing while drag start
    // return Tooltip(
    //   message: LocaleKeys.commons_list_dragTooltip.tr(),
    //   child:

    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.all(ThemeUtils.defaultPadding),
        child: Icon(Icons.drag_handle_outlined, size: ThemeUtils.iconSizeScaled),
      ),
    );
  }
}
