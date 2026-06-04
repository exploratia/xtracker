import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

import '../model/series/series_def.dart';
import 'device_storage/device_storage.dart';
import 'device_storage/device_storage_keys.dart';
import 'launch_uri.dart';
import 'logging/flutter_simple_logging.dart';

class AppIconQuickActions {
  static const _actionOpenExploratia = 'open_exploratia';
  static const _actionSeriesAddPrefix = 'series_add_';
  static const _quickActionIconOpenUrl = 'qa_open_url';
  static const _quickActionIconSeriesAdd = 'qa_series_add';
  static const _maxQuickActionCount = 4;
  static const _quickActions = QuickActions();
  static String? _pendingSeriesQuickActionSeriesId;

  static Future<void> init() async {
    if (!_isQuickActionsSupportedPlatform()) {
      return;
    }

    try {
      await _quickActions.initialize((String actionType) {
        if (actionType == _actionOpenExploratia) {
          LaunchUri.launchUriExploratia();
          return;
        }
        if (actionType.startsWith(_actionSeriesAddPrefix)) {
          var seriesUuid = actionType.substring(_actionSeriesAddPrefix.length);
          if (seriesUuid.isNotEmpty) {
            _pendingSeriesQuickActionSeriesId = seriesUuid;
          }
        }
      });

      await refreshSeriesShortcutItems(const []);
    } catch (err) {
      SimpleLogging.w('Could not initialize app icon quick actions', error: err);
    }
  }

  static String? consumePendingSeriesQuickActionSeriesId() {
    var res = _pendingSeriesQuickActionSeriesId;
    _pendingSeriesQuickActionSeriesId = null;
    return res;
  }

  static Future<Set<String>> readEnabledSeriesQuickActions() async {
    var rawSeriesIds = await DeviceStorage.read(DeviceStorageKeys.seriesQuickActions);
    if (rawSeriesIds == null || rawSeriesIds.trim().isEmpty) {
      return {};
    }

    return rawSeriesIds.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  }

  static Future<bool> isSeriesQuickActionEnabled(String seriesUuid) async {
    return (await readEnabledSeriesQuickActions()).contains(seriesUuid);
  }

  static Future<void> setSeriesQuickActionEnabled(String seriesUuid, bool enabled) async {
    var quickActionSeriesIds = await readEnabledSeriesQuickActions();
    if (enabled) {
      quickActionSeriesIds.add(seriesUuid);
    } else {
      quickActionSeriesIds.remove(seriesUuid);
    }
    await _storeEnabledSeriesQuickActions(quickActionSeriesIds);
  }

  static Future<Set<String>> cleanUpOrphanedSeriesQuickActions(Iterable<String> validSeriesUuids) async {
    var validSeriesUuidSet = validSeriesUuids.toSet();
    var quickActionSeriesIds = await readEnabledSeriesQuickActions();
    var filtered = quickActionSeriesIds.where(validSeriesUuidSet.contains).toSet();
    if (filtered.length != quickActionSeriesIds.length) {
      await _storeEnabledSeriesQuickActions(filtered);
    }
    return filtered;
  }

  static Future<void> refreshSeriesShortcutItems(
    List<SeriesDef> series, {
    Set<String>? enabledSeriesIds,
  }) async {
    if (!_isQuickActionsSupportedPlatform()) {
      return;
    }

    try {
      var quickActionSeriesIds = enabledSeriesIds ?? await readEnabledSeriesQuickActions();
      var shortcutItems = _buildShortcutItems(series, quickActionSeriesIds);
      await _quickActions.setShortcutItems(shortcutItems);
    } catch (err) {
      SimpleLogging.w('Could not refresh app icon quick actions', error: err);
    }
  }

  static Future<void> _storeEnabledSeriesQuickActions(Set<String> seriesIds) async {
    if (seriesIds.isEmpty) {
      await DeviceStorage.delete(DeviceStorageKeys.seriesQuickActions);
      return;
    }
    var sortedSeriesIds = seriesIds.toList()..sort();
    await DeviceStorage.write(DeviceStorageKeys.seriesQuickActions, sortedSeriesIds.join(','));
  }

  static List<ShortcutItem> _buildShortcutItems(List<SeriesDef> series, Set<String> enabledSeriesIds) {
    var useAndroidIcon = defaultTargetPlatform == TargetPlatform.android;
    var shortcutItems = <ShortcutItem>[
      ShortcutItem(
        type: _actionOpenExploratia,
        localizedTitle: 'exploratia.de',
        icon: useAndroidIcon ? _quickActionIconOpenUrl : null,
      ),
    ];

    var maxSeriesQuickActions = _maxQuickActionCount - shortcutItems.length;
    if (maxSeriesQuickActions <= 0) {
      return shortcutItems;
    }

    var enabledSeries = series.where((s) => enabledSeriesIds.contains(s.uuid)).take(maxSeriesQuickActions);
    for (var seriesDef in enabledSeries) {
      shortcutItems.add(
        ShortcutItem(
          type: '$_actionSeriesAddPrefix${seriesDef.uuid}',
          localizedTitle: seriesDef.name,
          icon: useAndroidIcon ? _quickActionIconSeriesAdd : null,
        ),
      );
    }

    return shortcutItems;
  }

  static bool _isQuickActionsSupportedPlatform() {
    if (kIsWeb) {
      return false;
    }
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }
}
