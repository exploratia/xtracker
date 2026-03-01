import 'package:sembast/sembast.dart';

import 'migration_v01_to_v02.dart';

class DbMigration {
  static const int latestVersion = 2;

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    var current = oldVersion;

    while (current < newVersion) {
      if (current == 1) {
        await db.transaction((txn) async {
          await _migrateV1toV2(txn);
        });
        current = 2;
      } else {
        throw Exception('No migration step for version $current');
      }
    }
  }

  static Future<void> _migrateV1toV2(DatabaseClient db) async {
    final seriesDefStore = StoreRef<String, Map<String, dynamic>>('seriesDef');
    final currentValueStore = StoreRef<String, Map<String, dynamic>>('seriesCurrentValue');

    // 1) SeriesDef
    await _migrateStore(seriesDefStore, db);

    // 2) SeriesData Stores
    final seriesDefList = await seriesDefStore.find(db);
    for (final record in seriesDefList) {
      final uuid = record.key;
      final seriesDataStore = StoreRef<String, Map<String, dynamic>>('seriesData_$uuid');
      await _migrateStore(seriesDataStore, db);
    }

    // 3) CurrentValue
    await _migrateStore(currentValueStore, db);
  }

  static Future<void> _migrateStore(
    StoreRef<String, Map<String, dynamic>> store,
    DatabaseClient db,
  ) async {
    final records = await store.find(db);
    for (final record in records) {
      final migrated = MigrationV01ToV02.migrate(record.value);
      await store.record(record.key).put(db, migrated);
    }
  }
}
