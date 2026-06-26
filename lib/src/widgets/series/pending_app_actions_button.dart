import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../providers/series_provider.dart';
import '../../util/pending_app_actions.dart';
import '../../util/theme_utils.dart';
import '../administration/settings/settings_controller.dart';
import 'pending_app_action_executor.dart';

class PendingAppActionsButton extends StatelessWidget {
  const PendingAppActionsButton({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PendingAppActions.listenable(),
      builder: (context, _, _) {
        var count = PendingAppActions.count;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: LocaleKeys.seriesDashboard_pendingActions_tooltip.tr(args: [count.toString()]),
          onPressed: () => _showPendingActionsPopup(context),
          icon: Badge.count(
            count: count,
            child: const Icon(Icons.notifications_active_outlined),
          ),
        );
      },
    );
  }

  Future<void> _showPendingActionsPopup(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: ThemeUtils.animationDurationShort),
      pageBuilder: (popupContext, _, _) {
        var mediaQueryData = MediaQuery.of(popupContext);
        var top = mediaQueryData.padding.top + kToolbarHeight;
        var maxHeight = math.max(220.0, mediaQueryData.size.height - top - ThemeUtils.screenPadding * 2);

        return Stack(
          children: [
            Positioned(
              top: top,
              left: ThemeUtils.defaultPadding,
              right: ThemeUtils.defaultPadding,
              child: Align(
                alignment: Alignment.topRight,
                child: _PendingActionsPopup(
                  actionContext: context,
                  maxHeight: math.min(420.0, maxHeight),
                  settingsController: settingsController,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }
}

class _PendingActionsPopup extends StatelessWidget {
  const _PendingActionsPopup({
    required this.actionContext,
    required this.maxHeight,
    required this.settingsController,
  });

  final BuildContext actionContext;
  final double maxHeight;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Material(
      elevation: ThemeUtils.elevation * 2,
      color: themeData.dialogTheme.backgroundColor ?? themeData.colorScheme.surface,
      borderRadius: ThemeUtils.borderRadiusCircular,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: maxHeight,
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: PendingAppActions.listenable(),
          builder: (context, _, _) {
            var actions = PendingAppActions.items();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ThemeUtils.defaultPadding,
                    ThemeUtils.defaultPadding,
                    ThemeUtils.defaultPadding,
                    ThemeUtils.paddingSmall,
                  ),
                  child: Text(
                    LocaleKeys.seriesDashboard_pendingActions_title.tr(),
                    style: themeData.textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                if (actions.isEmpty)
                  Padding(
                    padding: ThemeUtils.screenPaddingAll,
                    child: Text(LocaleKeys.seriesDashboard_pendingActions_label_empty.tr()),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: math.max(120.0, maxHeight - 56)),
                    child: Scrollbar(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: ThemeUtils.paddingSmall),
                        itemCount: actions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          var action = actions[index];
                          return _PendingActionTile(
                            action: action,
                            actionContext: actionContext,
                            settingsController: settingsController,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PendingActionTile extends StatelessWidget {
  const _PendingActionTile({
    required this.action,
    required this.actionContext,
    required this.settingsController,
  });

  final PendingAppAction action;
  final BuildContext actionContext;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_iconData()),
      title: Text(_title(context)),
      subtitle: Text(_subtitle()),
      trailing: IconButton(
        tooltip: LocaleKeys.commons_dialog_btn_delete.tr(),
        onPressed: () => PendingAppActions.remove(action.id),
        icon: const Icon(Icons.delete_outline),
      ),
      onTap: () => _consumeAndExecute(context),
    );
  }

  IconData _iconData() {
    return switch (action.type) {
      PendingAppActionType.seriesValue => Icons.add_chart_outlined,
      PendingAppActionType.backupReminder => Icons.backup_outlined,
    };
  }

  String _title(BuildContext context) {
    return switch (action.type) {
      PendingAppActionType.seriesValue => LocaleKeys.seriesDashboard_pendingActions_label_seriesValue.tr(args: [_seriesName(context)]),
      PendingAppActionType.backupReminder => LocaleKeys.seriesDashboard_pendingActions_label_backupReminder.tr(),
    };
  }

  String _subtitle() {
    return switch (action.type) {
      PendingAppActionType.seriesValue => switch (action.seriesSource) {
        PendingSeriesActionSource.quickAction => LocaleKeys.seriesDashboard_pendingActions_source_quickAction.tr(),
        PendingSeriesActionSource.notification => LocaleKeys.seriesDashboard_pendingActions_source_notification.tr(),
        null => '',
      },
      PendingAppActionType.backupReminder => LocaleKeys.seriesDashboard_pendingActions_source_backupReminder.tr(),
    };
  }

  String _seriesName(BuildContext context) {
    var seriesUuid = action.seriesUuid;
    if (seriesUuid == null) {
      return '';
    }

    var seriesDef = context.watch<SeriesProvider>().series.where((seriesDef) => seriesDef.uuid == seriesUuid).firstOrNull;
    return seriesDef?.name ?? seriesUuid;
  }

  Future<void> _consumeAndExecute(BuildContext popupContext) async {
    var consumedAction = PendingAppActions.take(action.id);
    if (consumedAction == null) {
      return;
    }

    Navigator.of(popupContext).pop();
    if (!actionContext.mounted) {
      return;
    }

    await PendingAppActionExecutor.execute(
      actionContext,
      consumedAction,
      settingsController: settingsController,
    );
  }
}
