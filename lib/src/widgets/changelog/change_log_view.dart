import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../model/changelog/change_log_entry.dart';
import '../../util/app_info.dart';
import '../../util/theme_utils.dart';
import '../controls/appbar/gradient_app_bar.dart';
import '../controls/card/settings_card.dart';
import '../controls/layout/scroll_footer.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import 'change_log_entries_view.dart';

/// Displays release notes and delegates closing to the caller.
class ChangeLogView extends StatelessWidget {
  const ChangeLogView({
    super.key,
    required this.entries,
    required this.onDismiss,
  });

  /// Release notes to display, ordered from newest to oldest.
  final List<ChangeLogEntry> entries;

  /// Called when either confirmation button is pressed.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Row(
          children: [
            SizedBox(
              width: 40,
              child: Assets.images.logos.appLogoWhite.image(fit: BoxFit.cover),
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.commons_dialog_btn_okay.tr(),
            onPressed: onDismiss,
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollViewWithScrollbar(
          useScreenPadding: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              spacing: ThemeUtils.screenPadding,
              children: [
                SettingsCard.singleEntry(
                  title: LocaleKeys.changeLog_title.tr(),
                  showDivider: true,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: ThemeUtils.verticalSpacing,
                    children: [
                      Text(
                        LocaleKeys.changeLog_label_versionChanged.tr(
                          args: [
                            AppInfo.version,
                          ],
                        ),
                      ),
                      const SizedBox(height: ThemeUtils.verticalSpacingSmall),
                      ChangeLogEntriesView(entries: entries),
                      const SizedBox(height: ThemeUtils.verticalSpacingSmall),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: onDismiss,
                          child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
                const ScrollFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
