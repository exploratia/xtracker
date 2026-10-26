import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/changelog/change_log_entry.dart';
import '../../util/theme_utils.dart';

/// Renders release notes inside the caller's layout and scroll view.
class ChangeLogEntriesView extends StatelessWidget {
  const ChangeLogEntriesView({super.key, required this.entries});

  /// Release notes to display in the supplied order.
  final List<ChangeLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ThemeUtils.verticalSpacing,
      children: [for (final entry in entries) _ChangeLogEntryView(entry: entry)],
    );
  }
}

class _ChangeLogEntryView extends StatelessWidget {
  const _ChangeLogEntryView({required this.entry});

  final ChangeLogEntry entry;

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
        LocaleKeys.changeLog_label_version.tr(args: [entry.version]),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall),
        child: Text(entry.messageKey.tr()),
      ),
    );
  }
}
