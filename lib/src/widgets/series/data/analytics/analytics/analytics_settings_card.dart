import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/card/settings_card.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';

class AnalyticsSettingsCard extends StatelessWidget {
  const AnalyticsSettingsCard({
    super.key,
    required this.analyticsSettingsCardEntries,
  });

  AnalyticsSettingsCard.singleEntry({super.key, required String title, Widget? infoDlgContent, required Widget content})
      : analyticsSettingsCardEntries = [AnalyticsSettingsCardEntry(title: title, infoDlgContent: infoDlgContent, content: content)];

  final List<AnalyticsSettingsCardEntry> analyticsSettingsCardEntries;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      settingCardEntries: analyticsSettingsCardEntries
          .map(
            (e) => SettingsCardEntry(
                title: Row(
                  spacing: ThemeUtils.horizontalSpacing,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OverflowText(
                      e.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      expanded: false,
                      flexible: true,
                    ),
                    if (e.infoDlgContent != null)
                      IconButton(
                        iconSize: ThemeUtils.iconSizeScaled,
                        tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
                        onPressed: () => Dialogs.simpleOkDialog(
                          SingleChildScrollViewWithScrollbar(
                            useHorizontalScreenPaddingForScrollbar: true,
                            child: e.infoDlgContent!,
                          ),
                          context,
                          title: e.title,
                        ),
                        icon: const Icon(Icons.info_outline),
                      ),
                  ],
                ),
                content: e.content),
          )
          .toList(),
    );
  }
}

class AnalyticsSettingsCardEntry {
  final String title;
  final Widget? infoDlgContent;
  final Widget content;

  AnalyticsSettingsCardEntry({required this.title, required this.content, this.infoDlgContent});
}

class TrendViewSettingsCard extends StatelessWidget {
  const TrendViewSettingsCard({
    super.key,
    required this.trendInfoDialogContent,
    required this.child,
  });

  final Widget trendInfoDialogContent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSettingsCard.singleEntry(infoDlgContent: trendInfoDialogContent, title: LocaleKeys.seriesDataAnalytics_trend_title.tr(), content: child);
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
