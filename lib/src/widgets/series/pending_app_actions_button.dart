import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/series_def.dart';
import '../../providers/series_provider.dart';
import '../../util/app_series_notifications.dart';
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
    await AppSeriesNotifications.synchronizeActiveSeriesNotificationActions();
    if (!context.mounted || PendingAppActions.count == 0) {
      return;
    }
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
        var popupWidth = mediaQueryData.size.width < 520 ? mediaQueryData.size.width : 520.0;
        var popupMaxHeight = mediaQueryData.size.height - top - bottom;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(popupContext).pop(),
              ),
            ),
            Positioned(
              top: top,
              right: 0,
              child: SizedBox(
                width: popupWidth,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: popupMaxHeight),
                  child: _PendingActionsPopup(
                    actionContext: context,
                    settingsController: settingsController,
                  ),
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
    required this.settingsController,
  });

  final BuildContext actionContext;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PendingAppActions.listenable(),
      builder: (context, _, _) {
        var actions = PendingAppActions.items();

        return _PendingActionsList(
          actions: actions,
          actionContext: actionContext,
          settingsController: settingsController,
        );
      },
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
  static const Duration _removeDuration = Duration(milliseconds: ThemeUtils.animationDuration);

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final ScrollController _scrollController;
  late List<PendingAppAction> _actions;
  final Set<String> _pendingDeleteActionIds = {};
  bool _closeWhenEmptyScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _actions = List<PendingAppAction>.of(widget.actions);
  }

  @override
  void didUpdateWidget(covariant _PendingActionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncActions(widget.actions);
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
      child: AnimatedList(
        key: _listKey,
        controller: _scrollController,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        initialItemCount: _actions.length,
        itemBuilder: (context, index, animation) => _buildActionItem(
          context,
          _actions[index],
          index,
          animation,
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    PendingAppAction action,
    int index,
    Animation<double> animation,
  ) {
    return _PendingActionItemTransition(
      animation: animation,
      child: _buildActionItemContent(action, index),
    );
  }

  Widget _buildActionItemContent(PendingAppAction action, int index) {
    return Padding(
      key: ValueKey(action.id),
      padding: EdgeInsets.fromLTRB(
        ThemeUtils.defaultPadding * 2,
        ThemeUtils.verticalSpacing,
        ThemeUtils.defaultPadding * 2,
        index == _actions.length - 1 ? ThemeUtils.verticalSpacing : 0,
      ),
      child: _PendingActionCard(
        action: action,
        actionContext: widget.actionContext,
        settingsController: widget.settingsController,
        onDelete: () => _deleteAction(action),
        isInteractive: true,
      ),
    );
  }

  Future<void> _deleteAction(PendingAppAction action) async {
    var index = _actions.indexWhere((item) => item.id == action.id);
    if (index < 0) {
      return;
    }

    _pendingDeleteActionIds.add(action.id);
    _actions.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _PendingActionItemTransition(
        animation: animation,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ThemeUtils.defaultPadding * 2,
            ThemeUtils.verticalSpacing,
            ThemeUtils.defaultPadding * 2,
            index == _actions.length ? ThemeUtils.verticalSpacing : 0,
          ),
          child: _PendingActionCard(
            action: action,
            actionContext: widget.actionContext,
            settingsController: widget.settingsController,
            onDelete: null,
            isInteractive: false,
          ),
        ),
      ),
      duration: _removeDuration,
    );

    await AppSeriesNotifications.cancelActiveNotification(action.notificationId);
    await Future<void>.delayed(_removeDuration);
    PendingAppActions.remove(action.id);
    _pendingDeleteActionIds.remove(action.id);
    if (PendingAppActions.count == 0) {
      _closePopupWhenEmpty();
    }
  }

  void _syncActions(List<PendingAppAction> nextActions) {
    var visibleNextActions = nextActions.where((action) => !_pendingDeleteActionIds.contains(action.id)).toList();
    var nextIds = visibleNextActions.map((action) => action.id).toSet();
    var localIds = _actions.map((action) => action.id).toSet();

    for (var index = _actions.length - 1; index >= 0; index--) {
      var action = _actions[index];
      if (!nextIds.contains(action.id)) {
        _actions.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _PendingActionItemTransition(
            animation: animation,
            child: _buildRemovedActionItemContent(action, index),
          ),
          duration: _removeDuration,
        );
      }
    }

    for (var index = 0; index < visibleNextActions.length; index++) {
      var action = visibleNextActions[index];
      if (!localIds.contains(action.id)) {
        _actions.insert(index, action);
        _listKey.currentState?.insertItem(
          index,
          duration: const Duration(milliseconds: ThemeUtils.animationDurationShort),
        );
      }
    }

    var sameOrder = _actions.length == visibleNextActions.length;
    if (sameOrder) {
      for (var index = 0; index < _actions.length; index++) {
        if (_actions[index].id != visibleNextActions[index].id) {
          sameOrder = false;
          break;
        }
      }
    }
    if (!sameOrder) {
      _actions = List<PendingAppAction>.of(visibleNextActions);
    }

    if (visibleNextActions.isEmpty && PendingAppActions.count == 0) {
      _closePopupWhenEmpty(delay: _removeDuration);
    }
  }

  Future<void> _closePopupWhenEmpty({Duration delay = Duration.zero}) async {
    if (_closeWhenEmptyScheduled && delay > Duration.zero) {
      return;
    }
    _closeWhenEmptyScheduled = true;

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (!mounted || PendingAppActions.count != 0) {
      _closeWhenEmptyScheduled = false;
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _buildRemovedActionItemContent(PendingAppAction action, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ThemeUtils.defaultPadding * 2,
        ThemeUtils.verticalSpacing,
        ThemeUtils.defaultPadding * 2,
        index == _actions.length ? ThemeUtils.verticalSpacing : 0,
      ),
      child: _PendingActionCard(
        action: action,
        actionContext: widget.actionContext,
        settingsController: widget.settingsController,
        onDelete: null,
        isInteractive: false,
      ),
    );
  }
}

class _PendingActionItemTransition extends StatelessWidget {
  const _PendingActionItemTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SizeTransition(
        sizeFactor: curvedAnimation,
        alignment: AlignmentDirectional.topStart,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      ),
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  const _PendingActionCard({
    required this.action,
    required this.actionContext,
    required this.settingsController,
    required this.onDelete,
    required this.isInteractive,
  });

  final PendingAppAction action;
  final BuildContext actionContext;
  final SettingsController settingsController;
  final VoidCallback? onDelete;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: ThemeUtils.cardBorderRadius,
        onTap: isInteractive ? () => _consumeAndExecute(context) : null,
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
                      _subtitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: LocaleKeys.commons_dialog_btn_delete.tr(),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: ThemeUtils.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (action.type) {
      PendingAppActionType.seriesValue => _seriesValueTitle(context),
      PendingAppActionType.backupReminder => LocaleKeys.seriesDashboard_pendingActions_label_backupReminder.tr(),
      PendingAppActionType.debugDummy => LocaleKeys.seriesDashboard_pendingActions_label_debugDummy.tr(args: [action.id]),
    };
  }

  String _seriesValueTitle(BuildContext context) {
    if (action.seriesSource == PendingSeriesActionSource.notification) {
      return _seriesDef(context)?.notificationSettingsReadonly().reminderText ?? LocaleKeys.seriesEdit_seriesSettings_notifications_action_enterValue.tr();
    }
    return LocaleKeys.seriesDashboard_pendingActions_label_seriesValue.tr(args: [_seriesName(context)]);
  }

  String _subtitle(BuildContext context) {
    return switch (action.type) {
      PendingAppActionType.seriesValue => _seriesName(context),
      PendingAppActionType.backupReminder => LocaleKeys.seriesDashboard_pendingActions_source_backupReminder.tr(),
      PendingAppActionType.debugDummy => LocaleKeys.seriesDashboard_pendingActions_source_debugDummy.tr(),
    };
  }

  String _seriesName(BuildContext context) {
    var seriesUuid = action.seriesUuid;
    if (seriesUuid == null) {
      return '';
    }

    var seriesDef = _seriesDef(context);
    return seriesDef?.name ?? seriesUuid;
  }

  SeriesDef? _seriesDef(BuildContext context) {
    var seriesUuid = action.seriesUuid;
    if (seriesUuid == null) {
      return null;
    }

    return context.watch<SeriesProvider>().series.where((seriesDef) => seriesDef.uuid == seriesUuid).firstOrNull;
  }

  Future<void> _consumeAndExecute(BuildContext popupContext) async {
    var consumedAction = PendingAppActions.take(action.id);
    if (consumedAction == null) {
      return;
    }

    await AppSeriesNotifications.cancelActiveNotification(consumedAction.notificationId);
    if (!popupContext.mounted) {
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
