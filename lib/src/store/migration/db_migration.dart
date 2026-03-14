import 'package:sembast/sembast.dart';

import '../../util/logging/flutter_simple_logging.dart';
import 'migration_v01_to_v02.dart';

class DbMigration {
  /// 1: initial version
  static const int v1 = 1;

  /// 2: attribute -> tag migration
  static const int v2 = 2;
  static const int latestVersion = v2;

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    // started on web?
    if (oldVersion <= 0) return;

    var current = oldVersion;

    while (current < newVersion) {
      if (current == v1) {
        SimpleLogging.i('DB MIGRATION for version $current ...');
        await db.transaction((txn) async {
          await _migrateV1toV2(txn);
        });
        SimpleLogging.i('DB MIGRATION for version $current finished.');
        current = v2;
      } else {
        throw Exception('No migration step for version $current');
      }
    }
  }

  static Future<void> _migrateV1toV2(DatabaseClient db) async {
    final seriesDefStore = StoreRef<String, Map<String, dynamic>>('seriesDef');
    final currentValueStore = StoreRef<String, Map<String, dynamic>>('seriesCurrentValue');

    // 1) SeriesDef
    await _migrateStore(seriesDefStore, seriesDefStore, db, MigrationV01ToV02.migrate);

    // 2) SeriesData Stores
    final seriesDefRecords = await seriesDefStore.find(db);
    for (final record in seriesDefRecords) {
      final uuid = record.key;
      final seriesType = record.value['seriesType'] as String?;

      if (seriesType == null || seriesType.isEmpty) {
        SimpleLogging.w('DB MIGRATION: evaluation of series type failed!');
        continue;
      }

      // correct store name as well
      final storeNameOld = 'seriesData_SeriesType.${seriesType}_$uuid';
      final storeNameNew = 'seriesData_$uuid';
      final seriesDataStoreOld = StoreRef<String, Map<String, dynamic>>(storeNameOld);
      final seriesDataStoreNew = StoreRef<String, Map<String, dynamic>>(storeNameNew);

      await _migrateStore(seriesDataStoreOld, seriesDataStoreNew, db, MigrationV01ToV02.migrate);

      // delete all data from old store
      // await seriesDataStoreOld.delete(db);
      await seriesDataStoreOld.drop(db);
    }

    // 3) CurrentValue
    await _migrateStore(currentValueStore, currentValueStore, db, MigrationV01ToV02.migrate);
  }

  /// source and target may be the same
  static Future<void> _migrateStore(
    StoreRef<String, Map<String, dynamic>> storeSource,
    StoreRef<String, Map<String, dynamic>> storeTarget,
    DatabaseClient db,
    Map<String, dynamic> Function(Map<String, dynamic>) migrateRecord,
  ) async {
    final records = await storeSource.find(db);
    for (final record in records) {
      final migrated = migrateRecord(record.value);
      await storeTarget.record(record.key).put(db, migrated);
    }
  }
}
