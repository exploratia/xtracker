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
    PendingAppActions.enqueueDebugDummyActionsIfEnabled();
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
        var bottom = mediaQueryData.padding.bottom;

        return Stack(
          children: [
            Positioned(
              top: top,
              bottom: bottom,
              left: 0,
              right: 0,
              child: _PendingActionsPopup(
                actionContext: context,
                settingsController: settingsController,
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
    required this.settingsController,
  });

  final BuildContext actionContext;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ValueListenableBuilder<int>(
          valueListenable: PendingAppActions.listenable(),
          builder: (context, _, _) {
            var actions = PendingAppActions.items();

            return _PendingActionsList(
              actions: actions,
              actionContext: actionContext,
              settingsController: settingsController,
            );
          },
        ),
      ),
    );
  }
}

class _PendingActionsList extends StatefulWidget {
  const _PendingActionsList({
    required this.actions,
    required this.actionContext,
    required this.settingsController,
  });

  final List<PendingAppAction> actions;
  final BuildContext actionContext;
  final SettingsController settingsController;

  @override
  State<_PendingActionsList> createState() => _PendingActionsListState();
}

class _PendingActionsListState extends State<_PendingActionsList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var scrollbarTheme = themeData.scrollbarTheme;
    var thumbColor = scrollbarTheme.thumbColor?.resolve(const <WidgetState>{}) ?? themeData.colorScheme.primary;
    var radius = scrollbarTheme.radius ?? Radius.zero;
    var thickness = scrollbarTheme.thickness?.resolve(const <WidgetState>{});
    var interactive = scrollbarTheme.interactive ?? true;

    return RawScrollbar(
      controller: _scrollController,
      thumbColor: thumbColor,
      radius: radius,
      thickness: thickness,
      interactive: interactive,
      mainAxisMargin: 0,
      crossAxisMargin: 0,
      padding: EdgeInsets.zero,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: widget.actions.length,
        separatorBuilder: (context, index) => const SizedBox(height: ThemeUtils.defaultPadding),
        itemBuilder: (context, index) {
          var action = widget.actions[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              ThemeUtils.defaultPadding * 2,
              index == 0 ? ThemeUtils.defaultPadding : 0,
              ThemeUtils.defaultPadding * 2,
              index == widget.actions.length - 1 ? ThemeUtils.defaultPadding : 0,
            ),
            child: _PendingActionCard(
              action: action,
              actionContext: widget.actionContext,
              settingsController: widget.settingsController,
            ),
          );
        },
      ),
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  const _PendingActionCard({
    required this.action,
    required this.actionContext,
    required this.settingsController,
  });

  final PendingAppAction action;
  final BuildContext actionContext;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: ThemeUtils.cardBorderRadius,
        onTap: () => _consumeAndExecute(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeUtils.defaultPadding,
            vertical: ThemeUtils.paddingSmall,
          ),
          child: Row(
            children: [
              _PendingActionIcon(action: action),
              const SizedBox(width: ThemeUtils.horizontalSpacing),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodyLarge,
                    ),
                    Text(
                      _subtitle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.commons_dialog_btn_delete.tr(),
                onPressed: () => PendingAppActions.remove(action.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (action.type) {
      PendingAppActionType.seriesValue => LocaleKeys.seriesDashboard_pendingActions_label_seriesValue.tr(args: [_seriesName(context)]),
      PendingAppActionType.backupReminder => LocaleKeys.seriesDashboard_pendingActions_label_backupReminder.tr(),
      PendingAppActionType.debugDummy => LocaleKeys.seriesDashboard_pendingActions_label_debugDummy.tr(args: [action.id]),
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
      PendingAppActionType.debugDummy => LocaleKeys.seriesDashboard_pendingActions_source_debugDummy.tr(),
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

class _PendingActionIcon extends StatelessWidget {
  const _PendingActionIcon({
    required this.action,
  });

  final PendingAppAction action;

  @override
  Widget build(BuildContext context) {
    if (action.type == PendingAppActionType.seriesValue) {
      var seriesUuid = action.seriesUuid;
      var seriesDef = seriesUuid == null ? null : context.watch<SeriesProvider>().series.where((seriesDef) => seriesDef.uuid == seriesUuid).firstOrNull;
      return Icon(
        seriesDef?.iconData() ?? Icons.add_chart_outlined,
        color: seriesDef?.color,
      );
    }

    return Icon(
      switch (action.type) {
        PendingAppActionType.backupReminder => Icons.backup_outlined,
        PendingAppActionType.debugDummy => Icons.bug_report_outlined,
        PendingAppActionType.seriesValue => Icons.add_outlined,
      },
    );
  }
}
