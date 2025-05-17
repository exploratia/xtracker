import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart'; // Nur für mobile Plattformen
import 'package:sembast/sembast_io.dart'; // Nur für mobile Plattformen
import 'package:sembast_web/sembast_web.dart';

class StoresUtils {
  static late final Database db;

  static const int _dbVersionInitial = 1;

  static Future<void> initDb() async {
    DatabaseFactory dbFactory;
    String dbPath;
    if (kIsWeb) {
      dbFactory = databaseFactoryWeb;
      dbPath = 'app_store';
    } else {
      dbFactory = databaseFactoryIo;
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = '${appDir.path}/app_store.db';
    }
    db = await dbFactory.openDatabase(
      dbPath,
      version: _dbVersionInitial,
      onVersionChanged: (db, oldVersion, newVersion) async {
        // implement migration if necessary
        if (kDebugMode) {
          print("DB Version old: $oldVersion, new: $newVersion");
        }
      },
    );
  }
}
