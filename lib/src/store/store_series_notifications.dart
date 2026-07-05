import 'package:sembast/sembast.dart';

import '../util/json_reader.dart';
import '../util/logging/flutter_simple_logging.dart';
import 'stores_utils.dart';

class StoreSeriesNotifications {
  final StoreRef _store = StoreRef<String, Map<String, dynamic>>('seriesNotifications');
  final Database _db = StoresUtils.db;

  Future<void> save(SeriesNotificationsStoreEntry entry) async {
    await _store.record(entry.seriesDefUuid).put(_db, entry.toJson());
  }

  Future<SeriesNotificationsStoreEntry?> get(String seriesDefUuid) async {
    var value = await _store.record(seriesDefUuid).get(_db);
    if (value == null) return null;
    return SeriesNotificationsStoreEntry.fromJson(JsonReader(value));
  }

  Future<void> delete(String seriesDefUuid) async {
    await _store.record(seriesDefUuid).delete(_db);
  }

  Future<void> deleteAll() async {
    await _store.drop(_db);
  }

  Future<List<SeriesNotificationsStoreEntry>> getAll() async {
    List<SeriesNotificationsStoreEntry> result = [];
    var records = await _store.find(_db, finder: Finder());
    SimpleLogging.i('Loaded SeriesNotifications count: ${records.length}');
    for (var value in records.values) {
      result.add(SeriesNotificationsStoreEntry.fromJson(JsonReader(value)));
    }
    return result;
  }
}

class SeriesNotificationsStoreEntry {
  final String seriesDefUuid;
  final List<int> notificationIds;
  final int scheduledAtUtcMs;
  final String scheduleSignature;
  final List<int> triggerUtcMs;

  const SeriesNotificationsStoreEntry({
    required this.seriesDefUuid,
    required this.notificationIds,
    required this.scheduledAtUtcMs,
    required this.scheduleSignature,
    required this.triggerUtcMs,
  });

  factory SeriesNotificationsStoreEntry.fromJson(JsonReader json) {
    return SeriesNotificationsStoreEntry(
      seriesDefUuid: json.asString('seriesDefUuid'),
      notificationIds: json.asListOr('notificationIds', const []).whereType<int>().toSet().toList(),
      scheduledAtUtcMs: json.asIntOr('scheduledAtUtcMs', 0),
      scheduleSignature: json.asStringOr('scheduleSignature', ''),
      triggerUtcMs: json.asListOr('triggerUtcMs', const []).whereType<int>().toSet().toList()..sort(),
    );
  }

  Map<String, dynamic> toJson() => {
    'seriesDefUuid': seriesDefUuid,
    'notificationIds': notificationIds,
    'scheduledAtUtcMs': scheduledAtUtcMs,
    'scheduleSignature': scheduleSignature,
    'triggerUtcMs': triggerUtcMs,
  };
}
