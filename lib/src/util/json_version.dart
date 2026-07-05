import '../store/migration/db_migration.dart';
import 'ex.dart';
import 'json_reader.dart';

class JsonVersion {
  JsonVersion._();

  /// Validates and returns the stored schema version for a versioned JSON object.
  ///
  /// Older versions are accepted so callers can choose version-specific parsing
  /// or run import migrations before deserializing.
  static int validateNotNewer(JsonReader json, String jsonType, {bool validateType = true}) {
    if (validateType) {
      final type = json.asStringOrNull('type');
      if (type != null && type != jsonType) {
        throw JsonParseException("Expected JSON type '$jsonType' at ${json.pathString} but found '$type'");
      }
    }

    final version = json.asIntOr('version', DbMigration.v1);
    if (version > DbMigration.latestVersion) {
      throw Ex(
        "Unsupported $jsonType JSON version $version. Latest supported version is ${DbMigration.latestVersion}.",
      );
    }

    return version;
  }
}
