import '../../util/ex.dart';
import '../../util/logging/flutter_simple_logging.dart';
import 'db_migration.dart';
import 'migration_v01_to_v02.dart';

class ImportMigration {
  static Map<String, dynamic> migrate(dynamic json, String fileName) {
    if (json is Map<String, dynamic>) {
      final int? version = json['version'] as int?;
      if (version == DbMigration.v1) {
        SimpleLogging.i('IMPORT MIGRATION for file "$fileName" version $version ...');
        var migrated = MigrationV01ToV02.migrate(json);
        SimpleLogging.i('IMPORT MIGRATION for file "$fileName" version $version finished.');
        return migrated;
      }
      // already latest? nothing to do
      else if (version == DbMigration.latestVersion) {
        return json;
      }
      throw Ex('Import migration failed - unexpected version in "$fileName"! No migration step for version $version defined');
    } else {
      throw Ex(
        "Import migration failed - unexpected file content in: $fileName",
      );
    }
  }
}
