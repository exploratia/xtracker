import 'package:flutter/foundation.dart';

import 'logging/flutter_simple_logging.dart';

enum PendingAppActionType {
  seriesValue,
  backupReminder,
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
  final DateTime createdAt;

  const PendingAppAction({
    required this.id,
    required this.type,
    required this.createdAt,
    this.seriesUuid,
    this.seriesSource,
    this.notificationId,
  });
}

class PendingAppActions {
  static final ValueNotifier<int> _versionNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> _externalSeriesActionVersionNotifier = ValueNotifier<int>(0);
  static final List<PendingAppAction> _items = [];
  static final Set<int> _handledNotificationIdsThisRun = {};
  static int _nextActionId = 0;
  static bool _backupReminderDismissedThisRun = false;
  static bool _automaticActionArmed = true;

  static int get count => _items.length;

  static bool get hasPendingExternalSeriesAction => _items.any((item) => item.type == PendingAppActionType.seriesValue);

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
    if (!_automaticActionArmed || _items.isEmpty) {
      return null;
    }

    _automaticActionArmed = false;
    var itemIdx = _indexOfHighestPriorityAction();
    if (itemIdx < 0) {
      return null;
    }
    return _takeAt(itemIdx, rearmIfEmpty: false);
  }

  static void completeAutomaticAction() {
    if (_items.isEmpty) {
      _automaticActionArmed = true;
    }
  }

  static void enqueueSeriesValue({
    required String seriesUuid,
    required PendingSeriesActionSource source,
    int? notificationId,
  }) {
    if (seriesUuid.trim().isEmpty) {
      SimpleLogging.d('Ignored pending series action: missing series uuid.');
      return;
    }
    if (notificationId != null && _handledNotificationIdsThisRun.contains(notificationId)) {
      SimpleLogging.d('Ignored pending notification action: notification already handled. notificationId=$notificationId');
      return;
    }
    if (notificationId != null && _items.any((item) => item.notificationId == notificationId)) {
      SimpleLogging.d('Ignored pending notification action: notification already queued. notificationId=$notificationId');
      return;
    }

    var action = PendingAppAction(
      id: _buildActionId(),
      type: PendingAppActionType.seriesValue,
      seriesUuid: seriesUuid,
      seriesSource: source,
      notificationId: notificationId,
      createdAt: DateTime.now(),
    );
    _items.add(action);
    _notifyChanged();
    _externalSeriesActionVersionNotifier.value++;
    SimpleLogging.d(
      'Queued pending series action. actionId=${action.id}, seriesUuid=$seriesUuid, source=${source.name}, pending=${_items.length}',
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
    _handledNotificationIdsThisRun.clear();
    _nextActionId = 0;
    _backupReminderDismissedThisRun = false;
    _automaticActionArmed = true;
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

  static int _indexOfHighestPriorityAction() {
    var bestIdx = -1;
    for (var idx = 0; idx < _items.length; idx++) {
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
    };
  }
}
