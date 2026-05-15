import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/dialogs.dart';
import '../../../util/theme_utils.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';

class InfoBtn extends StatelessWidget {
  const InfoBtn({super.key, required this.title, required this.content, this.tooltip});

  final dynamic title;
  final dynamic content;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: ThemeUtils.iconSizeScaled,
      tooltip: tooltip ?? LocaleKeys.commons_btn_info_tooltip.tr(),
      onPressed: () => Dialogs.simpleOkDialog(
        SingleChildScrollViewWithScrollbar(
          useHorizontalScreenPaddingForScrollbar: true,
          child: Dialogs.buildContentWidget(content),
        ),
        context,
        title: title,
      ),
      icon: const Icon(Icons.info_outline),
    );
  }
}
