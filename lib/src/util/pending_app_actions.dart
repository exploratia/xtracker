import 'package:flutter/foundation.dart';

import 'logging/flutter_simple_logging.dart';

enum PendingAppActionType {
  seriesValue,
  backupReminder,
  debugDummy,
}

enum PendingSeriesActionSource {
  quickAction,
  notification,
}

class PendingAppAction {
  final String id;
  final PendingAppActionType type;
  final String? seriesUuid;
  final PendingSeriesActionSource? seriesSource;
  final int? notificationId;
  final bool executeAutomatically;
  final DateTime createdAt;

  const PendingAppAction({
    required this.id,
    required this.type,
    required this.createdAt,
    this.executeAutomatically = false,
    this.seriesUuid,
    this.seriesSource,
    this.notificationId,
  });

  PendingAppAction copyWith({
    bool? executeAutomatically,
    DateTime? createdAt,
  }) {
    return PendingAppAction(
      id: id,
      type: type,
      createdAt: createdAt ?? this.createdAt,
      executeAutomatically: executeAutomatically ?? this.executeAutomatically,
      seriesUuid: seriesUuid,
      seriesSource: seriesSource,
      notificationId: notificationId,
    );
  }
}

class PendingAppActions {
  static final ValueNotifier<int> _versionNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> _externalSeriesActionVersionNotifier = ValueNotifier<int>(0);
  static final List<PendingAppAction> _items = [];
  static final List<PendingAppAction> _directActions = [];
  static final Set<int> _handledNotificationIdsThisRun = {};
  static const bool _debugShowDummyActions = true;
  static int _nextActionId = 0;
  static bool _backupReminderDismissedThisRun = false;
  static bool _automaticActionArmed = true;
  static bool _debugDummyActionsQueued = false;

  static int get count => _items.length;

  static bool get hasPendingExternalSeriesAction =>
      _directActions.any((item) => item.type == PendingAppActionType.seriesValue) || _items.any((item) => item.type == PendingAppActionType.seriesValue);

  static bool get hasAutomaticAction => _directActions.isNotEmpty || _items.isNotEmpty;

  static ValueListenable<int> listenable() {
    return _versionNotifier;
  }

  static ValueListenable<int> externalSeriesActionListenable() {
    return _externalSeriesActionVersionNotifier;
  }

  static int pendingExternalSeriesActionVersion() {
    return _externalSeriesActionVersionNotifier.value;
  }

  static List<PendingAppAction> items() {
    return List.unmodifiable(_sortedItems());
  }

  static PendingAppAction? takeNextAutomaticAction() {
    if (_directActions.isEmpty && _items.isEmpty) {
      return null;
    }

    var itemIdx = _indexOfNextAutomaticAction();
    if (itemIdx < 0) {
      return null;
    }

    _automaticActionArmed = false;
    if (_directActions.isNotEmpty) {
      return _takeDirectAt(itemIdx);
    }
    return _takeAt(itemIdx, rearmIfEmpty: false);
  }

  static void completeAutomaticAction() {
    if (_directActions.isEmpty && _items.isEmpty) {
      _automaticActionArmed = true;
    }
  }

  static void enqueueSeriesValue({
    required String seriesUuid,
    required PendingSeriesActionSource source,
    int? notificationId,
    bool executeAutomatically = false,
  }) {
    if (seriesUuid.trim().isEmpty) {
      SimpleLogging.d('Ignored pending series action: missing series uuid.');
      return;
    }
    if (notificationId != null && _handledNotificationIdsThisRun.contains(notificationId)) {
      SimpleLogging.d('Ignored pending notification action: notification already handled. notificationId=$notificationId');
      return;
    }
    if (executeAutomatically) {
      _enqueueDirectSeriesValue(
        seriesUuid: seriesUuid,
        source: source,
        notificationId: notificationId,
      );
      return;
    }
    if (notificationId != null) {
      if (_directActions.any((item) => item.notificationId == notificationId)) {
        SimpleLogging.d('Ignored pending notification action: notification already queued for automatic execution. notificationId=$notificationId');
        return;
      }
      if (_items.any((item) => item.notificationId == notificationId)) {
        SimpleLogging.d('Ignored pending notification action: notification already queued. notificationId=$notificationId');
        return;
      }
    }

    var action = PendingAppAction(
      id: _buildActionId(),
      type: PendingAppActionType.seriesValue,
      seriesUuid: seriesUuid,
      seriesSource: source,
      notificationId: notificationId,
      executeAutomatically: executeAutomatically,
      createdAt: DateTime.now(),
    );
    _items.add(action);
    _notifyChanged();
    _externalSeriesActionVersionNotifier.value++;
    SimpleLogging.d(
      'Queued pending series action. actionId=${action.id}, seriesUuid=$seriesUuid, source=${source.name}, executeAutomatically=$executeAutomatically, pending=${_items.length}',
    );
  }

  static void _enqueueDirectSeriesValue({
    required String seriesUuid,
    required PendingSeriesActionSource source,
    int? notificationId,
  }) {
    if (notificationId != null && _directActions.any((item) => item.notificationId == notificationId)) {
      SimpleLogging.d('Ignored direct notification action: notification already queued for automatic execution. notificationId=$notificationId');
      return;
    }

    var existingNotificationAction = notificationId == null ? null : _removeQueuedNotificationAction(notificationId);
    if (source == PendingSeriesActionSource.quickAction) {
      _directActions.removeWhere((item) => item.seriesSource == PendingSeriesActionSource.quickAction);
    }

    var action = PendingAppAction(
      id: existingNotificationAction?.id ?? _buildActionId(),
      type: PendingAppActionType.seriesValue,
      seriesUuid: seriesUuid,
      seriesSource: source,
      notificationId: notificationId,
      executeAutomatically: true,
      createdAt: DateTime.now(),
    );
    _directActions.add(action);
    _notifyChanged();
    _externalSeriesActionVersionNotifier.value++;
    SimpleLogging.d(
      'Queued direct series action. actionId=${action.id}, seriesUuid=$seriesUuid, source=${source.name}, pending=${_items.length}, direct=${_directActions.length}',
    );
  }

  static void enqueueBackupReminder() {
    if (_backupReminderDismissedThisRun || _items.any((item) => item.type == PendingAppActionType.backupReminder)) {
      return;
    }

    var action = PendingAppAction(
      id: _buildActionId(),
      type: PendingAppActionType.backupReminder,
      createdAt: DateTime.now(),
    );
    _items.add(action);
    _notifyChanged();
    SimpleLogging.d('Queued pending backup reminder. actionId=${action.id}, pending=${_items.length}');
  }

  static void enqueueDebugDummyActionsIfEnabled() {
    if (!_debugShowDummyActions || _debugDummyActionsQueued) {
      return;
    }

    for (var idx = 1; idx <= 20; idx++) {
      _items.add(
        PendingAppAction(
          id: _buildActionId(),
          type: PendingAppActionType.debugDummy,
          createdAt: DateTime.now().add(Duration(milliseconds: idx)),
        ),
      );
    }
    _debugDummyActionsQueued = true;
    _notifyChanged();
    SimpleLogging.d('Queued debug dummy pending app actions. pending=${_items.length}');
  }

  @visibleForTesting
  static void enqueueDebugDummyActionForTests() {
    _items.add(
      PendingAppAction(
        id: _buildActionId(),
        type: PendingAppActionType.debugDummy,
        createdAt: DateTime.now(),
      ),
    );
    _notifyChanged();
  }

  static PendingAppAction? take(String actionId) {
    var itemIdx = _items.indexWhere((item) => item.id == actionId);
    if (itemIdx < 0) {
      return null;
    }

    return _takeAt(itemIdx);
  }

  static PendingAppAction _takeAt(int itemIdx, {bool rearmIfEmpty = true}) {
    var action = _items.removeAt(itemIdx);
    if (action.type == PendingAppActionType.backupReminder) {
      _backupReminderDismissedThisRun = true;
    }
    if (action.notificationId != null) {
      _handledNotificationIdsThisRun.add(action.notificationId!);
    }
    if (rearmIfEmpty && _items.isEmpty) {
      _automaticActionArmed = true;
    }
    _notifyChanged();
    SimpleLogging.d('Consumed pending app action. actionId=${action.id}, type=${action.type.name}, remaining=${_items.length}');
    return action;
  }

  static PendingAppAction _takeDirectAt(int itemIdx) {
    var action = _directActions.removeAt(itemIdx);
    if (action.notificationId != null) {
      _handledNotificationIdsThisRun.add(action.notificationId!);
    }
    _notifyChanged();
    SimpleLogging.d('Consumed direct app action. actionId=${action.id}, type=${action.type.name}, remainingDirect=${_directActions.length}');
    return action;
  }

  static void remove(String actionId) {
    take(actionId);
  }

  static void removeBackupReminder() {
    _items.removeWhere((item) => item.type == PendingAppActionType.backupReminder);
    if (_items.isEmpty) {
      _automaticActionArmed = true;
    }
    _notifyChanged();
  }

  @visibleForTesting
  static void resetForTests() {
    _items.clear();
    _directActions.clear();
    _handledNotificationIdsThisRun.clear();
    _nextActionId = 0;
    _backupReminderDismissedThisRun = false;
    _automaticActionArmed = true;
    _debugDummyActionsQueued = false;
    _versionNotifier.value = 0;
    _externalSeriesActionVersionNotifier.value = 0;
  }

  static String _buildActionId() {
    _nextActionId++;
    return 'pending_app_action_$_nextActionId';
  }

  static void _notifyChanged() {
    _versionNotifier.value++;
  }

  static List<PendingAppAction> _sortedItems() {
    return List<PendingAppAction>.of(_items)..sort((a, b) {
      var priorityCompare = _priority(a).compareTo(_priority(b));
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  static int _indexOfNextAutomaticAction() {
    if (_directActions.isNotEmpty) {
      return _indexOfHighestPriorityDirectAction();
    }

    var explicitlyRequestedIdx = _indexOfHighestPriorityAction((item) => item.executeAutomatically);
    if (explicitlyRequestedIdx >= 0) {
      return explicitlyRequestedIdx;
    }
    if (!_automaticActionArmed) {
      return -1;
    }
    return _indexOfHighestPriorityAction((_) => true);
  }

  static PendingAppAction? _removeQueuedNotificationAction(int notificationId) {
    var existingNotificationIdx = _items.indexWhere((item) => item.notificationId == notificationId);
    if (existingNotificationIdx < 0) {
      return null;
    }
    return _items.removeAt(existingNotificationIdx);
  }

  static int _indexOfHighestPriorityDirectAction() {
    var bestIdx = 0;
    for (var idx = 1; idx < _directActions.length; idx++) {
      if (_priority(_directActions[idx]) < _priority(_directActions[bestIdx])) {
        bestIdx = idx;
      }
    }
    return bestIdx;
  }

  static int _indexOfHighestPriorityAction(bool Function(PendingAppAction item) predicate) {
    var bestIdx = -1;
    for (var idx = 0; idx < _items.length; idx++) {
      if (!predicate(_items[idx])) {
        continue;
      }
      if (bestIdx < 0 || _priority(_items[idx]) < _priority(_items[bestIdx])) {
        bestIdx = idx;
      }
    }
    return bestIdx;
  }

  static int _priority(PendingAppAction action) {
    return switch (action.type) {
      PendingAppActionType.seriesValue => switch (action.seriesSource) {
        PendingSeriesActionSource.quickAction => 0,
        PendingSeriesActionSource.notification => 1,
        null => 1,
      },
      PendingAppActionType.backupReminder => 2,
      PendingAppActionType.debugDummy => 3,
    };
  }
}
