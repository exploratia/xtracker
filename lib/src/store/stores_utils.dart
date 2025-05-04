import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart'; // Nur für mobile Plattformen
import 'package:sembast/sembast_io.dart'; // Nur für mobile Plattformen
import 'package:sembast_web/sembast_web.dart';

class StoresUtils {
  static late Database db;

  static Future<void> initDb() async {
    if (kIsWeb) {
      DatabaseFactory dbFactory = databaseFactoryWeb;
      db = await dbFactory.openDatabase(
        'app_store',
        version: 1,
        onVersionChanged: (db, oldVersion, newVersion) {
          // implement migration if necessary
        },
      );
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = '${appDir.path}/app_store.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      db = await dbFactory.openDatabase(dbPath);
    }
  }
}
