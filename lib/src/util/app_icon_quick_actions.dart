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
  static String? _lastShortcutItemsSignature;
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

  static Future<Set<String>> readEnabledSeriesQuickActions() async {
    return (await _readSeriesQuickActionsConfig()).enabledSeriesIds;
  }

  static Future<bool> isSeriesQuickActionEnabled(String seriesUuid) async {
    return (await readEnabledSeriesQuickActions()).contains(seriesUuid);
  }

  static Future<bool> setSeriesQuickActionEnabled(String seriesUuid, bool enabled) async {
    var config = await _readSeriesQuickActionsConfig();
    var iconIndexBySeriesId = {...config.iconIndexBySeriesId};
    var wasEnabled = iconIndexBySeriesId.containsKey(seriesUuid);
    if (wasEnabled == enabled) {
      return false;
    }

    if (enabled) {
      iconIndexBySeriesId[seriesUuid] = iconIndexBySeriesId[seriesUuid] ?? 0;
    } else {
      iconIndexBySeriesId.remove(seriesUuid);
    }
    await _storeSeriesQuickActionsConfig(config.copyWith(entries: _entriesFromIconIndexBySeriesId(iconIndexBySeriesId)));
    return true;
  }

  static Future<Set<String>> cleanUpOrphanedSeriesQuickActions(Iterable<String> validSeriesUuids) async {
    var config = await _readSeriesQuickActionsConfig();
    var validSeriesUuidSet = validSeriesUuids.toSet();
    var filteredIconIndexBySeriesId = <String, int>{};
    for (var entry in config.iconIndexBySeriesId.entries) {
      if (validSeriesUuidSet.contains(entry.key)) {
        filteredIconIndexBySeriesId[entry.key] = entry.value;
      }
    }

    var filteredConfig = config.copyWith(entries: _entriesFromIconIndexBySeriesId(filteredIconIndexBySeriesId));
    if (!config.equals(filteredConfig)) {
      await _storeSeriesQuickActionsConfig(filteredConfig);
    }
    return filteredIconIndexBySeriesId.keys.toSet();
  }

  static Future<void> refreshSeriesShortcutItems(
    List<SeriesDef> series, {
    Set<String>? enabledSeriesIds,
  }) async {
    if (!_isQuickActionsSupportedPlatform()) {
      return;
    }

    try {
      var config = await _readSeriesQuickActionsConfig();
      if (enabledSeriesIds != null && !setEquals(config.enabledSeriesIds, enabledSeriesIds)) {
        var iconIndexBySeriesId = {...config.iconIndexBySeriesId};
        iconIndexBySeriesId.removeWhere((seriesUuid, _) => !enabledSeriesIds.contains(seriesUuid));
        for (var seriesUuid in enabledSeriesIds) {
          iconIndexBySeriesId[seriesUuid] = iconIndexBySeriesId[seriesUuid] ?? 0;
        }
        config = config.copyWith(entries: _entriesFromIconIndexBySeriesId(iconIndexBySeriesId));
      }

      var buildResult = _buildShortcutItems(series, config);
      var shortcutItems = buildResult.shortcutItems;
      if (!config.equals(buildResult.updatedConfig)) {
        await _storeSeriesQuickActionsConfig(buildResult.updatedConfig);
      }

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

  static Future<_SeriesQuickActionsConfig> _readSeriesQuickActionsConfig() async {
    var rawValue = await DeviceStorage.read(DeviceStorageKeys.seriesQuickActions);
    return _SeriesQuickActionsConfig.fromStorageString(rawValue);
  }

  static Future<void> _storeSeriesQuickActionsConfig(_SeriesQuickActionsConfig config) async {
    if (config.entries.isEmpty) {
      await DeviceStorage.delete(DeviceStorageKeys.seriesQuickActions);
      return;
    }
    await DeviceStorage.write(DeviceStorageKeys.seriesQuickActions, config.toStorageString());
  }

  static _ShortcutItemsBuildResult _buildShortcutItems(List<SeriesDef> series, _SeriesQuickActionsConfig config) {
    var useAndroidIcon = defaultTargetPlatform == TargetPlatform.android;
    var enabledSeriesIds = config.enabledSeriesIds;
    var iconIndexBySeriesId = {...config.iconIndexBySeriesId};
    var enabledSeriesByUuid = {for (var s in series) s.uuid: s};

    for (var seriesUuid in enabledSeriesIds) {
      var seriesDef = enabledSeriesByUuid[seriesUuid];
      if (seriesDef == null) {
        continue;
      }
      iconIndexBySeriesId[seriesUuid] = _determineClosestSeriesQuickActionIconIndex(seriesDef.color);
    }
    iconIndexBySeriesId.removeWhere((seriesUuid, _) => !enabledSeriesIds.contains(seriesUuid));

    var shortcutItems = <ShortcutItem>[
      ShortcutItem(
        type: _actionOpenExploratia,
        localizedTitle: 'exploratia.de',
        icon: useAndroidIcon ? _quickActionIconOpenUrl : null,
      ),
    ];

    var enabledSeries = series.where((s) => enabledSeriesIds.contains(s.uuid));
    for (var seriesDef in enabledSeries) {
      var iconIndex = iconIndexBySeriesId[seriesDef.uuid] ?? 0;
      shortcutItems.add(
        ShortcutItem(
          type: '$_actionSeriesAddPrefix${seriesDef.uuid}',
          localizedTitle: seriesDef.name,
          icon: useAndroidIcon ? _quickActionIconNameForPaletteIndex(iconIndex) : null,
        ),
      );
    }

    return _ShortcutItemsBuildResult(
      shortcutItems,
      config.copyWith(entries: _entriesFromIconIndexBySeriesId(iconIndexBySeriesId)),
    );
  }

  static List<_SeriesQuickActionEntry> _entriesFromIconIndexBySeriesId(Map<String, int> iconIndexBySeriesId) {
    var sortedSeriesIds = iconIndexBySeriesId.keys.toList()..sort();
    return sortedSeriesIds.map((seriesId) => _SeriesQuickActionEntry(id: seriesId, iconIndex: iconIndexBySeriesId[seriesId]!)).toList();
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

class _ShortcutItemsBuildResult {
  final List<ShortcutItem> shortcutItems;
  final _SeriesQuickActionsConfig updatedConfig;

  _ShortcutItemsBuildResult(this.shortcutItems, this.updatedConfig);
}

class _SeriesQuickActionsConfig {
  static const storageVersion = 1;
  final int version;
  final List<_SeriesQuickActionEntry> entries;

  _SeriesQuickActionsConfig({
    required this.version,
    required this.entries,
  });

  factory _SeriesQuickActionsConfig.fromStorageString(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return _SeriesQuickActionsConfig(version: storageVersion, entries: const []);
    }

    try {
      var parsed = jsonDecode(rawValue);
      if (parsed is Map<String, dynamic>) {
        var parsedVersion = parsed['version'];
        var version = parsedVersion is int ? parsedVersion : storageVersion;
        var parsedEntries = <_SeriesQuickActionEntry>[];
        var seriesRaw = parsed['series'];
        if (seriesRaw is List) {
          for (var item in seriesRaw) {
            if (item is! Map) {
              continue;
            }
            var rawId = item['id'];
            var rawIconIndex = item['iconIndex'];
            if (rawId is! String || rawIconIndex is! int) {
              continue;
            }
            var trimmedId = rawId.trim();
            if (trimmedId.isEmpty) {
              continue;
            }
            parsedEntries.add(_SeriesQuickActionEntry(id: trimmedId, iconIndex: rawIconIndex));
          }
        }

        return _SeriesQuickActionsConfig(version: version, entries: parsedEntries);
      }
    } catch (err) {
      SimpleLogging.w('Could not parse series quick actions config from storage', error: err);
    }

    return _SeriesQuickActionsConfig(version: storageVersion, entries: const []);
  }

  Set<String> get enabledSeriesIds => entries.map((entry) => entry.id).toSet();

  Map<String, int> get iconIndexBySeriesId => {for (var entry in entries) entry.id: entry.iconIndex};

  _SeriesQuickActionsConfig copyWith({int? version, List<_SeriesQuickActionEntry>? entries}) {
    return _SeriesQuickActionsConfig(
      version: version ?? this.version,
      entries: entries ?? this.entries,
    );
  }

  bool equals(_SeriesQuickActionsConfig other) {
    if (version != other.version) {
      return false;
    }
    if (entries.length != other.entries.length) {
      return false;
    }
    for (var idx = 0; idx < entries.length; idx++) {
      if (!entries[idx].equals(other.entries[idx])) {
        return false;
      }
    }
    return true;
  }

  String toStorageString() {
    var sortedEntries = [...entries]..sort((left, right) => left.id.compareTo(right.id));

    return jsonEncode({
      'version': version,
      'series': sortedEntries.map((entry) => entry.toJson()).toList(),
    });
  }
}

class _SeriesQuickActionEntry {
  final String id;
  final int iconIndex;

  const _SeriesQuickActionEntry({
    required this.id,
    required this.iconIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconIndex': iconIndex,
    };
  }

  bool equals(_SeriesQuickActionEntry other) {
    return id == other.id && iconIndex == other.iconIndex;
  }
}
