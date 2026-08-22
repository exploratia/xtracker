import 'dart:async';

import 'package:flutter/material.dart';

import '../model/series/series_def.dart';
import '../store/stores.dart';
import '../util/app_icon_quick_actions.dart';
import '../util/app_series_notifications.dart';
import '../util/motion_utils.dart';
import 'series_providers.dart';

/// The kind of structural change most recently applied to the series list.
enum SeriesMutationType { inserted, deleted }

/// Describes a short-lived structural series change for UI feedback.
@immutable
class SeriesMutation {
  const SeriesMutation({
    required this.seriesUuid,
    required this.type,
    required this.version,
  });

  /// Duration of insert and delete transitions.
  static const transitionDuration = MotionUtils.standard;

  /// Delay before a deleted series is removed from the in-memory list.
  static const removalDelay = MotionUtils.emphasized;

  /// UUID of the affected series.
  final String seriesUuid;

  /// Operation that changed the series list.
  final SeriesMutationType type;

  /// Monotonically increasing identifier used to handle each change once.
  final int version;
}

class SeriesProvider with ChangeNotifier {
  final _storeMain = Stores.storeMain;
  final _storeSeriesDef = Stores.storeSeriesDef;
  List<SeriesDef> _series = [];
  bool _seriesLoaded = false;
  SeriesMutation? _latestMutation;
  Timer? _mutationTimer;
  int _mutationVersion = 0;

  /// The latest list change while its visual feedback is still relevant.
  SeriesMutation? get latestMutation => _latestMutation;

  Future<void> fetchDataIfNotYetLoaded() async {
    if (!_seriesLoaded) {
      await fetchData();
    }
  }

  Future<void> fetchData({bool refreshDueNotifications = true}) async {
    // await Future.delayed(const Duration(seconds: 10)); // for testing

    _series = await _storeSeriesDef.getAllSeries();

    // // TODO only for testing - remove it
    // if (_series.isEmpty) {
    //   await _storeSeriesDef.save(SeriesDef(
    //     uuid: const Uuid().v4().toString(),
    //     seriesType: SeriesType.bloodPressure,
    //     color: Colors.green,
    //     name: "1 mit sehr sehr sehr sehr sehr sehr viel sehr sehr sehr sehr sehr sehr und noch Mehr sehr sehr sehr sehr sehr sehr viel Text",
    //     seriesItems: SeriesItem.bloodPressureSeriesItems(),
    //   ));
    //
    //   await _storeSeriesDef.save(SeriesDef(
    //     uuid: const Uuid().v4().toString(),
    //     seriesType: SeriesType.bloodPressure,
    //     name: '2',
    //     seriesItems: SeriesItem.bloodPressureSeriesItems(),
    //   ));
    //
    //   await _storeSeriesDef.save(SeriesDef(
    //     uuid: const Uuid().v4().toString(),
    //     seriesType: SeriesType.dailyCheck,
    //     name: '3',
    //     seriesItems: [],
    //   ));
    //
    //   _series = await _storeSeriesDef.getAllSeries();
    // }

    List<String> orderedSeriesUuids = await _storeMain.loadSeriesOrder();

    _sortSeries(orderedSeriesUuids);
    var enabledSeriesQuickActions = await AppIconQuickActions.cleanUpOrphanedSeriesQuickActions(_series);
    await AppIconQuickActions.refreshSeriesShortcutItems(_series, enabledSeriesIds: enabledSeriesQuickActions);
    if (refreshDueNotifications) {
      await AppSeriesNotifications.refreshDueSeriesNotifications(_series);
    }

    _seriesLoaded = true;
    notifyListeners();
  }

  List<SeriesDef> get series {
    return [..._series];
  }

  Future<void> refreshDueNotifications() async {
    if (!_seriesLoaded) return;
    await AppSeriesNotifications.refreshDueSeriesNotifications(_series);
  }

  SeriesDef? getSeries(String seriesUuid) {
    if (_series.isEmpty) return null;
    return _series.where((s) => s.uuid == seriesUuid).firstOrNull;
  }

  Future<void> save(SeriesDef seriesDef, {bool forceNotificationRefresh = false}) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
    var previousSeriesDef = getSeries(seriesDef.uuid);
    var refreshNotifications = forceNotificationRefresh || AppSeriesNotifications.notificationScheduleChanged(previousSeriesDef, seriesDef);
    await _storeSeriesDef.save(seriesDef);
    if (refreshNotifications) {
      await AppSeriesNotifications.refreshSeriesNotification(seriesDef, force: true);
    }
    SeriesMutation? mutation;
    if (previousSeriesDef == null) {
      mutation = _setMutation(seriesDef.uuid, SeriesMutationType.inserted);
    }
    await fetchData(refreshDueNotifications: false);
    if (mutation != null) {
      _scheduleMutationClear(mutation);
    }
    // notifyListeners(); notify is in fetch
  }

  Future<void> deleteById(
    String seriesDefUuid,
    SeriesProviders seriesProviders, {
    Duration removalDelay = Duration.zero,
  }) async {
    var idx = _series.indexWhere((s) => s.uuid == seriesDefUuid);
    if (idx < 0) return;
    await delete(_series[idx], seriesProviders, removalDelay: removalDelay);
  }

  Future<void> delete(
    SeriesDef seriesDef,
    SeriesProviders seriesProviders, {
    Duration removalDelay = Duration.zero,
  }) async {
    // delete series data (current value is deleted inside)
    await seriesProviders.seriesDataProvider.delete(seriesDef, seriesProviders.seriesCurrentValueProvider);

    await AppSeriesNotifications.deleteSeriesNotifications(seriesDef.uuid);
    await _storeSeriesDef.delete(seriesDef);

    final mutation = _setMutation(seriesDef.uuid, SeriesMutationType.deleted);
    notifyListeners();
    _scheduleMutationClear(mutation);
    await Future<void>.delayed(removalDelay);

    await fetchData(refreshDueNotifications: false);
    // notifyListeners(); notify is in fetch
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (_series.length <= oldIndex || _series.length <= newIndex) return;
    var seriesUuids = [..._series.map((e) => e.uuid)];

    final item = seriesUuids.removeAt(oldIndex);
    seriesUuids.insert(newIndex, item);

    await _storeMain.saveSeriesOrder(seriesUuids);

    _sortSeries(seriesUuids);

    notifyListeners();
  }

  void _sortSeries(List<String> orderedSeriesUuids) {
    if (orderedSeriesUuids.isEmpty) return;
    _series.sort((a, b) {
      int indexA = orderedSeriesUuids.indexOf(a.uuid);
      int indexB = orderedSeriesUuids.indexOf(b.uuid);

      // Falls die UUID nicht in der zweiten Liste ist, setzen wir einen großen Index-Wert
      if (indexA == -1) indexA = orderedSeriesUuids.length;
      if (indexB == -1) indexB = orderedSeriesUuids.length;

      return indexA.compareTo(indexB);
    });
  }

  SeriesMutation _setMutation(String seriesUuid, SeriesMutationType type) {
    _mutationTimer?.cancel();
    final mutation = SeriesMutation(
      seriesUuid: seriesUuid,
      type: type,
      version: ++_mutationVersion,
    );
    _latestMutation = mutation;
    return mutation;
  }

  void _scheduleMutationClear(SeriesMutation mutation) {
    _mutationTimer = Timer(MotionUtils.feedbackRetention, () {
      if (_latestMutation?.version != mutation.version) {
        return;
      }
      _latestMutation = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _mutationTimer?.cancel();
    super.dispose();
  }
}
