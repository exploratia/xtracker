import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/card/settings_card.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';

class AnalyticsSettingsCard extends StatelessWidget {
  const AnalyticsSettingsCard({super.key, required this.infoDlgContent, required this.title, required this.children});

  final Widget infoDlgContent;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      spacing: ThemeUtils.verticalSpacingLarge,
      title: Row(
        spacing: ThemeUtils.horizontalSpacing,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OverflowText(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            expanded: false,
            flexible: true,
          ),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () => Dialogs.simpleOkDialog(
              SingleChildScrollViewWithScrollbar(
                useHorizontalScreenPaddingForScrollbar: true,
                child: infoDlgContent,
              ),
              context,
              title: title,
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      children: children,
    );
  }
}

class TrendViewSettingsCard extends StatelessWidget {
  const TrendViewSettingsCard({
    super.key,
    required this.trendInfoDialogContent,
    required this.children,
  });

  final Widget trendInfoDialogContent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSettingsCard(infoDlgContent: trendInfoDialogContent, title: LocaleKeys.seriesDataAnalytics_trend_title.tr(), children: children);
  }
}

class SimpleInfoDlgContent extends StatelessWidget {
  const SimpleInfoDlgContent({super.key, this.info, this.children});

  final String? info;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ThemeUtils.verticalSpacingLarge,
      children: children != null
          ? children!
          : [
              if (info != null) Text(info!),
            ],
    );
  }
}
