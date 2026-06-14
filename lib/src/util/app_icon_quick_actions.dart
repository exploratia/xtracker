import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  static const _quickActionIconSeriesAddPrefix = 'qa_series_add_';
  static const _maxQuickActionCountOnAndroid = 4;
  static const _seriesQuickActionIconCount = 12;
  static const _seriesQuickActionPaletteStartHexRgb = <int>[
    0xED1E79,
    0xED2B1E,
    0xED921E,
    0xE0ED1E,
    0x79ED1E,
    0x1EED2B,
    0x1EED92,
    0x1EE0ED,
    0x1E79ED,
    0x2B1EED,
    0x921EED,
    0xED1EE0,
  ];
  static const _quickActions = QuickActions();
  static String? _pendingSeriesQuickActionSeriesId;
  static int _quickActionResponseVersion = 0;
  static final ValueNotifier<int> _quickActionResponseVersionNotifier = ValueNotifier<int>(0);
  static String? _lastShortcutItemsSignature;
  static List<SeriesDef> _lastKnownSeries = const [];
  static final _seriesQuickActionPaletteHues = _seriesQuickActionPaletteStartHexRgb.map((hexRgb) => HSVColor.fromColor(_rgbToColor(hexRgb)).hue).toList();

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
            _quickActionResponseVersion++;
            _quickActionResponseVersionNotifier.value = _quickActionResponseVersion;
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

  static String? pendingSeriesQuickActionSeriesId() {
    return _pendingSeriesQuickActionSeriesId;
  }

  static int pendingSeriesQuickActionResponseVersion() {
    return _quickActionResponseVersion;
  }

  static ValueListenable<int> quickActionResponseVersionListenable() {
    return _quickActionResponseVersionNotifier;
  }

  static Future<Set<String>> readEnabledSeriesQuickActions(List<SeriesDef> series) async {
    return _enabledSeriesIds(series);
  }

  static Future<bool> isSeriesQuickActionEnabled(SeriesDef seriesDef) async {
    return seriesDef.quickActionsSettingsReadonly().showAddValueInAppContextMenu;
  }

  static Future<bool> setSeriesQuickActionEnabled(SeriesDef seriesDef, bool enabled) async {
    var quickActionsSettings = seriesDef.quickActionsSettingsEditable(() {});
    var wasEnabled = quickActionsSettings.showAddValueInAppContextMenu;
    if (wasEnabled == enabled) {
      return false;
    }

    quickActionsSettings.showAddValueInAppContextMenu = enabled;
    return true;
  }

  static Future<Set<String>> cleanUpOrphanedSeriesQuickActions(List<SeriesDef> series) async {
    return _enabledSeriesIds(series);
  }

  static Future<void> refreshSeriesShortcutItems(
    List<SeriesDef> series, {
    Set<String>? enabledSeriesIds,
  }) async {
    if (!_isQuickActionsSupportedPlatform()) {
      return;
    }

    try {
      _lastKnownSeries = List<SeriesDef>.unmodifiable(series);
      var hideExploratiaQuickActionUrl = await DeviceStorage.readBool(DeviceStorageKeys.quickActionsHideExploratiaUrl);
      var shortcutItems = _buildShortcutItems(
        series,
        enabledSeriesIds ?? _enabledSeriesIds(series),
        hideExploratiaQuickActionUrl: hideExploratiaQuickActionUrl,
      );

      var shortcutItemsSignature = _buildShortcutItemsSignature(shortcutItems);
      if (_lastShortcutItemsSignature == shortcutItemsSignature) {
        return;
      }
      await _quickActions.setShortcutItems(shortcutItems);
      _lastShortcutItemsSignature = shortcutItemsSignature;
    } catch (err) {
      SimpleLogging.w('Could not refresh app icon quick actions', error: err);
    }
  }

  static Future<void> refreshShortcutItemsFromCache() async {
    await refreshSeriesShortcutItems(_lastKnownSeries);
  }

  static Set<String> _enabledSeriesIds(List<SeriesDef> series) {
    return series.where((seriesDef) => seriesDef.quickActionsSettingsReadonly().showAddValueInAppContextMenu).map((seriesDef) => seriesDef.uuid).toSet();
  }

  static List<ShortcutItem> _buildShortcutItems(
    List<SeriesDef> series,
    Set<String> enabledSeriesIds, {
    required bool hideExploratiaQuickActionUrl,
  }) {
    var isAndroid = defaultTargetPlatform == TargetPlatform.android;
    var useAndroidIcon = isAndroid;
    var shortcutItems = <ShortcutItem>[];
    var showOpenLinkQuickAction = !hideExploratiaQuickActionUrl && (!isAndroid || enabledSeriesIds.length < _maxQuickActionCountOnAndroid);
    if (showOpenLinkQuickAction) {
      shortcutItems.add(
        ShortcutItem(
          type: _actionOpenExploratia,
          localizedTitle: 'exploratia.de',
          icon: useAndroidIcon ? _quickActionIconOpenUrl : null,
        ),
      );
    }

    var enabledSeries = series.where((s) => enabledSeriesIds.contains(s.uuid));
    for (var seriesDef in enabledSeries) {
      var iconIndex = _determineClosestSeriesQuickActionIconIndex(seriesDef.color);
      shortcutItems.add(
        ShortcutItem(
          type: '$_actionSeriesAddPrefix${seriesDef.uuid}',
          localizedTitle: seriesDef.name,
          icon: useAndroidIcon ? _quickActionIconNameForPaletteIndex(iconIndex) : null,
        ),
      );
    }

    return shortcutItems;
  }

  static int _determineClosestSeriesQuickActionIconIndex(Color color) {
    var hue = HSVColor.fromColor(color).hue;
    if (hue.isNaN) {
      hue = 0;
    }

    var closestIdx = 0;
    var smallestDistance = double.infinity;
    for (var idx = 0; idx < _seriesQuickActionPaletteHues.length; ++idx) {
      var distance = _circularHueDistance(hue, _seriesQuickActionPaletteHues[idx]);
      if (distance < smallestDistance) {
        smallestDistance = distance;
        closestIdx = idx;
      }
    }
    return closestIdx;
  }

  static double _circularHueDistance(double h1, double h2) {
    var diff = (h1 - h2).abs();
    return math.min(diff, 360 - diff);
  }

  static Color _rgbToColor(int hexRgb) {
    return Color(0xFF000000 | hexRgb);
  }

  static String _quickActionIconNameForPaletteIndex(int paletteIndex) {
    var normalizedIndex = paletteIndex % _seriesQuickActionIconCount;
    if (normalizedIndex < 0) {
      normalizedIndex += _seriesQuickActionIconCount;
    }
    return '$_quickActionIconSeriesAddPrefix${normalizedIndex.toString().padLeft(2, '0')}';
  }

  static String _buildShortcutItemsSignature(List<ShortcutItem> shortcutItems) {
    return jsonEncode(
      shortcutItems
          .map(
            (item) => {
              'type': item.type,
              'localizedTitle': item.localizedTitle,
              'localizedSubtitle': item.localizedSubtitle,
              'icon': item.icon,
            },
          )
          .toList(),
    );
  }

  static bool _isQuickActionsSupportedPlatform() {
    if (kIsWeb) {
      return false;
    }
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }
}
