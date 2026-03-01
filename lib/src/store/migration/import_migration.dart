import 'package:share_plus/share_plus.dart';

import '../../util/ex.dart';
import 'migration_v01_to_v02.dart';

class ImportMigration {
  static Map<String, dynamic> migrate(dynamic json, XFile file) {
    if (json is Map<String, dynamic>) {
      final int? version = json['version'] as int?;
      if (version == 1) {
        return MigrationV01ToV02.migrate(json);
      }
      throw Ex('Import migration failed - unexpected version in "${file.name}"! No migration step for version $version defined');
    } else {
      throw Ex(
        "Import migration failed - unexpected file content in: ${file.name}",
      );
    }
  }
}
