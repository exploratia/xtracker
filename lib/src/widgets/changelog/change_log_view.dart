import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../util/app_info.dart';
import '../../util/theme_utils.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/appbar/gradient_app_bar.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';

class ChangeLogView extends StatelessWidget {
  const ChangeLogView({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final entries = settingsController.changeLogEntries;

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
      ),
      body: SafeArea(
        child: SingleChildScrollViewWithScrollbar(
          useScreenPadding: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              child: Padding(
                padding: ThemeUtils.cardPaddingAll,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: ThemeUtils.verticalSpacing,
                  children: [
                    Text(
                      LocaleKeys.changeLog_title.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      LocaleKeys.changeLog_label_versionChanged.tr(
                        args: [
                          AppInfo.version,
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(),
                    ...entries.map((entry) => _ChangeLogEntryView(version: entry.version, message: entry.message)),
                    const SizedBox(height: ThemeUtils.verticalSpacingSmall),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: settingsController.dismissChangeLog,
                        child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
                      ),
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

class _ChangeLogEntryView extends StatelessWidget {
  const _ChangeLogEntryView({
    required this.version,
    required this.message,
  });

  final String version;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.new_releases_outlined),
      ),
      title: Text(
        LocaleKeys.changeLog_label_version.tr(args: [version]),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall),
        child: Text(message),
      ),
    );
  }
}
